{
  stdenv,
  fetchFromGitHub,
  cmake,
  ...
}:
stdenv.mkDerivation {
  pname = "utf8proc";
  version = "2.12.0";

  src = fetchFromGitHub {
    owner = "JuliaStrings";
    repo = "utf8proc";
    rev = "79cdd5ab40c79afa559f689ffc13b76812dee1ac";
    sha256 = "sha256-+MLxHKgssEM/q4eEHYnbpNTwz/5xZ72ut6AozaLNwo0=";
  };

  nativeBuildInputs = [
    cmake
  ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DUTF8PROC_INSTALL=ON"
    "-DUTF8PROC_ENABLE_TESTING=OFF"
  ];
}
