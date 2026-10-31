{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
  autoPatchelfHook,
  glibc,
  makeBinaryWrapper,
  installShellFiles,
  versionCheckHook,
  writableTmpDirAsHomeHook,
  ripgrep,
  sysctl,
  wayland,
}: let
  version = "2.0.30";
  archives = {
    x86_64-linux = {
      name = "opencode-linux-x64.tar.gz";
      hash = "sha256-7KlhZ6EtmCGJ1PjTWVK/JtE1oTdRdI22T+F7ctUll5M=";
    };
    aarch64-darwin = {
      name = "opencode-darwin-arm64.zip";
      hash = "sha256-HVyyowJy8HDJxVttiJW9odGSnncC9ea+sCtdOhfeiWE=";
    };
  };
  archive = archives.${stdenvNoCC.hostPlatform.system};
  canExecute = stdenvNoCC.buildPlatform.canExecute stdenvNoCC.hostPlatform;
in
  stdenvNoCC.mkDerivation {
    pname = "opencode";
    inherit version;

    src = fetchurl {
      url = "https://opencode.ai/files/bin/${version}/${archive.name}";
      inherit (archive) hash;
    };
    sourceRoot = ".";
    dontConfigure = true;
    dontBuild = true;
    # Bun embeds its application in the executable; leave those bytes intact.
    dontStrip = true;

    nativeBuildInputs =
      [makeBinaryWrapper installShellFiles writableTmpDirAsHomeHook]
      ++ lib.optional stdenvNoCC.hostPlatform.isDarwin unzip
      ++ lib.optional stdenvNoCC.hostPlatform.isLinux autoPatchelfHook;
    # readelf reports only glibc's libc, loader, pthread, dl and m libraries.
    buildInputs = lib.optional stdenvNoCC.hostPlatform.isLinux glibc;

    env.OPENCODE_DISABLE_MODELS_FETCH = true;

    installPhase = ''
      runHook preInstall
      install -Dm755 opencode "$out/bin/opencode"
      # Bun uses $TMPDIR/opencode for its embedded native libraries.
      rm opencode
      wrapProgram "$out/bin/opencode" \
        --prefix PATH : ${lib.makeBinPath ([ripgrep] ++ lib.optional stdenvNoCC.hostPlatform.isDarwin sysctl)} \
        ${lib.optionalString stdenvNoCC.hostPlatform.isLinux ''
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [wayland]}
      ''}
      ln -s opencode "$out/bin/opencode2"
      runHook postInstall
    '';

    # Run after autoPatchelfHook so the Linux executable has a Nix interpreter.
    preInstallCheck = lib.optionalString canExecute ''
      # Keep completion generation isolated from the builder's XDG defaults.
      export XDG_CACHE_HOME="$HOME/.cache"
      export XDG_CONFIG_HOME="$HOME/.config"
      export XDG_DATA_HOME="$HOME/.local/share"
      export XDG_STATE_HOME="$HOME/.local/state"
      $out/bin/opencode --completions bash > opencode.bash
      $out/bin/opencode --completions zsh > _opencode
      $out/bin/opencode --completions fish > opencode.fish
      installShellCompletion --cmd opencode \
        --bash opencode.bash --zsh _opencode --fish opencode.fish

      substitute opencode.bash opencode2.bash --replace-fail opencode opencode2
      substitute _opencode _opencode2 --replace-fail opencode opencode2
      substitute opencode.fish opencode2.fish --replace-fail opencode opencode2
      installShellCompletion --cmd opencode2 \
        --bash opencode2.bash --zsh _opencode2 --fish opencode2.fish
    '';

    nativeInstallCheckInputs = [versionCheckHook writableTmpDirAsHomeHook];
    doInstallCheck = canExecute;
    versionCheckKeepEnvironment = ["HOME" "OPENCODE_DISABLE_MODELS_FETCH"];
    versionCheckProgramArg = "--version";

    meta = {
      description = "The open source coding agent (official prebuilt binary)";
      homepage = "https://opencode.ai";
      license = lib.licenses.mit;
      mainProgram = "opencode";
      platforms = builtins.attrNames archives;
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    };
  }
