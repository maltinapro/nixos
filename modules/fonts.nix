# modules/fonts.nix
{pkgs, ...}:
{
  fonts = {
    fontconfig = {
      enable = true;
    };
    packages = with pkgs; [
      noto-fonts
      noto-fonts-emoji-blob-bin
      noto-fonts-cjk-sans
      nerd-fonts._0xproto # personal fav monospaced font. However, you can use whatever monospaced nerd font you'd like.
      nerd-fonts.symbols-only
    ];
  };
}

