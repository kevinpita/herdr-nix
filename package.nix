{
  lib,
  rustPlatform,
  fetchFromGitHub,
  zig_0_15,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "herdr";
  version = "0.6.10";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "ogulcancelik";
    repo = "herdr";
    tag = "v${finalAttrs.version}";
    hash = "sha256-QqjC/6vy6X7LAYn3YGmBJJTICeu4cj5qSX/DBaSlIfA=";
  };

  cargoHash = "sha256-EG5OcK/9c6euVx26wS0WLR6bO/Ohc7rQCsLqbK0fLWA=";

  zigDeps = zig_0_15.fetchDeps {
    inherit (finalAttrs) pname version;
    src = "${finalAttrs.src}/vendor/libghostty-vt";
    fetchAll = true;
    hash = "sha256-pgGu8+NwvFcj6SrN4VaTHLeHdA7QY731ctyrHZwgFAc=";
  };

  nativeBuildInputs = [ zig_0_15.hook ];

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
