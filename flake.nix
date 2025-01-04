{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };
  outputs =
    { nixpkgs, self, ... }: let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
        devShells."${system}".default = pkgs.mkShell {
            packages = with pkgs; [gnumake nodejs];
            shellHook = ''exec zsh'';
        };
        packages."${system}".default = pkgs.buildNpmPackage {
	     dontNpmBuild = true;
	     name = "swag";
         npmDepsHash = "sha256-w8ZEAK8rWAPYlJ5RhHml6iwgsM4YRpzX+6ExuORWki8=";
	     src = ./.;
        };
        apps."${system}".default = {
	     type = "app";
	     program = "${self.packages."${system}".default}/lib/node_modules/ttlr/main.js";
        };
    };
}
