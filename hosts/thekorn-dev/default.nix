{...}: {
  imports = [./hardware-configuration.nix];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "thekorn-dev";
  networking.networkmanager.enable = true;

  # Leave this at the release of the *initial* install; do not change.
  system.stateVersion = "25.11";
}
