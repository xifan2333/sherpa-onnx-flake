{
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  icu,
  zlib,
  ...
}:

stdenv.mkDerivation {
  pname = "openfst";
  version = "2024-06-13";

  src = fetchFromGitHub {
    owner = "csukuangfj";
    repo = "openfst";
    rev = "ae2489ec881e280030b79c5c368e11f9088d3115";
    sha256 = "sha256-tFdt7jVV9UJUVVywHWVgSC5RtfoFABnmks8zec0vpdo=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    icu
    zlib
  ];

  cmakeFlags = [
    "-DHAVE_BIN=OFF"
    "-DHAVE_SCRIPT=OFF"
    "-DHAVE_SPECIAL=OFF"
    "-DHAVE_PYTHON=OFF"
    "-DBUILD_USE_SOLUTION_FOLDERS=OFF"
    "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
    "-DBUILD_SHARED_LIBS=OFF"
  ];

  postPatch = ''
    substituteInPlace src/include/fst/fst.h \
    --replace 'impl.isymbols_->Copy()' 'std::unique_ptr<fst::SymbolTable>(impl.isymbols_->Copy())' \
    --replace 'impl.osymbols_->Copy()' 'std::unique_ptr<fst::SymbolTable>(impl.osymbols_->Copy())'
  '';
}
