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

## GitHub Copilot in Neovim (NvChad)

After rebuilding, open Neovim and authenticate once with:

```vim
:Copilot auth
```

Copilot Chat shortcuts (`<leader>` is `Space` in NvChad):

- `<leader>ao` open chat (approval prompt)
- `<leader>ae` explain selection/code (approval prompt)
- `<leader>ar` review code (approval prompt)
- `<leader>af` fix code (approval prompt)
- `<leader>at` generate tests (approval prompt)
- `<leader>aw` send workspace context (`git status` + `fd` listing, approval prompt)
- `<leader>ax` execute last `bash` block from chat (approval prompt)

Useful Copilot Chat commands:

```vim
:CopilotChatOpen
:CopilotChatRun list all files recursively in current folder
:CopilotChatExec find . -type f
:CopilotChatExecLast
:CopilotChatStrictMode status
:CopilotChatStrictMode on
```

Notes:

- `:CopilotChatRun` asks Copilot to generate exactly one `bash` command; it does not execute automatically.
- Execute generated commands with `:CopilotChatExecLast`, then approve the action.
- Strict mode is enabled by default and blocks risky command patterns.
