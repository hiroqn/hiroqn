{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
  protobuf,
  cmake,
}:
rustPlatform.buildRustPackage rec {
  pname = "lore";
  version = "0.8.3";

  src = fetchFromGitHub {
    owner = "EpicGames";
    repo = "lore";
    rev = "v${version}";
    hash = "sha256-PY7lcRbsxkDiuTpO7tjfXlgb789qxFAKXNXFJ+Nbdj4=";
  };

  cargoHash = "sha256-yapx4fEvljFlCpazOubTY2t/+pa7U9g60ZQ5mRMazIc=";

  cargoBuildFlags = [
    "-p"
    "lore-client"
    "--bins"
  ];

  doCheck = false;

  nativeBuildInputs = [
    pkg-config
    protobuf
    cmake
  ];

  buildInputs = [
    openssl
  ];

  OPENSSL_NO_VENDOR = true;

  # Lore's .cargo/config.toml enables tokio and uuid unstable cfgs.
  RUSTFLAGS = "--cfg tokio_unstable --cfg uuid_unstable";

  meta = {
    description = "Next-generation open source version control system by Epic Games";
    homepage = "https://github.com/EpicGames/lore";
    license = lib.licenses.mit;
    mainProgram = "lore";
  };
}
