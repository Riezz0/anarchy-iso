vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness

-- Exit insert mode
keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode" })
keymap.set("i", "kj", "<ESC>", { desc = "Exit insert mode" })

-- Clear search highlights
keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear highlights" })

-- Increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" })
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" })

-- Window splits
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split vertically" })
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split horizontally" })
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Equal split size" })
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close split" })

-- Window navigation
keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Resize windows
keymap.set("n", "<C-Up>", ":resize -2<CR>", { desc = "Decrease window height" })
keymap.set("n", "<C-Down>", ":resize +2<CR>", { desc = "Increase window height" })
keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width" })
keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase window width" })

-- Buffer management
keymap.set("n", "<leader>bn", "<cmd>bnext<CR>", { desc = "Next buffer" })
keymap.set("n", "<leader>bp", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
keymap.set("n", "<leader>bx", "<cmd>bdelete<CR>", { desc = "Close buffer" })
keymap.set("n", "<leader>bf", "<cmd>Telescope buffers<CR>", { desc = "Find buffer" })

-- Tab management
keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "New tab" })
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close tab" })
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Next tab" })
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Previous tab" })
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Tab from buffer" })

-- Move lines up/down in visual mode
keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up" })

-- Keep cursor centered when scrolling
keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down centered" })
keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up centered" })

-- Keep search results centered
keymap.set("n", "n", "nzzzv", { desc = "Next search result centered" })
keymap.set("n", "N", "Nzzzv", { desc = "Previous search result centered" })

-- Better paste (don't yank replaced text)
keymap.set("x", "<leader>p", '"_dP', { desc = "Paste without yanking" })

-- Yank to system clipboard
keymap.set("n", "<leader>y", '"+y', { desc = "Yank to clipboard" })
keymap.set("v", "<leader>y", '"+y', { desc = "Yank to clipboard" })

-- Delete to black hole register
keymap.set("n", "<leader>d", '"_d', { desc = "Delete without yanking" })
keymap.set("v", "<leader>d", '"_d', { desc = "Delete without yanking" })

-- File explorer
keymap.set("n", "<leader>ee", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
keymap.set("n", "<leader>ef", "<cmd>NvimTreeFindFileToggle<CR>", { desc = "Explorer on current file" })
keymap.set("n", "<leader>ec", "<cmd>NvimTreeCollapse<CR>", { desc = "Collapse explorer" })
keymap.set("n", "<leader>er", "<cmd>NvimTreeRefresh<CR>", { desc = "Refresh explorer" })

-- Session management
keymap.set("n", "<leader>wr", "<cmd>SessionRestore<CR>", { desc = "Restore session" })
keymap.set("n", "<leader>ws", "<cmd>SessionSave<CR>", { desc = "Save session" })

-- Colorizer
keymap.set("n", "<leader>cc", "<cmd>ColorizerToggle<CR>", { desc = "Toggle colorizer" })

-- Terminal
keymap.set("n", "<F7>", "<cmd>ToggleTerm<CR>", { desc = "Toggle terminal" })
keymap.set("t", "<F7>", "<cmd>ToggleTerm<CR>", { desc = "Toggle terminal" })
keymap.set("n", "<leader>tf", "<cmd>ToggleTerm direction=float<CR>", { desc = "Float terminal" })
keymap.set("n", "<leader>th", "<cmd>ToggleTerm direction=horizontal size=12<CR>", { desc = "Horizontal terminal" })
keymap.set("n", "<leader>tv", "<cmd>ToggleTerm direction=vertical size=80<CR>", { desc = "Vertical terminal" })

-- Git (basic)
keymap.set("n", "<leader>gs", "<cmd>Git<CR>", { desc = "Git status" })
keymap.set("n", "<leader>gp", "<cmd>Git push<CR>", { desc = "Git push" })
keymap.set("n", "<leader>gl", "<cmd>Git log<CR>", { desc = "Git log" })

-- Quick save/quit
keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = "Save file" })
keymap.set("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit" })
keymap.set("n", "<leader>Q", "<cmd>qa!<CR>", { desc = "Force quit all" })

-- Select all
keymap.set("n", "<leader>a", "ggVG", { desc = "Select all" })

-- Format file
keymap.set("n", "<leader>ff", "<cmd>lua vim.lsp.buf.format()<CR>", { desc = "Format file" })

-- Go to beginning/end of line
keymap.set("n", "H", "^", { desc = "Start of line" })
keymap.set("n", "L", "$", { desc = "End of line" })
