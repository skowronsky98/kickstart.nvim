return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      local install = require 'nvim-treesitter.install'
      install.prefer_git = true
      install.compilers = { 'clang', 'gcc' }

      vim.treesitter.language.register('html', 'mjml')

      vim.api.nvim_create_autocmd('FileType', {
        callback = function()
          pcall(vim.treesitter.start)
        end,
      })
    end,
  },
}
