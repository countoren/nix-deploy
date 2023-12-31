{
  inputs.flake-utils.url = "github:numtide/flake-utils";
  outputs = { self, nixpkgs, flake-utils }:
  flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" ] (system:
  let pkgs = import nixpkgs {
      inherit system;
  };
  in {
    packages.phone = pkgs.writeShellApplication {
      name = "phone";
      runtimeInputs = with pkgs; [ curl w3m ];
      text = ''
        echo 'This is me, Oren...'
       '';
    };
  });
}
