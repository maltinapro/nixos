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

`copilot.lua` runs its language server with Node.js (`server.type = "nodejs"`), because the prebuilt binary it downloads by default cannot run on NixOS.

Copilot Chat shortcuts (`<leader>` is `Space` in NvChad):

- `<leader>co` open chat (approval prompt)
- `<leader>ce` explain selection/code (approval prompt)
- `<leader>cr` review code (approval prompt)
- `<leader>cf` fix code (approval prompt)
- `<leader>ct` generate tests (approval prompt)
- `<leader>cw` send workspace context (`git status` + `fd` listing, approval prompt)
- `<leader>cx` execute last `bash` block from chat (approval prompt)

Useful Copilot Chat commands:

```vim
:CopilotChatOpen
:CopilotChatRun list all files recursively in current folder
:CopilotChatExec find . -type f
:CopilotChatExecLast
:CopilotChatStrictMode status
:CopilotChatStrictMode on
```

Avante (`avante.nvim`) reuses the login created by `:Copilot auth` (`provider = "copilot"`) and runs alongside Copilot Chat. Authenticate first and restart Neovim afterwards; without a login Avante fails to start with `You must setup copilot with either copilot.lua or copilot.vim`. Its native libraries are compiled with `make` (cargo) on the first start. This takes several minutes (lazy.nvim's process timeout is raised to 30 minutes for this build). If it was interrupted or failed, run `:Lazy build avante.nvim` again; cargo continues with what is already compiled. Its shortcuts use the `<leader>a` prefix (Copilot Chat uses `<leader>c`):

- `<leader>aa` ask Avante (normal/visual)
- `<leader>ae` edit selection (visual)
- `<leader>at` toggle sidebar
- `<leader>af` focus sidebar
- `<leader>aR` refresh sidebar
- `<leader>ac` add current buffer to context
- `<leader>aB` add all buffers to context
- `<leader>a?` select model, `<leader>aH` select history
- `<leader>as` toggle suggestions, `<leader>ad` toggle debug, `<leader>aM` toggle repo map

Notes:

- `:CopilotChatRun` asks Copilot to generate exactly one `bash` command; it does not execute automatically.
- Execute generated commands with `:CopilotChatExecLast`, then approve the action.
- Strict mode is enabled by default and blocks risky command patterns.
