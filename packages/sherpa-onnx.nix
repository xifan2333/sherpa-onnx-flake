{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  autoPatchelfHook,
  onnxruntime,
  alsa-lib,
  kaldi-native-fbank,
  nlohmann_json,
  simple-sentencepiece,
  kaldi-decoder,
  kaldifst,
  openfst,
  eigen,
  kissfft,
  sharedLibs ? false,
  enableTTS ? false,
  ...
}:
stdenv.mkDerivation {
  pname = "sherpa-onnx";
  version = "1.12.34";

  src = fetchFromGitHub {
    owner = "k2-fsa";
    repo = "sherpa-onnx";
    rev = "12e81142d6fac7182a2cea847a4b7f2170a086a4";
    sha256 = "sha256-D0ToF2t3zH2VAw2QRgdfYEgiXOPl7ExMHv2LT2Ea85U=";
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
    autoPatchelfHook
    kissfft
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
    ../patches/sherpa_onnx_find_kaldifst_instead_of_download.patch
    ../patches/sherpa_onnx_properly_link_deps_in_core.patch
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
