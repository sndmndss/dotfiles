return {
  'linux-cultist/venv-selector.nvim',
  -- Load when opening Python files or on command/key
  ft = 'python',
  cmd = { 'VenvSelect', 'VenvSelectCached' },
  dependencies = {
    'neovim/nvim-lspconfig',
    -- picker (use Telescope 0.1.x which kickstart already pulls)
    { 'nvim-telescope/telescope.nvim', branch = '0.1.x', dependencies = { 'nvim-lua/plenary.nvim' } },
    -- (optional) debugger integration
    'mfussenegger/nvim-dap',
    'mfussenegger/nvim-dap-python',
  },
  keys = {
    { '<leader>cv', '<cmd>VenvSelect<cr>', desc = 'Python: choose venv' },
    { '<leader>cV', '<cmd>VenvSelectCached<cr>', desc = 'Python: choose venv (cached)' },
  },
  opts = {
    -- Empty is fine (sane defaults). Add custom searches if you want (see below).
    search = {
      work = { command = 'fd /bin/python$ ~/work --full-path -IHL -E /proc' },
    },
    options = {
      -- keep defaults; venv-selector will reconfigure Pyright/Pylsp/Pylance automatically
    },
  },
}
