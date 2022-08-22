{ buildGoModule, fetchFromGitHub }:
buildGoModule rec {
  pname = "otel-cli";
  version = "v0.0.20";
  src = fetchFromGitHub {
    owner = "equinix-labs";
    repo = "otel-cli";
    rev = "${version}";
    sha256 = "sha256-bWdkuw0uEE75l9YCo2Dq1NpWXuMH61RQ6p7m65P1QCE=";
  };
  doCheck = false;
  vendorSha256 = "sha256-IJ2Gq5z1oNvcpWPh+BMs46VZMN1lHyE+M7kUinTSRr8=";
}
