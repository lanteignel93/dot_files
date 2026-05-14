return {
  "epwalsh/obsidian.nvim",
  version = "*",

  lazy = false,
  ft = "markdown",

  dependencies = {
    "nvim-lua/plenary.nvim",
  },

  opts = {
    workspaces = {
      {
        name = "Coding",
        path = vim.fn.expand("~/obsidian/Coding"),
      },
      {
        name = "Personal",
        path = vim.fn.expand("~/obsidian/Personal"),
      },
      {
        name = "Projects",
        path = vim.fn.expand("~/obsidian/Projects"),
      },
    },

    default_workspace = "Coding",

    templates = {
      folder = vim.fn.expand("~/obsidian/Coding/Templates"),
      date_format = "%Y-%m-%d",
      time_format = "%H:%M",
    },

    completion = {
      nvim_cmp = true,
    },

    note_frontmatter_func = function(note)
      -- replace spaces with hyphens, lowercase, strip punctuation
      local filename = note.title
          :gsub(" ", "-")
          :gsub("[^A-Za-z0-9%-]", "")
          :lower()

      note.id = filename -- this controls the filename

      return {
        id = note.id,
        aliases = {},
        tags = {},
        created = os.date("%Y-%m-%d %H:%M"),
      }
    end,
  },

  config = function(_, opts)
    require("obsidian").setup(opts)
  end,

  keys = {
    {
      "<leader>on",
      function()
        -- Prompt for title (cannot break)
        local title = vim.fn.input("New note title: ")
        if not title or title == "" then
          return
        end

        -- Convert to filename
        local filename = title
            :gsub(" ", "-")
            :gsub("[^A-Za-z0-9%-]", "")
            :lower()

        -- *** HARDCODE YOUR WORKSPACE PATH HERE ***
        local ws_path = vim.fn.expand("~/obsidian/Coding")

        -- Full path to new note
        local fullpath = ws_path .. "/" .. filename .. ".md"

        -- Create/open the file
        vim.cmd("edit " .. fullpath)

        -- Insert template
        vim.cmd("ObsidianTemplate project_note")
      end,
      mode = "n",
      desc = "Obsidian: New Note (title prompt + template)",
    },
    {
      "<leader>od",
      "<cmd>ObsidianToday<CR>",
      mode = "n",
      desc = "Obsidian: Daily Note",
    },

    {
      "<leader>oo",
      "<cmd>ObsidianQuickSwitch<CR>",
      mode = "n",
      desc = "Obsidian: Quick Switch",
    },

    {
      "<leader>os",
      "<cmd>ObsidianWorkspace<CR>",
      mode = "n",
      desc = "Obsidian: Switch Workspace",
    },

    -- ⭐ Checkbox toggling (no insert mode needed)
    {
      "<leader>oc",
      "<cmd>ObsidianToggleCheckbox<CR>",
      mode = "n",
      desc = "Obsidian: Toggle Checkbox",
    },
  },
}
