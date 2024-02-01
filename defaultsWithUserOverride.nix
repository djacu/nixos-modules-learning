let
  pkgs = import <nixpkgs> {};
  inherit (pkgs) lib;
  inherit (lib) types;

  testDefaults = {
    lib,
    config,
    ...
  }: {
    options = {
      user = lib.mkOption {
        description = "Test default things.";
        type = types.attrsOf types.int;
        default = {};
      };

      useDefault = lib.mkEnableOption "Enables default.";

      default = lib.mkOption {
        description = "The defaults";
        type = types.attrsOf types.int;
        default = {
          a = 1;
          b = 2;
        };
      };

      out = lib.mkOption {
        description = "The output.";
        type = types.attrsOf types.int;
        default = {};
      };
    };

    config = lib.mkMerge [
      (
        lib.mkIf config.useDefault {
          # out = config.default;
          # infinisil magic
          out = builtins.mapAttrs (name: lib.mkDefault) config.default;
        }
      )
      {
        out = config.user;
      }
    ];
  };

  userOptions = [
    ({...}: {useDefault = true;})

    # NONE OF THESE WORK; conflicting definitions
    ({...}: {user = {b = 3;};})
    # ({...}: {user = {b = lib.mkOverride 1 3;};})
    # ({...}: {user = {b = lib.mkDefault 3;};})
    # ({...}: {user = {b = lib.mkForce 3;};})
    # ({...}: {user = lib.mkForce {b = 3;};})
    # ({...}: lib.mkForce {user = {b = 3;};})

    # I can set an option not in default.
    ({...}: {user = {c = 3;};})
    # And I can override my own option using mkOVerride (<100).
    ({...}: {user = {c = lib.mkOverride 99 4;};})
    # Or just mkForce which is mkOverride 50.
    # ({...}: {user = {c = lib.mkForce 4;};})
  ];
in (
  (lib.evalModules {
    modules =
      [
        testDefaults
      ]
      ++ userOptions;
  })
  .config
)
