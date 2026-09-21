-- Show filename before directory in path displays (files, grep results, buffers)
local function filename_first(opts, path)
  local cwd = opts.cwd or vim.loop.cwd()
  local rel = require("plenary.path"):new(path):make_relative(cwd)
  local tail = vim.fn.fnamemodify(rel, ":t")
  local dir = vim.fn.fnamemodify(rel, ":h")
  return dir == "." and tail or (tail .. "  " .. dir)
end

-- Custom buffers picker: ordered to match the reverse of bufferline's tab order
-- (same order H/L cycle through), with the buffer we opened from pre-selected
-- instead of telescope's default MRU "%"/"#" selection.
local function bufferline_order_buffers()
  local origin_buf = vim.api.nvim_get_current_buf()
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local make_entry = require("telescope.make_entry")
  local conf = require("telescope.config").values

  local bufnrs = vim.tbl_filter(function(b)
    return vim.fn.buflisted(b) == 1
  end, vim.api.nvim_list_bufs())
  if #bufnrs == 0 then
    return
  end

  local order = {}
  local ok, bufferline = pcall(require, "bufferline")
  if ok then
    for i, elem in ipairs(bufferline.get_elements().elements) do
      order[elem.id] = i
    end
  end
  table.sort(bufnrs, function(a, b)
    local oa, ob = order[a], order[b]
    if oa and ob then
      return oa > ob
    end
    if oa then
      return true
    end
    if ob then
      return false
    end
    return a > b
  end)

  local opts = { path_display = filename_first }
  local buffers, default_selection_idx = {}, 1
  for i, bufnr in ipairs(bufnrs) do
    local flag = bufnr == vim.fn.bufnr("") and "%" or (bufnr == vim.fn.bufnr("#") and "#" or " ")
    table.insert(buffers, { bufnr = bufnr, flag = flag, info = vim.fn.getbufinfo(bufnr)[1] })
    if bufnr == origin_buf then
      default_selection_idx = i
    end
  end
  opts.bufnr_width = #tostring(math.max(unpack(bufnrs)))

  pickers.new(opts, {
    prompt_title = "Buffers",
    finder = finders.new_table({
      results = buffers,
      entry_maker = make_entry.gen_from_buffer(opts),
    }),
    previewer = conf.grep_previewer(opts),
    sorter = conf.generic_sorter(opts),
    default_selection_index = default_selection_idx,
  }):find()
end

return {
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      { "<leader>,", bufferline_order_buffers, desc = "Buffers" },
      { "<leader>ff", LazyVim.pick("files", { path_display = filename_first }), desc = "Find Files (Root Dir)" },
      {
        "<leader>fF",
        LazyVim.pick("files", { root = false, path_display = filename_first }),
        desc = "Find Files (cwd)",
      },
      { "<leader>sg", LazyVim.pick("live_grep", { path_display = filename_first }), desc = "Grep (Root Dir)" },
      {
        "<leader>sG",
        LazyVim.pick("live_grep", { root = false, path_display = filename_first }),
        desc = "Grep (cwd)",
      },
      {
        "<leader>sw",
        LazyVim.pick("grep_string", { word_match = "-w", path_display = filename_first }),
        desc = "Word (Root Dir)",
      },
      {
        "<leader>sW",
        LazyVim.pick("grep_string", { root = false, word_match = "-w", path_display = filename_first }),
        desc = "Word (cwd)",
      },
      {
        "<leader>sw",
        LazyVim.pick("grep_string", { path_display = filename_first }),
        mode = "x",
        desc = "Selection (Root Dir)",
      },
      {
        "<leader>sW",
        LazyVim.pick("grep_string", { root = false, path_display = filename_first }),
        mode = "x",
        desc = "Selection (cwd)",
      },
      {
        "<leader>fR",
        LazyVim.pick("oldfiles", { cwd = vim.uv.cwd(), path_display = filename_first }),
        desc = "Recent (cwd)",
      },
    },
  },
}
