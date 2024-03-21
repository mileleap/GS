{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = { self, flake-utils, nixpkgs }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ ];
        config = {
          allowUnfree = true;
          cudaSupport = true;
        };
      };
      my-python = pkgs.python3.withPackages (ppkgs: with ppkgs; [
        pip
        setuptools
        wheel
        ninja
        torch
      ]);
    in {
      devShells.default = (pkgs.mkShell.override { stdenv = pkgs.gcc12Stdenv; }) {
        buildInputs = with pkgs; [
          git

          my-python
          cudaPackages.cuda_nvcc
          cudatoolkit
        ];
        shellHook = ''
          export CUDA_HOME=${pkgs.cudatoolkit}
          export TORCH_CUDA_ARCH_LIST="8.0"
          export FORCE_CUDA="1"
        '';
      };
    });
}
