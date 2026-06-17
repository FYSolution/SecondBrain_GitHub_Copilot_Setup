# Second Brain for GitHub Copilot

A persistent, AI-maintained project wiki system that turns GitHub Copilot into a knowledge-compounding partner. Drop it into any repository and every coding session automatically captures, organizes, and surfaces project knowledge — so nothing learned is ever lost.

**Zero merge conflicts guaranteed** — the fragment-based architecture makes it structurally impossible for team members to conflict, even with frequent concurrent commits.

---

## The Problem

LLM-assisted coding sessions are **ephemeral** — insights, design decisions, and domain knowledge discovered during a session vanish when the chat closes. Teams re-explain the same context, re-discover the same patterns, and make the same mistakes across sessions.

Traditional shared wiki designs (where multiple developers edit the same files) create constant **merge conflicts** — blocking CI pipelines, wasting developer time on manual resolution, and discouraging wiki updates entirely.

## The Solution

The Second Brain uses an **atomic fragment architecture** — each developer writes knowledge as immutable fragments to their own folder. An AI synthesis layer intelligently combines all fragments into coherent project understanding at read-time.

```
┌──────────────┐     ┌───────────────────────┐     ┌─────────────────────────┐
│  Developer   │     │  GitHub Copilot       │     │  Second Brain           │
│              │────▶│                       │────▶│                         │
│ • Code       │     │ • Compiles fragments  │     │  COMMITTED (shared):    │
│ • Design     │     │   at session start    │     │  fragments/{user}/      │
│ • Review     │     │ • Synthesizes AI      │     │  log/{user}/            │
│ • Drop docs  │     │   understanding       │     │  journal/{user}/        │
│              │     │ • Writes new          │     │                         │
│              │     │   fragments after     │     │  GITIGNORED (local):    │
│              │     │   each task           │     │  .compiled/             │
└──────────────┘     └───────────────────────┘     └─────────────────────────┘
```

**Result:** Every session makes the next one better. Knowledge compounds without conflicts.

---

## Features

- **Zero merge conflicts** — Each developer writes only to their own folder; conflicts are structurally impossible
- **AI synthesis, not concatenation** — LLM intelligently combines knowledge from all developers with priority/recency/provenance reasoning
- **Zero-effort documentation** — Copilot writes fragments after every task automatically
- **Wiki-first answers** — Copilot consults synthesized knowledge before diving into code
- **Source ingestion** — Drop requirements, design docs, or meeting notes into `raw/` and they're captured as fragments
- **Synthesis caching** — AI synthesis is committed as a fragment, shared via Git, never repeated unnecessarily
- **Contradiction detection** — Conflicting fragments from different developers are flagged and resolved
- **Knowledge history** — Fragments are immutable after commit; full evolution is traceable
- **Obsidian-compatible** — Plain markdown with wikilinks; works as an Obsidian vault
- **Karpathy Guidelines integration** — Pairs with a behavioral ruleset for disciplined AI coding

---

## Architecture

### Knowledge Pipeline — Three Stages

Understanding the Second Brain requires knowing three distinct concepts and how they connect:

```
┌─────────────────────┐    compile-wiki.ps1    ┌──────────────────────┐
│  1. FRAGMENTS       │ ─────────────────────▶ │  2. .COMPILED WIKI   │
│  (Source of Truth)   │   mechanical grouping  │  (Mechanical Assembly)│
│                     │                        │                      │
│  wiki/fragments/    │                        │  wiki/.compiled/     │
│  Per-user, immutable│                        │  Gitignored, local   │
│  Committed to git   │                        │  Sorted & formatted  │
└─────────────────────┘                        └──────────────────────┘
         │                                                │
         │  LLM reads fragments directly                  │  provides manifest
         │  (using manifest as a map)                     │  & index as guide
         ▼                                                ▼
┌────────────────────────────────────────────────────────────────────┐
│                    3. AI SYNTHESIS                                  │
│                  (Intelligent Understanding)                       │
│                                                                    │
│  • Resolves contradictions      • Determines current truth         │
│  • Considers authorship/recency • Detects staleness                │
│  • Produces coherent narratives • Optionally writes back as        │
│                                   type: synthesis fragment         │
└────────────────────────────────────────────────────────────────────┘
```

