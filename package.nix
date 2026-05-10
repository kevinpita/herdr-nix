{ lib
, rustPlatform
, fetchFromGitHub
, zig_0_15
,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "herdr";
  version = "0.5.5";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "ogulcancelik";
    repo = "herdr";
    tag = "v${finalAttrs.version}";
    hash = "sha256-gkgnfpnyTcUcJ8Tn6B8//hgMbLR0a5DIfiE9NuNQWec=";
  };

  cargoHash = "sha256-lIa8BIvLJ7HUlWPyUNp/S4fK/1UzCQooeEjfousqtfw=";

  zigDeps = zig_0_15.fetchDeps {
    inherit (finalAttrs) pname version;
    src = "${finalAttrs.src}/vendor/libghostty-vt";
    fetchAll = true;
    hash = "sha256-RumTHGJrr4SuL6HIHwujSWrdtOsiqkcIBlwI/qIcAwE=";
  };

  nativeBuildInputs = [ zig_0_15.hook ];

  cargoTestFlags = [ "--bin=herdr" ];

  checkFlags = [
    "--skip=detect::tests::foreground_job_detects_shell_running_command"
    "--skip=detect::tests::foreground_job_detects_sleep"
  ];

  dontUseZigBuild = true;
  dontUseZigCheck = true;
  dontUseZigInstall = true;

  postConfigure = ''
    export ZIG_GLOBAL_CACHE_DIR=$(mktemp -d)
    cp -rL ${finalAttrs.zigDeps} "$ZIG_GLOBAL_CACHE_DIR/p"
    chmod -R u+w "$ZIG_GLOBAL_CACHE_DIR/p"
  '';

  meta = {
    description = "Agent multiplexer that lives in your terminal";
    homepage = "https://github.com/ogulcancelik/herdr";
    changelog = "https://github.com/ogulcancelik/herdr/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ kevinpita ];
    mainProgram = "herdr";
    platforms = lib.platforms.unix;
  };
})
