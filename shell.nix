{ pkgs ? import <nixpkgs> {} }:

with pkgs;

mkShell {
  nativeBuildInputs = [ hugo ];

  shellHooks = ''
    alias build='hugo -d docs'
  '';
}
