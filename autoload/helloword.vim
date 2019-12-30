" ========================================================================
" FileName: autoload/helloword.vim
" Description:
" Author: voldikss
" GitHub: https://github.com/voldikss
" ========================================================================

let s:helloword_failed_words = {}
let s:vacabulary = {}
let s:problem_winid = 0
let s:result_winid = 0
let s:bar = '========================================================='
let s:mode = 0

function! helloword#start() abort
  if !exists('g:helloword_vocabulary_path')
    let message = "g:helloword_vocabulary_path was not set. Set it in vimrc or use HelloWordSetvocabulary command"
    call helloword#util#show_msg(message, 'error')
    return
  endif

  if !filereadable(expand(g:helloword_vocabulary_path, ':p'))
    let message = "g:helloword_vocabulary_path is invalid"
    call helloword#util#show_msg(message, 'error')
    return
  endif

  let g:helloword_vocabulary_path = expand(g:helloword_vocabulary_path, ':p')
  try
    let f = readfile(g:helloword_vocabulary_path)
    let s:vocabulary = eval(join(f, ''))
  catch /.*/
    let message = "Error occurs while reading vocabulary file"
    call helloword#util#show_msg(message, 'error')
    return
  endtry

  let s:mode = str2nr(input('1.拼写题 2.选择题(英——>汉) 3.选择题(汉——>英): '))
  if index([1,2,3], s:mode) < 0
    call helloword#util#show_msg('Incorrect selection', 'warning')
    return
  endif

  " Split window
  tabnew helloword
  noswapfile bo pedit!
  enew
  call helloword#util#buf_config()
  let s:problem_winid = winnr()
  wincmd p
  call helloword#util#buf_config()
  let s:result_winid = winnr()

  " Start
  if s:mode == 1
    call s:pin_xie_ti()
  else
    call s:xuan_ze_ti()
  endif
endfunction

function! s:xuan_ze_ti() abort
  while 1
    let words = keys(s:vocabulary)
    let count = len(words)
    if count == 0
      call helloword#util#show_msg('单词已背完', 'more')
      return
    endif
    let choice = words[helloword#util#random(count)]
    let word_list = [choice]
    while len(word_list) < 4
      let random_num = helloword#util#random(count)
      let random_word = words[random_num]
      if random_word != choice && index(word_list, random_word) < 0
        call add(word_list, random_word)
      endif
    endwhile

    " Give the question
    if s:mode == 2  " English -> Chinese
      let prompt = choice
      let answer = s:vocabulary[choice]
      let candidates = map(copy(word_list), {key,val -> s:vocabulary[val]})
    else          " Chinese -> English
      let prompt = s:vocabulary[choice]
      let answer = choice
      let candidates = copy(word_list)
    endif

    call helloword#util#shuffle(candidates)
    let item = []
    for i in range(len(candidates))
      call add(item, i+1 . '. ' . candidates[i])
    endfor
    call helloword#util#display(s:problem_winid, [s:bar, prompt, ''] + item)

    " Check the answer
    let ans = str2nr(input('Choose: '))
    if ans == 0
      return
    elseif ans <= 4 && candidates[ans-1] == answer
      let message = "回答正确"
      call remove(s:vocabulary, choice)
    else
      let message = "回答错误，答案是：" . answer
      let s:helloword_failed_words[choice] = s:vocabulary[choice]
    endif
    call helloword#util#display(s:result_winid, message)
  endwhile
endfunction

function! s:pin_xie_ti() abort
  while 1
    let words = keys(s:vocabulary)
    let count = len(words)
    if count == 0
      call helloword#util#show_msg('单词已背完', 'more')
      return
    endif
    let choice = words[helloword#util#random(count)]
    call helloword#util#display(s:problem_winid, [s:bar, s:vocabulary[choice]])
    let spell = input('Input answer: ')
    if helloword#util#safe_trim(spell) == ''
      return
    elseif helloword#util#safe_trim(spell) == choice
      let message = "回答正确"
      call remove(s:vocabulary, choice)
    else
      let message = "回答错误：" . choice
      let s:helloword_failed_words[choice] = s:vocabulary[choice]
    endif
    call helloword#util#display(s:result_winid, message)
  endwhile
endfunction

function! helloword#export() abort
  let words = keys(s:helloword_failed_words)
  let words_len = len(words)
  if exists('s:helloword_failed_words') && words_len > 0
    tabnew helloword.json
    call append(0, '{')
    let cnt = 0
    for word in words
      if cnt == words_len - 1
        let line = '  "'.word.'": '.'"'.s:helloword_failed_words[word].'"'
      else
        let line = '  "'.word.'": '.'"'.s:helloword_failed_words[word].'",'
      endif
      call append(line('$')-1, line)
      let cnt += 1
    endfor
    call append(line('$')-1, '}')
    normal dd
    normal gg
  else
    let message = "No words to export"
    call helloword#util#show_msg(message, 'warning')
  endif
endfunction

function! helloword#set_vocabulary_path(path)
  if !filereadable(expand(a:path, ':p'))
    let message = "Vocabulary path is invalid"
    call helloword#util#show_msg(message, 'warning')
    return
  endif
  let g:helloword_vocabulary_path = fnamemodify(a:path, ':p')
endfunction
