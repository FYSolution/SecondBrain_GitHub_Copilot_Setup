# Second Brain for GitHub Copilot

A persistent, AI-maintained project wiki system that turns GitHub Copilot into a knowledge-compounding partner. Drop it into any repository and every coding session automatically captures, organizes, and surfaces project knowledge — so nothing learned is ever lost.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

## The Problem

LLM-assisted coding sessions are **ephemeral** — insights, design decisions, and domain knowledge discovered during a session vanish when the chat closes. Teams re-explain the same context, re-discover the same patterns, and make the same mistakes across sessions.

## The Solution

**Second Brain** is a structured wiki that lives alongside your code. It is automatically maintained by GitHub Copilot (or any LLM agent) using a defined schema. Every task completion triggers wiki updates — no manual documentation effort required.

```
┌──────────────┐     ┌───────────────────┐     ┌───────────────────┐
│  Developer   │     │  GitHub Copilot   │     │  Second Brain     │
│              │────▶│                   │────▶│  (wiki/)          │
│ • Code       │     │ • Reads wiki at   │     │ • entities/       │
│ • Design     │     │   session start   │     │ • concepts/       │
│ • Review     │     │ • Answers from    │     │ • sources/        │
│ • Drop docs  │     │   wiki first      │     │ • analysis/       │
│              │     │ • Auto-updates    │     │ • lessons.md      │
│              │     │   after each task  │     │ • journal/{user}/ │
└──────────────┘     └───────────────────┘     └───────────────────┘
```

**Result:** Every session makes the next one better. Knowledge compounds instead of evaporating.

---

## Features

- **Zero-effort documentation** — Copilot auto-updates the wiki after every task
- **Wiki-first answers** — Copilot consults the wiki before diving into code searches
- **Source ingestion** — Drop requirements, design docs, or meeting notes into `raw/` and they're synthesized into the wiki
- **Team-safe** — Per-user logs and journals prevent merge conflicts in multi-developer teams
- **Contradiction detection** — New information is checked against existing knowledge
- **Obsidian-compatible** — Plain markdown with wikilinks; works as an Obsidian vault out of the box
- **Karpathy Guidelines integration** — Pairs with a behavioral ruleset that enforces disciplined AI coding practices

---

## Quick Start

### 1. Copy into your repo

```bash
# Clone this template
git clone https://github.com/FYSolution/SecondBrain_GitHub_Copilot_Setup.git

# Copy the Second_Brain folder into your project
cp -r SecondBrain_GitHub_Copilot_Setup/Second_Brain /path/to/your-project/
```

### 2. Configure your Copilot instructions

Add to your `.github/copilot-instructions.md` (or create one):

```markdown
## Second Brain

At session start, read `Second_Brain/wiki/index.md` for full project context.
After every task that modifies code or produces reusable knowledge:

1. Write a code-update report to `Second_Brain/raw/code-updates/`
2. Update your daily journal at `Second_Brain/wiki/journal/{user}/`
3. Update relevant entity/concept pages in the wiki
4. Append to your operation log at `Second_Brain/wiki/log/{user}/`
5. Regenerate the index via `Second_Brain/scripts/generate-index.ps1`
```

### 3. Set your username

```bash
# Option A: environment variable
export SECOND_BRAIN_USER=yourname

# Option B: falls back to git user.name (lowercase, no spaces)
git config user.name  # "Jane Smith" → "janesmith"
```

### 4. Populate the `raw/` folder with your project documents

Gather all existing project knowledge and convert/copy them as markdown files into the appropriate `raw/` subfolders:

```
Second_Brain/raw/
├── requirements/       ← Business requirements, user stories, specs
├── design/             ← Architecture docs, ERDs, API contracts
├── decisions/          ← Meeting notes, ADRs, client feedback
├── analysis/           ← Security audits, performance reports
└── architecture/       ← Solution diagrams, service inventories
```

**Tips:**

- Convert Word/PDF docs to `.md` (use Pandoc: `pandoc input.docx -o output.md`)
- Name files descriptively: `BR001-claims-submission.md`, `ADR-003-auth-strategy.md`
- Include everything the AI should know — requirements, workflows, domain rules, past decisions
- These files are **immutable** once added — the LLM reads but never modifies them

### 5. Bootstrap the wiki — Initial scan with Agent Mode

Open VS Code **Agent Mode** chat (Ctrl+Shift+I or click the Copilot chat icon → select "Agent"), choose a capable model (e.g., **Claude Opus 4.6** or **GPT-4o**), then run this initialization prompt:

```
Scan the entire source code repository and all documents in Second_Brain/raw/ folder.
Based on the SCHEMA defined in Second_Brain/SCHEMA.md, initialize the Second Brain wiki:

1. Read Second_Brain/SCHEMA.md to understand the wiki structure and rules
2. Scan all files in Second_Brain/raw/ — summarize each into wiki/sources/
3. Scan the source code — create entity pages in wiki/entities/ for each
   major service, module, or component
4. Identify cross-cutting patterns and create pages in wiki/concepts/
5. Write wiki/overview.md with the full project architecture synthesis
6. Write wiki/lessons.md with any constraints or rules found in the docs
7. Synthesize requirements status into wiki/requirements/
8. Generate wiki/index.md by running: pwsh Second_Brain/scripts/generate-index.ps1

Use proper YAML frontmatter on each wiki page (created, updated, sources, tags).
Add inline citations [↗ raw/path/to/source.md] linking back to raw sources.
```

