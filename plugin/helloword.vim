" ========================================================================
" FileName: plugin/helloword.vim
" Description: 
" Author: voldikss
" GitHub: https://github.com/voldikss
" ========================================================================

command! HelloWord call helloword#Start()
command! HelloWordExport call helloword#Export()
command! -nargs=* -complete=file HelloWordSetLexicon call helloword#setLexiconPath(<q-args>)