| Aspect               | Fragments                   | `.compiled` Wiki                             | AI Synthesis                                       |
| -------------------- | --------------------------- | -------------------------------------------- | -------------------------------------------------- |
| **Nature**           | Individual knowledge atoms  | Mechanically assembled pages                 | Intelligent understanding                          |
| **Intelligence**     | None (just data)            | None (just sorting/grouping)                 | **Yes** — resolves conflicts, infers current truth |
| **Committed to git** | Yes                         | No (gitignored)                              | Yes, if persisted as `type: synthesis` fragment    |
| **Created by**       | LLM after tasks             | PowerShell script                            | LLM at session start / on query                    |
| **Purpose**          | Store knowledge permanently | Provide a navigable index for humans and LLM | Produce correct, coherent understanding for coding |
| **Analogy**          | Individual Lego bricks      | Bricks sorted into labeled bins              | A finished model built from the bricks             |

**In short:** Fragments are the **source of truth**. `.compiled` is a **table of contents** that organizes them mechanically. AI Synthesis is the **actual understanding** the LLM builds by reading fragments intelligently — and it can save that understanding back as a new synthesis fragment so future sessions don't redo the work.

---

### How Fragments Work

Every piece of knowledge is stored as an **atomic fragment** — a small markdown file with YAML frontmatter declaring its type, target, and merge strategy:

```markdown
---
type: entity
target: auth-service
section: token-management
created: 2026-06-14T09:30
author: fyang
action: replace
sources: [raw/design/auth-v3.md]
tags: [authentication, jwt]
---

JWT expiry set to 30 minutes. Refresh token rotation enabled.
Tokens stored in HttpOnly cookies to prevent XSS access.
```

Fragments are **immutable after commit** — to update knowledge, you create a new fragment (not edit the old one). The LLM determines current truth by timestamp, action type, and provenance.

### Zero-Conflict Guarantee

| Content Type        | Path                           | Conflict Risk                     |
| ------------------- | ------------------------------ | --------------------------------- |
| Knowledge fragments | `wiki/fragments/{user}/`       | **Impossible** — per-user folders |
| Operation logs      | `wiki/log/{user}/`             | **Impossible** — per-user folders |
| Daily journals      | `wiki/journal/{user}/`         | **Impossible** — per-user folders |
| Code-update reports | `raw/code-updates/{user}-*.md` | **Impossible** — per-user files   |
| Raw sources         | `raw/`                         | **None** — immutable after add    |
| Compiled output     | `wiki/.compiled/`              | **None** — gitignored             |

### AI Synthesis (Not Dumb Concatenation)

When the LLM reads fragments at session start, it applies intelligent synthesis:

1. **Sorts by timestamp** — newest first
2. **Applies action rules** — `correct` > `replace` > `append`
3. **Checks provenance** — fragments citing raw source docs have higher confidence
4. **Detects conflicts** — same target+section from different authors flagged
5. **Builds timeline** — tracks how knowledge evolved
6. **Persists synthesis** — writes a `type: synthesis` fragment so future sessions don't re-derive

Synthesis is committed to Git like any other fragment. Once one developer's LLM synthesizes, all other developers get it on `git pull` — no repeated work.

### Action Rules — How Compilation Decides What to Show

Each fragment declares an `action` field in its YAML frontmatter. This tells the compile script how to display that fragment relative to other fragments for the same target.

**How the action is determined (two levels):**

1. **Explicit declaration** — The LLM sets `action:` in the frontmatter when creating the fragment:

   ```yaml
   action: replace # ← LLM chose this based on the knowledge type
   ```

2. **Default fallback** — If `action:` is omitted, the compile script assigns a default based on `type:`:

   | Fragment `type` | Default `action` | Reasoning                                            |
   | --------------- | ---------------- | ---------------------------------------------------- |
   | `entity`        | `replace`        | You want the latest state, not all historical states |
   | `concept`       | `replace`        | Latest understanding supersedes older                |
   | `source`        | `replace`        | Latest document summary wins                         |
   | `overview`      | `replace`        | Latest project overview wins                         |
   | `synthesis`     | `replace`        | Latest AI synthesis wins                             |
   | `lesson`        | `append`         | Every lesson is valuable — never discard             |
   | `decision`      | `append`         | Decision history matters — never discard             |
   | `analysis`      | `append`         | Investigation results accumulate                     |

**How the compile script applies the rules:**

For each target+section group, the script separates fragments by action and renders them in this order:

