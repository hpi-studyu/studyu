#!/bin/bash
set -e

# Use the FVM-pinned Dart SDK so the setup honors .fvmrc.
if ! command -v fvm >/dev/null 2>&1; then
  echo "fvm not found on PATH. Install FVM and run './setup.sh' again." >&2
  exit 1
fi

# Install the Flutter SDK pinned in .fvmrc.
echo "Installing the Flutter SDK via fvm..."
fvm install

# Create the local environment file without overwriting developer changes.
env_example="flutter_common/lib/envs/.env.local.example"
env_local="flutter_common/lib/envs/.env.local"
[ -e "$env_local" ] || cp "$env_example" "$env_local"

# Resolve root dependencies via the pinned SDK. This also resolves the
# workspace-local Melos package from the lockfile.
echo "Running fvm dart pub get in root project..."
fvm dart pub get

# Bootstrap Melos packages via the lockfile-resolved package.
echo "Bootstrapping Melos packages via fvm dart run melos..."
fvm dart run melos bootstrap

# Configure Git to use the tracked hooks.
echo "Configuring Git hooks via fvm dart run melos..."
fvm dart run melos setup

# Optional: enable repo-provided coding-agent integrations (MCP servers + skills).
# Generic: templates under .agents/templates/ and servers in .mcp.json.example are
# copied into the active, gitignored locations. Re-copying is idempotent.
if [ -f .mcp.json ] && [ -d .agents/skills/sonar-analyze ]; then
  echo "Coding-agent integrations already enabled (remove .mcp.json and .agents/skills/sonar-* to reset)."
elif [ -f .mcp.json.example ]; then
  printf 'Enable repo-provided coding-agent integrations (MCP servers and skills)? [y/N] '
  read -r enable_agents || true
  case "$enable_agents" in
    [yY]*)
      cp -n .mcp.json.example .mcp.json
      mkdir -p .agents/skills .agents/agents .claude/skills .claude/agents .omp/agents
      if [ -d .agents/templates/skills ]; then cp -R .agents/templates/skills/. .agents/skills/; fi
      if [ -d .agents/templates/agents ]; then cp -R .agents/templates/agents/. .agents/agents/; fi
      for d in .agents/templates/skills/*; do
        [ -d "$d" ] || continue
        name=$(basename "$d")
        mkdir -p ".claude/skills/$name"
        ln -sfn "../../../.agents/skills/$name/SKILL.md" ".claude/skills/$name/SKILL.md"
      done
      for f in .agents/templates/agents/*.md; do
        [ -f "$f" ] || continue
        name=$(basename "$f")
        ln -sfn "../../.agents/agents/$name" ".claude/agents/$name"
        ln -sfn "../../.agents/agents/$name" ".omp/agents/$name"
      done
      echo "Enabled. For SonarQube: install the CLI and log in (see docs/sonarqube.md)."
      ;;
    *) echo "Skipped coding-agent integrations. Enable later: cp .mcp.json.example .mcp.json && cp -R .agents/templates/. .agents/";;
  esac
fi

echo "Setup complete!"
