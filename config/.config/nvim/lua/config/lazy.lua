-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- Set up leader keys before loading plugins
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Plugin setup with lazy.nvim
require("lazy").setup({
	spec = {

		-- General utilities
		{ "folke/which-key.nvim" }, -- Keybinding helper
		{ "nvim-treesitter/nvim-treesitter" }, -- Syntax highlighting

		-- Mason setup and LSP configurations
		{ "williamboman/mason.nvim", build = ":MasonUpdate", opts = {} },
		{ "williamboman/mason-lspconfig.nvim" }, -- Mason LSP integration
		{ "neovim/nvim-lspconfig" }, -- LSP configuration

		-- Code formatting with conform.nvim
		{
			"stevearc/conform.nvim",
			opts = {
				formatters_by_ft = { lua = { "stylua" } },
				format_on_save = { timeout_ms = 2000, lsp_fallback = true, quiet = false },
			},
		},
		{ "zapling/mason-conform.nvim" }, -- Mason integration for conform.nvim

		-- File navigation and icons
		{
			"nvim-tree/nvim-tree.lua",
			requires = { "nvim-tree/nvim-web-devicons" },
			config = true,
		},

		-- Color scheme
		{
			"oahlen/iceberg.nvim",
			lazy = false,
			priority = 1000,
			opts = { transparent = true },
			config = function()
				vim.cmd([[colorscheme iceberg-light]])
			end,
		},

		-- Autocompletion with nvim-cmp
		{
			"hrsh7th/nvim-cmp",
			event = "InsertEnter",
			dependencies = {
				"hrsh7th/cmp-path",
				"saadparwaiz1/cmp_luasnip",
				"L3MON4D3/LuaSnip",
				"dense-analysis/ale",
				"hrsh7th/cmp-emoji",
				"hrsh7th/cmp-nvim-lsp",
				"hrsh7th/cmp-buffer",
			},
			config = function()
				local cmp = require("cmp")
				require("cmp_nvim_lsp").default_capabilities()
				vim.opt.completeopt = "menu,menuone,noselect"

				cmp.setup({
					snippet = {
						expand = function(args)
							require("luasnip").lsp_expand(args.body)
						end,
					},
					mapping = cmp.mapping.preset.insert({
						["<C-p>"] = cmp.mapping.select_prev_item(),
						["<C-n>"] = cmp.mapping.select_next_item(),
						["<C-d>"] = cmp.mapping.scroll_docs(-4),
						["<C-f>"] = cmp.mapping.scroll_docs(4),
						["<C-Space>"] = cmp.mapping.complete(),
						["<C-e>"] = cmp.mapping.close(),
						["<CR>"] = cmp.mapping.confirm({ select = true }),
					}),
					sources = cmp.config.sources({
						{ name = "nvim_lsp" },
						{ name = "luasnip" },
					}, {
						{ name = "buffer" },
					}),
				})
			end,
		},

		-- Git integration
		{
			"lewis6991/gitsigns.nvim",
			requires = { "nvim-lua/plenary.nvim" },
			config = function()
				require("gitsigns").setup()
			end,
		},

		-- Fuzzy finder
		{
			"nvim-telescope/telescope.nvim",
			requires = { { "nvim-lua/plenary.nvim" } },
			config = function()
				require("telescope").setup({})
			end,
		},

		-- Status line
		{
			"hoob3rt/lualine.nvim",
			requires = { "kyazdani42/nvim-web-devicons", opt = true },
			config = function()
				require("lualine").setup({
					options = { theme = "iceberg_light" },
				})
			end,
		},

		-- Comment toggling
		{
			"numToStr/Comment.nvim",
			config = function()
				require("Comment").setup()
			end,
		},

		-- Auto pair completion
		{
			"windwp/nvim-autopairs",
			config = function()
				require("nvim-autopairs").setup()
			end,
		},

		-- Indentation guide
		{
			"lukas-reineke/indent-blankline.nvim",
			config = function()
				require("indent_blankline").setup({
					char = "│",
					show_trailing_blankline_indent = false,
				})
			end,
		},

		-- Plugin checker
		checker = { enabled = true },
	},
})
