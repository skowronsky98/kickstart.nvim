return {
  {
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local lint = require 'lint'
      lint.linters_by_ft = {
        markdown = { 'markdownlint' },
        terraform = { 'tflint' },
      }

      local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
      vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
        group = lint_augroup,
        callback = function()
          require('lint').try_lint()
        end,
      })
      -- tflint --act-as-bundled-plugin runs as a persistent gRPC daemon and is not
      -- cleaned up by nvim-lint on exit
      vim.api.nvim_create_autocmd('VimLeavePre', {
        group = lint_augroup,
        callback = function()
          local nvim_count = tonumber(vim.fn.system "pgrep -xc nvim 2>/dev/null") or 0
          if nvim_count <= 1 then
            -- Last nvim: kill all mason-managed tflint (both --langserver and --act-as-bundled-plugin)
            vim.fn.system "pkill -9 -f '/nvim/mason/bin/tflint' 2>/dev/null; true"
          else
            -- Other nvim sessions active: only kill orphaned bundled-plugin (PPID=1)
            vim.fn.system "pgrep -P 1 -f 'tflint --act-as-bundled-plugin' | xargs kill -9 2>/dev/null; true"
          end
        end,
      })
    end,
  },
}
