{pkgs, config, lib, ... }:

let
  themeFile = config.lib.stylix.colors {
    template = builtins.readFile ./template.mustache;
    extension = ".json";
  };
  publisher = "Stylix";
  name = "stylix";
  version = "0.0.0";

  themePackageJson = pkgs.writeText "package.json" (builtins.toJSON {
    inherit name publisher version;
    displayName = "Stylix";
    description = "Theme configured as part of your NixOS configuration.";
    engines.vscode = "^1.43.0";
    categories = [ "Themes" ];
    contributes.themes = [{
      label = "Stylix";
      uiTheme = "vs";
      path = "./themes/stylix.json";
    }];
    "__metadata" = {
      id = "6f0404ee-0463-4def-80f1-515adc5389fc";
      publisherDisplayName = "Stylix";
      publisherId = "b78a1e2c-a0b3-413a-8196-1b3e8ca3865b";
    };
  });

  themeExtension = pkgs.runCommandLocal "stylix-vscode" {
    passthru = {
      vscodeExtUniqueId="${publisher}.${name}";
      vscodeExtPublisher=publisher;
      vscodeExtName="stylix-vscode";
      inherit version;
    };
  } ''
    mkdir -p $out/share/vscode/extensions/stylix/themes
    ln -s ${themePackageJson} $out/share/vscode/extensions/stylix/package.json
    ln -s ${themeFile} $out/share/vscode/extensions/stylix/themes/stylix.json
  '';

in {
  options.stylix.targets.vscode.enable =
    config.lib.stylix.mkEnableTarget "VSCode" true;

  config = lib.mkIf config.stylix.targets.vscode.enable {
    programs.vscode = {
      extensions = [ themeExtension ];
      userSettings."workbench.colorTheme" = "Stylix";
    };
  };
}

