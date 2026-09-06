---@type LazySpec
return {
  "ThePrimeagen/vim-be-good", --:VimBeGood
  {
    "tris203/precognition.nvim",
    opts = {
      disabled_fts = { "startify", "markdown" },
    },
  },
  {
    "m4xshen/hardtime.nvim",
    opts = {
      disable_mouse = false
    },
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = function(_, opts)
      opts.filesystem = {
        filtered_items = {
          visible = false,
          show_hidden_count = true,
          hide_dotfiles = false,
          hide_gitignored = false,
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
  }
}
