{ lib, ... }:
let
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
      menubar = lib.mkOption {
        type = lib.types.listOf (
          lib.types.submodule {
            options = {
              name = lib.mkOption {
                type = lib.types.str;
                description = "The name of the menu";
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
        type = lib.types.submodule {
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
        };
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
    }:
    let
      generateItem =
        item:
        if item.type == "action" then
          ''<Action name="${item.value}"/>''
        else if item.type == "group" then
          ''<DefineGroup name="${item.value}"/>''
        else if item.type == "text" then
          "<text>${item.value}</text>"
        else
          "<Separator/>";

      generateActionProperty =
        property: ''<Action name="${property.name}" shortcut="${property.shortcut}">'';
    in
    ''
      <?xml version='1.0'?>
      <!DOCTYPE gui SYSTEM 'kpartgui.dtd'>
      <gui name="${name}" version="${toString version}">
        ${
          lib.optionalString (menubar != null) ''
            <MenuBar>
              ${
                lib.concatMapStringsSep "\n" (menu: ''
                  <Menu name="${menu.name}">
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
          lib.optionalString (toolbar != null) ''
            <ToolBar name="${toolbar.name}">
              ${
                lib.concatMapStringsSep "\n" (item: ''
                  ${generateItem item}
                '') toolbar.items
              }
            </ToolBar>
          ''
        }
        ${
          lib.optionalString (actionProperties != null) ''
            <ActionProperties scheme="${actionProperties.scheme}">
              ${
                lib.concatMapStringsSep "\n" (property: ''
                  ${generateActionProperty property}
                '') actionProperties.properties
              }
            </ActionProperties>
          ''
        }
      </gui>
    '';
in
{
  inherit generateKxmlgui kxmlguiType;
}
