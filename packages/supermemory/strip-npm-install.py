#!/usr/bin/env python3
import pathlib
import re
import sys

root = pathlib.Path(sys.argv[1])
skills = ("supermemory", "supermemory-cli")


def replace(rel, old, new, count=1):
    path = root / rel
    text = path.read_text()
    found = text.count(old)
    if found != count:
        raise SystemExit(f"{rel}: expected {count} occurrence(s), found {found}: {old!r}")
    path.write_text(text.replace(old, new))


replace(
    "supermemory-cli/SKILL.md",
    "Use the Supermemory CLI (`supermemory` 5.x on npm)",
    "Use the Supermemory CLI (`supermemory`)",
)
replace(
    "supermemory-cli/SKILL.md",
    "The CLI ships inside the `supermemory` npm package and calls the v5 API.",
    "The `supermemory` command calls the v5 API.",
)
replace(
    "supermemory-cli/SKILL.md",
    """## Install and auth

```bash
# Run without installing
npx supermemory --version

# Or install globally
npm i -g supermemory

# Browser login, stores credentials in ~/.supermemory/credentials.json
supermemory login
""",
    """## Auth

```bash
# Browser login, stores credentials in ~/.supermemory/credentials.json
supermemory login
""",
)
replace(
    "supermemory-cli/SKILL.md",
    "| `npm i -g @supermemory/cli` | `npm i -g supermemory` or `npx supermemory` |\n",
    "",
)
replace(
    "supermemory/SKILL.md",
    "npx supermemory@latest migrate",
    "supermemory migrate",
)
replace(
    "supermemory/references/sdk-guide.md",
    "npx supermemory@latest migrate",
    "supermemory migrate",
)
replace("supermemory/SKILL.md", " | `npm i supermemory` |", " | |")
replace("supermemory/SKILL.md", " | `npm i @supermemory/tools supermemory` |", " | |")
replace(
    "supermemory/SKILL.md",
    "- **CLI**: `npx supermemory` ships in the npm package. ",
    "- **CLI**: ",
)
replace(
    "supermemory/README.md",
    "`npm install supermemory`",
    "`supermemory`",
)
replace(
    "supermemory/references/quickstart.md",
    "npm i supermemory          # TypeScript, also ships the CLI (npx supermemory)\n",
    "",
)
replace(
    "supermemory/references/quickstart.md",
    "`npm i supermemory@5`, see ",
    "See ",
)
replace(
    "supermemory/references/sdk-guide.md",
    "npm i supermemory          # TypeScript, Node 18+, Bun, Deno, browsers, edge\n",
    "",
)
replace(
    "supermemory/references/sdk-integrations.md",
    "npm install @supermemory/tools          # brings supermemory@5 with it\n",
    "",
)

pattern = re.compile(r"npm(?: install| i\b)|npx ")
for skill in skills:
    for path in (root / skill).rglob("*"):
        if path.suffix not in {".md", ".txt"}:
            continue
        for number, line in enumerate(path.read_text().splitlines(), start=1):
            if pattern.search(line):
                raise SystemExit(f"npm install remains in {path.relative_to(root)}:{number}: {line}")
