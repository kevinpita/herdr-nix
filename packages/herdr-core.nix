{
  lib,
  rustPlatform,
  fetchFromGitHub,
  buildPackages,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "herdr-core";
  version = "0.1.17";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "herdrdev";
    repo = "herdr-core";
    tag = "v${finalAttrs.version}";
    fetchSubmodules = true;
    hash = "sha256-fulACGl26Pk6FAvOOJsFtPfFQMwJAfw/MqMa6Rq0/4c=";
  };

  cargoHash = "sha256-UZsc5AElm5gmIImgR8cZz0U9+2RNG+DRb+OU8ifZSXc=";

  # Build-platform Zig: passthru attrs are not spliced, and a static-host Zig
  # means compiling LLVM. build.rs passes -Dtarget, so this Zig still targets musl.
  zigDeps = buildPackages.zig_0_16.fetchDeps {
    inherit (finalAttrs) pname version;
    src = "${finalAttrs.src}/vendor/ghostty";
    fetchAll = true;
    hash = "sha256-G9xbZ/pyQTDIfzG0h++i70a45zpwyYpZMBZfAnoOQw0=";
  };

  nativeBuildInputs = [ buildPackages.zig_0_16.hook ];

  cargoBuildFlags = [
    "-p"
    "herdr-core"
  ];

  # The suite starts real cores, terminals and systemd user services.
  doCheck = false;

  dontUseZigBuild = true;
  dontUseZigCheck = true;
  dontUseZigInstall = true;

  postConfigure = ''
    export ZIG_GLOBAL_CACHE_DIR=$(mktemp -d)
    cp -rL ${finalAttrs.zigDeps} "$ZIG_GLOBAL_CACHE_DIR/p"
    chmod -R u+w "$ZIG_GLOBAL_CACHE_DIR/p"
  '';

  postInstall = ''
    ln -s herdr-core $out/bin/hc
    install -Dm444 skills/herdr-core/SKILL.md -t $out/share/herdr-core/skills/herdr-core
  '';

  meta = {
    description = "Terminals for coding agents that keep running after you leave (hc)";
    homepage = "https://github.com/herdrdev/herdr-core";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ kevinpita ];
    mainProgram = "herdr-core";
    platforms = lib.platforms.unix;
  };
})
