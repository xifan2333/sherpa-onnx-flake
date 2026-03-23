{
  stdenv,
  cmake,
  fetchFromGitHub,
  pkg-config,
  libpng,
  fftw,
  python3,
  ...
}:
stdenv.mkDerivation {
  pname = "kissfft";
  version = "131.2.0";

  src = fetchFromGitHub {
    owner = "mborgerding";
    repo = "kissfft";
    rev = "7bce4153c6bc8aba2db0e889e576f9d00505cbe1";
    sha256 = "sha256-fGOwH9CjXPxlxIny3L6z2MqeoRScjkjhFjqBTuQvjVU=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    libpng
    fftw
    python3
  ];

  cmakeFlags = [
    "-DFETCHCONTENT_FULLY_DISCONNECTED=ON"
    "-DCMAKE_BUILD_TYPE=Release"
    "-DBUILD_SHARED_LIBS=OFF"
    "-DKISSFFT_STATIC=ON"
    "-DKISSFFT_TOOLS=OFF"
  ];
}
