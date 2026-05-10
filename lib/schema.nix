{ lib }:
let
  machineType = import ./types/machine.nix;
  featureType = import ./types/feature.nix;
  defaultFacts = import ./defaultFacts.nix;

  isString = builtins.isString;
  isBool = builtins.isBool;
  isAttrs = builtins.isAttrs;
  isStringList = v: builtins.isList v && builtins.all builtins.isString v;

  unknownKeys = allowed: raw:
    builtins.filter (k: !(builtins.elem k allowed)) (builtins.attrNames raw);
in
{
  validateMachine = machineName: raw:
    let
      missing = builtins.filter (k: !(builtins.hasAttr k raw)) machineType.requiredKeys;
      unknown = unknownKeys machineType.allowedKeys raw;
    in
      if !isAttrs raw then
        throw "Machine '${machineName}' must evaluate to an attrset"
      else if unknown != [ ] then
        throw "Machine '${machineName}' has unknown keys: ${lib.concatStringsSep ", " unknown}"
      else if missing != [ ] then
        throw "Machine '${machineName}' is missing required keys: ${lib.concatStringsSep ", " missing}"
      else if raw ? system && !isString raw.system then
        throw "Machine '${machineName}': 'system' must be a string"
      else if raw ? user && !isString raw.user then
        throw "Machine '${machineName}': 'user' must be a string"
      else if raw ? hostName && !isString raw.hostName then
        throw "Machine '${machineName}': 'hostName' must be a string"
      else if !isStringList raw.roles then
        throw "Machine '${machineName}': 'roles' must be a list of strings"
      else if !isString raw.hardware then
        throw "Machine '${machineName}': 'hardware' must be a relative path string"
      else if !isString raw.stateVersion then
        throw "Machine '${machineName}': 'stateVersion' must be a string"
      else if !isString raw.homeStateVersion then
        throw "Machine '${machineName}': 'homeStateVersion' must be a string"
      else if !isStringList raw.features then
        throw "Machine '${machineName}': 'features' must be a list of strings"
      else if raw ? extraModules && !isStringList raw.extraModules then
        throw "Machine '${machineName}': 'extraModules' must be a list of strings"
      else if raw ? extraGroups && !isStringList raw.extraGroups then
        throw "Machine '${machineName}': 'extraGroups' must be a list of strings"
      else if raw ? allowedUnfree && !isStringList raw.allowedUnfree then
        throw "Machine '${machineName}': 'allowedUnfree' must be a list of strings"
      else if raw ? mutableUsers && !isBool raw.mutableUsers then
        throw "Machine '${machineName}': 'mutableUsers' must be a boolean"
      else
        raw;

  validateFacts = machineName: raw:
    if !isAttrs raw then
      throw "Machine '${machineName}' facts.nix must evaluate to an attrset"
    else
      lib.recursiveUpdate defaultFacts raw;

  validateFeature = featureName: raw:
    let
      unknown = unknownKeys featureType.allowedKeys raw;
    in
      if !isAttrs raw then
        throw "Feature '${featureName}' must evaluate to an attrset"
      else if unknown != [ ] then
        throw "Feature '${featureName}' has unknown keys: ${lib.concatStringsSep ", " unknown}"
      else if raw ? features && !(builtins.isList raw.features && builtins.all builtins.isString raw.features) then
        throw "Feature '${featureName}': 'features' must be a list of strings"
      else if raw ? modules && !(builtins.isList raw.modules && builtins.all builtins.isString raw.modules) then
        throw "Feature '${featureName}': 'modules' must be a list of strings"
      else if raw ? linuxModules && !(builtins.isList raw.linuxModules && builtins.all builtins.isString raw.linuxModules) then
        throw "Feature '${featureName}': 'linuxModules' must be a list of strings"
      else if raw ? darwinModules && !(builtins.isList raw.darwinModules && builtins.all builtins.isString raw.darwinModules) then
        throw "Feature '${featureName}': 'darwinModules' must be a list of strings"
      else
        raw;
}
