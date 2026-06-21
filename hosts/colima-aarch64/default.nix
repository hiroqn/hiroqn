{
  config,
  pkgs,
  lib,
  modulesPath,
  ...
}:

{
  # Virtio guest profile for Lima/Colima on macOS VZ (not a QEMU runtime choice).
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nix.settings.trusted-users = [ "@wheel" ];

  services.lima.enable = true;

  services.openssh.enable = true;

  security.sudo.wheelNeedsPassword = false;

  boot = {
    kernelParams = [ "console=tty0" ];
    loader.grub = {
      device = "nodev";
      efiSupport = true;
      efiInstallAsRemovable = true;
    };
    binfmt.emulatedSystems = [ "x86_64-linux" ];
  };

  fileSystems."/boot" = {
    device = lib.mkForce "/dev/vda1";
    fsType = "vfat";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    autoResize = true;
    fsType = "ext4";
    options = [
      "noatime"
      "nodiratime"
      "discard"
    ];
  };

  virtualisation.containerd.enable = true;

  environment.systemPackages = with pkgs; [
    nerdctl
    buildkit
    iptables
    curl
    git
    vim
  ];

  # Colima provision writes /etc/buildkit/buildkitd.toml; keep it off the Nix store path.
  systemd.tmpfiles.rules = [
    "d /var/lib/buildkit 0755 root root -"
    "d /etc/buildkit 0755 root root -"
    "f /var/lib/buildkit/buildkitd.toml 0644 root root - ${pkgs.writeText "buildkitd.toml" ''
      [worker.oci]
        enabled = false

      [worker.containerd]
        enabled = true
        namespace = "default"
    ''}"
    "L+ /etc/buildkit/buildkitd.toml - - - - /var/lib/buildkit/buildkitd.toml"
  ];

  systemd.services.buildkit = {
    description = "BuildKit";
    wantedBy = [ "multi-user.target" ];
    after = [
      "containerd.service"
      "network.target"
      "systemd-tmpfiles-setup.service"
    ];
    requires = [ "containerd.service" ];
    path = with pkgs; [
      buildkit
      containerd
      runc
    ];
    serviceConfig = {
      ExecStart = "${pkgs.buildkit}/bin/buildkitd --config /var/lib/buildkit/buildkitd.toml";
      Type = "notify";
      Restart = "always";
      RestartSec = "5";
    };
  };

  networking.hostName = "colima";

  system.stateVersion = "25.11";
}
