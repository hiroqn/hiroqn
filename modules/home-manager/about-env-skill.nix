# darwin-rebuild が確定している rev を about-env の SKILL.md に埋める。
{ lib }:
{
  nixDarwinRev,
  homeManagerRev,
  nixpkgsRev,
}:
original:
let
  pins = {
    "@nixDarwinRev@" = nixDarwinRev;
    "@homeManagerRev@" = homeManagerRev;
    "@nixpkgsRev@" = nixpkgsRev;
  };
  tokens = lib.attrNames pins;
  missing = lib.filter (token: !lib.hasInfix token original) tokens;
  blank = lib.filter (token: !builtins.isString pins.${token} || pins.${token} == "") tokens;
  replaced = lib.replaceStrings tokens (map (token: pins.${token}) tokens) original;
in
if missing != [ ] then
  throw "about-env: SKILL.md に pin のプレースホルダがない: ${lib.concatStringsSep ", " missing}"
else if blank != [ ] then
  throw "about-env: darwin-rebuild の input に rev がない: ${lib.concatStringsSep ", " blank}"
else
  replaced
