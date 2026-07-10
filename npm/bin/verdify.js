#!/usr/bin/env node
"use strict";

const childProcess = require("node:child_process");
const fs = require("node:fs");
const path = require("node:path");

const packageRoot = path.resolve(__dirname, "..", "..");
const packageJson = JSON.parse(fs.readFileSync(path.join(packageRoot, "package.json"), "utf8"));
const version = packageJson.version;

const COPY_ENTRIES = [
  "AGENTS.md",
  "AUTOMATION.md",
  "CHANGELOG.md",
  "CLAUDE.md",
  "COMMON_OPERATING_CONTRACT.md",
  "CONTRIBUTING.md",
  "README.md",
  "SECURITY.md",
  "VERSION",
  "WORKFLOW.md",
  ".github",
  "bin",
  "config",
  "docs",
  "evaluations",
  "examples",
  "lib",
  "npm",
  "packs",
  "package.json",
  "schemas",
  "scripts",
  "skills",
  "templates",
  "verdify.workflow.yaml"
];

function usage() {
  return `Verdify CLI ${version}

Usage:
  npx @verdify-cli/cli@${version} init [--repo PATH] [--host codex|claude|all] [--force]
  npx @verdify-cli/cli@${version} dl PACK [--repo PATH] [--host codex|claude|all] [--include-optional] [--force]
  npx @verdify-cli/cli@${version} <verdify-command> [options]

The init command installs the skills package under .agent-skills, links agent
skills into .agents/skills, writes AGENTS.md instructions, and initializes
.agent-workflow lifecycle artifacts. The dl command installs a specific skill
pack from the package registry without initializing lifecycle artifacts. Other
commands are forwarded to the packaged Ruby CLI.
`;
}

function parseInstallArgs(argv, options = {}) {
  const parsed = {
    repo: options.repo || process.cwd(),
    host: options.host || "codex",
    pack: options.pack || "all",
    force: false,
    includeOptional: false
  };

  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    if (arg === "--repo") {
      i += 1;
      if (!argv[i]) fail("--repo requires a path", 2);
      parsed.repo = argv[i];
    } else if (arg === "--host") {
      i += 1;
      if (!["codex", "claude", "all"].includes(argv[i])) fail("--host must be codex, claude, or all", 2);
      parsed.host = argv[i];
    } else if (arg === "--pack") {
      i += 1;
      if (!argv[i]) fail("--pack requires a name", 2);
      parsed.pack = argv[i];
    } else if (arg === "--include-optional") {
      parsed.includeOptional = true;
    } else if (arg === "--force") {
      parsed.force = true;
    } else if (arg === "-h" || arg === "--help") {
      process.stdout.write(usage());
      process.exit(0);
    } else {
      fail(`unknown option: ${arg}`, 2);
    }
  }

  return parsed;
}

function parseInitArgs(argv) {
  const options = {
    repo: process.cwd(),
    host: "codex",
    pack: "all",
    includeOptional: false,
    force: false
  };

  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    if (arg === "--repo") {
      i += 1;
      if (!argv[i]) fail("--repo requires a path", 2);
      options.repo = argv[i];
    } else if (arg === "--host") {
      i += 1;
      if (!["codex", "claude", "all"].includes(argv[i])) fail("--host must be codex, claude, or all", 2);
      options.host = argv[i];
    } else if (arg === "--pack") {
      i += 1;
      if (!argv[i]) fail("--pack requires a name", 2);
      options.pack = argv[i];
    } else if (arg === "--include-optional") {
      options.includeOptional = true;
    } else if (arg === "--force") {
      options.force = true;
    } else if (arg === "-h" || arg === "--help") {
      process.stdout.write(usage());
      process.exit(0);
    } else {
      fail(`unknown init option: ${arg}`, 2);
    }
  }

  return options;
}

function fail(message, status = 1) {
  process.stderr.write(`verdify: ${message}\n`);
  process.exit(status);
}

function run(command, args, options = {}) {
  const result = childProcess.spawnSync(command, args, {
    cwd: options.cwd || process.cwd(),
    stdio: options.stdio || "inherit",
    encoding: "utf8"
  });
  if (result.error || result.status !== 0) {
    if (options.cleanup) options.cleanup();
    if (result.error) fail(`${command} failed: ${result.error.message}`);
    process.exit(result.status || 1);
  }
  return result;
}

function capture(command, args, cwd) {
  const result = childProcess.spawnSync(command, args, {
    cwd,
    stdio: ["ignore", "pipe", "pipe"],
    encoding: "utf8"
  });
  if (result.error) fail(`${command} failed: ${result.error.message}`);
  if (result.status !== 0) {
    const detail = (result.stderr || result.stdout || "").trim();
    fail(detail || `${command} exited with status ${result.status}`, result.status || 1);
  }
  return result.stdout.trim();
}

