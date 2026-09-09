return {
  {
    "folke/snacks.nvim",
    keys = {
      {
        "<leader>,",
        function()
          Snacks.picker.buffers({
            formatters = { file = { filename_first = true } },
          })
        end,
        desc = "Buffers",
      },
      {
        "<leader>ff",
        function()
          Snacks.picker.files({
            formatters = { file = { filename_first = true } },
          })
        end,
        desc = "Find Files",
      },
      {
        "<leader>fF",
        function()
          Snacks.picker.files({
            root = false,
            formatters = { file = { filename_first = true } },
          })
        end,
        desc = "Find Files (cwd)",
      },
      {
        "<leader>sg",
        function()
          Snacks.picker.grep({
            formatters = { file = { filename_first = true } },
          })
        end,
        desc = "Grep",
      },
      {
        "<leader>sG",
        function()
          Snacks.picker.grep({
            root = false,
            formatters = { file = { filename_first = true } },
          })
        end,
        desc = "Grep (cwd)",
      },
      {
        "<leader>sw",
        function()
          Snacks.picker.grep_word({
            formatters = { file = { filename_first = true } },
          })
        end,
        desc = "Visual selection or word (Root Dir)",
        mode = { "n", "x" },
      },
      {
        "<leader>sW",
        function()
          Snacks.picker.grep_word({
            root = false,
            formatters = { file = { filename_first = true } },
          })
        end,
        desc = "Visual selection or word (cwd)",
        mode = { "n", "x" },
      },
      {
        "<leader>fR",
        function()
          Snacks.picker.recent({
            filter = { cwd = true },
            formatters = { file = { filename_first = true } },
          })
        end,
        desc = "Recent (cwd)",
      },
      {
        "<leader>sR",
        function()
          Snacks.picker.resume()
        end,
        desc = "Resume",
      },
    },
  },
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      -- Disable telescope's bindings so snacks can handle them
      { "<leader>,",  false },
      { "<leader>ff", false },
      { "<leader>fF", false },
      { "<leader>sg", false },
      { "<leader>sG", false },
      { "<leader>sw", false },
      { "<leader>sW", false },
      { "<leader>fR", false },
      { "<leader>sR", false },
    },
  },
}
