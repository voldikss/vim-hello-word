" ========================================================================
" FileName: plugin/helloword.vim
" Description:
" Author: voldikss
" GitHub: https://github.com/voldikss
" ========================================================================

command! HelloWord call helloword#start()
command! HelloWordExport call helloword#export()
command! -nargs=* -complete=file HelloWordSetVocabulary call helloword#set_vocabulary_path(<q-args>)
