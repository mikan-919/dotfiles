-- Plugin setup with lazy.nvim
require("lazy").setup({
	spec = {
		-- General utilities
		{ "folke/which-key.nvim" }, -- Keybinding helper
		{ "nvim-treesitter/nvim-treesitter" }, -- Syntax highlighting

		-- Mason setup and LSP configurations and Conform setup
		{ "williamboman/mason.nvim", build = ":MasonUpdate", opts = {} },
		{ "williamboman/mason-lspconfig.nvim" }, -- Mason LSP integration
		{ "neovim/nvim-lspconfig" }, -- LSP configuration
		{ "zapling/mason-conform.nvim" }, -- Mason integration for conform.nvim
		{
			"stevearc/conform.nvim",
			opts = {
				formatters_by_ft = { lua = { "stylua" } },
				format_on_save = { timeout_ms = 2000, lsp_fallback = true, quiet = false },
			},
		},

		-- File navigation and icons
		{
			"nvim-tree/nvim-tree.lua",
			requires = { "nvim-tree/nvim-web-devicons" },
			config = true,
		},

		-- Color scheme
		{
			"oahlen/iceberg.nvim",
			opts = { transparent = true },
			config = function()
				vim.cmd([[colorscheme iceberg]])
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
			ops = {},
		},

		-- Status line
		{
			"hoob3rt/lualine.nvim",
			requires = { "kyazdani42/nvim-web-devicons", opt = true },
			config = function()
				require("lualine").setup({
					options = { theme = "iceberg" },
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
		--		{
		--			"lukas-reineke/indent-blankline.nvim",
		--			config = function()
		--				require("indent_blankline").setup({
		--					char = "│",
		--					show_trailing_blankline_indent = false,
		--				})
		--			end,
		--		},

		-- Plugin checker
		checker = { enabled = true },
	},
})
