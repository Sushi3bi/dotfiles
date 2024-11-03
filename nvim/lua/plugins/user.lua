---@type LazySpec
return {
  "ThePrimeagen/vim-be-good", --:VimBeGood
  "aznhe21/actions-preview.nvim",
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = function(_, opts)
      opts.filesystem = {
        filtered_items = {
          visible = false,
          show_hidden_count = true,
          hide_dotfiles = false,
          hide_gitignored = true,
          hide_by_name = {
            ".git",
            ".DS_Store",
            ".idea",
            -- 'thumbs.db',
          },
          never_show = {},
        },
      }
    end,
  },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "Issafalcon/neotest-dotnet",
      "nvim-neotest/neotest-jest",
    },
    opts = function(_, opts)
      if not opts.adapters then
        opts.adapters = {}
      end
      local dotnetTest = require("neotest-dotnet")
      table.insert(opts.adapters, dotnetTest)
      local jestTest = require("neotest-jest")({
        jestCommand = "npm test --",
        jestConfigFile = "custom.jest.config.ts",
        env = { CI = true },
        cwd = function()
          return vim.fn.getcwd()
        end,
      })
      table.insert(opts.adapters, jestTest)
    end,
  },
  --
}
