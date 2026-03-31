return {
  {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local harpoon = require 'harpoon'
      harpoon:setup()

      vim.keymap.set('n', '<leader>pa', function() harpoon:list():add() end, { desc = '[A]dd file to list' })
      vim.keymap.set('n', '<leader>pr', function() harpoon:list():remove() end, { desc = '[R]emove file from list' })
      vim.keymap.set('n', '<leader>pn', function() harpoon:list():next() end, { desc = '[N]ext file from list' })
      vim.keymap.set('n', '<leader>pp', function() harpoon:list():prev() end, { desc = '[P]revious file from list' })

      vim.keymap.set('n', '<C-e>', function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)
      vim.keymap.set('n', '<C-y>', function() harpoon:list():select(1) end)
      vim.keymap.set('n', '<C-h>', function() harpoon:list():select(2) end)
      vim.keymap.set('n', '<C-n>', function() harpoon:list():select(3) end)
      vim.keymap.set('n', '<C-s>', function() harpoon:list():select(4) end)

      vim.keymap.set('n', '<C-S-P>', function() harpoon:list():prev() end)
      vim.keymap.set('n', '<C-S-N>', function() harpoon:list():next() end)
    end,
  },
}
