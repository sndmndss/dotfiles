-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  lazy = false,
  keys = {
    { '\\', ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
  },
  opts = {
    filesystem = {
      filtered_items = {
        visible = true,       -- show hidden files
        hide_dotfiles = false,
        hide_gitignored = false,
      },
      window = {
        mappings = {
          ['l'] = 'open',       -- open file / expand directory
          ['\\'] = 'close_window',
        },
      },
      -- Enable LSP-based file operations (automatic reference updates on rename/move)
      use_libuv_file_watcher = true,
      follow_current_file = {
        enabled = true,
      },
    },
    -- Enable LSP file operations for automatic reference updates
    event_handlers = {
      {
        event = 'file_renamed',
        handler = function(args)
          -- Notify LSP servers about the file rename to update imports
          -- This uses the workspace/willRenameFiles and workspace/didRenameFiles LSP methods
          local ts_clients = vim.lsp.get_clients()
          for _, client in ipairs(ts_clients) do
            if client.supports_method('workspace/willRenameFiles') then
              local params = {
                files = {
                  {
                    oldUri = vim.uri_from_fname(args.source),
                    newUri = vim.uri_from_fname(args.destination),
                  },
                },
              }
              local resp = client.request_sync('workspace/willRenameFiles', params, 1000, 0)
              if resp and resp.result then
                vim.lsp.util.apply_workspace_edit(resp.result, client.offset_encoding)
              end
            end
          end
        end,
      },
      {
        event = 'file_moved',
        handler = function(args)
          -- Same as file_renamed - notify LSP servers about the file move
          local ts_clients = vim.lsp.get_clients()
          for _, client in ipairs(ts_clients) do
            if client.supports_method('workspace/willRenameFiles') then
              local params = {
                files = {
                  {
                    oldUri = vim.uri_from_fname(args.source),
                    newUri = vim.uri_from_fname(args.destination),
                  },
                },
              }
              local resp = client.request_sync('workspace/willRenameFiles', params, 1000, 0)
              if resp and resp.result then
                vim.lsp.util.apply_workspace_edit(resp.result, client.offset_encoding)
              end
            end
          end
        end,
      },
    },
  },
}
