{ root, machineName }:
let
  moduleRoot = root + "/modules";

  mkModulePath = name:
    let
      path = moduleRoot + "/${name}/${name}.nix";
    in
      if builtins.pathExists path then
        path
      else
        throw "Machine '${machineName}' references missing module '${name}'";
in
{
  paths = names: map mkModulePath names;
}