> **Why Agent Mode?** Agent Mode allows Copilot to autonomously read multiple files, create pages, and run scripts — exactly what's needed for a full wiki bootstrap. A single chat message won't have enough context window for the entire codebase.

> **Model recommendation:** Use the most capable model available (Claude Opus 4.6, GPT-4o, or similar) for the initial bootstrap. The scan needs strong reasoning to synthesize architecture and identify patterns across many files.

### 6. Verify and start coding

After the bootstrap completes:

```powershell
# Check the generated wiki structure
Get-ChildItem Second_Brain/wiki/ -Recurse -Filter *.md | Measure-Object
# → Should show multiple pages across entities/, concepts/, sources/

# Verify the index was generated
cat Second_Brain/wiki/index.md

# Optional: lint the wiki for completeness
# (In Copilot chat) "lint wiki"
```

From this point forward, open any Copilot chat and it will automatically load wiki context and maintain it after every task.

---

## Architecture

| Layer       | Path        | Owner  | Purpose                                            |
| ----------- | ----------- | ------ | -------------------------------------------------- |
| **Schema**  | `SCHEMA.md` | Team   | Rules governing how the LLM maintains the wiki     |
| **Raw**     | `raw/`      | Human  | Immutable source documents (requirements, designs) |
| **Wiki**    | `wiki/`     | LLM(s) | Synthesized, cross-referenced knowledge pages      |
| **Scripts** | `scripts/`  | Team   | Automation helpers (index generation, log merging) |

### Directory Structure

```
Second_Brain/
├── SCHEMA.md                    # Operating rules for the LLM
├── SECOND-BRAIN-USAGE-GUIDE.md  # Detailed usage documentation
├── KARPATHY-GUIDELINES-GUIDE.md # Companion coding discipline guide
├── raw/                         # Human-owned, immutable sources
│   ├── requirements/            # Business requirement docs
│   ├── design/                  # Architecture & design decisions
│   ├── decisions/               # Meeting notes, client feedback
│   ├── analysis/                # Security scans, performance reports
│   ├── architecture/            # Solution structure snapshots
│   ├── code-updates/            # Per-session code change reports
│   └── sessions/                # Chat transcripts / session notes
├── wiki/                        # LLM-maintained knowledge pages
│   ├── index.md                 # Auto-generated catalog
│   ├── overview.md              # Project architecture synthesis
│   ├── lessons.md               # Accumulated corrections & rules
│   ├── entities/                # One page per service/component
│   ├── concepts/                # One page per cross-cutting pattern
│   ├── sources/                 # Summary page per ingested raw doc
│   ├── analysis/                # Promoted query answers & syntheses
│   ├── requirements/            # Synthesized BR status & changelog
│   ├── journal/{user}/          # Per-user daily session summaries
│   └── log/{user}/              # Per-user append-only operation log
└── scripts/
    ├── generate-index.ps1       # Rebuild wiki/index.md
    ├── merge-logs.ps1           # Combine per-user logs into timeline
    └── search-wiki.ps1          # Full-text search across the wiki
```

---

## How It Works

### Automated Behaviors

| Trigger             | What Happens                                                                               |
| ------------------- | ------------------------------------------------------------------------------------------ |
| **Session start**   | Copilot reads `wiki/index.md`, loads your recent log, detects new raw sources              |
| **Task completion** | Wiki log + journal + entity pages updated automatically                                    |
| **Document drop**   | Files in `raw/` are detected and offered for ingestion into wiki                           |
| **Query**           | Wiki is searched first; answers are cited; novel synthesis is promoted to `wiki/analysis/` |

### Commands

| Command           | Effect                                             |
| ----------------- | -------------------------------------------------- |
| `"ingest [path]"` | Process a raw source into the wiki                 |
| `"lint wiki"`     | Health-check: stale pages, orphans, contradictions |
| `"update wiki"`   | Force a wiki update for the current session        |
| `"wrap up"`       | Finalize session — write journal + log entries     |

---

## Karpathy Guidelines (Companion System)

The Second Brain pairs with the **Karpathy Guidelines** — a behavioral ruleset that prevents common LLM coding mistakes:

| Principle                 | Effect                                       |
| ------------------------- | -------------------------------------------- |
| **Think Before Coding**   | Check the wiki before writing business logic |
| **Simplicity First**      | Minimum code that solves the problem         |
| **Surgical Changes**      | Touch only what's necessary                  |
| **Goal-Driven Execution** | Task isn't done until wiki is updated        |

