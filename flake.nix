{
  description = "Sherpa-onnx flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        # "i686-linux" # broken
        # "x86_64-darwin"
        # "aarch64-darwin"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;
      pkgsFor = system: import nixpkgs { inherit system; };
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
          inherit (pkgs) callPackage;

          localPackages = rec {
            cargs = callPackage ./packages/cargs.nix { };
            kissfft = callPackage ./packages/kissfft.nix { };
            kaldi-native-fbank = callPackage ./packages/kaldi-native-fbank.nix {
              inherit cargs kissfft;
            };
            nlohmann_json = callPackage ./packages/nlohmann-json.nix { };
            simple-sentencepiece = callPackage ./packages/simple-sentencepiece.nix { };
            openfst = callPackage ./packages/openfst.nix { };
            kaldifst = callPackage ./packages/kaldifst.nix { inherit openfst; };
            kaldi-decoder = callPackage ./packages/kaldi-decoder.nix {
              inherit openfst kaldifst;
            };

            sherpa-onnx = callPackage ./packages/sherpa-onnx.nix {
              inherit
                openfst
                kaldifst
                kaldi-decoder
                kaldi-native-fbank
                nlohmann_json
                simple-sentencepiece
                kissfft
                ;
              sharedLibs = true;
            };

            default = sherpa-onnx;
          };
        in
        localPackages
      );
    };
}
