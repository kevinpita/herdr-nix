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
  version = "0.6.6";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "ogulcancelik";
    repo = "herdr";
    tag = "v${finalAttrs.version}";
    hash = "sha256-zim9JSVCfbSrH5XovifGFST9J1kYkjou7E5oeBXfF34=";
  };

  cargoHash = "sha256-CSwYkm8+JvN+9p3znoTrmLQ7qd5R0DjOGvS4NO68ghs=";

  zigDeps = zig_0_15.fetchDeps {
    inherit (finalAttrs) pname version;
    src = "${finalAttrs.src}/vendor/libghostty-vt";
    fetchAll = true;
    hash = "sha256-GTbHRmgVjq1J4mbiZvsQa78tUKSn9afFDH85d3rQQ3o=";
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
      src/persist/restore.rs \
      --replace-fail '/usr/bin/true' '${lib.getExe' coreutils "true"}'
    substituteInPlace \
      src/pane.rs \
      src/pty/backend.rs \
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
  #   - the restore test asserts that `ps` reports the pane child's command
  #     ending in "cat", but on NixOS `cat` lives at a long store path that the
  #     kernel's 15-char comm field truncates, dropping the "cat" suffix.
  checkFlags = [
    "--test-threads=1"
    "--skip=detect::tests::foreground_job_detects_sleep"
    "--skip=detect::tests::foreground_job_detects_shell_running_command"
    "--skip=pane::tests::spawn_agent_restore_uses_restore_command_as_pane_child"
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
