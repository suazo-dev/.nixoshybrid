{ lib }:
let
  machineType = import ./types/machine.nix;
  nodeType = import ./types/node.nix;
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
      else if !isString raw.hostName then
        throw "Machine '${machineName}': 'hostName' must be a string"
      else if raw ? user && !isString raw.user then
        throw "Machine '${machineName}': 'user' must be a string"
      else if !isString raw.nodeName then
        throw "Machine '${machineName}': 'nodeName' must be a string"
      else if !isString raw.instanceName then
        throw "Machine '${machineName}': 'instanceName' must be a string"
      else if !isString raw.hardware then
        throw "Machine '${machineName}': 'hardware' must be a relative path string"
      else if !isString raw.stateVersion then
        throw "Machine '${machineName}': 'stateVersion' must be a string"
      else if !isString raw.homeStateVersion then
        throw "Machine '${machineName}': 'homeStateVersion' must be a string"
      else if raw ? extraModules && !isStringList raw.extraModules then
        throw "Machine '${machineName}': 'extraModules' must be a list of strings"
      else if raw ? extraGroups && !isStringList raw.extraGroups then
        throw "Machine '${machineName}': 'extraGroups' must be a list of strings"
      else if raw ? allowedUnfree && !isStringList raw.allowedUnfree then
        throw "Machine '${machineName}': 'allowedUnfree' must be a list of strings"
      else if raw ? mutableUsers && !isBool raw.mutableUsers then
        throw "Machine '${machineName}': 'mutableUsers' must be a boolean"
      else if raw ? lan && !isAttrs raw.lan then
        throw "Machine '${machineName}': 'lan' must be an attrset"
      else
        raw;

  validateNode = nodeName: raw:
    let
      missing = builtins.filter (k: !(builtins.hasAttr k raw)) nodeType.requiredKeys;
      unknown = unknownKeys nodeType.allowedKeys raw;
    in
      if !isAttrs raw then
        throw "Node '${nodeName}' must evaluate to an attrset"
      else if unknown != [ ] then
        throw "Node '${nodeName}' has unknown keys: ${lib.concatStringsSep ", " unknown}"
      else if missing != [ ] then
        throw "Node '${nodeName}' is missing required keys: ${lib.concatStringsSep ", " missing}"
      else if !isStringList raw.supportedSystems then
        throw "Node '${nodeName}': 'supportedSystems' must be a list of strings"
      else if raw ? remove && !isStringList raw.remove then
        throw "Node '${nodeName}': 'remove' must be a list of strings"
      else if raw ? removeLinux && !isStringList raw.removeLinux then
        throw "Node '${nodeName}': 'removeLinux' must be a list of strings"
      else if raw ? removeDarwin && !isStringList raw.removeDarwin then
        throw "Node '${nodeName}': 'removeDarwin' must be a list of strings"
      else if raw ? network && !isAttrs raw.network then
        throw "Node '${nodeName}': 'network' must be an attrset"
      else if raw ? facts && !isAttrs raw.facts then
        throw "Node '${nodeName}': 'facts' must be an attrset"
      else
        raw;

  validateFacts = machineName: raw:
    if !isAttrs raw then
      throw "Machine '${machineName}' facts.nix must evaluate to an attrset"
    else
      lib.recursiveUpdate defaultFacts raw;

}