Together they create a feedback loop: the guidelines enforce wiki consultation and updates, while the wiki provides the knowledge that makes the guidelines effective.

See [KARPATHY-GUIDELINES-GUIDE.md](Second_Brain/KARPATHY-GUIDELINES-GUIDE.md) for full details.

---

## Wiki-Aware Planner (`@second_brain_planner`)

This repo includes a custom **Agent Mode agent** that replaces VS Code's default Plan mode with a wiki-first planning workflow.

### What It Does

The `@second_brain_planner` agent researches thoroughly before proposing — consulting the Second Brain wiki first, then code, then producing a structured implementation plan. It **never edits files directly** — it only proposes.

| Default Plan Mode                  | `@second_brain_planner`                                                                   |
| ---------------------------------- | ----------------------------------------------------------------------------------------- |
| Jumps straight to code exploration | Reads wiki first for existing knowledge                                                   |
| No awareness of project history    | Checks `lessons.md` for known pitfalls                                                    |
| Generic planning structure         | Produces implementation-ready plans with file manifests, risk areas, and testing strategy |
| Knowledge stays in chat            | Updates wiki with new knowledge discovered during planning                                |

### How to Use It

**Option A: Invoke directly in Agent Mode**

In VS Code, open Copilot Chat → switch to **Agent Mode** → type:

```
@second_brain_planner How should we implement the notification service for claim status changes?
```

**Option B: Built-in Plan mode (auto-redirects)**

The `.github/copilot-instructions.md` configures built-in Plan mode to follow the same wiki-first workflow automatically. Just use Plan mode as normal — it will consult the wiki.

### The Planning Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│  Phase 1: Context Gathering (Wiki-First)                         │
│  ─────────────────────────────────────────                       │
│  1. Read wiki/index.md → identify relevant pages                 │
│  2. Read wiki/lessons.md → known pitfalls                        │
│  3. Read relevant entities/ and concepts/ pages                  │
│  4. Present wiki-based context to user                           │
│  5. THEN explore code for details not in wiki                    │
├─────────────────────────────────────────────────────────────────┤
│  Phase 2: Analysis & Design                                      │
│  ─────────────────────────────                                   │
│  • Cross-reference patterns in wiki/concepts/                    │
│  • Present multiple approaches with pros/cons                    │
│  • Surface tradeoffs explicitly                                  │
├─────────────────────────────────────────────────────────────────┤
│  Phase 3: Structured Plan (The Proposal)                         │
│  ─────────────────────────────────────────                       │
│  • Summary — what changes and why                                │
│  • Numbered implementation steps                                 │
│  • File manifest (create/modify/delete)                          │
│  • Dependencies between steps                                    │
│  • Testing strategy                                              │
│  • Risk areas and mitigations                                    │
├─────────────────────────────────────────────────────────────────┤
│  Phase 4: User Decision                                          │
│  ──────────────────────────                                      │
│  → User approves → switch to Agent Mode to implement             │
│  → User modifies → planner revises                               │
│  → Wiki updated with new knowledge from planning                 │
└─────────────────────────────────────────────────────────────────┘
```

### Setup

The agent file lives at `.github/agents/second_brain_planner.agent.md` — it's included in this repo. No extra configuration needed. Once the `.github/` folder is in your project, VS Code Copilot automatically discovers the agent.

### When to Use the Planner

- Planning a new feature or module
- Investigating a bug before fixing
- Architecture exploration or refactoring decisions
- Comparing implementation approaches
- Any task where you want to **think first, implement second**

---

## Multi-Developer Usage

The system is designed for teams:

- **Per-user files** (`journal/{user}/`, `log/{user}/`, `raw/code-updates/{user}-*.md`) prevent merge conflicts
- **Shared pages** (entities, concepts) use additive edits to minimize conflict surface
- **Auto-generated index** is rebuilt by script, never hand-edited
- **Standard git workflow** — PRs resolve the rare conflicts on shared synthesis pages

---

## Obsidian Integration

The wiki is plain markdown and works as an [Obsidian](https://obsidian.md) vault:

1. Set vault root to `Second_Brain/`
2. Set attachment folder to `raw/assets/`
3. Use Graph View to visualize wiki structure
4. Use Dataview plugin to query YAML frontmatter
5. Use Web Clipper to save articles directly into `raw/`

---

## Scripts

| Script               | Purpose                                       | Usage                                  |
| -------------------- | --------------------------------------------- | -------------------------------------- |
| `generate-index.ps1` | Rebuild `wiki/index.md` from all wiki pages   | `pwsh scripts/generate-index.ps1`      |
| `merge-logs.ps1`     | Combine per-user logs into chronological view | `pwsh scripts/merge-logs.ps1 -Tail 20` |
| `search-wiki.ps1`    | Full-text search across wiki content          | `pwsh scripts/search-wiki.ps1 "query"` |

---

## Requirements

- **VS Code** with GitHub Copilot extension
- **PowerShell 7+** (for scripts)
- Git (for username fallback and version control)

---

## License

[MIT](LICENSE) — Felix Yang, 2026
