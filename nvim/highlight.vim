fun! ScalaKeywords()
    syn keyword scalaKeyword enum
    hi link scalaKeyword Keyword
endfu

autocmd filetype scala :call ScalaKeywords()
autocmd BufNewFile,BufRead *.pi set filetype=piforall
autocmd filetype piforall :set syntax=haskell
