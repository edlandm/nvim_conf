return {
  "chrisgrieser/nvim-origami",
  event = "BufReadPost", -- later or on keypress would prevent saving folds
  opts = {
    startofline = true,
    keepFoldsAcrossSessions = true,
    pauseFoldsOnSearch = true,
    setupFoldKeymaps = true,
  },
}
