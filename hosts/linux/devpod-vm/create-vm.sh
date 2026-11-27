#!/usr/bin/env nix
#! nix shell nixpkgs#libvirt nixpkgs#qemu_kvm --command bash
# Run it once in a pod, as your user:
#   hosts/linux/devpod-vm/create-vm.sh
# It asks for the disk's passphrase, and to log in devpod-vm's two Tailscale nodes: the system's,
# and the initrd's for unlocking, devpod-vm-initrd.
#
# libvirt runs as your user, from a user unit that lingering starts with the pod. It starts the VM
# with the pod and shuts it down with it. Manage the VM with virsh as your user:
#   nix shell nixpkgs#libvirt
#   virsh console devpod-vm   # also the passphrase prompt; Ctrl+] leaves
# The pod's localhost:2202 reaches the VM's initrd SSH, localhost:2201 only the installer's.
set -euo pipefail

name=devpod-vm
dir=/vms/$name
cfg=$(realpath "$(dirname "$0")/../../..")
export XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
# Fail rather than start a libvirt daemon of virsh's own when the unit's isn't up
export LIBVIRT_DEFAULT_URI=qemu:///session LIBVIRT_AUTOSTART=0

if [ "$(id -u)" = 0 ]; then
  echo "Run this as your user, whose libvirt session will hold the VM" >&2
  exit 1
fi
if [ ! -w /dev/kvm ]; then
  echo "/dev/kvm isn't writable for you" >&2
  exit 1
fi
if [ -e "$dir" ]; then
  echo "$dir exists. To start over: virsh destroy $name; virsh undefine --nvram $name; rm -r $dir" >&2
  exit 1
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

echo "Building $name" >&2
nix build -o "$tmp/system" "$cfg#nixosConfigurations.$name.config.system.build.toplevel"
system=$(readlink "$tmp/system")

