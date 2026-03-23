{
  stdenv,
  fetchFromGitHub,
  cmake,
  ...
}:
stdenv.mkDerivation {
  pname = "cargs";
  version = "1.20.0";

  src = fetchFromGitHub {
    owner = "likle";
    repo = "cargs";
    rev = "0fbac1a0c6ebb7ecd72f0d7ae89c2b79eb3a12eb";
    sha256 = "sha256-OS768AG4aSuz2Mr0NPeuFlJonezRXs2vmCEVTgwR/Q8=";
  };

  nativeBuildInputs = [
    cmake
  ];

  cmakeFlags = [
    "-DFETCHCONTENT_FULLY_DISCONNECTED=ON"
    "-DCMAKE_BUILD_TYPE=Release"
    "-DBUILD_SHARED_LIBS=OFF"
  ];
}
