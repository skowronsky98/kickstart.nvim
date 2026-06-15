return {
  {
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    event = 'InsertEnter',
    opts = {
      suggestion = {
        enabled = true,
        auto_trigger = true,
        keymap = {
          accept = '<Tab>',
          accept_word = '<C-e>',
          accept_line = '<F2>',
          next = '<C-j>',
          prev = '<C-k>',
          dismiss = '<C-]>',
        },
      },
      panel = { enabled = true },
    },
  },
}
