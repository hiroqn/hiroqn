{
  runCommand,
  python3,
  src,
}:
runCommand "supermemory-skills"
  {
    nativeBuildInputs = [ python3 ];
  }
  ''
    mkdir -p "$out"
    cp -a ${src}/. "$out/"
    chmod -R u+w "$out"
    python3 ${./strip-npm-install.py} "$out"
  ''
