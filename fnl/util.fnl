(module dotfiles.util
  {require {nvim aniseed.nvim}})

(def config-path (nvim.fn.stdpath "config"))

(defn expand [path]
  (nvim.fn.expand path))

(defn glob [path]
  (nvim.fn.glob path true true true))

(defn exists? [path]
  (= (nvim.fn.filereadable path) 1))

(defn lua-file [path]
  (nvim.ex.luafile path))