echo "Building the installer" >&2
ssh-keygen -q -t ed25519 -N "" -f "$tmp/key"
cat > "$tmp/installer.nix" <<'EOF'
((builtins.getFlake "nixpkgs").lib.nixosSystem {
  system = "x86_64-linux";
  modules = [
    ({ lib, modulesPath, pkgs, ... }: {
      imports = [ (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix") ];
      boot.kernelParams = [ "console=ttyS0,115200" ];
      systemd.services.sshd.wantedBy = lib.mkForce [ "multi-user.target" ];
      users.users.root.openssh.authorizedKeys.keyFiles = [ ./key.pub ];
      environment.systemPackages = [ pkgs.tailscale ];
    })
  ];
}).config.system.build.isoImage
EOF
nix build --impure -f "$tmp/installer.nix" -o "$tmp/installer"
ovmf=$(nix build --no-link --print-out-paths nixpkgs#OVMF.fd)/FV

echo "Starting libvirt" >&2
mkdir -p ~/.config/libvirt ~/.config/systemd/user ~/.local/state/virtqemud
cat > ~/.config/libvirt/qemu.conf <<'EOF'
# A VM's memory holds its disk's key: shut VMs down when the pod stops rather than save them
auto_shutdown_try_save = "none"
auto_shutdown_wait = 20
# Rather than raise the core dump limit to unlimited, which fails where its hard limit is lower
max_core = 0
EOF
cat > ~/.config/systemd/user/virtqemud.service <<'EOF'
[Unit]
Description=libvirt's QEMU daemon, for this user's VMs

[Service]
# /nix doesn't outlive the pod: fetch libvirt again, at the paths that this and the VMs use
ExecStartPre=/run/current-system/sw/bin/nix build -o %h/.local/state/virtqemud/libvirt nixpkgs#libvirt
ExecStartPre=/run/current-system/sw/bin/nix build -o %h/.local/state/virtqemud/qemu nixpkgs#qemu_kvm
ExecStartPre=/run/current-system/sw/bin/nix build -o %h/.local/state/virtqemud/passt nixpkgs#passt
Environment=PATH=%h/.local/state/virtqemud/qemu/bin:%h/.local/state/virtqemud/passt/bin:/run/current-system/sw/bin
ExecStart=%h/.local/state/virtqemud/libvirt/bin/virtqemud
# Shut the VMs down, which SIGTERM doesn't, and wait for it before systemd stops what's left
ExecStop=/bin/sh -c '%h/.local/state/virtqemud/libvirt/bin/virt-admin -c virtqemud:///session daemon-shutdown --preserve; while kill -0 $MAINPID 2> /dev/null; do sleep 1; done'
TimeoutStopSec=25
Restart=on-failure
RestartSec=10

[Install]
WantedBy=default.target
EOF
sudo loginctl enable-linger "$USER"
until [ -S "$XDG_RUNTIME_DIR/systemd/private" ]; do sleep 1; done
systemctl --user daemon-reload
systemctl --user enable virtqemud.service
# Not just start: a run that failed later may have started it, with an older unit
systemctl --user restart virtqemud.service
for _ in $(seq 300); do
  virsh version > /dev/null 2>&1 && break
  sleep 1
done
virsh version > /dev/null

echo "Starting the installer in $name" >&2
sudo install -d -o "$USER" "$dir"
install -m 644 "$ovmf/OVMF_CODE.fd" "$dir/OVMF_CODE.fd"
install -m 600 "$ovmf/OVMF_VARS.fd" "$dir/efivars.fd"
qemu-img create -q -f qcow2 "$dir/disk.qcow2" 200G
cat > "$tmp/domain.xml" <<EOF
<domain type='kvm'>
  <name>$name</name>
  <memory unit='GiB'>64</memory>
  <vcpu>64</vcpu>
  <cpu mode='host-passthrough'/>
  <os>
    <type arch='x86_64' machine='q35'>hvm</type>
    <loader readonly='yes' type='pflash'>$dir/OVMF_CODE.fd</loader>
    <nvram>$dir/efivars.fd</nvram>
  </os>
  <features>
    <acpi/>
    <apic/>
  </features>
  <devices>
    <emulator>$HOME/.local/state/virtqemud/qemu/bin/qemu-system-x86_64</emulator>
    <disk type='file' device='disk'>
      <driver name='qemu' type='qcow2'/>
      <source file='$dir/disk.qcow2'/>
      <target dev='vda' bus='virtio'/>
      <boot order='2'/>
    </disk>
    <disk type='file' device='cdrom'>
      <source file='$(echo "$tmp"/installer/iso/*.iso)'/>
      <target dev='sda' bus='sata'/>
      <readonly/>
      <boot order='1'/>
    </disk>
    <interface type='user'>
      <backend type='passt'/>
      <model type='virtio'/>
      <portForward proto='tcp' address='127.0.0.1'>
        <range start='2201' to='22'/>
        <range start='2202' to='2222'/>
      </portForward>
    </interface>
    <serial type='pty'/>
  </devices>
</domain>
EOF
virsh define "$tmp/domain.xml" > /dev/null
virsh start "$name" > /dev/null

ssh_opts=(-i "$tmp/key" -p 2201 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR)
for _ in $(seq 60); do
  ssh "${ssh_opts[@]}" root@localhost true 2> /dev/null && break
  sleep 5
done
ssh "${ssh_opts[@]}" root@localhost 'cat > format_drive.sh' < "$cfg/bootstrap/format_drive.sh"
ssh "${ssh_opts[@]}" -t root@localhost sh format_drive.sh /dev/vda
ssh "${ssh_opts[@]}" -t root@localhost "$(cat <<'EOF'
set -eu
# The initrd's secrets, which remote-unlock.nix and remote-unlock-tailscale.nix describe
mkdir -p /mnt/etc/secrets/initrd/tailscale
ssh-keygen -q -t ed25519 -N "" -f /mnt/etc/secrets/initrd/ssh_host_ed25519_key
# Log in a Tailscale node with a tailscaled on its state
login() {
  tailscaled --tun=userspace-networking --port=0 --no-logs-no-support --statedir="$1" --socket="/run/$2.sock" > /dev/null 2>&1 &
  until [ -S "/run/$2.sock" ]; do kill -0 $! && sleep 1; done
  echo "Log in $2:"
  tailscale --socket="/run/$2.sock" up --hostname="$2"
  kill $!
  wait $! || true
}
login /mnt/etc/secrets/initrd/tailscale devpod-vm-initrd
login /mnt/var/lib/tailscale devpod-vm
EOF
)"

echo "Installing $name" >&2
NIX_SSHOPTS="${ssh_opts[*]}" nix copy --no-check-sigs --to "ssh://root@localhost?remote-store=local%3Froot%3D%2Fmnt" "$system"
ssh "${ssh_opts[@]}" root@localhost nixos-install --system "$system" --no-root-passwd --no-channel-copy

virsh shutdown "$name" > /dev/null
for _ in $(seq 120); do
  [ "$(virsh domstate "$name")" = "shut off" ] && break
  sleep 1
done
virsh detach-disk "$name" sda --config > /dev/null
virsh autostart "$name" > /dev/null
virsh start "$name" > /dev/null
cat >&2 <<EOF
$name is starting. Unlock its disk with one of:
  virsh console $name
  ssh -p 2202 root@localhost
  ssh -p 2222 root@$name-initrd    # on your tailnet
Then disable the key expiry of $name-initrd in Tailscale's admin console: the initrd can't renew its key.
EOF
