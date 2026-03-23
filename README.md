# Nix flake for sherpa-onnx

- It only supports `x86_64-linux` at the moment. PRs for other architectures are welcome!
- Dynamic build is enabled by default. If you want static build, override the package with `sharedLibs = false;`
