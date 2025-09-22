{
  stdenv,
  fetchFromGitHub,
  python3,
  libarchive,
  openssl,
}:
let
  ctypescrypto = python3.pkgs.buildPythonPackage rec {
    pname = "ctypescrypto";
    version = "0.5";
    doCheck = false;
    src = python3.pkgs.fetchPypi {
      inherit pname version;
      sha256 = "1qncc45ahf1wkyfcrcb02gbxgq0vhbcwl9vp71fvfhip0bfl9xi9";
    };
  };
  fleep = python3.pkgs.buildPythonPackage rec {
    pname = "fleep";
    version = "1.0.1";
    src = python3.pkgs.fetchPypi {
      inherit pname version;
      sha256 = "0k0h3pilc271s55a4q0a7zy21479g3rg7l8ydizlsdp5iqjjpxn8";
    };
  };
  zeroconf_0_24 = python3.pkgs.buildPythonPackage rec {
    pname = "zeroconf";
    version = "0.24.4";
    doCheck = false;
    src = python3.pkgs.fetchPypi {
      inherit pname version;
      sha256 = "1zkxhasx156h1zmr2m21r9mmazx98qgqpdwsjdr7a296c3qkhvgn";
    };
    propagatedBuildInputs = with python3.pkgs; [ ifaddr ];
  };
  static_openssl = openssl.override { static = true; };
in
python3.pkgs.buildPythonApplication {
  name = "opendrop";
  src = fetchFromGitHub {
    owner = "seemoo-lab";
    repo = "opendrop";
    rev = "v0.11.0";
    sha256 = "1729799170cc7mxmdksajxb6xvaw74fpr8ccjlh1l54iza9kd4ap";
  };
  preConfigure = ''
    export DYLD_LIBRARY_PATH="${static_openssl.out}/lib:${libarchive}/lib"
  '';
  doCheck = false;
  buildInputs = [
    static_openssl
    libarchive
  ];
  propagatedBuildInputs = with python3.pkgs; [
    setuptools
    pillow
    ctypescrypto
    fleep
    ifaddr
    libarchive-c
    requests
    requests_toolbelt
    zeroconf_0_24
  ];
  makeFlags = [ "PYTHON=$(python3)/bin/python3" ];
  makeWrapperArgs = [ "--set DYLD_LIBRARY_PATH ${static_openssl.out}/lib:${libarchive}/lib" ];
}
