-- CodeCompanion with GitHub Copilot provider
-- https://github.com/olimorris/codecompanion.nvim

return {
	'olimorris/codecompanion.nvim',
	dependencies = {
		'nvim-lua/plenary.nvim',
		'nvim-treesitter/nvim-treesitter',
		'stevearc/dressing.nvim',
		'MunifTanjim/nui.nvim',
	},
	opts = {
		strategies = {
			chat = {
				adapter = 'copilot',
			},
			inline = {
				adapter = 'copilot',
			},
		},
	},
}
