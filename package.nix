{ lib
, rustPlatform
, fetchFromGitHub
, zig_0_15
,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "herdr";
  version = "0.6.4";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "ogulcancelik";
    repo = "herdr";
    tag = "v${finalAttrs.version}";
    hash = "sha256-bf1sVfGgfqpQYTRU2m0K/o2HEq5DV3R7nW5Lgll3+wI=";
  };

  cargoHash = "sha256-yRT31RnfjSQy5bxFXVvM9zRM59WAPrBozu3S2tag6s8=";

  zigDeps = zig_0_15.fetchDeps {
    inherit (finalAttrs) pname version;
    src = "${finalAttrs.src}/vendor/libghostty-vt";
    fetchAll = true;
    hash = "sha256-GTbHRmgVjq1J4mbiZvsQa78tUKSn9afFDH85d3rQQ3o=";
  };

  nativeBuildInputs = [ zig_0_15.hook ];

  # Upstream's nix/package.nix sets doCheck = false because the Rust test
  # suite is covered by herdr's own CI and several tests are flaky inside
  # the Nix sandbox (env-dependent shell behavior, parallel test races on
  # temp dirs). Match that intent here.
  doCheck = false;

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
