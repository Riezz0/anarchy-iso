return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 500
  end,
  opts = {
    plugins = { spelling = true },
    win = {
      border = "rounded",
    },
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)

    wk.add({
      { "<leader>e", group = "Explorer" },
      { "<leader>s", group = "Splits" },
      { "<leader>t", group = "Tabs/Terminal" },
      { "<leader>b", group = "Buffers" },
      { "<leader>w", group = "Workspace" },
      { "<leader>g", group = "Git" },
      { "<leader>f", group = "Find" },
      { "<leader>n", group = "No" },
      { "<leader>c", group = "Color" },
    })
  end,
}
