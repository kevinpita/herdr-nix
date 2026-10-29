{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  buildPackages,
  pkg-config,
  makeWrapper,
  clang,
  fontconfig,
  freetype,
  libxkbcommon,
  libxcb,
  wayland,
  vulkan-loader,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "herdr-app";
  version = "0.1.8";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "herdrdev";
    repo = "herdr-app";
    tag = "v${finalAttrs.version}";
    fetchSubmodules = true;
    hash = "sha256-NPhh39yknVBYdvUbSGxaMFTra7anNryfnE0sxlH9fgU=";
  };

  cargoHash = "sha256-acGcomB6O84E3C9oklTpToe+b3POI6iyxIOvTFD8zkQ=";

  # Build-platform Zig: passthru attrs are not spliced.
  zigDeps = buildPackages.zig_0_16.fetchDeps {
    inherit (finalAttrs) pname version;
    src = "${finalAttrs.src}/vendor/ghostty";
    fetchAll = true;
    hash = "sha256-G9xbZ/pyQTDIfzG0h++i70a45zpwyYpZMBZfAnoOQw0=";
  };

  nativeBuildInputs = [
    buildPackages.zig_0_16.hook
    rustPlatform.bindgenHook
    # ghostty-sys falls back to Zig's builtin headers when clang is not on
    # PATH, and those break the libc headers that bindgenHook adds.
    clang
    pkg-config
    makeWrapper
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    fontconfig
    freetype
    libxkbcommon
    libxcb
    wayland
  ];

  # Without HERDR_APP_RELEASE at build time the app never updates itself and
  # has no telemetry endpoint.
  doCheck = false;

  dontUseZigBuild = true;
  dontUseZigCheck = true;
  dontUseZigInstall = true;

  postConfigure = ''
    export ZIG_GLOBAL_CACHE_DIR=$(mktemp -d)
    cp -rL ${finalAttrs.zigDeps} "$ZIG_GLOBAL_CACHE_DIR/p"
    chmod -R u+w "$ZIG_GLOBAL_CACHE_DIR/p"
  '';

  postInstall = lib.optionalString stdenv.hostPlatform.isLinux ''
    install -Dm444 assets/icons/herdr-ui-icon-clean.svg $out/share/icons/hicolor/scalable/apps/herdr-app.svg
    install -Dm444 /dev/stdin $out/share/applications/herdr-app.desktop <<EOF
    [Desktop Entry]
    Type=Application
    Name=Herdr
    Comment=Terminals and coding agents that keep running
    Exec=herdr-app
    Icon=herdr-app
    Terminal=false
    Categories=Development;
    StartupWMClass=herdr-app
    EOF
  '';

  # GPUI loads Vulkan and Wayland at run time.
  postFixup = ''
    ${lib.optionalString stdenv.hostPlatform.isLinux ''
      patchelf $out/bin/herdr-app --add-rpath ${
        lib.makeLibraryPath [
          vulkan-loader
          wayland
          libxkbcommon
        ]
      }
    ''}
    wrapProgram $out/bin/herdr-app --set-default HERDR_TELEMETRY 0
  '';

  meta = {
    description = "Herdr desktop app for terminals and coding agents";
    homepage = "https://github.com/herdrdev/herdr-app";
    changelog = "https://github.com/herdrdev/herdr-app/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ kevinpita ];
    mainProgram = "herdr-app";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
  };
})
