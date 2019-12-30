" ========================================================================
" FileName: autoload/helloword/util.vim
" Description:
" Author: voldikss
" GitHub: https://github.com/voldikss
" ========================================================================

function! helloword#util#show_msg(message, ...)
  if a:0 == 0
    let msg_type = 'info'
  else
    let msg_type = a:1
  endif

  if type(a:message) != 1
    let message = string(a:message)
  else
    let message = a:message
  endif

  call helloword#util#echo('Constant', '[vim-helloword]')

  if msg_type == 'info'
    call helloword#util#echon('Normal', message)
  elseif msg_type == 'warning'
    call helloword#util#echon('WarningMsg', message)
  elseif msg_type == 'error'
    call helloword#util#echon('Error', message)
  endif
endfunction

function! helloword#util#echo(group, msg) abort
  if a:msg == '' | return | endif
  execute 'echohl' a:group
  echo a:msg
  echon ' '
  echohl NONE
endfunction

function! helloword#util#echon(group, msg) abort
  if a:msg == '' | return | endif
  execute 'echohl' a:group
  echon a:msg
  echon ' '
  echohl NONE
endfunction

function! helloword#util#random(range) abort
  if has("reltime")
    let l:timerstr=reltimestr(reltime())
    let l:number=split(l:timerstr, '\.')[1]+0
  elseif has("win32") && &shell =~ 'cmd'
    let l:number=system("echo %random%")+0
  else
    let l:number=expand("$RANDOM")+0
  endif
  return l:number % a:range
endfunction

function! helloword#util#shuffle(list) abort
  let pos = len(a:list)
  while 1 < pos
    let n = helloword#util#random(pos)
    let pos -= 1
    if n != pos
      let temp = a:list[n]
      let a:list[n] = a:list[pos]
      let a:list[pos] = temp
    endif
  endwhile
  return a:list
endfunction

function! helloword#util#safe_trim(text) abort
  return substitute(a:text, "^\\s*\\(.\\{-}\\)\\(\\n\\|\\s\\)*$", '\1', '')
endfunction

function helloword#util#display(winid, text) abort
  execute a:winid . ' wincmd w'
  call append('$', a:text)
  normal G
  redraw
endfunction

function helloword#util#buf_config() abort
  setl buftype=nofile
  setl bufhidden=hide
  setl noswapfile
  setl nobuflisted
  setl nolist
  setl nospell
endfunction
