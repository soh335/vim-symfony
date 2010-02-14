"Name: vim-symfony
"Author: soh kitahara <sugarbabe335@gmail.com>

let s:symfony_rout = {}
let s:symfony_cache_routes = {}
let s:cache_routes_name = 'routes'

function! s:main()
  if !isdirectory(g:vim_symfony_cache_dir_name)
    call mkdir(g:vim_symfony_cache_dir_name, 'p')
  endif

  let file = printf('%s/%s', g:vim_symfony_cache_dir_name, s:cache_routes_name)
  if filereadable(file)
    let lists = readfile(file)
    for dict in lists
      for [key, value] in items(eval(dict))
        let s:symfony_cache_routes[key] = value
      endfor
    endfor
  endif
endfunction

function! s:SymfonyMarkProject(version)
  let route = expand('%:p:h')
  if isdirectory(route) && s:CheckIsRoot(route) 
    let s:symfony_cache_routes[route] = a:version
  else
    echo "error"
    return
  endif

  let l:list = []
  for [key, value] in items(s:symfony_cache_routes)
      call add(l:list, string({key : value}))
  endfor

  let file = printf('%s/%s', g:vim_symfony_cache_dir_name, s:cache_routes_name)
  echo l:list
  call writefile(l:list, file)
endfunction

function! s:CheckIsRoot(path)
  return executable(a:path .'/symfony')
endfunction

function! s:Detect(path, version)
  if has_key(s:symfony_cache_routes, a:path)
    call symfony#projectInit(a:path, a:version)
  endif
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
    if has_key(s:symfony_rout, nfn)
      return symfony#projectInit(nfn)
    endif
    let ofn = nfn 
    let nfn = fnamemodify(nfn,':h')
  endwhile
  while fn != ofn
    if s:CheckIsRoot(fn) 
      let s:symfony_rout[fn] = 1
      return symfony#projectInit(fn)
    endif
    let ofn = fn
    let fn = fnamemodify(ofn,':s?\(.*\)[\/]\(apps\|batch\|cache\|config\|data\|lib\|log\|plugins\|test\|web\)\($\|[\/].*$\)?\1?')
  endwhile
endfunction

"command! -buffer -nargs=1 SymfonyMarkProject call <SID>SymfonyMarkProject(<q-args>)
"command! -buffer -nargs=0 SymfonyOpenProject call <SID>SymfonyOpenProject()

call s:Define('g:vim_symfony_auto_search_root_dirctory', 1)
call s:Define('g:vim_symfony_cache_dir_name', expand('~/.vim-symfony-cache'))
"call s:Define('g:vim_symfony_separate_complitation', 0)
call s:Define('g:vim_symfony_default_search_action_top_direction', 1)
call s:Define('g:vim_symfony_fuf', 0)

if g:vim_symfony_auto_search_root_dirctory == 1
  augroup symfonyPluginDetect
    autocmd!
    autocmd BufNewFile,BufRead * call s:SymfonyOpenProject(expand("<afile>:p"))
    autocmd VimEnter * if expand("<amatch>") == "" && !exists("b:sf_root_dir") | call s:SymfonyOpenProject(getcwd()) | endif
    autocmd FileType netrw if !exists("b:sf_root_dir") | call s:SymfonyOpenProject(expand("<afile>:p")) | endif
  augroup END
endif
