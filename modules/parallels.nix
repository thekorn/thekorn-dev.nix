{ config, pkgs, lib, ... }:

{
  # Parallels guest tools (clipboard, time sync, video resize, shared folders).
  hardware.parallels.enable = true;

  # Scope the unfree allowance to just prl-tools.
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [ "prl-tools" ];
}
