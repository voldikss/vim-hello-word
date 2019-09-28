" ========================================================================
" FileName: autoload/helloword.vim
" Description:
" Author: voldikss
" GitHub: https://github.com/voldikss
" ========================================================================

let g:helloword_failed_words = {}

function! helloword#Start()
  if !exists('g:helloword_vocabulary_path')
    echohl Error
    echo "g:helloword_vocabulary_path was not set. Set it in vimrc or use HelloWordSetvocabulary command"
    echohl None
    return
  endif

  if !filereadable(expand(g:helloword_vocabulary_path, ':p'))
    echohl Error
    echo "g:helloword_vocabulary_path is invalid"
    echohl None
    return
  endif

  let g:helloword_vocabulary_path = expand(g:helloword_vocabulary_path, ':p')
  try
    let f = readfile(g:helloword_vocabulary_path)
    let db = eval(join(f, ''))
  catch /.*/
     echohl Error
     echo "Error occurs while reading vocabulary file"
     echohl None
  endtry

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
  let vocabulary = a:db

  let modes = [
    \ '英——>汉',
    \ '汉——>英'
    \ ]
  let mode = str2nr(helloword#util#prompt('选择模式：', modes))
  if mode == 0
    return
  endif

  while 1
    let words = keys(vocabulary)
    let count = len(words)
    let choice = words[helloword#util#random(count)]
    let word_list = [choice]
    while len(word_list) < 4
      let random_num = helloword#util#random(count)
      let random_word = words[random_num]
      if random_word != choice && index(word_list, random_word) < 0
        call add(word_list, random_word)
      endif
    endwhile

    if mode == 1  " English -> Chinese
      let prompt = choice
      let answer = vocabulary[choice]
      let candidates = map(copy(word_list), {key,val -> vocabulary[val]})
    else          " Chinese -> English
      let prompt = vocabulary[choice]
      let answer = choice
      let candidates = copy(word_list)
    endif

    call helloword#util#shuffle(candidates)

    let res = str2nr(helloword#util#prompt(prompt, candidates))
    if res == 0
      return
    elseif res <= 4 && candidates[res-1] == answer
      echohl MoreMsg
      echo repeat(' ', 25) . "✔️ "
      echohl None
      call remove(vocabulary, choice)
    else
      echohl WarningMsg
      echo repeat(' ', 25) . "❌"
      echo "答案：" . answer
      echohl None
      let g:helloword_failed_words[choice] = vocabulary[choice]
    endif
  endwhile
endfunction

function! s:PinXieTi(db)
  let vocabulary = a:db
  while 1
    let words = keys(vocabulary)
    let count = len(words)
    let choice = words[helloword#util#random(count)]
    let spell = helloword#util#prompt(vocabulary[choice], [])
    if helloword#util#safeTrim(spell) == ''
      return
    elseif helloword#util#safeTrim(spell) == choice
      echohl MoreMsg
      echo repeat(' ', 25-len(spell)) . "✔️ "
      echohl None
      call remove(vocabulary, choice)
    else
      echohl WarningMsg
      echo repeat(' ', 25-len(spell)) . "❌"
      echo "答案：" . choice
      echohl None
      let g:helloword_failed_words[choice] = vocabulary[choice]
    endif
  endwhile
endfunction

function! helloword#Export() abort
  let words = keys(g:helloword_failed_words)
  let words_len = len(words)
  if exists('g:helloword_failed_words') && words_len > 0
    tabnew helloword.json
    call append(0, '{')
    let cnt = 0
    for word in words
      if cnt == words_len - 1
        let line = '  "'.word.'": '.'"'.g:helloword_failed_words[word].'"'
      else
        let line = '  "'.word.'": '.'"'.g:helloword_failed_words[word].'",'
      endif
      call append(line('$')-1, line)
      let cnt += 1
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

function! helloword#setVocabularyPath(path)
  if !filereadable(expand(a:path, ':p'))
    echohl Error
    echo "Vocabulary path is invalid"
    echohl None
    return
  endif
  let g:helloword_vocabulary_path = a:path
endfunction
