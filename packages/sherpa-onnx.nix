{
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  onnxruntime,
  alsa-lib,
  kaldi-native-fbank,
  nlohmann_json,
  simple-sentencepiece,
  kaldi-decoder,
  kaldifst,
  openfst,
  eigen,
  sharedLibs ? false,
  enableTTS ? false,
  ...
}:
stdenv.mkDerivation {
  pname = "sherpa-onnx";
  version = "1.12.31";

  src = fetchFromGitHub {
    owner = "k2-fsa";
    repo = "sherpa-onnx";
    rev = "e0ab4a8beb10477d25ef48e518a537995c38c698";
    sha256 = "sha256-R5KsTZoTsoGgplSW8IUtOPMsmgW1mhoutZYB66F9XXo=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    onnxruntime
    alsa-lib
    kaldi-native-fbank
    nlohmann_json
    simple-sentencepiece
    kaldi-decoder
    kaldifst
    openfst
    eigen
  ];

  buildInputs = [
    onnxruntime
    alsa-lib
  ];

  patches = [
    ../patches/find_nlohmann_json_instead_of_download.patch
    ../patches/find_simple_sentencepiece_instead_of_download.patch
    ../patches/find_kaldi_decoder_instead_of_download.patch
    ../patches/find_kaldi_native_fbank_instead_of_download.patch
    ../patches/link_eigen_in_sharpa_onnx_csrc.patch
  ];

  cmakeFlags = [
    "-DFETCHCONTENT_FULLY_DISCONNECTED=ON"
    "-DCMAKE_BUILD_TYPE=Release"
    "-DSHERPA_ONNX_ENABLE_BINARY=OFF"
    "-DSHERPA_ONNX_ENABLE_TESTS=OFF"
    "-DSHERPA_ONNX_ENABLE_WEBSOCKET=OFF"
    "-DSHERPA_ONNX_ENABLE_SPEAKER_DIARIZATION=OFF"
    "-DSHERPA_ONNX_ENABLE_PORTAUDIO=ON"
    (if enableTTS then "-DSHERPA_ONNX_ENABLE_TTS=ON" else "-DSHERPA_ONNX_ENABLE_TTS=OFF")
    (if sharedLibs then "-DBUILD_SHARED_LIBS=ON" else "-DBUILD_SHARED_LIBS=OFF")
  ];
}
