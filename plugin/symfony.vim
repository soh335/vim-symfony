"Name: vim-symfony
"Author: soh kitahara <sugarbabe335@gmail.com>

"reference plugin/rails.vim 
function! s:Detect(filename)
  if exists("b:sf_root_dir")
    return 0
  endif
  let fn = substitute(fnamemodify(a:filename,":p"),'\c^file://','','')
  let ofn = ""
  while fn != ofn
    if filereadable(fn."/config/databases.yml") && s:autoload() == 1
      return SymfonyProject(fn)
    endif
    let ofn = fn
    let fn = fnamemodify(ofn,':s?\(.*\)[\/]\(apps\|batch\|config\|data\|lib\|log\|plugins\|test\|web\)\($\|[\/].*$\)?\1?')
  endwhile
endfunction

"{{{ autoload
function! s:autoload()
  if !exists("g:autoloaded_symfony")
    runtime! autoload/symfony.vim
  endif
  if exists("g:autoloaded_symfony")
    return 1
  else
    return 0
  endif
endfunction
"}}}

"{{{ auto
"reference plugin/rails.vim 
augroup symfonyPluginDetect
  autocmd!
  autocmd BufNewFile,BufRead * call s:Detect(expand("<afile>:p"))
  autocmd VimEnter * if expand("<amatch>") == "" && !exists("b:sf_root_dir") | call s:Detect(getcwd()) | endif
  autocmd FileType netrw if !exists("b:sf_root_dir") | call s:Detect(expand("<afile>:p")) | endif
augroup END
"}}}
