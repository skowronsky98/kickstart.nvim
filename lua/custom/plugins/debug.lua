return {
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'rcarriga/nvim-dap-ui',
      'nvim-neotest/nvim-nio',
      'williamboman/mason.nvim',
      'jay-babu/mason-nvim-dap.nvim',
      'leoluz/nvim-dap-go',
    },
    config = function()
      local dap = require 'dap'
      local dapui = require 'dapui'

      require('mason-nvim-dap').setup {
        automatic_installation = true,
        handlers = {},  -- empty = use default handlers (install only, no config generation)
        ensure_installed = {
          'js-debug-adapter',
          'delve',
        },
      }

      -- Remove auto-generated Go configurations from mason-nvim-dap (keep only nvim-dap-go ones)
      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'go' },
        callback = function()
          vim.schedule(function()
            if dap.configurations.go then
              dap.configurations.go = vim.tbl_filter(function(c)
                return not vim.startswith(c.name, 'Delve:')
              end, dap.configurations.go)
            end
          end)
        end,
      })

      -- Keymaps
      vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Debug: Start/Continue' })
      vim.keymap.set('n', '<F1>', dap.step_into, { desc = 'Debug: Step Into' })
      vim.keymap.set('n', '<F2>', dap.step_over, { desc = 'Debug: Step Over' })
      vim.keymap.set('n', '<F3>', dap.step_out, { desc = 'Debug: Step Out' })
      vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
      vim.keymap.set('n', '<leader>B', function()
        dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end, { desc = 'Debug: Set Breakpoint' })
      vim.keymap.set('n', '<F7>', dapui.toggle, { desc = 'Debug: See last session result.' })

      -- DAP UI
      dapui.setup {
        icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
        controls = {
          icons = {
            pause = '⏸', play = '▶', step_into = '⏎', step_over = '⏭',
            step_out = '⏮', step_back = 'b', run_last = '▶▶',
            terminate = '⏹', disconnect = '⏏',
          },
        },
      }

      dap.listeners.after.event_initialized['dapui_config'] = dapui.open
      dap.listeners.before.event_terminated['dapui_config'] = dapui.close
      dap.listeners.before.event_exited['dapui_config'] = dapui.close

      -- Go
      require('dap-go').setup {
        delve = { detached = vim.fn.has 'win32' == 0 },
      }

      -- JS/TS adapter
      -- NOTE: use 127.0.0.1 NOT localhost — macOS resolves localhost to IPv6 which breaks connection
      local dap_server = vim.fn.stdpath 'data' .. '/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js'

      -- Use a function adapter so nvim-dap assigns a real port (not a template string)
      dap.adapters['pwa-node'] = function(cb, config)
        local port = math.random(49152, 65535)
        cb {
          type = 'server',
          host = '::1',  -- js-debug-adapter binds to IPv6 on macOS
          port = port,
          executable = {
            command = 'node',
            args = { dap_server, tostring(port) },
          },
        }
      end

      -- Alias for .vscode/launch.json compatibility
      dap.adapters['node'] = function(cb, config)
        config = vim.tbl_extend('force', config, { type = 'pwa-node' })
        dap.adapters['pwa-node'](cb, config)
      end


      -- Detect tsx or ts-node runtime
      local function get_ts_runtime()
        if vim.fn.executable 'tsx' == 1 then return 'tsx' end
        if vim.fn.executable 'ts-node' == 1 then return 'ts-node' end
        return nil
      end

      local source_map_opts = {
        sourceMaps = true,
        resolveSourceMapLocations = {
          '${workspaceFolder}/**',
          '!**/node_modules/**',
        },
        skipFiles = {
          '<node_internals>/**',
          '${workspaceFolder}/node_modules/**',
        },
      }

      -- JavaScript
      for _, lang in ipairs { 'javascript', 'javascriptreact' } do
        dap.configurations[lang] = {
          {
            type = 'pwa-node',
            request = 'launch',
            name = 'Launch file (node)',
            program = '${file}',
            cwd = '${workspaceFolder}',
            console = 'integratedTerminal',
            sourceMaps = true,
            skipFiles = source_map_opts.skipFiles,
          },
          {
            type = 'pwa-node',
            request = 'attach',
            name = 'Attach to process',
            processId = require('dap.utils').pick_process,
            cwd = '${workspaceFolder}',
            sourceMaps = true,
            skipFiles = source_map_opts.skipFiles,
          },
          {
            type = 'pwa-node',
            request = 'attach',
            name = 'Attach to port 9229',
            address = '127.0.0.1',
            port = 9229,
            cwd = '${workspaceFolder}',
            restart = true,
            sourceMaps = true,
            skipFiles = source_map_opts.skipFiles,
          },
        }
      end

      -- TypeScript
      for _, lang in ipairs { 'typescript', 'typescriptreact' } do
        dap.configurations[lang] = {
          {
            type = 'pwa-node',
            request = 'launch',
            name = 'Launch file (tsx/ts-node)',
            program = '${file}',
            runtimeExecutable = get_ts_runtime(),
            cwd = '${workspaceFolder}',
            console = 'integratedTerminal',
            internalConsoleOptions = 'neverOpen',
            sourceMaps = source_map_opts.sourceMaps,
            resolveSourceMapLocations = source_map_opts.resolveSourceMapLocations,
            skipFiles = source_map_opts.skipFiles,
          },
          {
            type = 'pwa-node',
            request = 'launch',
            name = 'Debug Jest (current file)',
            program = '${workspaceFolder}/node_modules/.bin/jest',
            args = { '${fileBasenameNoExtension}', '--runInBand', '--no-coverage' },
            cwd = '${workspaceFolder}',
            console = 'integratedTerminal',
            internalConsoleOptions = 'neverOpen',
            sourceMaps = source_map_opts.sourceMaps,
            resolveSourceMapLocations = source_map_opts.resolveSourceMapLocations,
            skipFiles = source_map_opts.skipFiles,
          },
          {
            type = 'pwa-node',
            request = 'launch',
            name = 'Debug Vitest (current file)',
            program = '${workspaceFolder}/node_modules/.bin/vitest',
            args = { 'run', '${fileBasenameNoExtension}', '--reporter=verbose' },
            cwd = '${workspaceFolder}',
            console = 'integratedTerminal',
            internalConsoleOptions = 'neverOpen',
            sourceMaps = source_map_opts.sourceMaps,
            resolveSourceMapLocations = source_map_opts.resolveSourceMapLocations,
            skipFiles = source_map_opts.skipFiles,
            env = { NODE_ENV = 'test' },
          },
          {
            type = 'pwa-node',
            request = 'attach',
            name = 'Attach to process',
            processId = require('dap.utils').pick_process,
            cwd = '${workspaceFolder}',
            sourceMaps = source_map_opts.sourceMaps,
            resolveSourceMapLocations = source_map_opts.resolveSourceMapLocations,
            skipFiles = source_map_opts.skipFiles,
          },
          {
            type = 'pwa-node',
            request = 'attach',
            name = 'Attach to port 9229',
            address = 'localhost',
            port = 9229,
            cwd = '${workspaceFolder}',
            restart = true,
            sourceMaps = source_map_opts.sourceMaps,
            resolveSourceMapLocations = source_map_opts.resolveSourceMapLocations,
            skipFiles = source_map_opts.skipFiles,
          },
        }
      end
    end,
  },
}