function findRepoRoot(repoPath) {
  const start = path.resolve(repoPath);
  return capture("git", ["rev-parse", "--show-toplevel"], start);
}

function copyPackage(dest, force) {
  if (fs.existsSync(dest)) {
    if (!force) return { changed: false, commit: () => {}, rollback: () => {} };
  }

  const parent = path.dirname(dest);
  const temp = `${dest}.tmp-${process.pid}`;
  const backup = `${dest}.rollback-${process.pid}`;
  fs.mkdirSync(parent, { recursive: true });
  fs.rmSync(temp, { recursive: true, force: true });
  fs.rmSync(backup, { recursive: true, force: true });
  try {
    fs.mkdirSync(temp, { recursive: true });
    for (const entry of COPY_ENTRIES) {
      const source = path.join(packageRoot, entry);
      if (!fs.existsSync(source)) continue;
      const target = path.join(temp, entry);
      fs.cpSync(source, target, {
        recursive: true,
        verbatimSymlinks: true,
        filter: (candidate) => {
          const relative = path.relative(packageRoot, candidate);
          return !relative.startsWith(".git")
            && !relative.startsWith(".agent-skills")
            && !relative.startsWith(".agent-workflow")
            && !relative.startsWith("dist")
            && !relative.startsWith("node_modules");
        }
      });
    }

    for (const executable of ["bin/verdify", "scripts/setup-agent-hosts.rb"]) {
      const file = path.join(temp, executable);
      if (fs.existsSync(file)) fs.chmodSync(file, 0o755);
    }
    if (fs.existsSync(dest)) fs.renameSync(dest, backup);
    fs.renameSync(temp, dest);
  } catch (error) {
    fs.rmSync(temp, { recursive: true, force: true });
    if (!fs.existsSync(dest) && fs.existsSync(backup)) fs.renameSync(backup, dest);
    throw error;
  }

  let active = true;
  return {
    changed: true,
    commit: () => {
      if (!active) return;
      fs.rmSync(backup, { recursive: true, force: true });
      active = false;
    },
    rollback: () => {
      if (!active) return;
      fs.rmSync(dest, { recursive: true, force: true });
      if (fs.existsSync(backup)) fs.renameSync(backup, dest);
      removeEmptyInstallParents(dest);
      active = false;
    }
  };
}

function removeEmptyInstallParents(installDir) {
  const stop = path.dirname(path.dirname(path.dirname(installDir)));
  let cursor = path.dirname(installDir);
  while (cursor !== stop && fs.existsSync(cursor) && fs.readdirSync(cursor).length === 0) {
    fs.rmdirSync(cursor);
    cursor = path.dirname(cursor);
  }
}

function pruneOtherVersions(installDir) {
  const parent = path.dirname(installDir);
  if (!fs.existsSync(parent)) return;
  for (const entry of fs.readdirSync(parent, { withFileTypes: true })) {
    if (entry.name === version || !entry.isDirectory()) continue;
    fs.rmSync(path.join(parent, entry.name), { recursive: true, force: true });
  }
}

function upsertAgentsBlock(repoRoot, installDir) {
  const file = path.join(repoRoot, "AGENTS.md");
  const relativeInstall = path.relative(repoRoot, installDir);
  const start = "<!-- BEGIN VERDIFY AGENT WORKFLOW -->";
  const end = "<!-- END VERDIFY AGENT WORKFLOW -->";
  const block = `${start}
# Verdify Agent Workflow

Use the Verdify lifecycle skills linked in \`.agents/skills\`.
Start or resume lifecycle work through \`$project-router\` unless the user explicitly names another lifecycle skill and its prerequisites are present.
GitHub Issues are the backlog source of truth, and GitHub is the delivery control plane.
Durable workflow artifacts live in \`.agent-workflow\`.
The installed skill package lives in \`${relativeInstall}\`; follow \`${relativeInstall}/COMMON_OPERATING_CONTRACT.md\` and \`${relativeInstall}/config/authority-matrix.yaml\`.
${end}
`;

  const existing = fs.existsSync(file) ? fs.readFileSync(file, "utf8") : "";
  const pattern = new RegExp(`${escapeRegExp(start)}[\\s\\S]*?${escapeRegExp(end)}\\n?`);
  const next = pattern.test(existing)
    ? existing.replace(pattern, block)
    : `${existing.replace(/\s*$/, "")}${existing.trim() ? "\n\n" : ""}${block}`;
  fs.writeFileSync(file, next, "utf8");
}

