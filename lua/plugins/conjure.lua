-- ensure Aniseed and Conjure are installed and initialized first so that the
-- rest of the configuration can be in Fennel
return {
  {
    "Olical/conjure",
    branch = 'main',
    event = 'VeryLazy',
    dependencies = {
      'Olical/aniseed',
    },
    init = function()
      vim.g["conjure#filetypes"] = {
        "clojure",
        "fennel",
        "janet",
        "lisp",
        "lua",
        "python",
        "racket",
        "rust",
        "scheme",
        -- "sql",
      }
      vim.g["conjure#mapping#doc_word"] = false
    end,
  },
}
