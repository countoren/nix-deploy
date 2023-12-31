{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs,  flake-utils, nix-on-droid }:
  flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" ] (system:
  let pkgs = import nixpkgs {
      inherit system;
  };
  in {
    packages.phone = pkgs.writeShellApplication {
      name = "phone";
      runtimeInputs = with pkgs; [ gh git openssh ];
      text = ''
        # we must install openssh globally in order gh to work correctly 
        nix-on-droid switch --flake github:countoren/nix-deploy
        gh auth login
        [ ! -d ~/nixpkgs ] && gh repo clone countoren/nixpkgs ~/nixpkgs
        # switch to private repo
        nix-on-droid switch --flake ~/nixpkgs
       '';
    };
    packages.default = self.packages.${system}.phone;
  }) // { 
       nixOnDroidConfigurations.default = nix-on-droid.lib.nixOnDroidConfiguration {
         modules = [ 
({ pkgs, config, ... }:

{
  environment.packages = with pkgs; [
    openssh
    git
    github-cli
  ];

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
       experimental-features = nix-command flakes
    '';
  };
  user.shell = "${pkgs.zsh}/bin/zsh";

  # Backup etc files instead of failing to activate generation if a file already exists in /etc
  environment.etcBackupExtension = ".bak";

  # Read the changelog before changing this value
  system.stateVersion = "22.05";
})
         ];
       };
  };
}
