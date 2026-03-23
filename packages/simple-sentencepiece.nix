{
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  ...
}:
stdenv.mkDerivation {
  pname = "simple-sentencepiece";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "pkufool";
    repo = "simple-sentencepiece";
    rev = "6a6f05951230a52ca6015623aabd2acaa0ab4db6";
    sha256 = "sha256-2mAR0Kx5BlAobNNyFT+tmndrLdHJG3r1hNj8CfRy3+8=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DSBPE_BUILD_PYTHON=OFF"
    "-DSBPE_ENABLE_TESTS=OFF"
    "-DBUILD_SHARED_LIBS=OFF"
  ];

  postInstall = ''
    rm $out/*.a
    mkdir -p $out/lib
    mkdir -p $out/include/ssentencepiece
    mv lib/* $out/lib/
    cp -r $src/ssentencepiece/csrc $out/include/ssentencepiece
  '';
}
