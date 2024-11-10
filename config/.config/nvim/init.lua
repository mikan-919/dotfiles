vim.scriptencoding = "utf-8"
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"
vim.opt.tabstop = 2
vim.opt.number = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2

require("config.lazy-loader")
require("plugins.user-command")
require("plugins.auto-command")
require("plugins.keymap")
