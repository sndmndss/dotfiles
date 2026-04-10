return {
  'pmizio/typescript-tools.nvim',
  dependencies = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },
  ft = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
  config = function()
    -- Get blink.cmp capabilities to advertise to TypeScript LSP
    local capabilities = require('blink.cmp').get_lsp_capabilities()

    require('typescript-tools').setup {
      on_attach = function(client, bufnr)
        -- Disable formatting capability since we use prettier/prettierd via conform.nvim
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
      end,

      -- Pass blink.cmp capabilities to typescript-tools
      capabilities = capabilities,

      settings = {
        -- Spawn additional tsserver instance to calculate diagnostics on it
        separate_diagnostic_server = true,
        -- "change"|"insert_leave" determine when the client asks the server about diagnostic
        publish_diagnostic_on = 'insert_leave',
        -- Specify a list of plugins to load by tsserver
        tsserver_plugins = {},
        -- Locale of all tsserver messages
        tsserver_locale = 'en',
        -- Enable function call completions for better IDE experience
        complete_function_calls = true,
        -- Include completions with insert text (required for auto-imports)
        include_completions_with_insert_text = true,
        -- CodeLens
        code_lens = 'off',
        -- Diagnostics
        disable_member_code_lens = true,
        -- Inlay Hints
        expose_as_code_action = {},
        tsserver_max_memory = 'auto',
        tsserver_path = nil,

        -- TypeScript-specific preferences for auto-imports and completions
        tsserver_file_preferences = {
          -- Enable auto-imports from external modules
          includeCompletionsForModuleExports = true,
          -- Include completions with snippet text
          includeCompletionsWithSnippetText = true,
          -- Include automatic imports in completion items
          includeCompletionsWithInsertText = true,
          -- Auto-import organization style
          importModuleSpecifierPreference = 'relative',
          -- How to handle auto-import file extensions
          importModuleSpecifierEnding = 'auto',
          -- Quote style for imports
          quotePreference = 'single',
          -- Include package.json auto imports
          includePackageJsonAutoImports = 'auto',
        },
      },
    }
  end,
}
