fun! ScalaKeywords()
    syn keyword scalaKeyword enum
    hi link scalaKeyword Keyword
endfu

autocmd filetype scala :call ScalaKeywords()
