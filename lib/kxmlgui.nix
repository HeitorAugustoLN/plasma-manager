{ lib, ... }:
let
  boolToString = value: if value then "1" else "0"; # builtins.toString turns false into an empty string
  kxmlguiType = lib.types.submodule {
    options = {
      name = lib.mkOption {
        type = lib.types.str;
        description = "The name of the application";
      };
      version = lib.mkOption {
        type = lib.types.ints.unsigned;
        description = "The version of the application";
      };
      translationDomain = lib.mkOption {
        type = with lib.types; nullOr str;
        default = "kxmlgui6";
        example = "kxmlgui6";
        description = "The translation domain of the application";
      };
      menubar = lib.mkOption {
        type = lib.types.listOf (
          lib.types.submodule {
            options = {
              name = lib.mkOption {
                type = lib.types.str;
                description = "The name of the menu";
              };
              alreadyVisited = lib.mkOption {
                type = lib.types.bool;
                default = true;
                example = false;
                description = "Whether the menu has already been visited";
                apply = boolToString;
              };
              noMerge = lib.mkOption {
                type = lib.types.bool;
                default = false;
                example = true;
                description = "Whether the menu should not be merged";
                apply = boolToString;
              };
              items = lib.mkOption {
                type = lib.types.listOf (
                  lib.types.submodule {
                    options = {
                      type = lib.mkOption {
                        type = lib.types.str;
                        description = "The type of the item";
                      };
                      value = lib.mkOption {
                        type = lib.types.str;
                        description = "The value of the item";
                      };
                    };
                  }
                );
                description = "The items of the menu";
              };
            };
          }
        );
      };
      toolbar = lib.mkOption {
        type = lib.types.submodule {
          options = {
            name = lib.mkOption {
              type = lib.types.str;
              description = "The name of the toolbar";
            };
            alreadyVisited = lib.mkOption {
              type = lib.types.bool;
              default = true;
              example = false;
              description = "Whether the menu has already been visited";
              apply = boolToString;
            };
            noMerge = lib.mkOption {
              type = lib.types.bool;
              default = false;
              example = true;
              description = "Whether the menu should not be merged";
              apply = boolToString;
            };
            items = lib.mkOption {
              type = lib.types.listOf (
                lib.types.submodule {
                  options = {
                    type = lib.mkOption {
                      type = lib.types.str;
                      description = "The type of the item";
                    };
                    value = lib.mkOption {
                      type = lib.types.str;
                      description = "The value of the item";
                    };
                  };
                }
              );
              description = "The items of the toolbar";
            };
          };
        };
      };
      actionProperties = lib.mkOption {
        type = lib.types.listOf (
          lib.types.submodule {
            options = {
              scheme = lib.mkOption {
                type = lib.types.str;
                description = "The scheme of the action properties";
              };
              properties = lib.mkOption {
                type = lib.types.listOf (
                  lib.types.submodule {
                    options = {
                      name = lib.mkOption {
                        type = lib.types.str;
                        description = "The name of the action";
                      };
                      shortcut = lib.mkOption {
                        type = lib.types.str;
                        description = "The shortcut of the action";
                      };
                    };
                  }
                );
                description = "The properties of the action";
              };
            };
          }
        );
      };
    };
  };

  generateKxmlgui =
    {
      name,
      version,
      menubar,
      toolbar,
      actionProperties,
      translationDomain ? null,
    }:
    let
      setTranslationDomain = lib.optionalString (
        translationDomain != null
      ) ''translationDomain="${translationDomain}"'';

      generateItem =
        item:
        if item.type == "action" then
          ''<Action name="${item.value}"/>''
        else if item.type == "group" then
          ''<DefineGroup name="${item.value}"/>''
        else if item.type == "text" then
          "<text ${setTranslationDomain}>${item.value}</text>"
        else
          "<Separator/>";

      generateActionProperty =
        property: ''<Action name="${property.name}" shortcut="${property.shortcut}">'';
    in
    ''
      <?xml version='1.0'?>
      <!DOCTYPE gui SYSTEM 'kpartgui.dtd'>
      <gui name="${name}" ${setTranslationDomain} version="${toString version}">
        ${
          lib.mkIf (menubar != null) ''
            <MenuBar <alreadyVisited="${menubar.alreadyVisited}">
              ${
                lib.concatMapStringsSep "\n" (menu: ''
                  <Menu alreadyVisited="${menubar.alreadyVisited} name="${menu.name} noMerge="${menubar.noMerge}">
                    ${
                      lib.concatMapStringsSep "\n" (item: ''
                        ${generateItem item}
                      '') menu.items
                    }
                  </Menu>
                '') menubar
              }
            </MenuBar>
          ''
        }
        ${
          lib.mkIf (toolbar != null) ''
            <ToolBar alreadyVisited="${toolbar.alreadyVisited}" name="${toolbar.name}" noMerge="${toolbar.noMerge}">
              ${
                lib.concatMapStringsSep "\n" (item: ''
                  ${generateItem item}
                '') toolbar.items
              }
            </ToolBar>
          ''
        }
        ${
          lib.mkIf (actionProperties != null) ''
            ${lib.concatMapStringsSep "\n" (actionProperties: ''
              <ActionProperties scheme="${actionProperties.scheme}">
                ${
                  lib.concatMapStringsSep "\n" (property: ''
                    ${generateActionProperty property}
                  '') actionProperties.properties
                }
              </ActionProperties>
            '') actionProperties}
          ''
        }
      </gui>
    '';
in
{
  inherit generateKxmlgui kxmlguiType;
}
