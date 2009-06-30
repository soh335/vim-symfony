"{{{ for symfony 
"Name: vim-symfony
"Author: soh kitahara <sugarbabe335@gmail.com>
"URL: http://github.com/soh335/vim-symfony/tree/master
"Description:
"   vim-symfony offers some convenient methods when you develp symfony project
"   in vim
"
"   :Sview
"       move to template/xxxSuccess.php from action file.
"       Even if Action file name is not actions.class.php but
"       xxxAction.class.php, it can move to xxxSuccess.php.
"       In case of actions.class.php it judges from the line of the cursor
"       position, in case of xxxAction.class.php it judges from filename.
"
"   :Sview error
"       If argument nameed error is passed to SymfonyView, move to
"       template/xxxError.php.
"
"   :Saction
"       move to actions/xxxAction.class.php or actions.class.php from
"       templates/xxxSuccess.php or templates/xxxError.php.
"       Find executeXXX or execute line and move this line number
"
"   :Saction ...
"       If argument is passed to SymfonyAction, can open file directly.
"       Ex:
"           :SymfonyAction foo   => open fooAction.class.php or
"           ../../foo/actions/actions.class.php
"
"           :SymfonyAction foo bar  => open
"           ../../foo/actions/barAction.class.php or
"           apps/foo/modules/bar/actions/actions.class.php
"
"           :SymfonyAction foo bar baz  => open
"           apps/foo/modules/bar/actions/bazAction.class.php
"
"   :SymfonyProject
"       This method is called automatically.
"       If you want to redefine root dir, use like this.
"       :SymfonyProject ../../../../../
"
"
"   :Smodel
"       move to lib/model/xxx.php or lib/model/xxxPeer.php from anywhere.
"       Also in lib/model/---/xxx.php or xxxPeer.php, it corrensponds.
"       if you call this medhot with no argument, judges from word under
"       cursor.
"
"   :Sform
"       move to lib/form/xxx.class.php.
"       if you call this medhot with no argument, judges from word under
"       cursor.
"
"   :Spartial
"       move to partial template file. It judges from line.
"       Also in global/xxx, it corresponds.
"
"   :Scomponent
"       move to component template file or components.class.php.
"       If you call this in 'include_component...', move to template file.
"       And when it is other than that, move to components.class.php file
"
"   :SymconyCC
"       execute symfony clear cache
"       It it necessary to do :SymfonyProject first.
"
"   :SymfonyInitApp
"       execute symfony init-app xxx
"       It it necessary to do :SymfonyProject first.
"
"   :SymfonyInitModule
"       execute symfony init-module xxx xxx
"       It it necessary to do :SymfonyProject first.
"
"   :SymfonyPropelInitAdmin
"       execyte symfony prople-init-admin xxx xxx xxx
"       It it necessary to do :SymfonyProject first.
"
"   :SConfig
"       It is shortcut to config/* files.
"
"   :SLib
"       It is shortcut to lib/* files.


"echo errormsg func
function! s:error(str)
  echohl ErrorMsg
  echomsg a:str
  echohl None
endfunction

function! s:sub(str, pat, rep)
  return substitute(a:str, '\v'.a:pat, a:rep, '')
endfunction

function! s:gsub(str, pat, rep)
  return substitute(a:str, '\v'.a:pat, a:rep, 'g')
endfunction

