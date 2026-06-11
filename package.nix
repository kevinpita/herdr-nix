{ lib
, rustPlatform
, fetchFromGitHub
, zig_0_15
, git
, coreutils
,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "herdr";
  version = "0.6.9";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "ogulcancelik";
    repo = "herdr";
    tag = "v${finalAttrs.version}";
    hash = "sha256-jguGh9RLet0jdEcMXCPWDLk8eo8Gsxn1+k8oGDOZP5c=";
  };

  cargoHash = "sha256-K+yrVj3akc4Zd3ydoqbF0s+kwLEKbSad129l8mz2vC4=";

  zigDeps = zig_0_15.fetchDeps {
    inherit (finalAttrs) pname version;
    src = "${finalAttrs.src}/vendor/libghostty-vt";
    fetchAll = true;
    hash = "sha256-pgGu8+NwvFcj6SrN4VaTHLeHdA7QY731ctyrHZwgFAc=";
  };

  nativeBuildInputs = [ zig_0_15.hook ];

  # The worktree/git unit tests shell out to `git`, which is otherwise not on
  # PATH inside the Nix build sandbox.
  nativeCheckInputs = [ git ];

  # Several tests exec a throwaway helper via its FHS path (/usr/bin/true,
  # /bin/cat), which does not exist on NixOS. Point them at coreutils so the
  # tests run instead of being skipped; this also avoids poisoning the shared
  # test mutex, which would otherwise cascade into ~18 unrelated failures.
  postPatch = ''
    substituteInPlace \
      src/app/api/worktrees.rs \
      src/app/mod.rs \
      src/app/input/terminal.rs \
      src/app/input/mouse.rs \
      --replace-fail '/usr/bin/true' '${lib.getExe' coreutils "true"}'
    substituteInPlace \
      src/pty/backend/unix.rs \
      --replace-fail '/bin/cat' '${lib.getExe' coreutils "cat"}'
  '';

  # Run the binary's unit tests only. The integration suite under tests/ spawns
  # herdr server processes, binds unix sockets and shells out to lsof/pgrep,
  # none of which work in the sandbox.
  cargoTestFlags = [ "--bin=herdr" ];

  # Run the suite single-threaded. Several tests race on shared temp files
  # under parallel load (e.g. a custom command spawns `printf x > f` and another
  # thread polls `f` before the write lands, reading it empty), which is why
  # upstream disables checks entirely. Serializing removes the contention that
  # widens that window.
  #
  # Remaining sandbox-only failures, not real defects:
  #   - the foreground-job tests spawn a process inside a PTY and inspect its
  #     foreground process group, which needs a controlling terminal the
  #     sandbox does not provide;
  #   - the manifest auto-update test exercises the remote manifest update path
  #     and reports no updated manifest under the Nix build sandbox.
  checkFlags = [
    "--test-threads=1"
    "--skip=detect::tests::foreground_job_detects_sleep"
    "--skip=detect::tests::foreground_job_detects_shell_running_command"
    "--skip=detect::manifest_update::tests::auto_update_reloads_manifest_cache_after_remote_commit"
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
