-- Rust tooling: LSP (rust-analyzer), formatting (rustfmt), linting (clippy), debugging (codelldb)
-- This uses rustaceanvim for LSP/UX, nvim-lint for extra lint, conform.nvim for formatting if present, and nvim-dap for debug.

return {
  -- Core Rust experience (includes LSP config & inlay hints)
  {
    'mrcjkb/rustaceanvim',
    version = '^5',
    ft = { 'rust' },
    init = function()
      -- Configure rust-analyzer with clippy on save and rustfmt formatting
      vim.g.rustaceanvim = {
        server = {
          on_attach = function(client, bufnr)
            -- If conform.nvim isn't installed, ensure format on save via LSP
            if not pcall(require, 'conform') then
              -- Format on save using LSP
              vim.api.nvim_create_autocmd('BufWritePre', {
                buffer = bufnr,
                callback = function()
                  vim.lsp.buf.format { async = false }
                end,
              })
            end
          end,
          default_settings = {
            ['rust-analyzer'] = {
              cargo = { allFeatures = true },
              checkOnSave = { command = 'clippy' },
              diagnostics = { enable = true },
              inlayHints = { enable = true },
              rustfmt = { rangeFormatting = { enable = true } },
            },
          },
        },
        tools = {
          float_win_config = { border = 'rounded' },
        },
      }
    end,
  },

  -- Formatter: use conform.nvim if available to call rustfmt
  {
    'stevearc/conform.nvim',
    optional = true,
    opts = function(_, opts)
      opts = opts or {}
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.rust = { 'rustfmt' }
      return opts
    end,
  },

  -- Linter: use nvim-lint if present (clippy is handled by rust-analyzer, but we add cargo clippy as a linter if desired)
  {
    'mfussenegger/nvim-lint',
    optional = true,
    opts = function(_, opts)
      opts = opts or {}
      opts.linters_by_ft = opts.linters_by_ft or {}
      -- nvim-lint doesn't ship a clippy linter; rust-analyzer checkOnSave=clippy covers it.
      -- Keep placeholder in case of custom linters.
      return opts
    end,
  },

  -- Debugging: codelldb via mason-nvim-dap
  {
    'jay-babu/mason-nvim-dap.nvim',
    optional = true,
    opts = function(_, opts)
      opts = opts or {}
      opts.ensure_installed = opts.ensure_installed or {}
      -- Ensure codelldb debugger for Rust
      if not vim.tbl_contains(opts.ensure_installed, 'codelldb') then
        table.insert(opts.ensure_installed, 'codelldb')
      end
      return opts
    end,
  },

  -- If user wants explicit DAP config without mason, provide a lightweight setup
  {
    'mfussenegger/nvim-dap',
    optional = true,
    config = function()
      local ok = pcall(require, 'dap')
      if not ok then return end
      -- If adapter not already defined (e.g., by mason), define codelldb via mason install path when possible
      if not require('dap').adapters['codelldb'] then
        local mason_registry_ok, mason_registry = pcall(require, 'mason-registry')
        if mason_registry_ok then
          local pkg = mason_registry.get_package('codelldb')
          if pkg:is_installed() then
            local install_path = pkg:get_install_path()
            local codelldb_path = install_path .. '/extension/adapter/codelldb'
            local liblldb_path = install_path .. '/extension/lldb/lib/liblldb'
            local this_os = vim.uv.os_uname().sysname
            if this_os:find('Windows') then
              codelldb_path = codelldb_path .. '.exe'
              liblldb_path = install_path .. '/extension/lldb/bin/liblldb.dll'
            elseif this_os == 'Darwin' then
              liblldb_path = liblldb_path .. '.dylib'
            else
              liblldb_path = liblldb_path .. '.so'
            end
            require('dap').adapters.codelldb = {
              type = 'server',
              port = '${port}',
              executable = {
                command = codelldb_path,
                args = { '--port', '${port}' },
              },
            }
            require('dap').configurations.rust = {
              {
                name = 'Debug current file',
                type = 'codelldb',
                request = 'launch',
                program = function()
                  -- Build and return binary for current package
                  vim.fn.jobstart({ 'cargo', 'build' }, { stdout_buffered = true })
                  return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/target/debug/', 'file')
                end,
                cwd = '${workspaceFolder}',
                stopOnEntry = false,
                args = {},
              },
            }
          end
        end
      end
    end,
  },
}
