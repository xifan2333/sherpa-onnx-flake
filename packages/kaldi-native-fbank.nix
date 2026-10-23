{
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  cargs,
  libpng,
  fftw,
  python3,
  kissfft,
  ...
}:
stdenv.mkDerivation {
  pname = "kaldi-native-fbank";
  version = "1.22.4";

  src = fetchFromGitHub {
    owner = "csukuangfj";
    repo = "kaldi-native-fbank";
    rev = "95032e2223c73addc965bb84d2d1b11498eda4e9";
    sha256 = "sha256-dHXlGQ3/v68lXub5XDI5VuFd7Ij/qO92dP4czdITrx0=";
  };

  buildInputs = [
    cmake
    pkg-config
    cargs
    libpng
    fftw
    python3
    kissfft
  ];

  patches = [
    ../patches/find_kissfft_instead_of_download.patch
  ];

  cmakeFlags = [
    "-DFETCHCONTENT_FULLY_DISCONNECTED=ON"
    "-DKALDI_NATIVE_FBANK_BUILD_PYTHON=OFF"
    "-DKALDI_NATIVE_FBANK_BUILD_TESTS=OFF"
    "-DBUILD_SHARED_LIBS=OFF"
  ];

  postPatch = ''
    substituteInPlace kaldi-native-fbank/csrc/rfft.cc \
      --replace '#include "kiss_fftr.h"' '#include <kissfft/kiss_fftr.h>'

    substituteInPlace kaldi-native-fbank/csrc/CMakeLists.txt \
      --replace "kissfft" "kissfft-float"
  '';
}
