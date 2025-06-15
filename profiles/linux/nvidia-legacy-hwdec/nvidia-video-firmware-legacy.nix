{ stdenv, fetchurl, fetchFromGitHub, which, python3 }:

with stdenv.lib;

let
  driverVersion = "325.15";
in

stdenv.mkDerivation {
  pname = "nvidia-video-firmware-legacy";
  version = driverVersion;

  driverInstallerSrc = fetchurl {
    url = "https://download.nvidia.com/XFree86/Linux-x86/${driverVersion}/NVIDIA-Linux-x86-${driverVersion}.run";
    sha256 = "0xc7w2ia2fnkn20s6aq1f4ib2ljxmd2931vnrkvl2injzr5hwy9x";
  };
  extractFirmwareSrc = fetchFromGitHub {
    owner = "envytools";
    repo = "firmware";
    rev = "a0b9f9be0efad90cc84b8b2eaf587c3d7d350ea9";
    sha256 = "1yw0a0h0rflfy2vz9yrr1qk6byl91ngfcx55lnpmrclvixjjlyw4";
  };

  nativeBuildInputs = [
    which # Used by makeself executable archive to check dependencies
  ];

  phases = [ "unpackPhase" "installPhase" ];

  unpackPhase = ''
    runHook preUnpack

    ${stdenv.shell} "$driverInstallerSrc" --extract-only
    ${python3}/bin/python "$extractFirmwareSrc/extract_firmware.py"

    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p    "$out/lib/firmware/nouveau"
    cp nv* vuc* "$out/lib/firmware/nouveau"

    runHook postInstall
  '';
}
