-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
    { "AstroNvim/astrocommunity" },
    -- import/override with your plugins folder
    { import = "astrocommunity.recipes.heirline-nvchad-statusline" },
    { import = "astrocommunity.terminal-integration.flatten-nvim" },
    { import = "astrocommunity.utility.telescope-fzy-native-nvim" },
    { import = "astrocommunity.editing-support.auto-save-nvim" },
    { import = "astrocommunity.editing-support.chatgpt-nvim" },
    --{ import = "astrocommunity.diagnostics.lsp_lines-nvim" },
    { import = "astrocommunity.git.diffview-nvim" },
    { import = "astrocommunity.syntax.hlargs-nvim" },

    { import = "astrocommunity.colorscheme.catppuccin" },
    { import = "astrocommunity.colorscheme.tokyonight-nvim" },
    { import = "astrocommunity.colorscheme.gruvbox-baby" },
    --{ import = "astrocommunity.colorscheme.nightfox-nvim" },

    { import = "astrocommunity.diagnostics.trouble-nvim" },
    { import = "astrocommunity.pack.markdown" },
    { import = "astrocommunity.pack.lua" },
    { import = "astrocommunity.pack.json" },
    { import = "astrocommunity.pack.html-css" },
    { import = "astrocommunity.pack.docker" },
    { import = "astrocommunity.pack.cs" },
    { import = "astrocommunity.pack.rust" },
    { import = "astrocommunity.pack.swift" },
    { import = "astrocommunity.pack.typescript" },
    { import = "astrocommunity.pack.yaml" },

    { import = "astrocommunity.test.neotest" },
    --{ import = "astrocommunity.scrolling.satellite-nvim", enabled = false },
    { import = "astrocommunity.scrolling.neoscroll-nvim" },
    { import = "astrocommunity.indent.indent-tools-nvim" },

    { import = "astrocommunity.lsp.lspsaga-nvim" },
    { import = "astrocommunity.completion.cmp-emoji" },
    { import = "astrocommunity.completion.cmp-cmdline" },
}
