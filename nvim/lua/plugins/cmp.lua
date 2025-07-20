return {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  dependencies = {
    -- Snippet engine
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",

    -- Completion sources
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path", -- ADDED a comma here

    -- The new blink source
    "saghen/blink.cmp",

    -- UI for completion menu
    "hrsh7th/cmp-cmdline",
    "onsails/lspkind.nvim",
  },
  config = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")
    local lspkind = require("lspkind")

    -- Custom styling for blink to match your darkvoid theme
    local blink_style = {
      style = "minimal",
      source_name = {
        hl = "Comment", -- Use your theme's comment color for the source name
        text = "[*] ",
      },
    }

    cmp.setup({
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ["<C-k>"] = cmp.mapping.select_prev_item(),
        ["<C-j>"] = cmp.mapping.select_next_item(),
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
      }),
      -- Define the completion sources
      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "buffer" },
        { name = "path" },
        -- Add blink here with its custom styling
        { name = "blink", option = blink_style },
      }),
      -- Configure the look of the completion menu
      formatting = {
        format = lspkind.cmp_format({
          maxwidth = 50,
          ellipsis_char = "...",
          -- Use a custom format for blink to make it stand out
          before = function(entry, vim_item)
            if entry.source.name == "blink" then
              vim_item.kind = "󰄀" -- A custom icon for blink results
              vim_item.kind_hl_group = "DiagnosticHint"
            end
            return vim_item
          end,
        }),
      },
    })

    --
    -- KEYMAP TO TRIGGER BLINK
    --
    -- This keymap in Insert mode will trigger a completion that
    -- searches ALL sources, powered by blink.
    vim.keymap.set("i", "<C-s>", function()
      cmp.complete({
        config = {
          sources = {
            { name = "blink", option = blink_style },
          },
        },
      })
    end, { desc = "Blink: [S]earch all sources" })
  end,
}
