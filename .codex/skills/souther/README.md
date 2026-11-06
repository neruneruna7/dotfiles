# Souther for Claude Code

Language support for [Souther](https://github.com/souther-lang/souther) (`.sou`) in
[Claude Code](https://claude.com/claude-code): the language server, and the language specification
and stdlib surface as tools.

Souther postdates the training data of every model that will write it, so an agent left on its own
guesses at the syntax and at what the stdlib publishes. This plugin gives it two ways not to guess.

## What you get

An MCP server and an LSP server, answering different questions.

`souther mcp` says what Souther is. The tools are `doc_search`, `doc_read`, `stdlib_api`,
`stdlib_api_search`, `stdlib_api_source` and `jar_api` — the language specification, the stdlib's
published names and signatures, and a dependency jar's public API with its javadoc. None of them
needs a source file.

`souther lsp` says what one source means. Claude Code pushes the server's diagnostics into the
conversation after every edit, so a `.sou` file that does not compile says so without a build being
run, and the model reads the error where it wrote the line. Go-to-definition, find-references,
hover, completion, quick-fix code actions, rename, formatting and semantic tokens come with it.

Names are resolved over the workspace, so a definition, a reference and a rename reach the module
that imported the name and the module that exposed it alike — which is the half of a Souther model
a text search is worst at.

## Requirements

The `souther` binary on the path, from a release that has `souther lsp` — nothing else. Both servers
are launched as subcommands of it, so there is no jar path to configure, no Java to locate, and no
way for the compiler and the language server to be from different releases.

```sh
brew install souther-lang/souther/souther
souther help          # `lsp` and `mcp` are both on the listing
```

## Install

```text
/plugin marketplace add souther-lang/souther-claude-plugin
/plugin install souther@souther-claude-plugin
```

Editing a `.sou` file starts the server. `/mcp` lists the documentation tools, and
`claude plugin details souther` says what the plugin registered.

## Checking it works

Write a `.sou` naming a type nothing declares, ask Claude Code to edit the file, and the next turn
carries the error the server published:

```text
-- I CANNOT FIND THIS TYPE  E1023 --trip.sou:8:47
```

Diagnostics are delivered after the edit rather than in its result, so what a turn wrote is answered
on the turn after it.

## The skill, and why there is one

Wiring the servers in is not enough to get them used. Given a plain rename across six modules,
Claude reaches for `rg` and `perl -pi` — which is a correct answer, and which the language server
never sees, because an edit made through the shell sends no `didChange` and produces no
diagnostics. Asked to find every reference, it greps, and gets the comments too. Then it runs
`mvn compile` to find out whether any of it worked.

None of that is a wiring problem. The capability is there and unused, so what the plugin needs is a
rule rather than another capability. `skills/souther` is that rule and nothing more: edit `.sou`
with the Edit tool, ask the `LSP` tool before searching for text, and treat the diagnostics as the
check rather than repeating them with a build. It costs about 115 tokens in a session that never
touches Souther.

Measured on the [examples repository](https://github.com/souther-lang/examples), same prompt, same
task, with and without it:

| | builds run | wall clock |
| --- | --- | --- |
| `ordering`, add a field | 2 → 0 | 133s → 119s |
| `crm`, add a field | 1 → 0 | 57s → 46s |
| `crm`, rename across 6 modules | 4 → 0 | 68s → 66s |

The rename is the one to read twice. Without the skill it was a `perl -pi` sweep that no analysis
ever saw, checked afterwards by four builds; with it, the references come from the server and the
edits go through the Edit tool. The clock barely moved. What changed is that the work is now
checked as it is written.

What is still deliberately absent is a second copy of the language specification. That is an answer
the MCP server already gives, and duplicating it here would be one more thing to keep in step with
the language.

## License

[EPL-2.0](LICENSE).
