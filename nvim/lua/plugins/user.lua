---@type LazySpec
return {
  "ThePrimeagen/vim-be-good", --:VimBeGood
  "aznhe21/actions-preview.nvim",
  {
    "tris203/precognition.nvim",
    opts = {
      disabled_fts = { "startify", "markdown" },
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
