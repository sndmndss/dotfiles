-- autopairs
-- https://github.com/windwp/nvim-autopairs

return {
  'windwp/nvim-autopairs',
  event = 'InsertEnter',
  opts = {
    disable_filetype = { 'TelescopePrompt' },
    enable_check_bracket_line = false,
    fast_wrap = {},
    map_bs = true,
  },
}
