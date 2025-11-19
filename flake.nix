{
  inputs.nixpkgs.url = "nixpkgs/nixos-25.05";

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; overlays = [ self.overlays.default ]; });
    in
    {
      overlays.default = final: prev: {
        hyprland-dynamic-workspaces-manager = with final; stdenvNoCC.mkDerivation rec {
          pname = "hyprland-dynamic-workspaces-manager";
          version = "2b8bad4";

          src = fetchurl {
            url = "https://github.com/sslater11/hyprland-dynamic-workspaces-manager/archive/${version}.tar.gz";
            hash = "sha256-FMFvnBE1539z5LYoS/qhrwo23jzBc9RPhwX4T3BoE+g=";
          };

          buildInputs = [ python3 ];

          installPhase = ''
            mkdir -p $out/bin
            cp -R rofi-themes-collection $out/
            sed -i -e "s#rofi_theme_path = full_script_path#rofi_theme_path = '$out'#" hyprland-dynamic-workspaces-manager.py
            cp hyprland-dynamic-workspaces-manager.py $out/bin
          '';
        };
      };

      # Provide some binary packages for selected system types.
      packages = forAllSystems (system:
        rec {
          inherit (nixpkgsFor.${system}) hyprland-dynamic-workspaces-manager;
          default = hyprland-dynamic-workspaces-manager;
        });
    };
}
