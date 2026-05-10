{ root, machineName }:
let
  moduleRoot = root + "/modules";
  topLevelEntries = builtins.readDir moduleRoot;
  topLevelDirs = builtins.filter (name: topLevelEntries.${name} == "directory") (builtins.attrNames topLevelEntries);

  mkModulePath = name:
    let
      nestedMatch = builtins.match ".*/([^/]+)" name;
      baseName = if nestedMatch == null then name else builtins.head nestedMatch;
      nestedName = nestedMatch != null;
      directCandidates =
        if nestedName then
          [
            (moduleRoot + "/${name}.nix")
            (moduleRoot + "/${name}/${baseName}.nix")
          ]
        else
          [ (moduleRoot + "/${name}/${name}.nix") ];
      nestedCandidates =
        if nestedName then
          [ ]
        else
          map (dir: moduleRoot + "/${dir}/${name}/${name}.nix") topLevelDirs;
      candidates = builtins.filter builtins.pathExists (directCandidates ++ nestedCandidates);
    in
      if candidates == [] then
        throw "Machine '${machineName}' references missing module '${name}'"
      else if builtins.length candidates > 1 then
        throw "Machine '${machineName}' references ambiguous module '${name}'"
      else
        builtins.head candidates;
in
{
  paths = names: map mkModulePath names;
}