function escapeRegExp(value) {
  return value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

function upsertPackBlock(repoRoot, installDir, packName) {
  const file = path.join(repoRoot, "AGENTS.md");
  const relativeInstall = path.relative(repoRoot, installDir);
  const start = "<!-- BEGIN VERDIFY SKILL PACKS -->";
  const end = "<!-- END VERDIFY SKILL PACKS -->";
  const block = `${start}
# Verdify Skill Packs

Installed Verdify skill package: \`${relativeInstall}\`.
Installed pack: \`${packName}\`.
Use the linked skills under \`.agents/skills\` or \`.claude/skills\` according to host setup. Packs are installable subsets of the package registry under \`${relativeInstall}/packs\`.
${end}
`;

  const existing = fs.existsSync(file) ? fs.readFileSync(file, "utf8") : "";
  const pattern = new RegExp(`${escapeRegExp(start)}[\\s\\S]*?${escapeRegExp(end)}\\n?`);
  const next = pattern.test(existing)
    ? existing.replace(pattern, block)
    : `${existing.replace(/\s*$/, "")}${existing.trim() ? "\n\n" : ""}${block}`;
  fs.writeFileSync(file, next, "utf8");
}

function init(argv) {
  const options = parseInitArgs(argv);
  const repoRoot = findRepoRoot(options.repo);
  const installDir = path.join(repoRoot, ".agent-skills", "verdify-skills", version);
  const installTransaction = copyPackage(installDir, options.force);
  const copied = installTransaction.changed;
  const runOptions = { cleanup: installTransaction.rollback };

  run("ruby", [path.join(installDir, "bin", "verdify"), "init", "--repo", repoRoot].concat(options.force ? ["--force"] : []), runOptions);
  run("ruby", [
    path.join(installDir, "scripts", "setup-agent-hosts.rb"),
    "--root", repoRoot,
    "--source", installDir,
    "--host", options.host,
    "--pack", options.pack
  ].concat(options.includeOptional ? ["--include-optional"] : []), runOptions);
  if (options.pack !== "all") {
    run("ruby", [path.join(installDir, "bin", "verdify"), "pack", "install", "--repo", repoRoot, "--pack", options.pack, "--host", options.host, "--force"].concat(options.includeOptional ? ["--include-optional"] : []), runOptions);
  }
  run("ruby", [path.join(installDir, "bin", "verdify"), "route", "--repo", repoRoot, "--write"], runOptions);
  upsertAgentsBlock(repoRoot, installDir);
  upsertPackBlock(repoRoot, installDir, options.pack);
  installTransaction.commit();
  pruneOtherVersions(installDir);

  process.stdout.write(`Verdify skills ${version} ${copied ? "installed" : "already installed"} in ${path.relative(repoRoot, installDir)}\n`);
  process.stdout.write(`Skill pack: ${options.pack}\n`);
  process.stdout.write("Workflow artifacts: .agent-workflow\n");
  process.stdout.write("Agent skills: .agents/skills\n");
}

function dl(argv) {
  if (argv.length === 0 || argv[0] === "-h" || argv[0] === "--help") {
    process.stdout.write(usage());
    process.exit(0);
  }
  const packName = argv[0];
  const options = parseInstallArgs(argv.slice(1), { pack: packName });
  const repoRoot = findRepoRoot(options.repo);
  const installDir = path.join(repoRoot, ".agent-skills", "verdify-skills", version);
  const installTransaction = copyPackage(installDir, options.force);
  const copied = installTransaction.changed;
  const args = [
    path.join(installDir, "bin", "verdify"),
    "pack",
    "install",
    "--repo", repoRoot,
    "--pack", options.pack,
    "--host", options.host
  ];
  if (options.includeOptional) args.push("--include-optional");
  if (options.force) args.push("--force");
  run("ruby", args, {
    cleanup: installTransaction.rollback
  });
  installTransaction.commit();
  pruneOtherVersions(installDir);
  upsertPackBlock(repoRoot, installDir, options.pack);
  process.stdout.write(`Verdify skill pack ${options.pack} ${copied ? "downloaded" : "already downloaded"} from @verdify-cli/cli ${version}\n`);
}

function forwardToRuby(argv) {
  run("ruby", [path.join(packageRoot, "bin", "verdify")].concat(argv));
}

const argv = process.argv.slice(2);
if (argv.length === 0 || argv[0] === "help" || argv[0] === "-h" || argv[0] === "--help") {
  process.stdout.write(usage());
  process.exit(0);
}

if (argv[0] === "version" || argv[0] === "--version" || argv[0] === "-v") {
  process.stdout.write(`${version}\n`);
  process.exit(0);
}

if (argv[0] === "init") {
  init(argv.slice(1));
} else if (argv[0] === "dl") {
  dl(argv.slice(1));
} else {
  forwardToRuby(argv);
}
