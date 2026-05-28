# Second Brain — Usage Guide

## What Is This?

The **Second Brain** is a persistent, LLM-maintained project wiki that lives alongside your code. It automatically captures, organizes, and surfaces project knowledge so that every future coding session, code review, and design decision benefits from everything the team has learned.

Unlike traditional documentation that goes stale, the Second Brain is **auto-updated by your AI assistant** at the end of every task — no manual effort required.

---

## How It Works

```
┌─────────────────────────────────────────────────────────────────────┐
│                         YOUR WORKFLOW                                 │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ┌──────────┐     ┌───────────────────┐     ┌───────────────────┐   │
│  │  Human    │     │  Copilot (LLM)    │     │  Second Brain     │   │
│  │           │     │                   │     │  (wiki/)          │   │
│  │ • Code    │────▶│ • Reads wiki at   │────▶│ • entities/       │   │
│  │ • Design  │     │   session start   │     │ • concepts/       │   │
│  │ • Review  │     │ • Answers from    │     │ • sources/        │   │
│  │ • Drop    │     │   wiki first      │     │ • analysis/       │   │
│  │   docs    │     │ • Auto-updates    │     │ • lessons.md      │   │
│  │           │     │   after each task  │     │ • journal/{user}/ │   │
│  └──────────┘     └───────────────────┘     └───────────────────┘   │
│       │                                             ▲                 │
│       │           ┌───────────────────┐             │                 │
│       └──────────▶│  Raw Sources      │─────────────┘                 │
│                   │  (raw/)           │  ingested into wiki            │
│                   │  • requirements/  │                               │
│                   │  • design/        │                               │
│                   │  • analysis/      │                               │
│                   └───────────────────┘                               │
└─────────────────────────────────────────────────────────────────────┘
```

### The Three Layers

| Layer      | Path        | Who Owns It   | Purpose                                                           |
| ---------- | ----------- | ------------- | ----------------------------------------------------------------- |
| **Raw**    | `raw/`      | You (human)   | Immutable source documents — requirements, designs, meeting notes |
| **Wiki**   | `wiki/`     | LLM (Copilot) | Synthesized, cross-referenced knowledge pages                     |
| **Schema** | `SCHEMA.md` | Team          | Rules that tell the LLM how to maintain the wiki                  |

---

## Automated Behaviors (What Copilot Does For You)

### 1. Session Start — Context Loading + New Source Detection

Every time you open a chat, Copilot automatically:

- Reads `wiki/index.md` to understand the full knowledge map
- Loads your recent log for continuity with past sessions
- **Scans `raw/` for un-ingested documents** — if you dropped new files, it notifies you:
  > "I found 3 new raw sources not yet ingested. Want me to process them?"

### 2. Chat End — Auto-Summary Sync

After every task that produces reusable knowledge, Copilot automatically:

- Writes a code-update report to `raw/code-updates/{user}-YYYY-MM-DD.md`
- Updates your daily journal at `wiki/journal/{user}/YYYY-MM-DD.md`
- Updates relevant entity/concept pages in the wiki
- Appends to your operation log at `wiki/log/{user}/YYYY-MM-DD.md`
- Regenerates `wiki/index.md` via the indexing script

**You don't need to ask.** This happens as the final step of every task.

### 3. Document Ingestion — Raw → Wiki

When you add documents to `raw/` and confirm ingestion:

- Creates a source summary page in `wiki/sources/`
- Updates affected entity/concept pages with new knowledge
- Flags contradictions if new info conflicts with existing wiki content
- Adds inline citations (`[↗ raw/path/to/source.md]`) for traceability

### 4. Query Answering — Wiki-First

When you ask about the project, Copilot:

- Searches the wiki **before** diving into code
- Presents the wiki-based answer with citations
- Offers to verify against current code if you want
- Promotes valuable answers to `wiki/analysis/` pages for future reuse

---

## Usage Guide

### Daily Development Workflow

1. **Start a chat** — Copilot loads context automatically. If new raw docs are detected, you'll be notified.
2. **Code as normal** — Ask questions, fix bugs, implement features. Copilot consults the wiki for context.
3. **End your task** — Copilot auto-updates the wiki. No action needed from you.

### Adding New Documents

Drop files into the appropriate `raw/` subfolder:

