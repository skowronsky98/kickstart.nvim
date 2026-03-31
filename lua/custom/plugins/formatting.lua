return {
  {
    'stevearc/conform.nvim',
    lazy = false,
    keys = {
      {
        '<leader>f',
        function() require('conform').format { async = true, lsp_format = 'fallback' } end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      notify_on_error = true,
      format_on_save = function(bufnr)
        local disable_filetypes = {
          c = true, cpp = true,
          javascript = true, typescript = true,
          javascriptreact = true, typescriptreact = true,
          json = true, yaml = true,
        }
        if disable_filetypes[vim.bo[bufnr].filetype] then
          return nil
        end
        return { timeout_ms = 3000, lsp_format = 'fallback' }
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        c = { 'clang_format' },
        cpp = { 'clang_format' },
        javascript = { 'prettierd' },
        typescript = { 'prettierd' },
        javascriptreact = { 'prettierd' },
        typescriptreact = { 'prettierd' },
        json = { 'prettierd' },
        html = { 'prettierd', 'prettier' },
        css = { 'prettierd', 'prettier' },
        markdown = { 'prettierd', 'prettier' },
        yaml = { 'prettierd', 'prettier' },
        go = { 'goimports' },
        terraform = { 'terraform_fmt' },
        tf = { 'terraform_fmt' },
      },
      default_format_opts = { stop_after_first = true },
    },
  },
}
