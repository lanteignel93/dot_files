return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "github/copilot.vim" },
      { "nvim-lua/plenary.nvim", branch = "master" },
    },
    build = "make tiktoken",
    opts = {
      debug = false, -- Enable debugging
      -- window = {
      --   relative = "editor", -- 'editor' | 'win' | 'cursor' | 'mouse'
      --   border = "rounded", -- 'none' | 'single' | 'double' | 'rounded'
      -- },
      mappings = {
        close = "q", -- Close window
        reset = "<C-l>", -- Reset chat
        submit = "<CR>", -- Submit user input
      },
      prompts = {
        -- Custom prompt commands
        Explain = "Explain how this code works:",
        Review = "Review this code and provide suggestions:",
        Tests = "Generate unit tests for this code:",
        Refactor = "Refactor this code to improve:",
      },
    },
    -- If you want to lazy load on specific commands
    cmd = {
      "CopilotChat",
      "CopilotChatToggle",
      "CopilotChatExplain",
      "CopilotChatTests",
      "CopilotChatReview",
      "CopilotChatRefactor",
    },
  },
}