| Document Type                       | Drop Location       |
| ----------------------------------- | ------------------- |
| Business requirements               | `raw/requirements/` |
| Architecture/design docs            | `raw/design/`       |
| Meeting notes, client feedback      | `raw/decisions/`    |
| Security scans, performance reports | `raw/analysis/`     |
| Architecture diagrams, service maps | `raw/architecture/` |

Next time you start a chat, Copilot will detect and offer to ingest them.

**Or trigger immediately:** Say `"ingest raw/requirements/new-doc.md"` in chat.

### Asking Questions (Query)

Just ask naturally. Examples:

- "How does the notification service work?"
- "What are the roles and permissions?"
- "What's the claim workflow from submission to payment?"

Copilot answers from the wiki first, then offers to verify against code.

### Manual Commands

| Command                      | What It Does                                                            |
| ---------------------------- | ----------------------------------------------------------------------- |
| `"ingest [path]"`            | Process a raw source into the wiki                                      |
| `"ingest raw/requirements/"` | Batch-ingest all files in a folder                                      |
| `"lint wiki"`                | Health-check: stale pages, orphans, contradictions, missing frontmatter |
| `"update wiki"`              | Force a wiki update for the current session                             |
| `"wrap up"`                  | Finalize session — write journal + log entries                          |

### Regenerating the Index

If you need to manually rebuild the index (rare — Copilot does this automatically):

```powershell
cd Second_Brain
pwsh scripts/generate-index.ps1
```

### Reviewing the Operation Timeline

Per-user logs are great for merge safety but make it harder to see "what happened across the team this week." Use `merge-logs.ps1` to recombine them into a single chronological view:

```powershell
# Write merged view to wiki/.merged-log.md
pwsh Second_Brain/scripts/merge-logs.ps1

# Or just print the last 20 entries to the console
pwsh Second_Brain/scripts/merge-logs.ps1 -Tail 20
```

The output is read-only and gitignored — regenerate any time.

---

## Obsidian Conventions

The wiki is a plain markdown folder, so any editor works — but Obsidian gives you wikilinks, graph view, and live preview essentially for free.

### Recommended Setup

| Setting                   | Value           | Why                                                |
| ------------------------- | --------------- | -------------------------------------------------- |
| Vault root                | `Second_Brain/` | Treat the whole second brain as one vault          |
| Attachment folder         | `raw/assets/`   | Keeps downloaded images out of `wiki/` (LLM-owned) |
| Default new-file location | `wiki/`         | Anything you create lands in the LLM-managed area  |

In **Settings → Files and links**, set "Attachment folder path" to `raw/assets/`. Then in **Settings → Hotkeys**, search for "Download attachments for current file" and bind it (e.g. `Ctrl+Shift+D`). After clipping an article with Obsidian Web Clipper, hit the hotkey to localize all images so the LLM can view them directly.

### Useful Plugins

- **Web Clipper** (browser extension) — convert web articles to markdown straight into `raw/`. Drop URL → article appears in `raw/sources/` (or wherever you point it) → LLM ingests on next session.
- **Graph view** (built-in) — best way to see wiki shape: hubs, orphans, clusters. Run `lint wiki` when the graph reveals islands.
- **Dataview** — runs queries over YAML frontmatter. Our frontmatter (`created`, `updated`, `sources`, `tags`) is Dataview-compatible. Example:

  ```dataview
  TABLE updated, length(sources) AS "source count"
  FROM "wiki/entities"
  SORT updated DESC
  LIMIT 10
  ```

- **Marp** — markdown-based slide decks. Use it when a query answer is better presented as slides than a wiki page. File deck output in `wiki/analysis/decks/` and link it from the analysis page.

### Output Formats Beyond Markdown

Query answers don't have to be pages. The LLM may produce:

| Format                 | Where it goes                                       |
| ---------------------- | --------------------------------------------------- |
| Markdown analysis page | `wiki/analysis/*.md` (default)                      |
| Marp slide deck        | `wiki/analysis/decks/*.md`                          |
| Chart / diagram        | `wiki/analysis/charts/` (PNG/SVG) or inline mermaid |
| Comparison table       | Inline in an analysis page                          |

Whichever form is used, the artifact stays inside `wiki/analysis/` so it benefits from the same indexing, citations, and cross-referencing as everything else.

