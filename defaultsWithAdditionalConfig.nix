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
      test = lib.mkOption {
        description = "Test default things.";
        type = types.attrsOf (types.attrsOf types.int);
        # if you define a.b here, it is wiped with user config
        #default = {a = {b = 1;};};
      };
    };

    config = {
      # if you define a.b here, it is preserved with user config
      test = {a.b = 1;};
    };
  };
in (
  (lib.evalModules {
    modules = [
      testDefaults
      ({...}: {
        test.a.c = 2;
        test.d.e = 3;
      })
    ];
  })
  .config
)