| Action    | Display Rule                           | Visual Treatment                                          |
| --------- | -------------------------------------- | --------------------------------------------------------- |
| `correct` | **Shown first, prominently**           | Blockquote with ⚠️ warning icon — impossible to miss      |
| `replace` | **Latest only shown as current truth** | Older versions collapsed in a `<details>` history block   |
| `append`  | **All shown, newest first**            | Each displayed with timestamp and author — nothing hidden |

**Concrete walkthrough — 4 fragments targeting `auth-service` / section `token-management`:**

| #   | Created | Author | Action    | Content                             |
| --- | ------- | ------ | --------- | ----------------------------------- |
| 1   | June 10 | fyang  | `replace` | "JWT expiry: 30 min"                |
| 2   | June 12 | fyang  | `replace` | "JWT expiry: 20 min"                |
| 3   | June 14 | jsmith | `correct` | "CORRECTION: JWT is 15 min in prod" |
| 4   | June 14 | fyang  | `append`  | "Lesson: always check prod config"  |

The compiled output in `.compiled/entities/auth-service.md` would render as:

```markdown
## Token Management

> ⚠️ **Correction** (jsmith, 2026-06-14): ← correct: shown first
> CORRECTION: JWT is 15 min in prod

JWT expiry: 20 min ← replace: only #2 shown (latest)

<details><summary>History (1 prior version)</summary>
- **2026-06-10 (fyang)** [superseded]               ← replace: #1 hidden in history
  JWT expiry: 30 min
</details>

### [2026-06-14 fyang] ← append: always shown

Lesson: always check prod config
```

**Then AI Synthesis takes over:** The LLM reads these fragments, understands that #3 corrects #1 and #2, checks `raw/code-updates/` for verification, and produces a single coherent understanding: _"JWT expiry is 15 minutes in production. Refresh rotation enabled. HttpOnly cookies."_ — which it can then use to write correct code and optionally persist as a `type: synthesis` fragment.

### Directory Structure (after install)

```
your-project/
├── .github/
│   ├── copilot-instructions.md          # Main Copilot behavior config
│   ├── agents/
│   │   └── second_brain_planner.agent.md # Wiki-aware planning agent
│   └── instructions/
│       └── karpathy-guidelines.instructions.md # Coding discipline rules
├── Second_Brain/
│   ├── SCHEMA.md                    # Operating rules for the LLM
│   ├── SECOND-BRAIN-USAGE-GUIDE.md  # Detailed usage documentation
│   ├── KARPATHY-GUIDELINES-GUIDE.md # Companion coding discipline guide
│   ├── .gitignore                   # Ignores wiki/.compiled/
│   ├── raw/                         # Human-owned, immutable sources
│   │   ├── requirements/            # Business requirement docs
│   │   ├── design/                  # Architecture & design decisions
│   │   ├── decisions/               # Meeting notes, client feedback
│   │   ├── analysis/                # Security scans, performance reports
│   │   ├── architecture/            # Solution structure snapshots
│   │   ├── code-updates/            # Per-user code change reports
│   │   └── sessions/                # Chat transcripts / session notes
│   ├── wiki/                        # LLM-maintained knowledge
│   │   ├── fragments/{user}/        # Atomic knowledge units (per-user)
│   │   ├── .compiled/              # GITIGNORED — assembled view
│   │   ├── journal/{user}/         # Per-user daily session summaries
│   │   └── log/{user}/             # Per-user operation log
│   └── scripts/
│       ├── compile-wiki.ps1         # Compile fragments → .compiled/
│       ├── merge-logs.ps1           # Combine per-user logs into timeline
│       └── search-wiki.ps1          # Full-text search across fragments
└── ... (your source code)
```

---

## Quick Start

### 1. Copy into your repo

Copy the contents of `GitHub_Copilot_Setup/` into your project root:

```bash
# Clone this template
git clone https://dev.azure.com/BDOInternal/SPARQ/_git/SecondBrainTemplate

# Copy both folders into your project root
cp -r SecondBrainTemplate/GitHub_Copilot_Setup/.github /path/to/your-project/
cp -r SecondBrainTemplate/GitHub_Copilot_Setup/Second_Brain /path/to/your-project/
```

Your project should end up with:

```
your-project/
├── .github/
│   ├── copilot-instructions.md
│   ├── agents/
│   │   └── second_brain_planner.agent.md
│   └── instructions/
│       └── karpathy-guidelines.instructions.md
├── Second_Brain/
│   ├── SCHEMA.md
│   ├── raw/
│   ├── wiki/
│   └── scripts/
└── ... (your existing code)
```

