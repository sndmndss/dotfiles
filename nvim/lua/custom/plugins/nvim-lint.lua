return {
	'nvimtools/none-ls.nvim',
	dependencies = {
		'nvimtools/none-ls-extras.nvim',
		'jayp0521/mason-null-ls.nvim', -- ensure dependencies are installed
	},
	config = function()
		local null_ls = require 'null-ls'
		local formatting = null_ls.builtins.formatting -- to setup formatters
		local diagnostics = null_ls.builtins.diagnostics -- to setup linters

		-- list of formatters & linters for mason to install
		require('mason-null-ls').setup {
			ensure_installed = {
				'checkmake',
				'prettier', -- ts/js formatter
				-- Note: eslint_d linting is now handled by nvim-lint in kickstart/plugins/lint.lua
				'shfmt',
				-- 'stylua', -- lua formatter; Already installed via Mason
				-- 'ruff', -- Python linter and formatter; Already installed via Mason
			},
			-- auto-install configured formatters & linters (with null-ls)
			automatic_installation = true,
		}

		local sources = {
			diagnostics.checkmake,
			-- Note: prettier formatting for JS/TS is handled by conform.nvim in init.lua
			formatting.prettier.with { filetypes = { 'html', 'json', 'yaml', 'markdown' } },
			formatting.stylua,
			formatting.shfmt.with { args = { '-i', '4' } },
			formatting.terraform_fmt,
			require('none-ls.formatting.ruff').with { extra_args = { '--extend-select', 'I' } },
			require 'none-ls.formatting.ruff_format',
		}

		-- Note: Format-on-save is now handled by conform.nvim in init.lua to avoid conflicts
		-- The on_attach autocmd below has been disabled to prevent double formatting
		-- If you need to format manually with none-ls, use :lua vim.lsp.buf.format()
		null_ls.setup {
			-- debug = true, -- Enable debug mode. Inspect logs with :NullLsLog.
			sources = sources,
		}
	end,
}