{
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  openfst,
  ...
}:

stdenv.mkDerivation {
  pname = "kaldifst";
  version = "1.7.17";

  src = fetchFromGitHub {
    owner = "k2-fsa";
    repo = "kaldifst";
    rev = "8d26c8dbac0d4a021746da2ec923a2300d4c5828";
    sha256 = "sha256-tHDkQP9FVgDr9g4mTsgBTfA8RSV+AY8oT8kLiUKd1rg=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    openfst
  ];

  cmakeFlags = [
    "-DKALDIFST_BUILD_PYTHON=OFF"
    "-DBUILD_SHARED_LIBS=OFF"
    "-DKALDIFST_BUILD_TESTS=OFF"
  ];

  patches = [
    ../patches/find_open_fst_instead_of_download.patch
  ];

  postInstall = ''
    mkdir -p $out/include/kaldifst
    cp -r $src/kaldifst/csrc $out/include/kaldifst/
  '';
}
