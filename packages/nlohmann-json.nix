{
  stdenv,
  fetchFromGitHub,
  cmake,
  ...
}:
stdenv.mkDerivation {
  pname = "nlohmann";
  version = "3.12.0";

  src = fetchFromGitHub {
    owner = "nlohmann";
    repo = "json";
    rev = "55f93686c01528224f448c19128836e7df245f72";
    sha256 = "sha256-cECvDOLxgX7Q9R3IE86Hj9JJUxraDQvhoyPDF03B2CY=";
  };

  nativeBuildInputs = [
    cmake
  ];

  cmakeFlags = [
    "-DCMAKE_INSTALL_INCLUDEDIR=include"
    "-DJSON_FastTests=ON"
    "-DJSON_MultipleHeaders=ON"
  ];
}
