--[[
=====================================================================
==================== READ THIS BEFORE CONTINUING ====================
=====================================================================
========                                    .-----.          ========
========         .----------------------.   | === |          ========
========         |.-""""""""""""""""""-.|   |-----|          ========
========         ||                    ||   | === |          ========
========         ||   KICKSTART.NVIM   ||   |-----|          ========
========         ||                    ||   | === |          ========
========         ||                    ||   |-----|          ========
========         ||:Tutor              ||   |:::::|          ========
========         |'-..................-'|   |____o|          ========
========         `"")----------------(""`   ___________      ========
========        /::::::::::|  |::::::::::\  \ no mouse \     ========
========       /:::========|  |==hjkl==:::\  \ required \    ========
========      '""""""""""""'  '""""""""""""'  '""""""""""'   ========
========                                                     ========
=====================================================================
=====================================================================

Migrated from macOS config for Linux usage
]]

-- Set <space> as the leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- [[ Setting options ]]
-- Make line numbers default
vim.o.number = true
vim.o.relativenumber = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.o.showmode = false

-- Sync clipboard between OS and Neovim
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default  
vim.o.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250

-- Decrease mapped sequence wait time
vim.o.timeoutlen = 300

-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.o.inccommand = 'split'

-- Show which line your cursor is on (disable if distracting)
vim.o.cursorline = false

-- Minimal number of screen lines to keep above and below the cursor.
vim.o.scrolloff = 10

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
vim.o.confirm = true

-- [[ C/C++ specific indentation settings ]]
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"c", "cpp", "cc", "cxx", "h", "hpp"},
  callback = function()
    vim.bo.tabstop = 2          -- Tab width when reading files  
    vim.bo.softtabstop = 2      -- Tab width when editing
    vim.bo.shiftwidth = 2       -- Width for auto-indentation
    vim.bo.expandtab = true     -- Use spaces instead of tabs
    vim.bo.cindent = true       -- Enable C-style indentation
    vim.bo.cinoptions = "N-s"   -- No indent for namespace contents
  end,
})

-- [[ Basic Keymaps ]]
-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

vim.keymap.set('n', '<leader>w', ':e<CR>', {
  noremap = true,
  silent = true,
  desc = 'Reload file from disk',
})

-- Keybinds to make split navigation easier.
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Run current file in terminal split (reuses terminal)
vim.keymap.set('n', '<leader>r', function()
  local file = vim.fn.expand '%'
  vim.cmd 'w' -- save file before running
  
  -- Close any existing terminal buffers
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].buftype == 'terminal' then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end
  
  -- Create new terminal
  vim.cmd('split | resize 10 | terminal ' .. get_run_cmd(file) .. '; exit')
end, { desc = 'Run current file in terminal (single)', noremap = true, silent = true })

-- Helper: detect run command based on file extension with venv support
function get_run_cmd(file)
  local ext = vim.fn.fnamemodify(file, ':e')
  
  -- Python with virtual environment detection
  if ext == 'py' then
    local python_cmd = get_python_cmd()
    return python_cmd .. ' ' .. file
  elseif ext == 'c' then
    local basename = vim.fn.fnamemodify(file, ':r')
    return 'gcc -o ' .. basename .. ' ' .. file .. ' && ./' .. basename
  elseif ext == 'cpp' or ext == 'cc' or ext == 'cxx' then
    local basename = vim.fn.fnamemodify(file, ':r')
    return 'g++ -o ' .. basename .. ' ' .. file .. ' && ./' .. basename
  elseif ext == 'sh' then
    return 'bash ' .. file
  elseif ext == 'js' then
    return 'node ' .. file
  else
    return "echo '🚫 No runner for ." .. ext .. "'"
  end
end

