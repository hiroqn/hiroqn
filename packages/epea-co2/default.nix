{
  writeShellApplication,
  ruby,
}:

writeShellApplication {
  name = "epea-co2";
  runtimeInputs = [ ruby ];
  text = ''
    exec ruby ${./epea-co2.rb} "$@"
  '';
}