> **⚠️ IMPORTANT: `.github/` and `Second_Brain/` MUST be at the workspace root.**
>
> VS Code only loads `.github/copilot-instructions.md` and `.github/agents/` from the root.
> If your repo already has a `.github/` folder, merge the contents rather than overwriting.

### 2. Set your username

```bash
# Option A: environment variable
export SECOND_BRAIN_USER=yourname

# Option B: falls back to git user.name (lowercase, no spaces)
git config user.name  # "Jane Smith" → "janesmith"
```

### 3. Populate the `raw/` folder

Gather existing project knowledge and copy as markdown into `raw/`:

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
- These files are **immutable** once added — the LLM reads but never modifies them

### 4. Bootstrap the wiki

Open VS Code **Agent Mode** chat (Ctrl+Shift+I), choose a capable model (e.g., **Claude Opus 4** or **GPT-4o**), then run:

```
Scan the entire source code repository and all documents in Second_Brain/raw/ folder.
Based on the SCHEMA defined in Second_Brain/SCHEMA.md, initialize the Second Brain wiki:

1. Read Second_Brain/SCHEMA.md to understand the fragment architecture
2. Scan all files in Second_Brain/raw/ — create source fragments in
   wiki/fragments/{user}/ for each document
3. Scan the source code — create entity fragments for each major service/component
4. Identify cross-cutting patterns — create concept fragments
5. Create an overview fragment summarizing the full project architecture
6. Create lesson fragments for any constraints or rules found in the docs
7. Run: pwsh Second_Brain/scripts/compile-wiki.ps1

Each fragment must have proper YAML frontmatter (type, target, section, created, author, action, sources, tags).
Add inline citations [↗ raw/path/to/source.md] linking back to raw sources.
```

### 5. Verify

```powershell
# Compile and check output
pwsh Second_Brain/scripts/compile-wiki.ps1
# → Should show fragment count and assembled pages

# Browse compiled wiki
Get-ChildItem Second_Brain/wiki/.compiled/ -Recurse -Filter *.md
```

---

## Usage Guide

### Automatic Mode (Default)

Once set up, everything happens automatically:

| Trigger              | What Copilot Does                                                          |
| -------------------- | -------------------------------------------------------------------------- |
| **Session start**    | Compiles fragments, synthesizes understanding, detects new raw sources     |
| **Task completion**  | Writes fragment(s), updates journal + log, recompiles                      |
| **Question asked**   | Searches fragments first, answers with citations, promotes novel synthesis |
| **Document dropped** | Detects un-ingested sources, offers to process them                        |

### Manual Wiki Update

If the automatic wiki update doesn't trigger, or you want to capture knowledge at a specific moment, tell Copilot explicitly:

```
Update the wiki for the work I just completed.
Write fragments for the auth service changes, update my journal, and recompile.
```

Or run compilation manually at any time:

```powershell
# Recompile fragments into readable pages
pwsh Second_Brain/scripts/compile-wiki.ps1
```

### When to Manually Trigger Wiki Updates

| Scenario                      | What to Say to Copilot                                                                       |
| ----------------------------- | -------------------------------------------------------------------------------------------- |
| Completed a major feature     | `"Update wiki — I just finished [feature]. Capture the architecture decisions and lessons."` |
| Made a design decision        | `"Write a decision fragment — we chose [X] over [Y] because [reason]."`                      |
| Found and fixed a tricky bug  | `"Write a lesson fragment — [describe the issue and fix]."`                                  |
| Finished a design review      | `"Ingest this design doc and update affected entity fragments."`                             |
| End of day wrap-up            | `"Wrap up — summarize today's work, write journal entry, and recompile wiki."`               |
| After pulling team changes    | `"Recompile wiki and check for any conflicts or stale synthesis."`                           |
| Mid-session important insight | `"Capture this — [insight]. Write a fragment before I forget."`                              |

### Commands Reference

| Command                 | Effect                                                                     |
| ----------------------- | -------------------------------------------------------------------------- |
| `"ingest [path]"`       | Process a raw source into knowledge fragments                              |
| `"lint wiki"`           | Health-check: stale fragments, orphans, contradictions, gaps               |
| `"update wiki"`         | Force a wiki update for current session's work                             |
| `"wrap up"`             | Finalize session — write journal + log + fragments                         |
| `"recompile"`           | Run compile-wiki.ps1 and reload context                                    |
| `"synthesize [target]"` | Force AI synthesis for a specific target (e.g., "synthesize auth-service") |

