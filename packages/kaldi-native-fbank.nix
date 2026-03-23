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
  version = "1.22.3";

  src = fetchFromGitHub {
    owner = "csukuangfj";
    repo = "kaldi-native-fbank";
    rev = "b09e686fe2084732ddd30d1ef80acfc0f13eaf01";
    sha256 = "sha256-Wu4wM52T6NoQ1t5/iAyPtkEGnZki5P0jx0eYMFZMb5o=";
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
  ];

  postPatch = ''
    substituteInPlace kaldi-native-fbank/csrc/rfft.cc \
      --replace '#include "kiss_fftr.h"' '#include <kissfft/kiss_fftr.h>'

    substituteInPlace kaldi-native-fbank/csrc/CMakeLists.txt \
      --replace "kissfft" "kissfft-float"
  '';
}
