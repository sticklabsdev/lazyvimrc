return {
  "nvim-mini/mini.files",
  opts = {
    mappings = {
      toggle_hidden = "g.",
      change_cwd = "et",
    },
  },
  config = function(_, opts)
    require("mini.files").setup(opts)

    -- `toggle_hidden`/`change_cwd` aren't mini.files-core mappings; they're
    -- wired up by LazyVim's `lazyvim.plugins.extras.editor.mini-files` extra,
    -- which reads these same `opts.mappings` keys. Defining our own `config`
    -- here replaces that extra's `config` entirely (lazy.nvim only runs one
    -- per plugin), so its behavior is reproduced below to avoid losing it.
    local show_dotfiles = true
    local filter_show = function(fs_entry)
      return true
    end
    local filter_hide = function(fs_entry)
      return not vim.startswith(fs_entry.name, ".")
    end

    local toggle_dotfiles = function()
      show_dotfiles = not show_dotfiles
      local new_filter = show_dotfiles and filter_show or filter_hide
      require("mini.files").refresh({ content = { filter = new_filter } })
    end

    local map_split = function(buf_id, lhs, direction, close_on_file)
      local rhs = function()
        local new_target_window
        local cur_target_window = require("mini.files").get_explorer_state().target_window
        if cur_target_window ~= nil then
          vim.api.nvim_win_call(cur_target_window, function()
            vim.cmd("belowright " .. direction .. " split")
            new_target_window = vim.api.nvim_get_current_win()
          end)

          require("mini.files").set_target_window(new_target_window)
          require("mini.files").go_in({ close_on_file = close_on_file })
        end
      end

      local desc = "Open in " .. direction .. " split"
      if close_on_file then
        desc = desc .. " and close"
      end
      vim.keymap.set("n", lhs, rhs, { buffer = buf_id, desc = desc })
    end

    -- Sets cwd to the directory currently being browsed (dirname of the
    -- entry under cursor), regardless of which entry the cursor is on.
    local files_set_cwd = function()
      local cur_entry_path = MiniFiles.get_fs_entry().path
      local cur_directory = vim.fs.dirname(cur_entry_path)
      if cur_directory ~= nil then
        vim.fn.chdir(cur_directory)
      end
    end

    vim.api.nvim_create_autocmd("User", {
      pattern = "MiniFilesBufferCreate",
      callback = function(args)
        local buf_id = args.data.buf_id

        vim.keymap.set(
          "n",
          opts.mappings and opts.mappings.toggle_hidden or "g.",
          toggle_dotfiles,
          { buffer = buf_id, desc = "Toggle hidden files" }
        )

        vim.keymap.set(
          "n",
          opts.mappings and opts.mappings.change_cwd or "gc",
          files_set_cwd,
          { buffer = buf_id, desc = "Set cwd" }
        )

        map_split(buf_id, opts.mappings and opts.mappings.go_in_horizontal or "<C-w>s", "horizontal", false)
        map_split(buf_id, opts.mappings and opts.mappings.go_in_vertical or "<C-w>v", "vertical", false)
        map_split(buf_id, opts.mappings and opts.mappings.go_in_horizontal_plus or "<C-w>S", "horizontal", true)
        map_split(buf_id, opts.mappings and opts.mappings.go_in_vertical_plus or "<C-w>V", "vertical", true)
      end,
    })

    vim.api.nvim_create_autocmd("User", {
      pattern = "MiniFilesActionRename",
      callback = function(event)
        Snacks.rename.on_rename_file(event.data.from, event.data.to)
      end,
    })

    -- Persist bookmarks (the `m`/`'` marks) across sessions.
    local bookmarks_file = vim.fn.stdpath("data") .. "/mini-files-bookmarks.json"

    local function read_bookmarks()
      local f = io.open(bookmarks_file, "r")
      if not f then
        return {}
      end
      local content = f:read("*a")
      f:close()
      local ok, data = pcall(vim.json.decode, content)
      return (ok and type(data) == "table") and data or {}
    end

    local function write_bookmarks(bookmarks)
      local f = io.open(bookmarks_file, "w")
      if not f then
        return
      end
      f:write(vim.json.encode(bookmarks))
      f:close()
    end

    vim.api.nvim_create_autocmd("User", {
      pattern = "MiniFilesExplorerOpen",
      callback = function()
        for id, data in pairs(read_bookmarks()) do
          MiniFiles.set_bookmark(id, data.path, { desc = data.desc })
        end
      end,
    })

    vim.api.nvim_create_autocmd("User", {
      pattern = "MiniFilesExplorerClose",
      callback = function()
        local bookmarks = MiniFiles.get_explorer_state().bookmarks
        local to_save = {}
        for id, data in pairs(bookmarks) do
          -- skip the auto-set "previous location" mark and non-path (callable) bookmarks
          if id ~= "'" and type(data.path) == "string" then
            to_save[id] = { path = data.path, desc = data.desc }
          end
        end
        write_bookmarks(to_save)
      end,
    })

    -- Show file size as virtual text at end of line (mini.files has no
    -- built-in metadata column; this is the documented extmark approach).
    local size_ns = vim.api.nvim_create_namespace("mini-files-sizes")

    local function format_size(bytes)
      if bytes < 1024 then
        return bytes .. "B"
      elseif bytes < 1024 * 1024 then
        return string.format("%.1fK", bytes / 1024)
      elseif bytes < 1024 * 1024 * 1024 then
        return string.format("%.1fM", bytes / (1024 * 1024))
      else
        return string.format("%.1fG", bytes / (1024 * 1024 * 1024))
      end
    end

    vim.api.nvim_create_autocmd("User", {
      pattern = "MiniFilesBufferUpdate",
      callback = function(args)
        local buf_id = args.data.buf_id
        vim.api.nvim_buf_clear_namespace(buf_id, size_ns, 0, -1)
        for line = 1, vim.api.nvim_buf_line_count(buf_id) do
          local entry = MiniFiles.get_fs_entry(buf_id, line)
          local stat = entry and entry.fs_type == "file" and vim.uv.fs_stat(entry.path)
          if stat then
            vim.api.nvim_buf_set_extmark(buf_id, size_ns, line - 1, 0, {
              virt_text = { { format_size(stat.size), "Comment" } },
              virt_text_pos = "eol",
            })
          end
        end
      end,
    })
  end,
  keys = {
    {
      "<leader>et",
      function()
        require("mini.files").open(vim.api.nvim_buf_get_name(0), true)
      end,
      desc = "Open mini.files (Directory of Current File)",
    },
    {
      "<leader>eT",
      function()
        require("mini.files").open(vim.uv.cwd(), true)
      end,
      desc = "Open mini.files (cwd)",
    },
  },
}
