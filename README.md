# Neovim for C# and .NET

This configuration uses Roslyn for C#, Blink for completion, Conform for formatting,
Telescope for search, and nvim-dap with netcoredbg for debugging. Lua, TypeScript,
and C++ keep their existing language servers.

## Arch installation

Install the editor and command line dependencies:

```sh
sudo pacman -Syu neovim dotnet-sdk git ripgrep fd curl unzip nodejs npm base-devel tree-sitter-cli wl-clipboard
```

For ASP.NET projects, also install `aspnet-runtime` and `aspnet-targeting-pack`.
Projects targeting other .NET versions may require their matching SDK/runtime and
targeting packs; respect the project's `global.json`.
[Arch packages .NET SDK](https://archlinux.org/packages/extra/x86_64/dotnet-sdk/)
and [Tree-sitter CLI](https://archlinux.org/packages/extra/x86_64/tree-sitter-cli/)
provide the SDK/runtime and parser build tools. `wl-clipboard` supports Hyprland's
Wayland clipboard. Existing external formatters remain optional (`stylua`,
`prettier`, `shfmt`, `clang-format`).

1. Run `:Lazy restore` to install the locked plugin versions.
2. Run `:MasonInstall roslyn netcoredbg`. Wait for installation to finish.
3. Run `:TSInstall c_sharp` if the parser has not finished installing automatically.
4. Run `dotnet restore` and `dotnet build` in your solution, then open a C# file.
5. Check `:checkhealth vim.lsp`, `:checkhealth telescope`, `:Mason`, and `:messages`.

The locked [roslyn.nvim](https://github.com/seblyng/roslyn.nvim) requires Neovim
0.12+ and Roslyn server 5.12.0-1.26453.19+. Mason uses the upstream-recommended
Crashdummyy registry for `roslyn`; the default registry remains available for other
tools. The tested server is 5.13.0-1.26519.5. Server binaries are not pinned by
`lazy-lock.json`; check compatibility before updating them.

The plugin resolves `$MASON/bin/roslyn-language-server`, then PATH. The debugger
uses `stdpath("data") .. "/mason/bin/netcoredbg"`. Neither server ships inside this
repository. Do not additionally enable OmniSharp, csharp_ls, or another Roslyn
integration. Mason LSP automatic enabling is disabled so installing another C#
server cannot silently start a duplicate.

## Editing and search

| Key | Action |
| --- | --- |
| `gd`, `gr`, `K` | Definition, references, hover |
| `<Space>rn`, `<Space>ca` | Rename, code actions |
| `<C-k>` in insert mode | Signature help |
| `<Space>cd`, `<Space>xx` | Line diagnostics, diagnostics list |
| `<Space>cf` | Format buffer |
| `<Space>ff`, `<Space>fg` | Find files, live grep |
| `<Space>fb`, `<Space>fh`, `<Space>fr` | Buffers, help, recent files |
| `<Space>db`, `<Space>dt` | Build, test in a terminal split |

Roslyn detects `.sln`, `.slnx`, and standalone `.csproj` workspaces and loads
referenced projects. Use `:Roslyn target` when multiple solutions are possible.
Blink advertises its LSP completion capabilities to all configured servers and
shows completion documentation and signature help. Roslyn supplies semantic
highlighting and diagnostics; Tree-sitter supplies syntax highlighting. Compiler
and analyzer diagnostics are limited to open files to bound background work;
`dotnet build` still checks the complete solution.

Conform uses Roslyn's LSP formatter for C#, including on save, honoring applicable
`.editorconfig` settings. No extra C# formatter is installed. Use `dotnet format`
from the solution directory for deliberate solution-wide cleanup. Existing Git
hunk navigation, previews, and blame remain available through Gitsigns.

Telescope searches the current working directory, respects ignore files, and
omits hidden files by default. Use `:pwd` and `:cd /path/to/solution` if the result
set is unexpected. The mappings deliberately retain Telescope's cwd behavior.

Build and test find the containing solution from the current file, falling back
to projects in its repository/project directory. Multiple targets prompt for a
selection. Terminal output remains visible; the terminal remembers its solution
root for subsequent build/test commands.

## Debugging

Build the executable project with `dotnet build -c Debug` before launching.
`<F5>` prompts for a project beneath the solution root, then a target framework
for projects using `TargetFrameworks`. Choose the console/web executable project.
Libraries and test projects are rejected with a clear message; run tests using
`<Space>dt` instead.

MSBuild evaluates `TargetPath` for Debug, so nested projects, custom assembly
names, and output directories work without guessing DLL names. Evaluation runs
asynchronously with a 30-second timeout. The selected project's directory becomes
the debuggee working directory. Cancellation aborts launch; missing assemblies
produce a build instruction. This intentionally does not rebuild automatically.
For launch arguments, environment variables, non-Debug configurations, or projects
outside this directory tree, use `.vscode/launch.json` with `type: "coreclr"`.
The locked nvim-dap reads launch.json automatically.

| Key | Action |
| --- | --- |
| `<Space>b` | Toggle breakpoint |
| `<F5>` | Launch or continue |
| `<F10>`, `<F11>`, `<F12>` | Step over, into, out |
| `<Space>du`, `<Space>dr` | Toggle debugger UI, open REPL |

The debugger UI exposes scopes/variables, watches, and call stacks. Existing
JavaScript/TypeScript adapters and F#/VB launch aliases remain configured.
C++ debugging configuration was preserved; it was not validated by the .NET tests.

## Regression checks

Run from this repository with its configuration active. The fixture script needs
.NET SDK 10 and network access for xUnit's NuGet packages, and writes only to the
specified new temporary directory:

```sh
export NVIM_DOTNET_FIXTURE="$(mktemp -d /tmp/nvim-dotnet.XXXXXX)"
bash tests/create-dotnet-fixture.sh "$NVIM_DOTNET_FIXTURE"
for check in editor dotnet-lsp dotnet-selection dotnet-dap other-languages; do
  nvim --headless -i NONE -c "lua local ok,e=pcall(dofile,'tests/$check.lua'); if not ok then print(e); vim.cmd('cquit') end" || break
done
```

Tests send real LSP/DAP requests, exercise Telescope preview/file selection and
live grep, and reject bad launch selections. Rename edits and invalid C# code are
applied only to temporary buffers and discarded on exit. These are integration
checks: plugins, parsers, and Mason tools must already be installed.

Validation on Arch, Neovim 0.12.6, SDK 10.0.113, Roslyn 5.13.0-1.26519.5,
and netcoredbg 3.1.3:

- Three-project console/library/xUnit solution builds; one xUnit test passes.
- Roslyn attaches once at the `.slnx` root. Completion, definition, references,
  hover, signature help, code actions, Conform formatting, compiler error CS0029, and cross-project
  rename pass. Separate real `.sln` and standalone `.csproj` projects attach and
  answer semantic hover requests.
- Telescope mappings, preview highlighting, selection, and live grep pass.
- Debugger hits a breakpoint, supplies stack/scopes/variables, steps into/out/over,
  and continues to exit. Project cancellation, library/test rejection, and
  missing output checks pass.
- LSP health reports two existing clangd filetype warnings (`c.doxygen` and
  `cpp.doxygen`); no C# health error was reported.
- Lua, TypeScript, and C++ servers attach and answer hover requests. Build/test
  terminal commands both exit successfully.
- Three warm empty-start samples showed roughly 34–37 ms before and 25–29 ms
  after, using shared installed plugins and redirected writable cache/state.
  This is a local configuration comparison, not a general performance benchmark.

The original Telescope failure was reproduced as `ft_to_lang` missing in the
0.1.x previewer with Tree-sitter's main branch. Telescope master uses Neovim's
supported highlighting API. Plenary, ripgrep, fd, loading, and mappings passed
inspection. The original C# failure had no configured C# server or installed
Roslyn binary. Original debugging searched only cwd/bin/Debug/net* and could
select dependency DLLs instead of the executable assembly.

Graphical/interactive Hyprland checks remain manual: completion popup/documentation
appearance and acceptance, visual picker operation, debugger UI presentation,
clipboard behavior, and normal-session responsiveness on large solutions.
