return {
  'mfussenegger/nvim-dap-python',
  ft = 'python',
  dependencies = { 'mfussenegger/nvim-dap' },
  config = function()
    local dap_py = require 'dap-python'
    -- Ask venv-selector for the current Python; fallback to "python"
    local vs = require 'venv-selector'
    local py = vs.python() or 'python'
    dap_py.setup(py)

    vim.keymap.set('n', '<leader>dn', function()
      dap_py.test_method()
    end, { desc = 'DAP: Test method' })
    vim.keymap.set('n', '<leader>df', function()
      dap_py.test_class()
    end, { desc = 'DAP: Test class' })
    vim.keymap.set('v', '<leader>ds', function()
      dap_py.debug_selection()
    end, { desc = 'DAP: Debug selection' })
  end,
}
