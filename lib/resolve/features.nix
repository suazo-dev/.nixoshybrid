{ lib, schema, machineName, root }:
let
  featureRoot = root + "/features";

  resolvePath = name:
    let
      p = featureRoot + "/${name}.nix";
    in
      if builtins.pathExists p then p else
        throw "Machine '${machineName}' references missing feature '${name}'";

  getFeature = name:
    schema.validateFeature name (import (resolvePath name));

  resolve = requested:
    let
      go = seenNames: seenFeatures: pending:
        if pending == [ ] then
          { names = seenNames; features = seenFeatures; }
        else
          let
            current = builtins.head pending;
            rest = builtins.tail pending;
          in
            if builtins.elem current seenNames then
              go seenNames seenFeatures rest
            else
              let
                feature = getFeature current;
                children = feature.features or [ ];
              in
                go (seenNames ++ [ current ]) (seenFeatures ++ [ feature ]) (children ++ rest);
    in
      go [ ] [ ] requested;
in
{
  inherit getFeature resolve;
}
