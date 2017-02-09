{ pkgs }:

rec {

  doHaddock = drv: drv.overrideAttrs (drv: { doHaddock = true; });
  dontHaddock = drv: drv.overrideAttrs (drv: { doHaddock = false; });

  doJailbreak = drv: drv.overrideAttrs (drv: { jailbreak = true; });
  dontJailbreak = drv: drv.overrideAttrs (drv: { jailbreak = false; });

  doCheck = drv: drv.overrideAttrs (drv: { doCheck = true; });
  dontCheck = drv: drv.overrideAttrs (drv: { doCheck = false; });

  doDistribute = drv: drv.overrideAttrs (drv: { hydraPlatforms = drv.platforms or ["i686-linux" "x86_64-linux" "x86_64-darwin"]; });
  dontDistribute = drv: drv.overrideAttrs (drv: { hydraPlatforms = []; });

  appendConfigureFlag = drv: x: drv.overrideAttrs (drv: { configureFlags = (drv.configureFlags or []) ++ [x]; });
  removeConfigureFlag = drv: x: drv.overrideAttrs (drv: { configureFlags = pkgs.stdenv.lib.remove x (drv.configureFlags or []); });

  addBuildTool = drv: x: addBuildTools drv [x];
  addBuildTools = drv: xs: drv.overrideAttrs (drv: { buildTools = (drv.buildTools or []) ++ xs; });

  addExtraLibrary = drv: x: addExtraLibraries drv [x];
  addExtraLibraries = drv: xs: drv.overrideAttrs (drv: { extraLibraries = (drv.extraLibraries or []) ++ xs; });

  addBuildDepend = drv: x: addBuildDepends drv [x];
  addBuildDepends = drv: xs: drv.overrideAttrs (drv: { buildDepends = (drv.buildDepends or []) ++ xs; });

  addPkgconfigDepend = drv: x: addPkgconfigDepends drv [x];
  addPkgconfigDepends = drv: xs: drv.overrideAttrs (drv: { pkgconfigDepends = (drv.pkgconfigDepends or []) ++ xs; });

  enableCabalFlag = drv: x: appendConfigureFlag (removeConfigureFlag drv "-f-${x}") "-f${x}";
  disableCabalFlag = drv: x: appendConfigureFlag (removeConfigureFlag drv "-f${x}") "-f-${x}";

  markBroken = drv: drv.overrideAttrs (drv: { broken = true; });
  markBrokenVersion = version: drv: assert drv.version == version; markBroken drv;

  enableLibraryProfiling = drv: drv.overrideAttrs (drv: { enableLibraryProfiling = true; });
  disableLibraryProfiling = drv: drv.overrideAttrs (drv: { enableLibraryProfiling = false; });

  enableSharedExecutables = drv: drv.overrideAttrs (drv: { enableSharedExecutables = true; });
  disableSharedExecutables = drv: drv.overrideAttrs (drv: { enableSharedExecutables = false; });

  enableSharedLibraries = drv: drv.overrideAttrs (drv: { enableSharedLibraries = true; });
  disableSharedLibraries = drv: drv.overrideAttrs (drv: { enableSharedLibraries = false; });

  enableSplitObjs = drv: drv.overrideAttrs (drv: { enableSplitObjs = true; });
  disableSplitObjs = drv: drv.overrideAttrs (drv: { enableSplitObjs = false; });

  enableStaticLibraries = drv: drv.overrideAttrs (drv: { enableStaticLibraries = true; });
  disableStaticLibraries = drv: drv.overrideAttrs (drv: { enableStaticLibraries = false; });

  appendPatch = drv: x: appendPatches drv [x];
  appendPatches = drv: xs: drv.overrideAttrs (drv: { patches = (drv.patches or []) ++ xs; });

  doHyperlinkSource = drv: drv.overrideAttrs (drv: { hyperlinkSource = true; });
  dontHyperlinkSource = drv: drv.overrideAttrs (drv: { hyperlinkSource = false; });

  disableHardening = drv: flags: drv.overrideAttrs (drv: { hardeningDisable = flags; });

  sdistTarball = pkg: pkgs.lib.overrideDerivation pkg (drv: {
    name = "${drv.pname}-source-${drv.version}";
    buildPhase = "./Setup sdist";
    haddockPhase = ":";
    checkPhase = ":";
    installPhase = "install -D dist/${drv.pname}-*.tar.gz $out/${drv.pname}-${drv.version}.tar.gz";
    fixupPhase = ":";
  });

  buildFromSdist = pkg: pkgs.lib.overrideDerivation pkg (drv: {
    unpackPhase = let src = sdistTarball pkg; tarname = "${pkg.pname}-${pkg.version}"; in ''
      echo "Source tarball is at ${src}/${tarname}.tar.gz"
      tar xf ${src}/${tarname}.tar.gz
      cd ${pkg.pname}-*
    '';
  });

  buildStrictly = pkg: buildFromSdist (appendConfigureFlag pkg "--ghc-option=-Wall --ghc-option=-Werror");

  buildStackProject = pkgs.callPackage ./generic-stack-builder.nix { };

  triggerRebuild = drv: i: drv.overrideAttrs (drv: { postUnpack = ": trigger rebuild ${toString i}"; });

}
