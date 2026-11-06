---
name: souther
description: Use whenever reading, editing, renaming, or reasoning about Souther (.sou) source — before the first search or edit, not after. Souther has a language server and a specification server behind this plugin, and the habits that serve an untyped file (ripgrep for names, sed for renames, a build to find out what broke) throw all of it away.
---

# Working in Souther

This plugin gives you two servers. Both are already running; neither is used unless you reach for
it, and the defaults you would otherwise fall back on are worse here than they look.

## Edit `.sou` with the Edit tool, never through the shell

`sed -i`, `perl -pi`, and a heredoc rewrite the file without the language server ever seeing it. No
`didChange` is sent, so no diagnostics are produced, and a rewrite of six files lands with nothing
checking it. The Edit tool is what connects an edit to the analysis. Use it even for a mechanical
substitution across many files — several Edit calls beat one `perl -pi`.

## Ask the `LSP` tool before searching for text

`rg` finds a spelling. The language server knows what a name means, which is a different question
and usually the one you have:

- **definition** — where a name is declared, including across a module boundary.
- **references** — where it is actually used. `rg` also returns the comment that mentions it, the
  generated `.class` under `target/`, and the field whose name merely contains it.
- **rename** — every use and no near-miss, in every module at once. This is the one to reach for
  when asked to rename a `data`, a `behavior`, or a field.

Names resolve over the whole workspace, so a definition in one module and a use in another are one
question to the server.

## The diagnostics are the check. Do not run a build to repeat them

After an Edit, the server's diagnostics arrive in your context on the next turn, with the error
code, the line, and the message the compiler would print. They come from the same compiler front
end `mvn compile` runs, so a build that reports nothing new is a build that told you what you had
already been told — and each one costs a turn you spend waiting rather than working.

So: **do not run `mvn compile`, `souther compile`, or the tests to check your own edit.** When the
diagnostics are clean, the edit is clean; say so and stop. Reach for a build only when

- the user asked for one, or asked you to run the tests;
- you need what a build produces rather than what it checks — generated classes, a test result, a
  runtime failure;
- an edit went in through the shell rather than the Edit tool, so nothing analysed it. Prefer going
  back and doing it with Edit.

Two things worth knowing. The first analysis of a session takes a second or two while the server
loads the workspace — after that it is tens of milliseconds. If nothing arrived after your first
edit, it will on the next turn; a second edit or a Read is enough to carry it, and that is still
far cheaper than a build. And the diagnostics only cover files the Edit tool touched.

## Do not guess the language

Souther postdates your training data. Its syntax is not Haskell's, ML's or Elm's, and a construct
that looks obvious by analogy is usually wrong. Before writing an unfamiliar form, ask the
documentation server rather than inferring it:

- `doc_search` / `doc_read` — the language specification, and the error codes by name (`E1023`).
- `stdlib_api` / `stdlib_api_search` / `stdlib_api_source` — what the stdlib publishes, and its
  signatures.
- `jar_api` — a dependency jar's public API with its javadoc, for a `behavior` implemented in Java.

An error code in a diagnostic is addressable: `doc_read` it rather than guessing what it means.
