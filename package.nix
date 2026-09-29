{
  lib,
  rustPlatform,
  fetchFromGitHub,
  installShellFiles,
  stdenv,
  zig_0_16,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "herdr";
  version = "0.9.3";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "herdrdev";
    repo = "herdr";
    tag = "v${finalAttrs.version}";
    hash = "sha256-uu452Xe23pSvFk7w7fKPjiaqY5QenUIljao2SFAxpc0=";
  };

  cargoHash = "sha256-+gTWtEheyuI59yf2PqRbcbcFIW+/cYb7zZ2mPv2VN0Y=";

  zigDeps = zig_0_16.fetchDeps {
    inherit (finalAttrs) pname version;
    src = "${finalAttrs.src}/vendor/libghostty-vt";
    fetchAll = true;
    hash = "sha256-Cy0DdSvce+fhOFIfxHMQGF2b2j16UkS27UpGbfC42XI=";
  };

  nativeBuildInputs = [
    zig_0_16.hook
    installShellFiles
  ];

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
    if [ -f skills/herdr/SKILL.md ]; then
      skill_path=skills/herdr/SKILL.md
    else
      skill_path=SKILL.md
    fi
    install -Dm444 "$skill_path" -t $out/share/herdr/skills/herdr
    cp -r src/integration/assets $out/share/herdr/integrations
  ''
  + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd herdr \
      --bash <($out/bin/herdr completion bash) \
      --fish <($out/bin/herdr completion fish) \
      --zsh <($out/bin/herdr completion zsh)
    $out/bin/herdr --default-config > $out/share/herdr/default-config.toml
  '';

  meta = {
    description = "Agent multiplexer that lives in your terminal";
    homepage = "https://github.com/herdrdev/herdr";
    changelog = "https://github.com/herdrdev/herdr/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ kevinpita ];
    mainProgram = "herdr";
    platforms = lib.platforms.unix;
  };
})