-- Helper: get the correct Python command with venv support
function get_python_cmd()
  -- Method 1: Check if VIRTUAL_ENV is set (most common)
  local venv_path = vim.fn.getenv('VIRTUAL_ENV')
  if venv_path and venv_path ~= vim.NIL then
    local venv_python = venv_path .. '/bin/python'
    if vim.fn.executable(venv_python) == 1 then
      return venv_python
    end
  end
  
  -- Method 2: Check for local .venv directory
  local cwd = vim.fn.getcwd()
  local local_venv_paths = {
    cwd .. '/.venv/bin/python',
    cwd .. '/venv/bin/python',
    cwd .. '/env/bin/python'
  }
  
  for _, venv_python in ipairs(local_venv_paths) do
    if vim.fn.executable(venv_python) == 1 then
      return venv_python
    end
  end
  
  -- Method 3: Look for venv in parent directories
  local current_dir = cwd
  for _ = 1, 5 do  -- Check up to 5 levels up
    local parent_venv_paths = {
      current_dir .. '/.venv/bin/python',
      current_dir .. '/venv/bin/python',
      current_dir .. '/env/bin/python'
    }
    
    for _, venv_python in ipairs(parent_venv_paths) do
      if vim.fn.executable(venv_python) == 1 then
        return venv_python
      end
    end
    
    -- Move up one directory
    local parent = vim.fn.fnamemodify(current_dir, ':h')
    if parent == current_dir then break end  -- Reached root
    current_dir = parent
  end
  
  -- Method 4: Check for conda environment
  local conda_env = vim.fn.getenv('CONDA_DEFAULT_ENV')
  if conda_env and conda_env ~= vim.NIL and conda_env ~= 'base' then
    local conda_python = vim.fn.getenv('CONDA_PREFIX') .. '/bin/python'
    if vim.fn.executable(conda_python) == 1 then
      return conda_python
    end
  end
  
  -- Method 5: Check for Poetry project
  if vim.fn.filereadable(cwd .. '/pyproject.toml') == 1 then
    -- Try to use poetry run python
    if vim.fn.executable('poetry') == 1 then
      return 'poetry run python'
    end
  end
  
  -- Method 6: Check for pipenv
  if vim.fn.filereadable(cwd .. '/Pipfile') == 1 then
    if vim.fn.executable('pipenv') == 1 then
      return 'pipenv run python'
    end
  end
  
  -- Fallback to system Python
  if vim.fn.executable('python3') == 1 then
    return 'python3'
  elseif vim.fn.executable('python') == 1 then
    return 'python'
  else
    return 'echo "❌ No Python interpreter found"'
  end
end

vim.keymap.set('n', '<leader>t', function()
  vim.cmd 'belowright split' -- create horizontal split
  vim.cmd 'resize 10' -- resize it to 10 lines tall
  vim.cmd 'terminal' -- open terminal
end, { desc = 'Open terminal below', noremap = true, silent = true })

-- GitHub CLI keybindings
vim.keymap.set('n', '<leader>gc', ':!gh pr create<CR>', { desc = '[G]it [C]reate PR', noremap = true })
vim.keymap.set('n', '<leader>gp', ':!gh pr list<CR>', { desc = '[G]it [P]R list', noremap = true })
vim.keymap.set('n', '<leader>gi', ':!gh issue create<CR>', { desc = '[G]it [I]ssue create', noremap = true })
vim.keymap.set('n', '<leader>gs', ':!gh status<CR>', { desc = '[G]it [S]tatus', noremap = true })
vim.keymap.set('n', '<leader>gr', ':!gh repo view<CR>', { desc = '[G]it [R]epo view', noremap = true })

-- Syntax highlighting fix keybinding
vim.keymap.set('n', '<leader>sy', function()
  vim.cmd('TSBufDisable highlight')
  vim.cmd('TSBufEnable highlight') 
  vim.cmd('syntax clear')
  vim.cmd('syntax on')
  vim.cmd('doautocmd FileType')
  print("Syntax highlighting refreshed!")
end, { desc = '[S]yntax refresh', noremap = true, silent = true })

-- Show which Python interpreter will be used
vim.keymap.set('n', '<leader>py', function()
  local python_cmd = get_python_cmd()
  local venv_info = ""
  
  -- Add virtual environment info
  local venv_path = vim.fn.getenv('VIRTUAL_ENV')
  if venv_path and venv_path ~= vim.NIL then
    local venv_name = vim.fn.fnamemodify(venv_path, ':t')
    venv_info = " (venv: " .. venv_name .. ")"
  end
  
  print("🐍 Python: " .. python_cmd .. venv_info)
end, { desc = '[P]ython interpreter info', noremap = true, silent = true })

-- Theme switching keybindings - VS Code style easy switching
vim.keymap.set('n', '<leader>tt', function()
  vim.ui.select(
    { 'tokyonight-night', 'tokyonight-storm', 'tokyonight-moon', 'catppuccin-mocha', 'kanagawa', 'rose-pine', 'gruvbox' },
    { prompt = '🎨 Select theme:' },
    function(choice)
      if choice then
        vim.cmd.colorscheme(choice)
        print('🎨 Theme: ' .. choice)
      end
    end
  )
end, { desc = '[T]heme [T]oggle', noremap = true, silent = true })

-- Quick theme shortcuts
vim.keymap.set('n', '<leader>t1', function() vim.cmd.colorscheme('tokyonight-night') end, { desc = 'Tokyo Night', noremap = true })
vim.keymap.set('n', '<leader>t2', function() vim.cmd.colorscheme('catppuccin-mocha') end, { desc = 'Catppuccin', noremap = true })
vim.keymap.set('n', '<leader>t3', function() vim.cmd.colorscheme('kanagawa') end, { desc = 'Kanagawa', noremap = true })
vim.keymap.set('n', '<leader>t4', function() vim.cmd.colorscheme('rose-pine') end, { desc = 'Rose Pine', noremap = true })
vim.keymap.set('n', '<leader>t5', function() vim.cmd.colorscheme('gruvbox') end, { desc = 'Gruvbox', noremap = true })

