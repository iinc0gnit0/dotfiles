local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath("data").."/site/pack/packer/start/packer.nvim"
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({"git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path})
    vim.cmd([[packadd packer.nvim]])
    return true
  end
  return false
end
local packer_bootstrap = ensure_packer()

require("packer").startup(function(use)
  use("wbthomason/packer.nvim")
  use({
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate"
  })
  use("neovim/nvim-lspconfig")
  use("williamboman/mason.nvim")
  use("williamboman/mason-lspconfig.nvim")
  use("hrsh7th/nvim-cmp")
  use("hrsh7th/cmp-nvim-lsp")
  use("hrsh7th/cmp-buffer")
  use("hrsh7th/cmp-path")
  use({"L3MON4D3/LuaSnip", run = "make install_jsregexp"})
  use("saadparwaiz1/cmp_luasnip")
  use("stevearc/conform.nvim")
  use("ellisonleao/gruvbox.nvim")
  use({
    'nvim-lualine/lualine.nvim',
    requires = { 'nvim-tree/nvim-web-devicons', opt = true}
  })
  use({"lukas-reineke/indent-blankline.nvim", commit = "8299fe7"})

  use {
    "zbirenbaum/copilot.lua",
    requires = {
      "copilotlsp-nvim/copilot-lsp", -- (optional) for NES functionality
    },
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require('copilot').setup({
        filetypes = {
          markdown = true,
          yaml = true,
          sh = function ()
            if string.match(vim.fs.basename(vim.api.nvim_buf_get_name(0)), '^%.env.*') then
              -- disable for .env files
              return false
            end
            return true
          end,
        },
        panel = {
          enabled = true,
          auto_refresh = true,
          keymap = {
            jump_prev = "[[",
            jump_next = "]]",
            accept = "<CR>",
            refresh = "gr",
            open = "<M-CR>"
          },
          layout = {
            position = "bottom", -- | top | left | right | bottom |
            ratio = 0.4
          },
        },
        suggestion = {
          enabled = true,
          auto_trigger = true,
          hide_during_completion = true,
          debounce = 15,
          trigger_on_accept = true,
          keymap = {
            accept = "<M-l>",
            accept_word = false,
            accept_line = false,
            next = "<M-]>",
            prev = "<M-[>",
            dismiss = "<C-]>",
            toggle_auto_trigger = false,
          },
        },
        nes = {
          enabled = false, -- requires copilot-lsp as a dependency
          auto_trigger = false,
          keymap = {
            accept_and_goto = false,
            accept = false,
            dismiss = false,
          },
        },
        auth_provider_url = nil, -- URL to authentication provider, if not "https://github.com/"
        logger = {
          file = vim.fn.stdpath("log") .. "/copilot-lua.log",
          file_log_level = vim.log.levels.OFF,
          print_log_level = vim.log.levels.WARN,
          trace_lsp = "off", -- "off" | "debug" | "verbose"
          trace_lsp_progress = false,
          log_lsp_messages = false,
        },
        copilot_node_command = 'node', -- Node.js version must be > 22
        workspace_folders = {},
        copilot_model = "",
        disable_limit_reached_message = false,  -- Set to `true` to suppress completion limit reached popup
        root_dir = function()
          return vim.fs.dirname(vim.fs.find(".git", { upward = true })[1])
        end,
        should_attach = function(_, _)
          if not vim.bo.buflisted then
            logger.debug("not attaching, buffer is not 'buflisted'")
            return false
          end

          if vim.bo.buftype ~= "" then
            logger.debug("not attaching, buffer 'buftype' is " .. vim.bo.buftype)
            return false
          end

          return true
        end,
        server = {
          type = "nodejs", -- "nodejs" | "binary"
          custom_server_filepath = nil,
        },
        server_opts_overrides = {},
      })
    end
  }

  use({"wakatime/vim-wakatime"})
  use {
    "nvim-telescope/telescope.nvim", tag = '0.1.8',
    requires = { {'nvim-lua/plenary.nvim'} }
  }
use 'nvim-tree/nvim-web-devicons'

use {'kaarmu/typst.vim', ft = {'typst'}}

if packer_bootstrap then
  require("packer").sync()
end

end)

vim.cmd.packadd("packer.nvim")
