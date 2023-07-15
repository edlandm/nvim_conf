return {
    'gbprod/substitute.nvim',
    opts = {},
    main = "substitute",
    keys = {
        { "<leader>x", "<cmd>lua require'substitute.range'.operator()<cr>", desc = "substitute text in <motion1> over range in <motion2>" },
        { "cx", "<cmd>lua require'substitute.exchange'.operator()<cr>", desc = "exchange <motion>" },
        { "X", "<cmd>lua require'substitute.exchange'.visual()<cr>", mode = "v", desc = "exchange selection" },
    }
}
