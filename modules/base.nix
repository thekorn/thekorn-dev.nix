{pkgs, ...}: {
  # Nix daemon configuration
  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    trusted-users = ["root" "thekorn"];
    auto-optimise-store = true;
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # Allow unfree (needed for prl-tools and friends).
  nixpkgs.config.allowUnfree = true;

  # Locale & time
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Handy tools always available on the box.
  environment.systemPackages = with pkgs; [
    git
    vim
    htop
    curl
    rsync
  ];
}
