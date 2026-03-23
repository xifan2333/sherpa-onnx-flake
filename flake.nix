{
  description = "Sherpa-onnx flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        # "aarch64-linux"
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
          callPackage = pkgs.callPackage;

          cargs = callPackage ./packages/cargs.nix { };
          kissfft = callPackage ./packages/kissfft.nix { };
          kaldi-native-fbank = callPackage ./packages/kaldi-native-fbank.nix {
            inherit cargs;
            inherit kissfft;
          };
          nlohmann_json = callPackage ./packages/nlohmann-json.nix { };
          simple-sentencepiece = callPackage ./packages/simple-sentencepiece.nix { };
          openfst = callPackage ./packages/openfst.nix { };
          kaldifst = callPackage ./packages/kalifst.nix { inherit openfst; };
          kaldi-decoder = callPackage ./packages/kaldi-decoder.nix {
            inherit openfst;
            inherit kaldifst;
          };

          sherpa-onnx = pkgs.lib.makeOverridable (
            callPackage ./packages/sherpa-onnx.nix {
              inherit openfst;
              inherit kaldifst;
              inherit kaldi-decoder;
              inherit kaldi-native-fbank;
              inherit simple-sentencepiece;
              sharedLibs = true;
            }
          );
        in
        {
          inherit kissfft;
          inherit nlohmann_json;
          inherit kaldi-native-fbank;
          inherit simple-sentencepiece;
          inherit kaldi-decoder;
          inherit kaldifst;
          inherit openfst;
          inherit cargs;
          inherit sherpa-onnx;
          default = sherpa-onnx;
        }
      );
    };
}
