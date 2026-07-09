{ pkgs, ... }:

{
  services.throttled.enable = true;

  nixpkgs.overlays = [
    (final: prev: {
      throttled = prev.throttled.overrideAttrs (old: {
        propagatedBuildInputs = (old.propagatedBuildInputs or []) ++ [
          prev.python3Packages.dbus-next
        ];
      });
    })
  ];
}
