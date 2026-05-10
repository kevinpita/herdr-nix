{ lib
, rustPlatform
, fetchFromGitHub
, zig_0_15
,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "herdr";
  version = "0.5.6";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "ogulcancelik";
    repo = "herdr";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ny7M5o1me/ptKNbjOOZq7jbjAqTjxnhP/7y1M4Rvu6w=";
  };

  cargoHash = "sha256-fHJlTpEAYkl0EcXagMHiBdE+TJHptad79V7KwzXCojA=";

  zigDeps = zig_0_15.fetchDeps {
    inherit (finalAttrs) pname version;
    src = "${finalAttrs.src}/vendor/libghostty-vt";
    fetchAll = true;
    hash = "sha256-GTbHRmgVjq1J4mbiZvsQa78tUKSn9afFDH85d3rQQ3o=";
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