-- Python type checking toggle
vim.keymap.set('n', '<leader>tc', function()
  local clients = vim.lsp.get_clients({ name = 'pyright' })
  if #clients == 0 then
    print("Pyright LSP not active")
    return
  end

  local client = clients[1]
  local current_mode = client.config.settings.python.analysis.typeCheckingMode
  local new_mode = current_mode == 'off' and 'basic' or 'off'
  
  -- Update client settings
  client.config.settings.python.analysis.typeCheckingMode = new_mode
  
  -- Notify the server of the new settings
  client.notify('workspace/didChangeConfiguration', {
    settings = client.config.settings
  })
  
  print("Type checking mode: " .. new_mode)
end, { desc = '[T]oggle type [C]hecking (off/basic)', noremap = true, silent = true })

-- ===== FRICTION-REDUCING KEYMAPS =====

-- Quick save
vim.keymap.set('n', '<C-s>', '<cmd>w<cr><esc>', { desc = 'Save file' })
vim.keymap.set('i', '<C-s>', '<esc><cmd>w<cr><esc>', { desc = 'Save file' })

-- Better line movement
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Better indenting in visual mode
vim.keymap.set('v', '<', '<gv')
vim.keymap.set('v', '>', '>gv')

-- Move lines up/down
vim.keymap.set('n', '<A-j>', '<cmd>m .+1<cr>==', { desc = 'Move line down' })
vim.keymap.set('n', '<A-k>', '<cmd>m .-2<cr>==', { desc = 'Move line up' })
vim.keymap.set('i', '<A-j>', '<esc><cmd>m .+1<cr>==gi', { desc = 'Move line down' })
vim.keymap.set('i', '<A-k>', '<esc><cmd>m .-2<cr>==gi', { desc = 'Move line up' })
vim.keymap.set('v', '<A-j>', ":m '>+1<cr>gv=gv", { desc = 'Move selection down' })
vim.keymap.set('v', '<A-k>', ":m '<-2<cr>gv=gv", { desc = 'Move selection up' })

-- Quick quit
vim.keymap.set('n', '<C-q>', '<cmd>qa<cr>', { desc = 'Quit all' })

-- Clear search highlighting
vim.keymap.set('n', '<leader>h', '<cmd>nohlsearch<cr>', { desc = 'Clear highlights' })

-- Quick file explorer
vim.keymap.set('n', '<leader>e', '<cmd>Neotree toggle<cr>', { desc = 'Toggle file explorer' })

-- Quick diagnostics
vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, { desc = 'Show diagnostics' })
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Prev diagnostic' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Next diagnostic' })

-- Center cursor when jumping
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')

-- Debug command to turn off everything distracting
vim.keymap.set('n', '<leader>zz', function()
  -- Clear git-blame virtual text
  pcall(function()
    local ns_ids = vim.api.nvim_get_namespaces()
    for name, id in pairs(ns_ids) do
      if name:match("git%-blame") or name:match("blame") then
        vim.api.nvim_buf_clear_namespace(0, id, 0, -1)
      end
    end
  end)
  
  -- Force disable gitsigns blame
  pcall(function()
    local gitsigns = require('gitsigns')
    if gitsigns.get_config().current_line_blame then
      gitsigns.toggle_current_line_blame()
    end
  end)
  
  -- Clear all LSP highlights and search
  vim.cmd('nohlsearch')
  pcall(vim.lsp.buf.clear_references)
  
  -- Make highlight groups invisible
  local hl_groups = {
    'LspReferenceText', 'LspReferenceRead', 'LspReferenceWrite',
    'IlluminatedWordText', 'IlluminatedWordRead', 'IlluminatedWordWrite',
    'CursorWord', 'CursorWord0', 'CursorWord1'
  }
  
  for _, group in ipairs(hl_groups) do
    vim.api.nvim_set_hl(0, group, { bg = 'NONE', fg = 'NONE' })
  end
  
  print("All distractions cleared")
end, { desc = 'Kill all distractions' })

-- [[ Basic Autocommands ]]
-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Seamless insert mode escaping
vim.keymap.set('i', 'jk', '<Esc>', { noremap = true })

-- Block indent/unindent in visual mode
vim.keymap.set('v', '<Tab>', '>gv', { noremap = true })
vim.keymap.set('v', '<S-Tab>', '<gv', { noremap = true })

-- Automatically save buffers, but skip unnamed/new files
vim.cmd [[
  autocmd TextChanged,FocusLost * if bufname('%') != '' && &modifiable && !&readonly | silent! update | endif
]]

-- [[ Install `lazy.nvim` plugin manager ]]
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end

---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
require('lazy').setup({
  -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  { import = 'custom.plugins' },
}, {
  ui = {
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})

-- Load custom options
require('custom.options')

-- Set default colorscheme
vim.cmd.colorscheme('tokyonight-night')

-- Auto-reload files when they change on disk
vim.opt.autoread = true
vim.api.nvim_create_autocmd({ 'BufEnter', 'CursorHold', 'CursorHoldI', 'FocusGained' }, {
  command = "if mode() != 'c' | checktime | endif",
  pattern = { '*' },
})

-- vim: ts=2 sts=2 sw=2 et