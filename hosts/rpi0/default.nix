{ pkgs, lib, modulesPath, config, ... }:
{
  imports = [
    ../rpi-bcm2835.nix
    "${modulesPath}/installer/sd-card/sd-image-raspberrypi.nix"

    ../../profiles/user.nix
  ];

  config = {
    #    networking.hostName = hn;
    #    system.stateVersion = "21.11";

    # networking
    networking.dhcpcd.denyInterfaces = [ "usb0" ];
    services.dhcpd4 = {
      enable = true;
      interfaces = [ "usb0" ];
      extraConfig = ''
        option domain-name "nixos";
        option domain-name-servers 8.8.8.8, 8.8.4.4;
        subnet 10.0.3.0 netmask 255.255.255.0 {
          range 10.0.3.100 10.0.3.200;
          option subnet-mask 255.255.255.0;
          option broadcast-address 10.0.3.255;
        }
      '';
    };

    networking.interfaces.usb0.ipv4.addresses = [
      {
        address = "10.0.3.1";
        prefixLength = 24;
      }
    ];
    # ssh

    # networking
    networking.nameservers = [ "1.1.1.1" "8.8.8.8" "8.8.4.4" ];

    # SSH
    services.openssh.enable = mkDefault true;
    services.openssh.permitRootLogin = mkDefault "yes";

    # DNS
    services.resolved.enable = true;
    services.resolved.dnssec = "false";

    # set a default root password
    users.users.root.initialPassword = lib.mkDefault "toor";


    #    nixcfg.common.useZfs = false;
    environment.systemPackages = with pkgs; [
      #      picocom
      #      keyboard-layouts
    ];

    boot.kernelPatches = [
      {
        name = "usb-otg";
        patch = null;
        extraConfig = ''
          USB_GADGET y
          USB_DWC2 m
          USB_DWC2_DUAL_ROLE y
          USB_ETH m
        '';
      }
    ];

    boot = {
      kernelPackages = lib.mkForce pkgs.linuxPackages_5_15;
      #      supportedFilesystems = lib.mkForce [ "vfat" ]; # so we can include profiles/base without pulling in zfs
      #      initrd.availableKernelModules = [ "dwc2" "g_ether" ];
      kernelModules = [ "dwc2" "g_ether" ];
    };
    boot.loader.raspberryPi = {
      enable = true;
      uboot.enable = true;
      version = 0;
      firmwareConfig = ''
        dtoverlay=dwc2
      '';
    };
  };
}
