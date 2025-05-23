
# Build environment for Typst document
# =============================================================================
# Contains binaries required to compile the document in this repository in
# a reproducible shell. Additionally tools needed for formatting, syntax
# checks, grammar or spelling are included.
#

let
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-unstable";
  pkgs = import nixpkgs { config = {}; overlays = []; };
in

pkgs.mkShellNoCC {
  packages = with pkgs; [
    python312
    python312Packages.pyyaml
    typst
    typstyle
    ripgrep
  ];
}
