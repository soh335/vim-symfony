"Name: vim-symfony
"Author: soh kitahara <sugarbabe335@gmail.com>

if exists('g:loaded_vim_symfony')
  finish
end

let g:loaded_vim_symfony = 1
let s:symfony_roots = {}

function! s:CheckIsRoot(path)
  return filereadable(a:path .'/symfony')
endfunction

function! s:Define(key, value)
  if !exists(a:key)
    let {a:key} = a:value
  endif
endfunction

function! s:SymfonyOpenProject(filename)
  if isdirectory(a:filename)
    let fn = substitute(fnamemodify(a:filename,":p:h"),'\c^file://','','')
  else
    let fn = substitute(fnamemodify(a:filename,":p"),'\c^file://','','')
  endif
  let ofn = ""
  let nfn = fn
  while nfn != ofn && nfn != ""
    if has_key(s:symfony_roots, nfn)
      return symfony#projectInit(nfn)
    endif
    let ofn = nfn 
    let nfn = fnamemodify(nfn,':h')
  endwhile
  while fn != ofn
    if s:CheckIsRoot(fn) 
      let s:symfony_roots[fn] = 1
      return symfony#projectInit(fn)
    endif
    let ofn = fn
    let fn = fnamemodify(ofn,':s?\(.*\)[\/]\(apps\|batch\|cache\|config\|data\|lib\|log\|plugins\|test\|web\)\($\|[\/].*$\)?\1?')
  endwhile
endfunction

command! -buffer -nargs=0 SymfonyOpenProject call <SID>SymfonyOpenProject(expand('%:p'))

call s:Define('g:vim_symfony_auto_search_root_dirctory', 1)
call s:Define('g:vim_symfony_default_search_action_top_direction', 1)
call s:Define('g:vim_symfony_autocmd_version', 0)

if g:vim_symfony_auto_search_root_dirctory == 1
  augroup symfonyPluginDetect
    autocmd!
    autocmd BufNewFile,BufRead * call s:SymfonyOpenProject(expand("<afile>:p"))
    autocmd VimEnter * if expand("<amatch>") == "" && !exists("b:sf_root_dir") | call s:SymfonyOpenProject(getcwd()) | endif
    autocmd FileType netrw if !exists("b:sf_root_dir") | call s:SymfonyOpenProject(expand("<afile>:p")) | endif
  augroup END
endif
