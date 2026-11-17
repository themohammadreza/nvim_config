# nvim_config

My Neovim config: [lazy.nvim](https://github.com/folke/lazy.nvim) plugins, catppuccin (mocha), nvim-tree,
telescope, treesitter, nvim-cmp and native LSP (`vim.lsp.config`) with Mason.

Language servers: pyright + ruff (Python), tsgo / ts_ls (TypeScript/React), lua_ls, bashls, rust_analyzer,
clangd. gopls is configured but disabled.

---

## 1. Requirements

| Tool | Why | Check |
| --- | --- | --- |
| **Neovim ≥ 0.11** (tested on 0.12) | `vim.lsp.config` / `vim.lsp.enable` API | `nvim --version` |
| git | lazy.nvim clones plugins | `git --version` |
| make, gcc (or clang) | builds telescope-fzf-native, LuaSnip regex, treesitter parsers | `make -v`, `cc --version` |
| curl or wget, unzip, tar, gzip | Mason downloads language servers | |
| node + npm | pyright, typescript-language-server, bash-language-server | `node -v` |
| python3 | ruff/pyright, Python projects | `python3 -V` |
| ripgrep (`rg`) | telescope `live_grep` | `rg --version` |
| A [Nerd Font](https://www.nerdfonts.com/) set in your terminal | icons in nvim-tree, barbar, lualine | |
| *optional:* `fd`, `clangd`, `cargo` | faster file browser, C/C++, Rust | |

Debian / Ubuntu:

```bash
sudo apt install git make gcc curl wget unzip tar gzip nodejs npm python3 python3-venv ripgrep fd-find xclip
```

macOS (Homebrew):

```bash
brew install neovim git make node python ripgrep fd
```

Ubuntu's `apt` Neovim is often older than 0.11. If `nvim --version` shows less than 0.11, install a newer
build (the [official release](https://github.com/neovim/neovim/releases), `brew install neovim`, or the
`neovim-ppa/unstable` PPA).

`xclip` (or `wl-clipboard` on Wayland) is needed because the config uses the system clipboard
(`clipboard=unnamedplus`).

---

## 2. Remove conflicts with a previous config (this config wins)

Neovim uses these four folders. A previous config (your own, LazyVim, NvChad, AstroNvim, kickstart...) leaves
files in all of them, and leftovers in the data/state/cache folders cause errors even after you replace
the config folder: old plugin versions, a different plugin manager, stale treesitter parsers, old swap/undo
files. **Move all four aside** so this config starts clean.

| Folder | Holds | Linux / macOS path |
| --- | --- | --- |
| config | `init.lua`, `lua/` | `~/.config/nvim` |
| data | plugins, Mason servers, parsers | `~/.local/share/nvim` |
| state | logs, shada, undo, swap | `~/.local/state/nvim` |
| cache | lua cache, luac | `~/.cache/nvim` |

(If `$XDG_CONFIG_HOME` / `$XDG_DATA_HOME` / `$XDG_STATE_HOME` / `$XDG_CACHE_HOME` are set, the folders are
under those instead. `nvim --headless -c 'lua for _,k in ipairs({"config","data","state","cache"}) do print(k, vim.fn.stdpath(k)) end' -c q`
prints the real paths.)

### 2.1 Back up the old setup (nothing is deleted)

```bash
ts=$(date +%Y%m%d-%H%M%S)
for d in ~/.config/nvim ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim; do
  [ -e "$d" ] && mv "$d" "$d.bak-$ts" && echo "moved $d -> $d.bak-$ts"
done
```

To go back to the old setup later, move the `.bak-…` folders back to their original names.

### 2.2 Check for things outside those folders

These are not moved by the step above and can still override or break this config:

1. **Shell aliases and env vars.** Look in `~/.bashrc`, `~/.zshrc`, `~/.profile`:

   ```bash
   grep -nE 'NVIM_APPNAME|alias (vim|vi|nvim)=|XDG_CONFIG_HOME|VIMINIT|MYVIMRC' ~/.bashrc ~/.zshrc ~/.profile 2>/dev/null
   ```

   - `NVIM_APPNAME=…` makes nvim read `~/.config/<that name>` instead of `~/.config/nvim`. Remove it.
   - `VIMINIT` / `MYVIMRC` force a different init file. Remove them.
   - `alias nvim=…` pointing at another binary or wrapper (e.g. `lvim`). Remove it.

   Then open a new terminal (or `exec $SHELL`).

2. **An old `init.vim`.** If both `init.vim` and `init.lua` exist in the config folder, Neovim stops with
   `E5422: Conflicting configs`. Step 2.1 already moved the folder, so the fresh clone has only `init.lua`.

3. **System-wide plugins.** Neovim also loads plugins from site folders. Look for leftovers from
   packer.nvim, vim-plug or distro packages:

   ```bash
   ls ~/.local/share/nvim/site/pack 2>/dev/null   # gone after 2.1
   ls /usr/share/nvim/site/pack /usr/local/share/nvim/site/pack 2>/dev/null
   ls /etc/xdg/nvim 2>/dev/null                    # system sysinit.vim
   ```

   If a distro package installed plugins there (e.g. `vim-*` / `neovim-*` packages), remove that package. Don't
   delete files under `/usr/share` by hand.

4. **Several nvim binaries.** Make sure the one on `PATH` is ≥ 0.11:

   ```bash
   which -a nvim; nvim --version | head -1
   ```

### 2.3 Install this config

```bash
git clone git@github.com:themohammadreza/nvim_config.git ~/.config/nvim
# or over HTTPS:
# git clone https://github.com/themohammadreza/nvim_config.git ~/.config/nvim
```

---

## 3. First launch

```bash
nvim
```

On the first start:

1. lazy.nvim clones itself, then installs every plugin. Wait until the Lazy window finishes, then press `q`.
2. Pin plugins to the exact versions in `lazy-lock.json` (the versions this config was tested with):

   ```vim
   :Lazy restore
   ```

3. Restart nvim. Mason installs the language servers in the background (pyright, ruff, ts_ls, lua_ls,
   bashls, rust_analyzer, clangd). Check progress with `:Mason`.
4. Treesitter compiles its parsers on first start (needs `gcc`). Check with `:TSInstallInfo`.
5. Run a health check and fix anything marked ERROR:

   ```vim
   :checkhealth
   ```

If a plugin build failed (e.g. `make` was missing), install the tool and run `:Lazy build telescope-fzf-native.nvim`
or `:Lazy build LuaSnip`.

### Try it without touching the old config

To test before removing your old setup, clone it under a different name and start it with `NVIM_APPNAME`.
It gets its own config/data/state/cache folders, so there's no conflict at all:

```bash
git clone git@github.com:themohammadreza/nvim_config.git ~/.config/nvim-mario
NVIM_APPNAME=nvim-mario nvim
```

When you're happy with it, do section 2 and clone into `~/.config/nvim`.

---

## 4. Project notes

- **Python env.** pyright picks the interpreter in this order: activated venv / conda env
  (not `base`) → `.venv` or `venv` in the project → the conda env named in the project's `environment.yml`
  (e.g. `name: hrms` → `~/miniconda3/envs/hrms`) → `python3` on `PATH`. So Django imports resolve even if
  nvim was started outside the env. Create the env first (`conda env create -f environment.yml`).
- **TypeScript 7** projects have no `tsserver.js`; for them the project's own `node_modules/.bin/tsc --lsp`
  is used (`tsgo`). Older TypeScript projects use `ts_ls`. Run `npm install` in the frontend first.
- **Persian / RTL text.** Spell check is only on in markdown and git commits (the English dictionary marks
  every Persian word). `termbidi` is on, so the terminal must do bidi shaping (e.g. Konsole, GNOME
  Terminal with VTE ≥ 0.76, mlterm).

---

## 5. Keymaps

Leader is `Space`.

| Keys | Action |
| --- | --- |
| `<leader>e`, `Shift-b` | toggle file tree |
| `-` | telescope file browser (current file's folder) |
| `<leader>ff` / `fg` / `fb` / `fr` | find files / live grep / buffers / recent files |
| `<leader>fd` / `fh` / `fs` / `fx` | diagnostics / help / spelling suggestions / treesitter symbols |
| `gd` / `gr` / `K` | go to definition / references / hover |
| `<leader>rn` / `ca` / `lf` | rename / code action / format |
| `<leader>d`, `[d`, `]d` | show diagnostic / previous / next |
| `Tab` / `Shift-Tab` | next / previous buffer |
| `Alt-1`…`Alt-9`, `Alt-0` | go to buffer N / last buffer |
| `Alt-,` / `Alt-.` | previous / next buffer (barbar order) |
| `Alt-c` / `Alt-b` / `Alt-p` | close buffer / close all others / pin |
| `<leader>w` | save |
| `Esc` | clear search highlight |
| `<leader>r` | save and `cargo run` |
| `F5` | `g++ *.cpp -o main && ./main` |
| `gcc` / `gc` (visual) | toggle comment |
| `ys`, `ds`, `cs` | add / delete / change surroundings |

In completion: `Tab` / `Shift-Tab` next/previous item (or jump in a snippet), `Enter` confirm,
`Ctrl-Space` open, `Ctrl-e` close.

---

## 6. Updating and rolling back

```vim
:Lazy update
```

`lazy-lock.json` records the exact plugin versions. Commit it after an update that works. If an update breaks
something:

```bash
cd ~/.config/nvim && git checkout lazy-lock.json
```

then `:Lazy restore` in nvim.

`nvim-treesitter` and `telescope.nvim` are pinned to their `master` branch on purpose: treesitter's `main`
branch is a rewrite without the `nvim-treesitter.configs` module this config uses, and without a branch
lazy.nvim can fall back to an old telescope release tag.

## 7. Troubleshooting

| Symptom | Fix |
| --- | --- |
| `E5422: Conflicting configs` | an `init.vim` and `init.lua` are both in `~/.config/nvim`; see 2.2 |
| errors mentioning packer / old plugins | data folder from the previous config is still there; redo 2.1 |
| `module 'nvim-treesitter.configs' not found` | treesitter is on `main`; `:Lazy restore` |
| boxes instead of icons | terminal font is not a Nerd Font |
| `live_grep` shows nothing | install `ripgrep` |
| Django imports "could not be resolved" | create/activate the project's conda env; see section 4 |
| language server missing | `:Mason`, install it, then `:LspInfo` (or `:checkhealth vim.lsp`) |
| logs | `~/.local/state/nvim/lsp.log`, `:MasonLog`, `:messages` |
