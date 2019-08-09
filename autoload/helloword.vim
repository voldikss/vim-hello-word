" ========================================================================
" FileName: autoload/helloword.vim
" Description:
" Author: voldikss
" GitHub: https://github.com/voldikss
" ========================================================================

let g:helloword_words = {}
let g:helloword_failed_words = []
let g:helloword_passed_words = []

function! helloword#Start()
  if !exists('g:helloword_lexicon_path')
    echohl Error
    echo "g:helloword_lexicon_path was not set. Set it in vimrc or use HelloWordSetLexicon command"
    echohl None
    return
  endif

  if !filereadable(expand(g:helloword_lexicon_path, ':p'))
    echohl Error
    echo "g:helloword_lexicon_path is invalid"
    echohl None
    return
  endif

  let g:helloword_lexicon_path = expand(g:helloword_lexicon_path, ':p')
  try
    let f = readfile(g:helloword_lexicon_path)
    let db = eval(join(f, ''))
  catch /.*/
     echohl Error
     echo "Error occurs while reading lexicon file"
     echohl None
  endtry

  let g:helloword_words = db

  let patterns = [
    \ '选择题',
    \ '拼写题'
    \ ]
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
  let words_count = len(words)

  let modes = [
    \ '英——>汉',
    \ '汉——>英'
    \ ]
  let mode = str2nr(helloword#util#prompt('选择模式：', modes))
  if mode == 0
    return
  endif

  while 1
    let chosen_word = words[helloword#util#random(words_count)]
    " if word was passed, we wont check it later
    if index(g:helloword_passed_words, chosen_word) >= 0
      continue
    endif

    let word_list = [chosen_word]
    while len(word_list) < 4
      let random_num = helloword#util#random(words_count)
      let random_word = words[random_num]
      if random_word != chosen_word && index(word_list, random_word) < 0
        call add(word_list, random_word)
      endif
    endwhile

    if mode == 1  " English -> Chinese
      let prompt = chosen_word
      let answer = a:db[chosen_word]
      let candidates = map(copy(word_list), {key,val -> a:db[val]})
    else          " Chinese -> English
      let prompt = a:db[chosen_word]
      let answer = chosen_word
      let candidates = copy(word_list)
    endif

    call helloword#util#shuffle(candidates)

    let res = str2nr(helloword#util#prompt(prompt, candidates))
    if res == 0
      return
    elseif res <= 4 && candidates[res-1] == answer
      echohl MoreMsg
      echo "       ✔️ "
      echohl None
      call add(g:helloword_passed_words, chosen_word)
    else
      echohl WarningMsg
      echo "       ❌"
      echo "答案：" . answer
      echohl None
      call add(g:helloword_failed_words, chosen_word)
    endif
  endwhile
endfunction

function! s:PinXieTi(db)
  let words = keys(a:db)
  let max_words = len(words)
  while 1
    let chosen_word = words[helloword#util#random(max_words)]
    let spell = helloword#util#prompt(a:db[chosen_word], [])
    if helloword#util#safeTrim(spell) == ''
      return
    elseif helloword#util#safeTrim(spell) == chosen_word
      echohl MoreMsg
      echo repeat(' ', 25-len(spell)) . "✔️ "
      echohl None
      call add(g:helloword_passed_words, chosen_word)
    else
      echohl WarningMsg
      echo repeat(' ', 25-len(spell)) . "❌"
      echo "答案：" . chosen_word      
      echohl None
      call add(g:helloword_failed_words, chosen_word)
    endif
  endwhile
endfunction

function! helloword#Export() abort
  if exists('g:helloword_failed_words') && len(g:helloword_failed_words) > 0
    tabnew helloword.json
    call append(0, '{')
    for i in range(len(g:helloword_failed_words))
      let word = g:helloword_failed_words[i]
      let line = '  "'.word.'": '.'"'.g:helloword_words[word].'",'
      if i != len(g:helloword_failed_words)-1
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
  let g:helloword_lexicon_path = a:path
endfunction
