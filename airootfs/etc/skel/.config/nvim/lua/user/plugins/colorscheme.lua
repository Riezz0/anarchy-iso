return {
  {
    "AlphaTechnolog/pywal.nvim",
    name = "pywal",
    lazy = false, 
    priority = 1000,
    config = function()
      local pywal = require("pywal")
      
      -- 1. Setup pywal
      pywal.setup()
      
      -- 2. Apply the colorscheme
      vim.cmd("colorscheme pywal")

      -- 3. HOT RELOAD LOGIC
      -- Check where pywal is generating the file. Usually ~/.cache/wal/colors-wal.vim
      local wal_file = vim.fn.expand("~/.cache/wal/colors-wal.vim")
      
      local uv = vim.uv or vim.loop
      local w = uv.new_fs_event()

      local function on_change()
        vim.schedule(function()
          -- A. Clear the cached Lua module so it re-reads the file
          package.loaded["pywal"] = nil
          package.loaded["pywal.core"] = nil -- Sometimes needed for deep reloading
          package.loaded["pywal.config"] = nil 

          -- B. Re-run setup
          require("pywal").setup()
          
          -- C. Re-apply colorscheme
          vim.cmd("colorscheme pywal")
          
          -- D. Refresh Lualine (Ensure your lualine theme is set to 'pywal' or 'auto')
          if package.loaded["lualine"] then
            require("lualine").refresh()
          end

          print("Pywal colors reloaded!")
        end)
      end

      -- Start watching
      w:start(wal_file, {}, on_change)
    end,
  },
}
