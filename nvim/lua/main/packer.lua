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
      init = function()
        vim.g.copilot_nes_debounce = 500
      end,
    },
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        filetypes = {
          ["*"] = true,
          sh = function ()
            if string.match(vim.fs.basename(vim.api.nvim_buf_get_name(0)), '^%.env.*') then
              -- disable for .env files
              return false
            end
            return true
          end,
        },
        nes = {
          enabled = true,
          keymap = {
            accept_and_goto = "<leader>p",
            accept = false,
            dismiss = "<Esc>",
          },
        },
        server_opt_overrides = {
          offset_encoding = "utf-16"
        }
      })
      require("copilot.suggestion").toggle_auto_trigger()
    end,
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
