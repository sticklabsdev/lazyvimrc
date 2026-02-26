return {
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
  },
}
