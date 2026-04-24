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
    },
  },
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      -- Disable telescope's <leader>, binding so snacks can handle it
      { "<leader>,", false },
    },
  },
}
