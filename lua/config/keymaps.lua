-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- BAG Allows you to copy to the system clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

-- -----------------------------------------------
--                  BAG KEYMAPS
-- -----------------------------------------------
-- vim.keymap.set("n", "<leader>viam", vim.cmd.Ex)
vim.keymap.set("n", "<leader>viam", ":tabe .<CR>")
vim.keymap.set("n", "<leader>tabe", ":tabe<CR>")
vim.keymap.set("n", "<leader>tele", ":Telescope<CR>")
vim.keymap.set("n", "<leader>psh", ":!start powershell<CR>")
vim.keymap.set("n", ",n", ":tabn<CR>")
vim.keymap.set("n", ",b", ":tabp<CR>")
-- BAG doesn't work, I wanted to remap "ma" to "mf" in netrw
-- vim.keymap.set("n", "ma", "mf")

-- BAG Set search highlight color
vim.cmd("highlight Search guibg=#CCCC00 guifg=black")
vim.cmd("highlight IncSearch guibg=yellow guifg=blue")
vim.cmd("highlight CurSearch guibg=yellow guifg=red")

-- BAG via Copilot
-- Copy current path to system clipboard
vim.keymap.set("n", "<leader>cppath", function()
  local path = vim.fn.expand("%:p")
  vim.fn.setreg("+", path)
  print("Copied path: " .. path)
end, { desc = "Copy current file path to clipboard" })

vim.keymap.set("n", "<leader>setpath", function()
  local dir = vim.fn.expand("%:p:h")
  vim.cmd("cd " .. dir)
  print("Changed directory to: " .. dir)
end, { desc = "Change cwd to current file's directory" })

vim.keymap.set("n", "<leader>fae", function()
  vim.fn.setreg("+", "Brad Grissom\nField Application Engineer\nElatec Inc.")
  print("Copied FAE")
end, { desc = "Copy custom string to system clipboard" })

-- In Ex, using "v" to open a file sets the window width correctly
vim.api.nvim_create_autocmd("WinNew", {
  callback = function()
    if vim.fn.winwidth(0) < 80 then
      vim.cmd("vertical resize 80")
    end
  end,
})

-- Visual macro for searching in current file
-- :vmap T y:vim /<C-R>"/ <C-R>%<CR>:cw<CR>/<C-R>"<CR>
-- vim.keymap.set("n", "<leader>search", [[y:vim /<C-R>"/ <C-R>%<CR>:cw<CR>/<C-R>"<CR>]])
vim.keymap.set("n", "<leader>search", [[y:vim /<C-R>"/ <C-R>%<CR>:cw<CR>/<C-R>"<CR>]])

-- vim.keymap.set('v', '<leader>search', function()
--   -- Yank the visual selection
--   vim.cmd("normal! y")
--
--   -- Get the yanked text
--   local search_term = vim.fn.getreg('"')
--
--   -- Get the current file path
--   local current_file = vim.fn.expand("%:p")
--
--   -- Run vimgrep on the current file
--   vim.cmd("vimgrep /" .. search_term .. "/ " .. current_file)
--
--   -- Open quickfix window
--   vim.cmd("cw")
--
--   -- Start a search for the term
--   vim.cmd("/" .. search_term)
-- end, { desc = "Search visual selection in current file and open quickfix" })

vim.keymap.set(
  "n",
  "<leader>note",
  ":tabe C:/Users/b.grissom/OneDrive - ELATEC Cloud Global/Documents/notes_new_laptop.md<CR>",
  { desc = "Open my notes" }
)
vim.keymap.set(
  "n",
  "<leader>nvim",
  ":tabe C:/Users/b.grissom/AppData/Local/nvim/lua/theprimeagen/lazy/<CR>",
  { desc = "Open neovim config dir" }
)

-- Turn off auto completion
vim.g.cmp_enabled = true
vim.api.nvim_set_keymap("n", "<leader>noauto", [[:lua ToggleCmp()<CR>]], { noremap = true, silent = true })
function ToggleCmp()
  vim.g.cmp_enabled = not vim.g.cmp_enabled
  require("cmp").setup.buffer({ enabled = vim.g.cmp_enabled })
  print("Completion " .. (vim.g.cmp_enabled and "enabled" or "disabled"))
end
-- -----------------------------------------------
--              end BAG KEYMAPS
-- -----------------------------------------------