---

## Multi-Developer Workflow

```
Developer A (morning):
  ├─ Starts session → compiles fragments (includes team's latest)
  ├─ Works on auth feature
  ├─ Copilot writes: fragments/devA/20260614-auth-token.md
  ├─ Commits & pushes (only files in own folder)
  └─ Zero conflict risk

Developer B (afternoon):
  ├─ Pulls → gets A's new fragments
  ├─ Starts session → compiles (sees A's auth changes)
  ├─ Works on caching
  ├─ Copilot writes: fragments/devB/20260614-cache-redis.md
  ├─ Commits & pushes (only files in own folder)
  └─ Zero conflict risk

Both developers share ALL knowledge via Git.
Neither ever touches the other's files.
```

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

A custom **Agent Mode agent** that researches thoroughly before proposing — consulting the wiki first, then code, then producing a structured implementation plan.

### How to Use

In VS Code Agent Mode:

```
@second_brain_planner How should we implement the notification service for claim status changes?
```

### The Planning Workflow

```
Phase 1: Context Gathering → reads fragments, lessons, relevant entities
Phase 2: Analysis & Design → cross-references patterns, surfaces tradeoffs
Phase 3: Structured Plan   → implementation steps, file manifest, risks, testing
Phase 4: User Decision     → approve → implement, or revise → re-plan
```

The agent file lives at `.github/agents/second_brain_planner.agent.md` — automatically discovered by VS Code.

---

## Beyond Second Brain: Capturing the Thinking Flow

### The Missing Knowledge Layer

A codebase is a **snapshot** — it tells you _what_ exists today but not _why_ it evolved this way, _what was tried and rejected_, or _how the team's understanding grew over time_.

The fragment timeline preserves the **growth trajectory** of project understanding:

```
Timeline ──────────────────────────────────────────────────────────▶

  Day 1          Day 30           Day 90           Day 180
  ┌────┐         ┌────┐           ┌────┐           ┌────┐
  │Init│         │Pivot│          │Scale│           │Mature│
  │Assumptions│  │Corrections│    │Patterns│        │Wisdom│
  │First design│ │Lessons learned│ │Architecture│   │Org knowledge│
  └────┘         └────┘           └────┘           └────┘
     │               │                │                │
     ▼               ▼                ▼                ▼
  fragments/     lessons (append)  synthesis       synthesis (mature)
  journal/       correct fragments concept frags   org-level knowledge
```

### Long-Term Vision

| Phase             | Capability                                                                         |
| ----------------- | ---------------------------------------------------------------------------------- |
| **Phase 1** (Now) | Capture knowledge and reasoning into timestamped, per-user fragments               |
| **Phase 2**       | Aggregate Second Brain wikis across projects into org-level knowledge graph        |
| **Phase 3**       | Train domain-specific AI on captured thinking flows for autonomous decision-making |

Every session you run today is an investment in future AI capability. Every correction logged teaches future systems what not to do. Every planning session captured models expert decision-making for AI training.

---

## Obsidian Integration

The wiki is plain markdown and works as an [Obsidian](https://obsidian.md) vault:

1. Set vault root to `Second_Brain/`
2. Use Graph View to visualize fragment relationships
3. Use Dataview plugin to query YAML frontmatter across fragments
4. Use Web Clipper to save articles directly into `raw/`

---

## Scripts

| Script             | Purpose                                              | Usage                                               |
| ------------------ | ---------------------------------------------------- | --------------------------------------------------- |
| `compile-wiki.ps1` | Compile fragments → `.compiled/` (manifest + pages)  | `pwsh Second_Brain/scripts/compile-wiki.ps1`        |
| `merge-logs.ps1`   | Combine per-user logs into chronological view        | `pwsh Second_Brain/scripts/merge-logs.ps1 -Tail 20` |
| `search-wiki.ps1`  | Full-text search across fragments and compiled pages | `pwsh Second_Brain/scripts/search-wiki.ps1 "query"` |

---

## Requirements

- **VS Code** with GitHub Copilot extension
- **PowerShell 7+** (for scripts)
- Git (for username fallback and version control)
