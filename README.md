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

## GitHub Copilot + Avante in Neovim (NvChad)

After rebuilding, open Neovim and authenticate once with:

```vim
:Copilot auth
```

If Avante reports `You must setup copilot` or `missing avante_templates`, run:

```vim
:Copilot auth
:Lazy sync
:Lazy build avante.nvim
```

Then fully restart Neovim.

If it still fails, verify Copilot and Avante build state:

```vim
:Copilot status
:Lazy build avante.nvim
```

`<leader>` is `Space` in NvChad.

### Avante shortcuts (`<leader>a...`)

- `<leader>aa` ask Avante
- `<leader>ae` edit/refactor with Avante
- `<leader>at` toggle Avante panel
- `<leader>ar` refresh Avante context

Visual mode:
- Select code, then use `<leader>aa` to ask with selection context
- Select code, then use `<leader>ae` to edit/refactor selection

### Copilot Chat shortcuts (`<leader>c...`)

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
