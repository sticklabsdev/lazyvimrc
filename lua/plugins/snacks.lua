-- Sort the buffer picker to match the reverse of bufferline's tab order (same order H/L cycle through)
local function buffers_in_bufferline_order(opts, ctx)
  local items = require("snacks.picker.source.buffers").buffers(opts, ctx)
  local ok, bufferline = pcall(require, "bufferline")
  if not ok then return items end
  local order = {}
  for i, elem in ipairs(bufferline.get_elements().elements) do
    order[elem.id] = i
  end
  table.sort(items, function(a, b)
    local oa, ob = order[a.buf], order[b.buf]
    if oa and ob then return oa > ob end
    if oa then return true end
    if ob then return false end
    return a.buf > b.buf
  end)
  return items
end

return {
  {
    "folke/snacks.nvim",
    keys = {
      {
        "<leader>,",
        function()
          local origin_buf = vim.api.nvim_get_current_buf()
          Snacks.picker.buffers({
            sort_lastused = false,
            finder = buffers_in_bufferline_order,
            formatters = { file = { filename_first = true } },
            on_show = function(picker)
              for i, item in ipairs(picker:items()) do
                if item.buf == origin_buf then
                  picker.list:view(i)
                  Snacks.picker.actions.list_scroll_center(picker)
                  break
                end
              end
            end,
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