---

## What Gets Tracked (Long-Term Memory)

| Category              | Wiki Location                        | Use Case                                        |
| --------------------- | ------------------------------------ | ----------------------------------------------- |
| **Services**          | `wiki/entities/`                     | Code review — understand what each service does |
| **Patterns**          | `wiki/concepts/`                     | Design — reuse established patterns             |
| **Bug Fixes**         | `wiki/concepts/bug-fixes.md`         | Bug tracking — avoid repeating past mistakes    |
| **Requirements**      | `wiki/requirements/status-matrix.md` | Sprint planning — track BR progress             |
| **Lessons Learned**   | `wiki/lessons.md`                    | Code review — rules that prevent known issues   |
| **Source Provenance** | `wiki/sources/`                      | Audit — trace any wiki claim back to its origin |
| **Analyses**          | `wiki/analysis/`                     | Design — reuse past research and comparisons    |
| **Daily Work**        | `wiki/journal/{user}/`               | Handoff — see what teammates did recently       |

---

## Team Collaboration

Multiple developers can use this simultaneously:

- **Per-user files** (logs, journals, code-updates) — zero merge conflicts
- **Shared pages** (entities, concepts) — use additive edits with `<!-- updated: user YYYY-MM-DD -->` stamps
- **Auto-generated index** — never hand-edited, rebuilt by script
- **Git-friendly** — all markdown, standard merge workflow for rare conflicts

### Your Username

Derived automatically from `git config user.name` → lowercase, no spaces.
Example: "Frank Yang" → `fyang`

All your personal files go under this username:

- `wiki/log/fyang/2026-05-25.md`
- `wiki/journal/fyang/2026-05-25.md`
- `raw/code-updates/fyang-2026-05-25.md`

---

## Design Principles

1. **Knowledge compounds** — Every session makes the wiki richer. Unlike chat history that disappears, the wiki persists and grows.
2. **Zero maintenance burden** — The LLM does all the bookkeeping. You never need to manually update the wiki.
3. **Source of truth** — Raw documents are immutable. Wiki synthesizes. Claims are traceable via citations.
4. **Contradiction-aware** — When new info conflicts with old, it's flagged explicitly rather than silently overwritten.
5. **Forward-only provenance** — Every wiki page knows which raw sources informed it (via YAML frontmatter `sources:` field).

---

## File Structure

```
Second_Brain/
├── SCHEMA.md                    ← Operating rules (how the LLM maintains the wiki)
├── USAGE-GUIDE.md               ← This file
├── raw/                         ← Human-owned, immutable source documents
│   ├── requirements/            ← Business requirements (BR docs)
│   ├── design/                  ← Architecture & design decisions
│   ├── decisions/               ← Meeting notes, client feedback
│   ├── analysis/                ← Security scans, performance reports
│   ├── architecture/            ← Service inventory, structure snapshots
│   ├── sessions/                ← Chat transcripts (dropped by user)
│   └── code-updates/            ← Auto-generated code change reports
├── wiki/                        ← LLM-owned, auto-maintained
│   ├── index.md                 ← Auto-generated catalog (never hand-edit)
│   ├── overview.md              ← Project architecture synthesis
│   ├── lessons.md               ← Accumulated corrections & rules
│   ├── entities/                ← One page per service/component
│   ├── concepts/                ← One page per cross-cutting pattern
│   ├── sources/                 ← One summary page per ingested raw source
│   ├── analysis/                ← Promoted query answers & syntheses
│   ├── requirements/            ← BR status tracking
│   ├── journal/{user}/          ← Daily session summaries (per user)
│   └── log/{user}/              ← Operation log (per user)
└── scripts/
    ├── generate-index.ps1       ← Index regeneration script
    ├── search-wiki.ps1          ← Keyword search across wiki pages
    └── merge-logs.ps1           ← Recombines per-user logs into a single timeline
```

---

## Quick Start

1. **Just start coding.** The system works automatically via `.github/copilot-instructions.md`.
2. **Drop documents** into `raw/` when you have new requirements or designs.
3. **Ask questions** about the project — Copilot answers from accumulated knowledge.
4. **Say "lint wiki"** occasionally to health-check the knowledge base.

That's it. The LLM handles everything else.
