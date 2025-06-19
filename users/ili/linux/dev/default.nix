{ pkgs, ... }:
{
  home.packages = with pkgs; [
    docker-machine-kvm2 # needed for minikube --driver=kvm2
  ];
}
