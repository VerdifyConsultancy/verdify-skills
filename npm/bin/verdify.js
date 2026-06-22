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
  "examples",
  "lib",
  "npm",
  "package.json",
  "schemas",
  "scripts",
  "skills",
  "verdify.workflow.yaml"
];

function usage() {
  return `Verdify CLI ${version}

Usage:
  npx @verdify/cli@${version} init [--repo PATH] [--host codex|claude|all] [--force]
  npx @verdify/cli@${version} <verdify-command> [options]

The init command installs the skills package under .agent-skills, links agent
skills into .agents/skills, writes AGENTS.md instructions, and initializes
.agent-workflow lifecycle artifacts. Other commands are forwarded to the
packaged Ruby lifecycle CLI.
`;
}

function parseInitArgs(argv) {
  const options = {
    repo: process.cwd(),
    host: "codex",
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
  if (result.error) fail(`${command} failed: ${result.error.message}`);
  if (result.status !== 0) process.exit(result.status || 1);
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
    if (!force) return false;
    fs.rmSync(dest, { recursive: true, force: true });
  }

  fs.mkdirSync(dest, { recursive: true });
  for (const entry of COPY_ENTRIES) {
    const source = path.join(packageRoot, entry);
    if (!fs.existsSync(source)) continue;
    const target = path.join(dest, entry);
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
    const file = path.join(dest, executable);
    if (fs.existsSync(file)) fs.chmodSync(file, 0o755);
  }
  return true;
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

function init(argv) {
  const options = parseInitArgs(argv);
  const repoRoot = findRepoRoot(options.repo);
  const installDir = path.join(repoRoot, ".agent-skills", "verdify-skills", version);
  const copied = copyPackage(installDir, options.force);

  run("ruby", [path.join(installDir, "bin", "verdify"), "init", "--repo", repoRoot].concat(options.force ? ["--force"] : []));
  run("ruby", [path.join(installDir, "scripts", "setup-agent-hosts.rb"), "--root", repoRoot, "--source", installDir, "--host", options.host]);
  upsertAgentsBlock(repoRoot, installDir);
  run("ruby", [path.join(installDir, "bin", "verdify"), "route", "--repo", repoRoot, "--write"]);

  process.stdout.write(`Verdify skills ${version} ${copied ? "installed" : "already installed"} in ${path.relative(repoRoot, installDir)}\n`);
  process.stdout.write("Workflow artifacts: .agent-workflow\n");
  process.stdout.write("Agent skills: .agents/skills\n");
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
} else {
  forwardToRuby(argv);
}
