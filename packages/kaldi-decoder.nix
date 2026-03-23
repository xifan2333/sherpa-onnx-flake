{
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  kaldifst,
  eigen,
  openfst,
  ...
}:

stdenv.mkDerivation {
  pname = "kaldi-decoder";
  version = "0.2.11";

  src = fetchFromGitHub {
    owner = "k2-fsa";
    repo = "kaldi-decoder";
    rev = "52bf99ec828d8cc8ab6a92be8484284b52682777";
    sha256 = "sha256-xQ+N5NSXYk9JfSpkOCRCclj3Y04niAPSh37Nv7X6RHU=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    kaldifst
    eigen
    openfst
  ];

  cmakeFlags = [
    "-DKALDI_DECODER_BUILD_PYTHON=OFF"
    "-DBUILD_SHARED_LIBS=OFF"
    "-DKALDI_DECODER_ENABLE_TESTS=OFF"
  ];

  patches = [
    ../patches/find_eigen_instead_of_download.patch
    ../patches/find_kaldifst_instead_of_download.patch
  ];

  postInstall = ''
    mkdir -p $out/lib
    mkdir -p $out/include
    mkdir -p $out/include/kaldi-decoder/csrc
    cp -r $src/kaldi-decoder/csrc $out/include/kaldi-decoder
  '';
}
