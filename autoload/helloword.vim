" ========================================================================
" FileName: autoload/helloword.vim
" Description: 
" Author: voldikss
" GitHub: https://github.com/voldikss
" ========================================================================

let g:words_db = {}
let g:failed_words = []
let g:passed_words = []

function! helloword#Start()
  if !exists('g:lexicon_path') || !filereadable(g:lexicon_path)
    echoerr "g:lexicon_path was not set. Set it in vimrc or use HelloWordLexicon command"
    return
  endif
  let f = readfile(g:lexicon_path)
  let db = eval(join(f, ''))
  let g:words_db = db

  let patterns = [
    \ '选择题',
    \ '拼写题'
    \ ]
  echo
  let pattern = helloword#util#prompt('选择考察形式：', patterns)

  if pattern == 0
    return
  elseif pattern == 1
    call s:XuanZeTi(db)
  else
    call s:PinXieTi(db)
  endif
endfunction

function! s:XuanZeTi(db)
  let words = keys(a:db)
  let max_words = len(words)

  let modes = [
    \ '英——>汉',
    \ '汉——>英'
    \ ]
  let mode = helloword#util#prompt('选择模式：', modes)
  if mode == 0
    return
  endif

  while 1
    let selected = words[helloword#util#random(max_words)]
    " if word was passed, we wont check it later
    if index(g:passed_words, selected) >= 0
      continue
    endif

    let word_list = [selected]

    while len(word_list) < 4
      let random_num = helloword#util#random(max_words)
      let random_word = words[random_num]
      if random_word != selected && index(word_list, random_word) < 0
        call add(word_list, random_word)
      endif
    endwhile

    if mode == 1  " English -> Chinese
      let prompt = selected
      let answer = a:db[selected]
      let candidates = []
      for w in word_list
        call add(candidates, a:db[w])
      endfor
    else
      let prompt = a:db[selected]
      let answer = selected
      let candidates = []
      for w in word_list
        call add(candidates, w) " deep copy
      endfor
    endif

    call helloword#util#shuffle(candidates)

    let res = helloword#util#prompt(prompt, candidates)
    if res == 0
      return
    endif

    if candidates[res-1] == answer
      echohl MoreMsg
      echo "       ✔️ "
      echohl None
      call add(g:passed_words, selected)
    else
      echohl WarningMsg
      echo "       ❌"
      echo "答案：" . answer
      echohl None
      call add(g:failed_words, selected)
    endif
  endwhile
endfunction

function! s:PinXieTi(db)
  let words = keys(a:db)
  let max_words = len(words)
  while 1
    let selected = words[helloword#util#random(max_words)]
    let spell = helloword#util#prompt(a:db[selected], [])
    if trim(spell) == ''
      return
    elseif trim(spell) == selected
      echohl MoreMsg
      echo repeat(' ', 25-len(spell)) . "✔️ "
      echohl None
      call add(g:passed_words, selected)
    else
      echohl WarningMsg
      echo repeat(' ', 25-len(spell)) . "❌"
      echo "答案：" . selected
      echohl None
      call add(g:failed_words, selected)
    endif
  endwhile
endfunction

function! helloword#Export() abort
  if exists('g:failed_words') && len(g:failed_words) > 0
    tabnew helloword.json
    call append(0, '{')
    for i in range(len(g:failed_words))
      let word = g:failed_words[i]
      let line = '  "'.word.'": '.'"'.g:words_db[word].'",'
      if i != len(g:failed_words)-1
        call append(line('$')-1, line)
      else
        call append(line('$')-1, line[:-2])
      endif
    endfor
    call append(line('$')-1, '}')
    normal dd
    normal gg
  else
    echohl WarningMsg
    echo "No words to export"
    echohl None
  endif
endfunction

function! helloword#setLexiconPath(path)
  let g:lexicon_path = a:path
endfunction