function! s:escapeback(str)
  return substitute(a:str, '\v\', '\\\', 'g')
endfunction

" open template file function
function! s:openTemplateFile(file)
  echo b:sf_root_dir."/apps/".s:GetApp()."/modules/".s:GetModule()."/templates"
  if isdirectory(b:sf_root_dir."/apps/".s:GetApp()."/modules/".s:GetModule()."/templates")
    silent edit `=b:sf_root_dir."/apps/".s:GetApp()."/modules/".s:GetModule()."/templates/".a:file`
  else
    call s:error("error not find  templates directory")
  endif
endfunction

"find and edit symfony view file 
"find and edit xxxError.php if argument is error
"find executeXXX or execute in line
function! s:SymfonyView(arg)
  let l:suffix = "Success.php"
  if a:arg == "error"
    let l:suffix = "Error.php"
  endif
  let l:word = matchstr(getline('.'),'execute[0-9a-zA-Z_-]*')
  if l:word == 'execute'
    "if action file is separeted
    let l:file = substitute(expand('%:t'),"Action.class.php","","").l:suffix
    call s:openTemplateFile(l:file)
    unlet l:file
    return
  elseif l:word  =~ 'execute' && strlen(l:word)>7
    let l:file = tolower(l:word[7:7]).l:word[8:].l:suffix
    call s:openTemplateFile(l:file)
    unlet l:file
    return
  endif
  call s:error("not find executeXXX in this line")
endfunction

" find and edit action class file
" and find exexuteXXX by xxxSuccess.php or xxxError.php
" or if passed argument, open action file directory
function! s:SymfonyAction(...)
  if a:1 == ""
    if expand('%:t') =~ 'Success.php'
      let l:view = 'Success.php'
    elseif expand('%:t') =~ 'Error.php'
      let l:view = 'Error.php'
    endif
    if substitute(expand('%:p:h'),'.*/','','') == "templates"
      let l:prefix = substitute(expand('%:t'),l:view,"","") 
      let l:file = l:prefix."Action.class.php"
      if filereadable(b:sf_root_dir."/apps/".s:GetApp()."/modules/".s:GetModule()."/actions/".l:file)
        silent edit `=b:sf_root_dir."/apps/".s:GetApp()."/modules/".s:GetModule()."/actions/".l:file`
        call s:searchWordInFileAndMove('execute')
      elseif filereadable(b:sf_root_dir."/apps/".s:GetApp()."/modules/".s:GetModule()."/actions/actions.class.php")
        silent edit `=b:sf_root_dir."/apps/".s:GetApp()."/modules/".s:GetModule()."/actions/actions.class.php"`
        call s:searchWordInFileAndMove('execute'.toupper(l:prefix[0:0]).l:prefix[1:])
      else
        call s:error("not exist action class file")
      endif
    else
      call s:error("not exitst action dir")
    endif
  elseif a:0 == 1
    let l:list = split(a:1)
    if len(l:list) == 1
      if !exists("b:sf_root_dir")
        call s:error("not set root dir")
      endif
      if s:OpenExistFile(b:sf_root_dir."/apps/".b:sf_default_app."/modules/".s:GetModule()."/actions/".l:list[0]."Action.class.php") != 0
      elseif s:OpenExistFile(b:sf_root_dir."/apps/".b:sf_default_app."/modules/".l:list[0]."/actions/actions.class.php") != 0
      else
        call s:error("Not find")
      endif
    elseif len(l:list) == 2
      if s:OpenExistFile(b:sf_root_dir."/apps/".b:sf_default_app."/modules/".l:list[0]."/actions/".l:list[1]."Action.class.php") != 0
      elseif s:OpenExistFile(b:sf_root_dir."/apps/".l:list[0]."/modules/".l:list[1]."/actions/actions.class.php") != 0
      else
        call s:error("Not find")
      endif
    elseif len(l:list) == 3
      if s:OpenExistFile(b:sf_root_dir."/apps/".l:list[0]."/modules/".l:list[1]."/actions/".l:list[2]."Action.class.php") != 0
      else
        call s:error("Not find")
      endif
    endif
  endif
endfunction

function! s:OpenExistFile(path)
  if filereadable(a:path)
    silent edit `=a:path`
    return 1
  endif
  return 0
endfunction

"find model class
function! s:SymfonyModel(word)
  if a:word == ""
    let l:word = expand('<cword>')
  else
    let l:word = a:word
  endif
  if l:word !~ "\.php"
    let l:word = l:word.".php"
  endif

  if l:word =~ "/" || b:sf_model_dir !~ "\\*"
    let l:path = b:sf_root_dir."/lib/model/".l:word
    if filereadable(l:path) == "1"
      silent edit `=l:path`
    endif
  else
    if filereadable(glob(b:sf_model_dir."/".l:word))
      silent edit `=glob(b:sf_model_dir."/".l:word)`
    else
      call s:error("not find ".l:word)
    endif
  endif
endfunction

"find form class
function! s:SymfonyForm(word)
  if a:word == ""
    let l:word = expand('<cword>')
  else
    let l:word = a:word
  endif
  if l:word !~ "\.class\.php"
    let l:word = l:word.".class.php"
  endif
  if filereadable(b:sf_root_dir."/lib/form/".l:word)
    silent edit `=b:sf_root_dir."/lib/form/".l:word`
  else
    call s:error("not find ".l:word)
  endif
endfunction

function! s:SymfonyComponent()
  let l:mx = 'include_component(["'']\(.\{-}\)["''].\{-}["'']\(.\{-}\)["'']'
  let l:l = matchstr(getline('.'), l:mx)
  if l:l != ""
    let l:module = substitute(l:l, l:mx, '\1', '')
    let l:temp = substitute(l:l, l:mx, '\2', '')
    "silent execute ':e ../../'.l:module.'/templates/_'.l:temp.'.php'
    silent edit `=b:sf_root_dir.'/apps/'.s:GetApp().'/'.l:module.'templates/_'.l:tmp.'php'`
  else
    let l:file = expand('%:r')
    let l:file = l:file[1:]
    silent edit `=b:sf_root_dir.'/apps/'.s:GetApp().'/modules/'.s:GetModule().'/actions/components.class.php'`
    call s:searchWordInFileAndMove('execute'.toupper(l:file[0:0]).l:file[1:])
  endif
endfunction

"find and edit partial template
function! s:SymfonyPartial()
  let l:word = matchstr(getline('.'), 'include_partial(["''].\{-}["'']')
  let l:tmp = l:word[17:-2]
  if l:tmp[0:5] == "global"
    silent edit `=b:sf_root_dir.'/apps/'.s:GetApp().'/templates/_'.l:tmp[7:].'.php'`
  elseif l:tmp =~ "/"
    let l:list = matchlist(l:tmp, '\(.*\)/\(.*\)')
    silent edit `=b:sf_root_dir.'/apps/'.s:GetApp().'/modules/'.l:list[1].'/templates/_'.l:list[2].'.php'`
  else
    silent edit `=b:sf_root_dir.'/apps/'.s:GetApp().'/modules/'.s:GetModule().'/templates/_'.l:tmp.'.php'`
  endif
endfunction


"set symfony home project directory
function! s:SymfonyProject(word)
  if isdirectory(a:word.'/apps') && isdirectory(a:word.'/web') && isdirectory(a:word.'/lib')
    "let l:tmp = s:finddir_esc('apps', a:word)
    let b:sf_root_dir = a:word
    "if l:tmp == "apps"
    "    let b:sf_root_dir =substitute(expand('%:p'),"/apps.*","", "")."/"
    "else
    "    let b:sf_root_dir = s:finddir_esc('apps',a:word)[:-5]
    "endif
    call s:SetSymfonyVersion()
    call s:SetModelPath()
    call s:SetDefaultApp()
    call s:SetBufferCommand()
    call s:SetBufferMap()
  else
    call s:error("nof find apps, web, lib dir")
  endif
endfunction

function! s:SetDefaultApp()
  if exists("b:sf_root_dir") && filereadable(b:sf_root_dir."/web/index.php")
    for l:line in readfile(b:sf_root_dir."/web/index.php")
      if b:sf_version == 10
        if l:line =~ 'define(.*SF_APP.*)'
          let l:app = substitute(l:line,'define.*SF_APP.*,.\{-}["'']','','')
          let l:app = substitute(l:app,'["''].*','','')
          let b:sf_default_app = l:app
        endif
      else
        if l:line =~ 'getApplicationConfiguration'
          let l:app = matchstr(l:line, '''\(.\{-}\)''')[1:-2]
          let b:sf_default_app = l:app
        endif
      endif
    endfor
  endif
endfunction

function! s:SetSymfonyVersion()
  if filereadable(b:sf_root_dir."/config/ProjectConfiguration.class.php")
    if s:finddir_esc("sfProtoculousPlugin", b:sf_root_dir."/web/") != ""
      let b:sf_version = 12
    else
      let b:sf_version = 11
    endif
  else
    let b:sf_version = 10
  endif
endfunction

function! s:SetModelPath()
  if exists("b:sf_root_dir")
    if glob(b:sf_root_dir."/lib/model/*Peer.php") != ""
      let b:sf_model_dir = b:sf_root_dir."/lib/model/"
    elseif glob(b:sf_root_dir."/lib/model/*/*Peer.php") != ""
      let b:sf_model_dir = b:sf_root_dir."/lib/model/*/"
    endif
  endif
endfunction

"execute symfony clear cache
function! s:SymconyCC()
  if exists("b:sf_root_dir")
    silent execute '!'.b:sf_root_dir."/symfony cc"
    echo "cache clear"
  else
    call s:error("not set symfony root dir")
  endif
endfunction

"execute symfony init-app 
function! s:SymfonyInitApp(app)
  if exists("b:sf_root_dir")
    silent execute '!'.b:sf_root_dir."/symfony init-app ".a:app
    echo "init app ".a:app
  else
    call s:error("not set symfony root dir")
  endif
endfunction

"get now app
function! s:GetApp()
  if exists("b:sf_app_name") == 0
    let l:t = substitute(expand('%:p'), b:sf_root_dir, '', '')
    let b:sf_app_name = substitute(matchstr(l:t, 'apps[/\\]\(.\{-}\)[/\\]')[:-2], 'apps[/\\]', '', '')
  endif
  return b:sf_app_name
endfunction

"get now module
function! s:GetModule()
  if exists("b:sf_module_name") == 0
    let l:t = substitute(expand('%:p'), b:sf_root_dir, '', '')
    let b:sf_module_name = substitute(matchstr(l:t, 'modules[/\\]\(.\{-}\)[/\\]')[:-2], 'modules[/\\]', '', '')
  endif
  return b:sf_module_name
endfunction

"execute symfony init-module
function! s:SymfonyInitModule(app, module)
  if exists("b:sf_root_dir")
    silent execute '!'.b:sf_root_dir."/symfony init-module ".a:app." ".a:module
    echo "init module ".a:app." ".a:module
  else
    call s:error("not set symfony root dir")
  endif
endfunction

"execute symfony propel-init-admin    
function! s:SymfonyPropelInitAdmin(app, module, model)
  if exists("b:sf_root_dir")
    silent execute '!'.b:sf_root_dir."/symfony propel-init-admin ".a:app." ".a:module." ".a:model
    echo "propel-init-admin ".a:app." ".a:module." ".a:model
  else
    call s:error("not set symfony root dir")
  endif
endfunction

function! s:GetSymfonyActionList(A,L,P)
  if exists("b:sf_root_dir")
    let words = split(a:L)
    if len(words) == 4 || (len(words) == 3 && a:A == "")
      let lists = split(substitute(glob(b:sf_root_dir."/apps/".words[1]."/modules/".words[2].'/actions/*Action\.class\.php'), s:escapeback(b:sf_root_dir.'[/\]apps[/\]'.words[1].'[/\]modules[/\]'.words[2].'[/\]actions[/\]\(.\{-}\)Action\.class\.php'), '\1', "g"), "\n")
    elseif len(words) == 3 || (len(words) == 2 && a:A == "")
      let list1 = split(substitute(glob(b:sf_root_dir."/apps/".words[1]."/modules/*"), s:escapeback(b:sf_root_dir.'[/\]apps[/\]'.words[1].'[/\]modules[/\]'), "", "g"), "\n")
      let list2 = split(substitute(glob(b:sf_root_dir."/apps/*/modules/".words[1].'/actions/*Action\.class\.php'), s:escapeback(b:sf_root_dir.'[/\]apps[/\].\{-}[/\]modules[/\]'.words[1].'[/\]actions[/\]\(.\{-}\)Action\.class\.php'), '\1', "g"), "\n")
      let lists = list1 + list2
    elseif len(words) <= 2 
      let list1 = split(substitute(glob(b:sf_root_dir."/apps/*"), s:escapeback(b:sf_root_dir.'[/\]apps[/\]'), "", "g"), "\n")
      let list2 = split(s:gsub(glob(b:sf_root_dir."/apps/*/modules/*"), s:escapeback(b:sf_root_dir.'[/\]apps[/\].{-}[/\]modules[/\]'), ""), "\n")
      let lists = list1 + list2
    endif
    return filter(lists, 'v:val =~ "^".a:A')
  else
    call s:error("not set symfony root dir")
  endif
endfunction

function! s:GetSymfonyViewList(A,L,P)
  if exists("b:sf_root_dir")
  endif
endfunction

"open symfonyProject/config/* file
function! s:GetSymfonyConfigList(A,L,P)
  if exists("b:sf_root_dir")
    if exists("s:sf_complete_session")
      return s:sf_complete_session
    else
      let list = substitute(glob(b:sf_root_dir."/config/"."**"),s:escapeback(b:sf_root_dir.'[/\]'),"","g")
      let list2 = substitute(glob(b:sf_root_dir."/apps/*/config/"."**"),s:escapeback(b:sf_root_dir.'[/\]apps[/\]*[/\]'),"","g")
      let list3 = substitute(glob(b:sf_root_dir."/apps/*/modules/*/config/"."**"),s:escapeback(b:sf_root_dir.'[/\]apps[/\]'),"","g")
      let s:sf_complete_session = join(sort(split(list."\n".list2."\n".list3, "\n")), "\n")
      return s:sf_complete_session
    endif
  else
    call s:error("not set symfony root dir")
  endif
endfunction

function! s:SymfonyOpenConfigFile(word)
  if exists("s:sf_complete_session")
    unlet s:sf_complete_session
  endif
  let path = a:word
  if a:word[0:5] != "config"
    let path = "apps/".a:word
  endif
  silent edit `=b:sf_root_dir."/".path`
endfunction

"open symfonyProject/lib* file
function! s:GetSymfonyLibList(A,L,P)
  if exists("b:sf_root_dir")
    return split(substitute(glob(b:sf_root_dir."/lib/".a:A."*"), s:escapeback(b:sf_root_dir.'[/\]lib[/\]'),"","g"), "\n")
  else
    call s:error("not set symfony root dir")
  endif
endfunction

function! s:GetSymfonyModelList(A, L, P)
  if exists("b:sf_model_dir")
    return split(substitute(glob(b:sf_root_dir.'/lib/model/'.a:A."*"),s:escapeback(b:sf_root_dir.'[/\]lib[/\]model[/\]'),"","g"), "\n")
  else
    call s:error("not set symfony model path")
  endif
endfunction

function! s:GetSymfonyFormList(A, L, P)
  if exists("b:sf_root_dir")
    return split(substitute(glob(b:sf_root_dir."/lib/form/".a:A."*"),s:escapeback(b:sf_root_dir.'[/\]lib[/\]form[/\]',"","g"), "\n")
  else
    call s:error("not set symfony root dir")
  endif
endfunction

function! s:SymfonyOpenLibFile(word)
  silent edit `=b:sf_root_dir.'/lib/'.a:word`
endfunction

"search argument word in current buffer and move this line
function! s:searchWordInFileAndMove(str)
  let l:num = 0
  while l:num <= line('$')
    let l:line = getline(l:num)
    let l:word = matchstr(l:line, a:str)
    if l:word == a:str
      break
    endif
    let l:num = l:num + 1
  endwhile
  if l:num != -1
    silent execute l:num
  endif
endfunction
"}}}

"reference plugin/rails.vim 
function! s:Detect(filename)
  if exists("b:sf_root_dir")
    return 0
  endif
  let fn = substitute(fnamemodify(a:filename,":p"),'\c^file://','','')
  let ofn = ""
  while fn != ofn
    if filereadable(fn."/config/databases.yml")
      return s:SymfonyProject(fn)
    endif
    let ofn = fn
    let fn = fnamemodify(ofn,':s?\(.*\)[\/]\(apps\|config\|data\|doc\|lib\|log\|plugins\|test\|web\)\($\|[\/].*$\)?\1?')
  endwhile
endfunction

function! s:SetBufferCommand()
  command! -buffer -nargs=* -complete=customlist,s:GetSymfonyViewList Sview :call s:SymfonyView(<q-args>)
  command! -buffer -nargs=* -complete=customlist,s:GetSymfonyActionList Saction :call s:SymfonyAction(<q-args>)
  command! -buffer -nargs=? -complete=customlist,s:GetSymfonyModelList Smodel :call s:SymfonyModel(<q-args>)
  command! -buffer -nargs=? -complete=customlist,s:GetSymfonyFormList Sform :call s:SymfonyForm(<q-args>)
  command! -buffer -nargs=0 Spartial :call s:SymfonyPartial()
  command! -buffer -nargs=0 Scomponent :call s:SymfonyComponent()
  command! -buffer -complete=file -nargs=1 SymfonyProject :call s:SymfonyProject(<f-args>)
  command! -buffer -nargs=0 SymfonyCC :call s:SymconyCC()
  command! -buffer -nargs=1 SymfonyInitApp :call s:SymfonyInitApp(<f-args>)
  command! -buffer -nargs=+ SymfonyInitModule :call s:SymfonyInitModule(<f-args>)
  command! -buffer -nargs=+ SymfonyPropelInitAdmin :call s:SymfonyPropelInitAdmin(<f-args>)
  command! -buffer -nargs=? -complete=custom,s:GetSymfonyConfigList Sconfig :call s:SymfonyOpenConfigFile(<f-args>)
  command! -buffer -nargs=? -complete=customlist,s:GetSymfonyLibList Slib :call s:SymfonyOpenLibFile(<f-args>)
endfunction

function! s:SetBufferMap()
endfunction

"{{{ auto
augroup symfonyPluginDetect
  autocmd!
  autocmd BufNewFile,BufRead * call s:Detect(expand("<afile>:p"))
augroup END
"}}}
