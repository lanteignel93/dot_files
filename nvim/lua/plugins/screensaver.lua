return {
  {
    "Root-lee/screensaver.nvim",
    event = "VeryLazy", -- No need to load it on startup
    opts = {
      -- Start after 5 minutes of inactivity (default is 1 min)
      idle_ms = 5 * 60 * 1000,

      -- Choose your favorite animation:
      -- "rain", "game_of_life", "move_left", "scramble",
      -- "random_case", "bounce", "starfield", "pipes",
      -- "fire", "snow", "zoo"
      animation = "game_of_life",

      -- Support for external terminal apps if you have them installed
      custom_commands = {
        -- aquarium = "asciiquarium -t",
        -- matrix = "cmatrix -s",
      },

      -- Key to exit the screensaver (default is <Esc>)
      exit_key = "<Esc>",
    },
    keys = {
      -- Manual trigger for when you're heading to get coffee
      { "<leader>ss", "<cmd>Screensaver<cr>", desc = "Screensaver: Start Now" },
    },
  }
}
