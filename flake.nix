{
  description = "Sherpa-onnx flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
      };

      cargs = pkgs.stdenv.mkDerivation {
        pname = "cargs";
        version = "1.20.0";

        src = pkgs.fetchFromGitHub {
          owner = "likle";
          repo = "cargs";
          rev = "0fbac1a0c6ebb7ecd72f0d7ae89c2b79eb3a12eb";
          sha256 = "sha256-OS768AG4aSuz2Mr0NPeuFlJonezRXs2vmCEVTgwR/Q8=";
        };

        nativeBuildInputs = with pkgs; [
          cmake
          gnumake
          alsa-lib
        ];

        cmakeFlags = [
          "-DFETCHCONTENT_FULLY_DISCONNECTED=ON"
          "-DCMAKE_BUILD_TYPE=Release"
          "-DBUILD_SHARED_LIBS=OFF"
        ];
      };

      lib_kissfft = pkgs.stdenv.mkDerivation {
        pname = "kissfft";
        version = "131.2.0";

        src = pkgs.fetchFromGitHub {
          owner = "mborgerding";
          repo = "kissfft";
          rev = "7bce4153c6bc8aba2db0e889e576f9d00505cbe1";
          sha256 = "sha256-fGOwH9CjXPxlxIny3L6z2MqeoRScjkjhFjqBTuQvjVU=";
        };

        nativeBuildInputs = with pkgs; [
          cmake
          ninja
          gnumake
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
      };

      kaldi-native-fbank = pkgs.stdenv.mkDerivation {
        pname = "kaldi-native-fbank";
        version = "1.22.3";

        src = pkgs.fetchFromGitHub {
          owner = "csukuangfj";
          repo = "kaldi-native-fbank";
          rev = "b09e686fe2084732ddd30d1ef80acfc0f13eaf01";
          sha256 = "sha256-Wu4wM52T6NoQ1t5/iAyPtkEGnZki5P0jx0eYMFZMb5o=";
        };

        buildInputs = with pkgs; [
          cmake
          ninja
          gnumake
          alsa-lib
          pkg-config
          cargs
          libpng
          fftw
          python3
          lib_kissfft
        ];

        patches = [
          ./patch/find_kissfft_instead_of_download.patch
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
      };

      lib_nlohmann_json = pkgs.stdenv.mkDerivation {
        pname = "nlohmann";
        version = "3.12.0";

        src = pkgs.fetchFromGitHub {
          owner = "nlohmann";
          repo = "json";
          rev = "55f93686c01528224f448c19128836e7df245f72";
          sha256 = "sha256-cECvDOLxgX7Q9R3IE86Hj9JJUxraDQvhoyPDF03B2CY=";
        };

        nativeBuildInputs = with pkgs; [
          cmake
          gnumake
        ];

        cmakeFlags = [
          "-DCMAKE_INSTALL_INCLUDEDIR=include"
          "-DJSON_FastTests=ON"
          "-DJSON_MultipleHeaders=ON"
        ];
      };

      simple-sentencepiece = pkgs.stdenv.mkDerivation {
        pname = "simple-sentencepiece";
        version = "0.10.0";

        src = pkgs.fetchFromGitHub {
          owner = "pkufool";
          repo = "simple-sentencepiece";
          rev = "6a6f05951230a52ca6015623aabd2acaa0ab4db6";
          sha256 = "sha256-2mAR0Kx5BlAobNNyFT+tmndrLdHJG3r1hNj8CfRy3+8=";
        };

        nativeBuildInputs = with pkgs; [
          cmake
          ninja
          pkg-config
          gnumake
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
      };

      openfst = pkgs.stdenv.mkDerivation {
        pname = "openfst";
        version = "2024-06-13";

        src = pkgs.fetchFromGitHub {
          owner = "csukuangfj";
          repo = "openfst";
          rev = "ae2489ec881e280030b79c5c368e11f9088d3115";
          sha256 = "sha256-tFdt7jVV9UJUVVywHWVgSC5RtfoFABnmks8zec0vpdo=";
        };

        nativeBuildInputs = with pkgs; [
          cmake
          pkg-config
          gnumake
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
      };

      kaldifst = pkgs.stdenv.mkDerivation {
        pname = "kaldifst";
        version = "1.7.17";

        src = pkgs.fetchFromGitHub {
          owner = "k2-fsa";
          repo = "kaldifst";
          rev = "8d26c8dbac0d4a021746da2ec923a2300d4c5828";
          sha256 = "sha256-tHDkQP9FVgDr9g4mTsgBTfA8RSV+AY8oT8kLiUKd1rg=";
        };

        nativeBuildInputs = with pkgs; [
          cmake
          ninja
          pkg-config
          gnumake
          openfst
        ];

        cmakeFlags = [
          "-DKALDIFST_BUILD_PYTHON=OFF"
          "-DBUILD_SHARED_LIBS=OFF"
          "-DKALDIFST_BUILD_TESTS=OFF"
        ];

        patches = [
          ./patch/find_open_fst_instead_of_download.patch
        ];

        postInstall = ''
          mkdir -p $out/include/kaldifst
          cp -r $src/kaldifst/csrc $out/include/kaldifst/
        '';
      };

      kaldi-decoder = pkgs.stdenv.mkDerivation {
        pname = "kaldi-decoder";
        version = "0.2.11";

        src = pkgs.fetchFromGitHub {
          owner = "k2-fsa";
          repo = "kaldi-decoder";
          rev = "52bf99ec828d8cc8ab6a92be8484284b52682777";
          sha256 = "sha256-xQ+N5NSXYk9JfSpkOCRCclj3Y04niAPSh37Nv7X6RHU=";
        };

        nativeBuildInputs = with pkgs; [
          cmake
          ninja
          pkg-config
          gnumake
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
          ./patch/find_eigen_instead_of_download.patch
          ./patch/find_kaldifst_instead_of_download.patch
        ];

        postInstall = ''
          mkdir -p $out/lib
          mkdir -p $out/include
          mkdir -p $out/include/kaldi-decoder/csrc
          cp -r $src/kaldi-decoder/csrc $out/include/kaldi-decoder
        '';
      };

      sherpa-onnx = pkgs.stdenv.mkDerivation {
        pname = "sherpa-onnx";
        version = "1.12.31";

        src = pkgs.fetchFromGitHub {
          owner = "k2-fsa";
          repo = "sherpa-onnx";
          rev = "e0ab4a8beb10477d25ef48e518a537995c38c698";
          sha256 = "sha256-R5KsTZoTsoGgplSW8IUtOPMsmgW1mhoutZYB66F9XXo=";
        };

        nativeBuildInputs = with pkgs; [
          cmake
          ninja
          pkg-config
          gnumake
          onnxruntime
          alsa-lib
          kaldi-native-fbank
          lib_nlohmann_json
          simple-sentencepiece
          kaldi-decoder
          kaldifst
          openfst
          eigen
        ];

        buildInputs = with pkgs; [
          onnxruntime
          alsa-lib
        ];

        patches = [
          ./patch/find_nlohmann_json_instead_of_download.patch
          ./patch/find_simple_sentencepiece_instead_of_download.patch
          ./patch/find_kaldi_decoder_instead_of_download.patch
          ./patch/find_kaldi_native_fbank_instead_of_download.patch
          ./patch/link_eigen_in_sharpa_onnx_csrc.patch
        ];

        cmakeFlags = [
          "-DCMAKE_BUILD_TYPE=Release"
          "-DBUILD_SHARED_LIBS=OFF"
          "-DSHERPA_ONNX_ENABLE_BINARY=OFF"
          "-DSHERPA_ONNX_ENABLE_TESTS=OFF"
          "-DSHERPA_ONNX_ENABLE_WEBSOCKET=OFF"
          "-DSHERPA_ONNX_ENABLE_TTS=OFF"
          "-DSHERPA_ONNX_ENABLE_SPEAKER_DIARIZATION=OFF"
          "-DSHERPA_ONNX_ENABLE_PORTAUDIO=OFF"
          "-DFETCHCONTENT_FULLY_DISCONNECTED=ON"
        ];
      };
    in
    {
      packages."${system}" = {
        kissfft = lib_kissfft;
        nlohmann_json = lib_nlohmann_json;
        inherit kaldi-native-fbank;
        inherit simple-sentencepiece;
        inherit kaldi-decoder;
        inherit kaldifst;
        inherit openfst;
        inherit sherpa-onnx;
      };
    };
}
