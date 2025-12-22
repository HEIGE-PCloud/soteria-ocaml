{
  description = "Soteria (OCaml) development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        lib = pkgs.lib;
      in
      {
        # Default dev shell: meant for interactive development.
        # It avoids building the project as a Nix derivation (which can require
        # macOS-only tools like `codesign` inside the Nix sandbox).
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            git
            z3
            pkg-config
            pkgconf
            gmp
            ocaml
            ocamlPackages.dune_3
            opam
            nodejs_22
            yarn
          ];
            shellHook = ''
              if command -v opam >/dev/null 2>&1; then
                # If a local switch exists for this directory, auto-activate it.
                # (opam creates a `_opam/` folder for directory switches.)
                if [ -d "_opam" ]; then
                  eval "$(opam env --switch=. --set-switch 2>/dev/null || opam env --switch=. 2>/dev/null || opam env)"
                fi
              fi
            '';
        };

        # Optional shell that mirrors the existing `shell.nix` (builds soteria-c
        # as a Nix package). This may not work on macOS due to sandboxed
        # `codesign` usage during build.
        devShells.legacy = import ./shell.nix { inherit pkgs; };
      });
}
