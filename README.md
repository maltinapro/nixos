# nixos

This repository contains the [NixOS](https://nixos.org/) configuration of my ThinkPad T490 with multiple profiles.
It is based on the following [blog article](https://laniakita.com/blog/nixos-fde-tpm-hm-guide) and uses disk encryption and Secure Boot
in combination with [Flakes](https://wiki.nixos.org/wiki/Flakes) and [Home Manager](https://github.com/nix-community/home-manager).

Secure Boot is realized via [Lanzaboote](https://github.com/nix-community/lanzaboote).
Multiple profiles such as Development, Test, and Media are managed using Flakes.

## First Time Setup

Install NixOS via the provided ISO image. The host-specific `configuration.nix` generated during the NixOS installation should be used instead of this repository's file. During setup, choose disk encryption. It is also a good idea to set a BIOS password when using Secure Boot.

## Everyday Commands

```bash
# Apply changes:
# The last segment is the profile name, e.g. thinkpad-test or thinkpad-media
nixos-rebuild switch --flake /etc/nixos#thinkpad-development

# Update all inputs to their latest versions:
nix flake update
```
