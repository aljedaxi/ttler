{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { nixpkgs, self, flake-utils, ... }: flake-utils.lib.eachDefaultSystem (system:
    let pkgs = nixpkgs.legacyPackages.${system}; in
    {
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [gnumake nodejs];
        shellHook = ''exec zsh'';
      };
      packages.default = pkgs.buildNpmPackage {
        dontNpmBuild = true;
        name = "ttlr";
        npmDepsHash = "sha256-w8ZEAK8rWAPYlJ5RhHml6iwgsM4YRpzX+6ExuORWki8=";
        src = ./.;
      };
      apps.default = {
	      type = "app";
	      program = "${self.packages."${system}".default}/lib/node_modules/ttlr/main.js";
      };
    });
}
