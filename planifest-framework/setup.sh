#!/usr/bin/env bash
set -euo pipefail

# Planifest Setup - Configures skills for your agentic coding tool.
#
# Usage:  ./planifest-framework/setup.sh <tool>
#
# Tools:  claude-code | cursor | codex | antigravity | copilot | windsurf | cline | all
#
# Each tool's specific config lives in setup/<tool>.sh
# This script handles shared logic only.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILLS_SRC="$SCRIPT_DIR/skills"
WORKFLOWS_SRC="$SCRIPT_DIR/workflows"
SETUP_DIR="$SCRIPT_DIR/setup"

VALID_TOOLS="claude-code cursor codex antigravity copilot windsurf cline"

# --- Shared functions ---

copy_skills() {
  local target_dir="$1"

  for skill_dir in "$SKILLS_SRC"/*; do
    if [ -d "$skill_dir" ] && [ -f "$skill_dir/SKILL.md" ]; then
      local skill_name
      skill_name="$(basename "$skill_dir")"
      local dest_dir="$target_dir/$skill_name"
      
      mkdir -p "$dest_dir"
      cp "$skill_dir/SKILL.md" "$dest_dir/SKILL.md"

      # Rewrite relative paths to match bundled directory structure
      sed -i.bak \
        -e 's|\.\./templates/|./assets/templates/|g' \
        -e 's|\.\./standards/|./references/|g' \
        -e 's|\.\./standards/reference/|./references/reference/|g' \
        -e 's|\.\./schemas/|./assets/schemas/|g' \
        "$dest_dir/SKILL.md" && rm -f "$dest_dir/SKILL.md.bak"

      echo "  + $skill_name/SKILL.md"
      
      for opt_dir in scripts assets references; do
        if [ -d "$skill_dir/$opt_dir" ]; then
          cp -r "$skill_dir/$opt_dir" "$dest_dir/"
        fi
      done
      
      # Selective bundling: read bundle_templates and bundle_standards from SKILL.md frontmatter
      local skill_md="$skill_dir/SKILL.md"
      
      # Parse bundle_templates from frontmatter
      local bundle_templates
      bundle_templates=$(sed -n '/^---$/,/^---$/p' "$skill_md" | grep '^bundle_templates:' | sed 's/bundle_templates: *\[//;s/\]//;s/,/ /g;s/^ *//;s/ *$//')
      
      # Parse bundle_standards from frontmatter
      local bundle_standards
      bundle_standards=$(sed -n '/^---$/,/^---$/p' "$skill_md" | grep '^bundle_standards:' | sed 's/bundle_standards: *\[//;s/\]//;s/,/ /g;s/^ *//;s/ *$//')
      
      # Bundle only declared templates (or all if no manifest found)
      if [ -d "$SCRIPT_DIR/templates" ]; then
        mkdir -p "$dest_dir/assets/templates"
        if [ -n "$bundle_templates" ]; then
          for tpl in $bundle_templates; do
            local tpl_path="$SCRIPT_DIR/templates/$tpl"
            if [ -f "$tpl_path" ]; then
              cp "$tpl_path" "$dest_dir/assets/templates/"
            fi
          done
          echo "    templates: selective ($(echo $bundle_templates | wc -w | tr -d ' ') files)"
        else
          cp -r "$SCRIPT_DIR/templates"/* "$dest_dir/assets/templates/"
          echo "    templates: all (no manifest)"
        fi
      fi
      
      # Always bundle schemas (small, universally needed)
      if [ -d "$SCRIPT_DIR/schemas" ]; then
        mkdir -p "$dest_dir/assets/schemas"
        cp -r "$SCRIPT_DIR/schemas"/* "$dest_dir/assets/schemas/"
      fi
      
      # Bundle only declared standards (or all if no manifest found)
      if [ -d "$SCRIPT_DIR/standards" ]; then
        mkdir -p "$dest_dir/references"
        if [ -n "$bundle_standards" ]; then
          for std in $bundle_standards; do
            local std_path="$SCRIPT_DIR/standards/$std"
            if [ -f "$std_path" ]; then
              cp "$std_path" "$dest_dir/references/"
            fi
          done
          echo "    standards: selective ($(echo $bundle_standards | wc -w | tr -d ' ') files)"
        else
          # No manifest — copy all top-level standards (skip reference/ subdirectory)
          find "$SCRIPT_DIR/standards" -maxdepth 1 -type f -exec cp {} "$dest_dir/references/" \;
          echo "    standards: all top-level (no manifest)"
        fi
      fi
    fi
  done
}

write_boot_file() {
  local path="$1"
  local content="$2"

  mkdir -p "$(dirname "$path")"
  if [ ! -f "$path" ]; then
    echo "$content" > "$path"
    echo "  + $(basename "$path") (created)"
  else
    echo "  - $(basename "$path") (already exists, skipped)"
  fi
}

copy_workflow() {
  local workflow_file="$1"
  local target_dir="$2"
  local name
  name="$(basename "$workflow_file" .md)"
  local dest_file="$target_dir/${name}.md"

  mkdir -p "$target_dir"
  cp "$workflow_file" "$dest_file"
  echo "  + workflows/${name}.md"
}

activate_guardrails() {
  echo ""
  echo "  Activating Planifest Git Guardrails"

  # Point Git to the version-controlled hooks directory
  git config core.hooksPath planifest-framework/hooks
  echo "  + git config core.hooksPath planifest-framework/hooks"

  # Ensure hook scripts are executable (critical for Unix systems)
  chmod +x "$SCRIPT_DIR/hooks/pre-commit"
  chmod +x "$SCRIPT_DIR/hooks/pre-push"
  echo "  + hooks/pre-commit (executable)"
  echo "  + hooks/pre-push (executable)"

  # Deploy the CI/CD pipeline workflow
  local github_workflows="$PROJECT_ROOT/.github/workflows"
  local workflow_src="$SCRIPT_DIR/hooks/planifest.yml"
  if [ -f "$workflow_src" ]; then
    mkdir -p "$github_workflows"
    if [ ! -f "$github_workflows/planifest.yml" ]; then
      cp "$workflow_src" "$github_workflows/planifest.yml"
      echo "  + .github/workflows/planifest.yml (created)"
    else
      echo "  - .github/workflows/planifest.yml (already exists, skipped)"
    fi
  fi

  # Deploy .gitattributes to enforce LF endings on hook scripts
  # Without this, Git for Windows re-adds CRLF on checkout, breaking the bash shebang.
  local gitattributes_src="$SCRIPT_DIR/.gitattributes"
  local gitattributes_dest="$PROJECT_ROOT/.gitattributes"
  if [ -f "$gitattributes_src" ]; then
    if [ ! -f "$gitattributes_dest" ]; then
      cp "$gitattributes_src" "$gitattributes_dest"
      echo "  + .gitattributes (created — enforces LF on hook scripts)"
    else
      echo "  - .gitattributes (already exists, skipped)"
    fi
  fi

  echo "  ✅ Git guardrails activated."
}

initialize_repo() {
  echo ""
  echo "  Initializing Repository Structure"

  local gitignore_src="$SCRIPT_DIR/.gitignore"
  local gitignore_dest="$PROJECT_ROOT/.gitignore"
  
  if [ -f "$gitignore_src" ]; then
    if [ ! -f "$gitignore_dest" ]; then
      cp "$gitignore_src" "$gitignore_dest"
      echo "  + .gitignore (copied)"
    else
      echo "  - .gitignore (already exists at root, skipped)"
    fi
  else
    echo "  ! Warning: .gitignore not found in framework directory ($gitignore_src)"
  fi

  local src_dir="$PROJECT_ROOT/src"
  if [ ! -d "$src_dir" ]; then
    mkdir -p "$src_dir"
    echo "  + src/ (created)"
  fi
  
  if [ ! -f "$src_dir/README.md" ]; then
    cat << 'EOF' > "$src_dir/README.md"
# src/

Components live here. Each component is a subfolder with a `component.yml` manifest.

See [planifest/spec/initiative-structure.md](../planifest/spec/initiative-structure.md) for the canonical layout.
EOF
    echo "  + src/README.md (created)"
  fi

  local plan_dir="$PROJECT_ROOT/plan"
  if [ ! -d "$plan_dir" ]; then
    mkdir -p "$plan_dir"
    echo "  + plan/ (created)"
  fi

  if [ ! -f "$plan_dir/README.md" ]; then
    cat << 'EOF' > "$plan_dir/README.md"
# plan/

Initiative specifications live here. Each initiative gets a subfolder.

See [plan/initiative-structure.md](initiative-structure.md) for the canonical layout.
EOF
    echo "  + plan/README.md (created)"
  fi

  if [ ! -f "$plan_dir/initiative-structure.md" ]; then
    cat << 'EOF' > "$plan_dir/initiative-structure.md"
# Planifest â€” Repository Structure

> The canonical layout for a Planifest-managed repository. Three top-level folders, three concerns.

---

## The Three Folders

```
repo/
â”œâ”€â”€ planifest-framework/        â† The framework (skills, templates, schemas, standards)
â”‚                                 Drop this in. Don't modify it per-project.
â”‚
â”œâ”€â”€ plan/                       â† The specifications (organized by initiative)
â”‚                                 Plans, briefs, specs, ADRs, risk, scope, glossary.
â”‚                                 Everything that describes WHAT to build and WHY.
â”‚
â””â”€â”€ src/                        â† The code (organized by component)
                                  Implementation, tests, config, manifests.
                                  Everything that IS the built thing.
```

---

## `planifest-framework/` â€” The Framework

This folder is the Planifest framework itself. It is the same across every project. You do not modify it per-initiative â€” you update it when the framework evolves.

```
planifest/
â”œâ”€â”€ skills/           â† Agent instructions (orchestrator + phase skills)
â”œâ”€â”€ templates/        â† File format templates for every artifact
â”œâ”€â”€ schemas/          â† JSON Schema validation definitions
â”œâ”€â”€ standards/        â† Code quality standards
â””â”€â”€ spec/             â† This file â€” the canonical structure definition
```

---

## `plan/` â€” The Plan/Specifications

Organized by initiative. Each initiative gets a subfolder. This is where humans write briefs and agents write specs. No code lives here.

```
plan/
â””â”€â”€ {initiative-id}/
    â”œâ”€â”€ initiative-brief.md          â† Human input (start here)
    â”œâ”€â”€ design.md                 â† Validated plan (orchestrator output)
    â”œâ”€â”€ pipeline-run.md              â† Audit trail (per run)
    â”œâ”€â”€ pipeline-run-phase-2.md      â† Phase 2 audit (if phased)
    â”‚
    â”œâ”€â”€ design-spec.md               â† Functional & non-functional requirements
    â”œâ”€â”€ design-spec-phase-2.md       â† Phase 2 spec (if phased)
    â”œâ”€â”€ openapi-spec.yaml            â† API contract
    â”œâ”€â”€ scope.md                     â† In / Out / Deferred
    â”œâ”€â”€ risk-register.md             â† Risk items with likelihood & impact
    â”œâ”€â”€ domain-glossary.md           â† Ubiquitous language
    â”œâ”€â”€ security-report.md           â† Security review findings
    â”œâ”€â”€ quirks.md                    â† Quirks and workarounds
    â”œâ”€â”€ recommendations.md           â† Improvement suggestions
    â”‚
    â””â”€â”€ adr/
        â”œâ”€â”€ ADR-001-{title}.md       â† Architecture decision records
        â”œâ”€â”€ ADR-002-{title}.md
        â””â”€â”€ ...
```

### Path Rules â€” plan/

1. **Initiative ID** follows the format `{0000000}-{kebab-case-name}` — a 7-digit zero-padded number prefix for chronological ordering, followed by a human-chosen kebab-case name.
2. **No nesting** â€” specs, ADRs, and supporting docs are flat within the initiative folder. One level of subfolders only (adr/).
3. **No code** â€” nothing executable lives in `plan/`. If it runs, it belongs in `src/`.
4. **Phased initiatives** append the phase number: `design-spec-phase-2.md`, `pipeline-run-phase-2.md`. The `design.md` is updated per phase, not duplicated.
5. **ADRs** are numbered sequentially. Never renumber. Superseded ADRs stay with `status: superseded`.

---

## `src/` â€” The Code

Organized by component. Each component is a subfolder at the top level of `src/`. The component manifest lives with the code, not with the plan.

```
src/
â””â”€â”€ {component-id}/
    â”œâ”€â”€ component.yml               â† Component manifest (from template)
    â”œâ”€â”€ package.json                  â† (or equivalent for the stack)
    â”‚
    â”œâ”€â”€ src/                          â† Implementation (structure varies by stack)
    â”‚   â””â”€â”€ ...
    â”‚
    â”œâ”€â”€ tests/                        â† Tests
    â”‚   â””â”€â”€ ...
    â”‚
    â””â”€â”€ docs/
        â”œâ”€â”€ data-contract.md          â† Schema ownership & invariants
        â””â”€â”€ migrations/
            â””â”€â”€ proposed-{desc}.md    â† Migration proposals
```

### Path Rules â€” src/

1. **Component ID** is kebab-case, matches the `id` in `component.yml`.
2. **component.yml is mandatory** â€” every component has one. Read it before any work; update it after every build.
3. **Component-specific docs** live with the component at `src/{component-id}/docs/`. These describe the component's data contract, migrations, and technical specifics.
4. **Initiative-level docs** live in `plan/`. The component's `component.yml` references the initiative via the `initiative` field.
5. **Existing components** that predate Planifest are retrofitted by adding a `component.yml` at their root.

---

## How the Three Folders Connect

```
plan/current/design.md
    â””â”€â”€ lists component IDs â†’ src/{component-id}/component.yml
                                    â””â”€â”€ references initiative â†’ plan/

plan/current/design-spec.md
    â””â”€â”€ functional requirements â†’ implemented in â†’ src/{component-id}/src/

plan/current/adr/ADR-001-*.md
    â””â”€â”€ decisions â†’ followed by â†’ src/{component-id}/src/

plan/current/openapi-spec.yaml
    â””â”€â”€ API contract â†’ implemented in â†’ src/{component-id}/src/
```

The relationship is bidirectional:
- `design.md` lists all component IDs
- Each `component.yml` references its initiative ID
- The plan describes WHAT; the code IS the WHAT

---

## Retrofit â€” Adding Planifest to an Existing Repo

If the repo already has code:

1. Drop `planifest/` into the repo root
2. Create `plan/` for the first initiative
3. Move existing components under `src/` (or leave them if they're already there)
4. Add a `component.yml` to each existing component
5. The orchestrator's retrofit mode will read the codebase and infer the existing architecture

---

*Templates for each file are in [planifest/templates/](../templates/). Skills reference these paths.*
EOF
    echo "  + plan/initiative-structure.md (created)"
  fi

  # Add tool ignore rules to keep context windows lean
  local ignore_content="
# Planifest - Token Reduction (keeps agent semantic search from bloating context)
plan/_archive/
node_modules/
dist/
build/
out/
.next/
"
  for ignore_file in ".cursorignore" ".claudeignore" ".windsurfignore" ".clineignore"; do
    if [ ! -f "$PROJECT_ROOT/$ignore_file" ]; then
      echo "$ignore_content" > "$PROJECT_ROOT/$ignore_file"
      echo "  + $ignore_file (created)"
    elif ! grep -q "Planifest - Token Reduction" "$PROJECT_ROOT/$ignore_file"; then
      echo "$ignore_content" >> "$PROJECT_ROOT/$ignore_file"
      echo "  + $ignore_file (appended Planifest ignore rules)"
    fi
  done

  # Deploy .cursorindexingignore — excludes large reference docs from semantic
  # search indexing but keeps them accessible via explicit @ mention
  local indexing_ignore_content="
# Planifest - Indexing Exclusions (files accessible via @ mention but excluded from search)
*-evaluation.md
*-guide.md
tool-setup-reference.md
getting-started.md
"
  local indexing_ignore_file="$PROJECT_ROOT/.cursorindexingignore"
  if [ ! -f "$indexing_ignore_file" ]; then
    echo "$indexing_ignore_content" > "$indexing_ignore_file"
    echo "  + .cursorindexingignore (created)"
  elif ! grep -q "Planifest - Indexing Exclusions" "$indexing_ignore_file"; then
    echo "$indexing_ignore_content" >> "$indexing_ignore_file"
    echo "  + .cursorindexingignore (appended Planifest rules)"
  fi
}

setup_tool() {
  local tool="$1"
  local tool_config="$SETUP_DIR/${tool}.sh"

  if [ ! -f "$tool_config" ]; then
    echo "Error: no config file at setup/${tool}.sh"
    exit 1
  fi

  # Load tool-specific config
  source "$tool_config"

  local skills_dir="$PROJECT_ROOT/$TOOL_SKILLS_DIR"

  echo ""
  echo "  Setting up $tool"
  echo "  Skills directory: $TOOL_SKILLS_DIR/"

  # Copy skills (now automatically bundles supporting files)
  copy_skills "$skills_dir"

  # Copy workflows (if tool defines a workflow dir)
  if [ -n "${TOOL_WORKFLOWS_DIR:-}" ] && [ -d "$WORKFLOWS_SRC" ]; then
    local workflows_dir="$PROJECT_ROOT/$TOOL_WORKFLOWS_DIR"
    for wf in "$WORKFLOWS_SRC"/*.md; do
      [ -f "$wf" ] && copy_workflow "$wf" "$workflows_dir"
    done
  fi

  # Create boot file (if tool defines one)
  if [ -n "${TOOL_BOOT_FILE:-}" ]; then
    if [ -z "${TOOL_BOOT_CONTENT:-}" ] && [ -n "${TOOL_BOOT_TEMPLATE:-}" ]; then
      TOOL_BOOT_CONTENT=$(cat "$SCRIPT_DIR/../$TOOL_BOOT_TEMPLATE")
    fi
    write_boot_file "$PROJECT_ROOT/$TOOL_BOOT_FILE" "$TOOL_BOOT_CONTENT"
  fi

  echo "  Done."
}

# --- Main ---

TOOL="${1:-}"

if [ -z "$TOOL" ]; then
  echo ""
  echo "Planifest Setup"
  echo ""
  echo "Usage: ./planifest-framework/setup.sh <tool>"
  echo ""
  echo "Tools:"
  for t in $VALID_TOOLS; do
    echo "  $t"
  done
  echo "  all"
  echo ""
  echo "Run from the repository root."
  echo "Each tool's config: planifest-framework/setup/<tool>.sh"
  exit 0
fi

echo "Planifest Setup"
echo "â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•"

initialize_repo
activate_guardrails

if [ "$TOOL" = "all" ]; then
  for t in $VALID_TOOLS; do
    setup_tool "$t"
  done
elif echo "$VALID_TOOLS" | grep -qw "$TOOL"; then
  setup_tool "$TOOL"
else
  echo "Unknown tool: $TOOL"
  echo "Valid tools: $VALID_TOOLS, all"
  exit 1
fi

echo ""
echo "Setup complete."
echo "  Source of truth: planifest-framework/"
echo "  Re-run after updating framework files."
