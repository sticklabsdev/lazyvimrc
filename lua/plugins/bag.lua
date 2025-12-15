-- BAG Options
return {
  "folke/snacks.nvim",
  keys = {
    -- Top Pickers & Explorer
    -- { "<leader><space>", function() Snacks.picker.smart() end, desc = "Smart Find Files", },
    -- { "<leader>,", function() Snacks.picker.buffers() end, desc = "Buffers" },
    -- { "<leader>/", function() Snacks.picker.grep() end, desc = "Grep" },
    -- { "<leader>:", function() Snacks.picker.command_history() end, desc = "Command History" },
    -- { "<leader>n", function() Snacks.picker.notifications() end, desc = "Notification History" },
    {
      "<leader>yak",
      function()
        Snacks.explorer()
      end,
      desc = "BAG was here File Explorer",
    },
  },
}
