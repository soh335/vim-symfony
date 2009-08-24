"Name: vim-symfony
"Author: soh kitahara <sugarbabe335@gmail.com>

if exists("g:autoloaded_symfony")
  finish
end

let g:autoloaded_symfony = 1

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

function! s:splitWindow(t)
  if a:t == 'V'
    execute 'vsplit'
  elseif a:t == 'S'
    execute 'split'
  endif
endfunction

"find and edit symfony view file 
"find and edit xxxError.php if argument is error
"find executeXXX or execute in line
function! s:SymfonyView(args, t)
  if a:args == "" || a:args == "error"
    let l:suffix = "Success.php"
    if a:args == "error"
      let l:suffix = "Error.php"
    endif
    let l:lineNum = line(".")
    while( l:lineNum > 0 )
      let l:line = getline(l:lineNum)
      let l:t = matchlist(l:line,'function\s\+\(execute\)\([0-9a-zA-Z_-]*\)')
      if (get(l:t,1) != "")
        break
      endif
      let l:lineNum = l:lineNum - 1
    endwhile
    let path = b:sf_root_dir."/apps/".s:GetApp()."/modules/".s:GetModule()."/templates/"
    if get(l:t, 2) == "" "if action file is separated
      let file = path.substitute(expand('%:t'),"Action.class.php","","").l:suffix
    elseif get(l:t,1) == 'execute' && get(l:t, 2) != ""
      let l:word =get(l:t, 2)
      let file = path.tolower(l:word[0:0]).l:word[1:].l:suffix
    endif
    if filereadable(file)
      call s:splitWindow(a:t)
      silent edit `=file`
    else
      call s:error("not find executeXXX")
    end
  else
    let words = split(a:args)
    if len(words) == 1 && words[0] =~ "\.php$"
      silent edit `=b:sf_root_dir."/apps/".s:GetApp()."/modules/".s:GetModule()."/templates/".words[0]`
    elseif len(words) == 2 && words[1] =~ "\.php$"
      silent edit `=b:sf_root_dir."/apps/".words[0]."/templates/".words[1]`
    else
      silent edit `=b:sf_root_dir."/apps/".words[0]."/modules/".words[1]."/templates/".words[2]`
    endif
  endif
endfunction

" find and edit action class file
" and find exexuteXXX by xxxSuccess.php or xxxError.php
" or if passed argument, open action file directory
function! s:SymfonyAction(args, t)
  if a:args == ""
    if expand('%:t') =~ 'Success.php'
      let l:view = 'Success.php'
    elseif expand('%:t') =~ 'Error.php'
      let l:view = 'Error.php'
    endif
    if substitute(expand('%:p:h'),'.*/','','') == "templates"
      let l:prefix = substitute(expand('%:t'),l:view,"","") 
      let l:file = l:prefix."Action.class.php"
      if filereadable(b:sf_root_dir."/apps/".s:GetApp()."/modules/".s:GetModule()."/actions/".l:file)
        call s:splitWindow(a:t)
        silent edit `=b:sf_root_dir."/apps/".s:GetApp()."/modules/".s:GetModule()."/actions/".l:file`
        call s:SearchWordInFileAndMove('execute')
      elseif filereadable(b:sf_root_dir."/apps/".s:GetApp()."/modules/".s:GetModule()."/actions/actions.class.php")
        call s:splitWindow(a:t)
        silent edit `=b:sf_root_dir."/apps/".s:GetApp()."/modules/".s:GetModule()."/actions/actions.class.php"`
        call s:SearchWordInFileAndMove('execute'.toupper(l:prefix[0:0]).l:prefix[1:])
      else
        call s:error("not exist action class file")
      endif
    else
      call s:error("not exitst action dir")
    endif
  else
    let l:list = split(a:args)
    if len(l:list) == 1
      if !exists("b:sf_root_dir")
        call s:error("not set root dir")
      endif
      if s:OpenFilereadble([b:sf_root_dir."/apps/".b:sf_default_app."/modules/".s:GetModule()."/actions/".l:list[0]."Action.class.php",
            \b:sf_root_dir."/apps/".b:sf_default_app."/modules/".l:list[0]."/actions/actions.class.php"], 'call s:splitWindow(a:t)', 0) == 0
        call s:error("Not find")
      endif
    elseif len(l:list) == 2
      if s:OpenFilereadble([b:sf_root_dir."/apps/".b:sf_default_app."/modules/".l:list[0]."/actions/".l:list[1]."Action.class.php",
            \b:sf_root_dir."/apps/".l:list[0]."/modules/".l:list[1]."/actions/actions.class.php"], 'call s:splitWindow(a:t)', 0) == 0
        call s:error("Not find")
      endif
    elseif len(l:list) == 3
      if s:OpenExistFile[b:sf_root_dir."/apps/".l:list[0]."/modules/".l:list[1]."/actions/".l:list[2]."Action.class.php"], 'call s:splitWindow(a:t)', 0) == 0
        call s:error("Not find")
      endif
    endif
  endif
endfunction

function! s:OpenFilereadble(list, before_eval, after_eval)
  for item in a:list
    if filereadable(item)
      if a:before_eval | call eval(a:before_eval) | endif
      silent edit `=item`
      if a:after_eval | call eval(a:after_eval) | endif
      return 1
    endif
  endfor
  return 0
endfunction

"find model class
function! s:SymfonyModel(word, t)
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
      call s:splitWindow(a:t)
      silent edit `=l:path`
    endif
  else
    if filereadable(glob(b:sf_model_dir."/".l:word))
      call s:splitWindow(a:t)
      silent edit `=glob(b:sf_model_dir."/".l:word)`
    else
      call s:error("not find ".l:word)
    endif
  endif
endfunction

"find form class
function! s:SymfonyForm(word, t)
  if a:word == ""
    let l:word = expand('<cword>')
  else
    let l:word = a:word
  endif
  if l:word !~ "\.class\.php"
    let l:word = l:word.".class.php"
  endif
  if filereadable(b:sf_root_dir."/lib/form/".l:word)
    call s:splitWindow(a:t)
    silent edit `=b:sf_root_dir."/lib/form/".l:word`
  else
    call s:error("not find ".l:word)
  endif
endfunction

function! s:SymfonyComponent(t)
  let l:mx = 'include_component(["'']\(.\{-}\)["''].\{-}["'']\(.\{-}\)["'']'
  let l:l = matchstr(getline('.'), l:mx)
  if l:l != ""
    let l:module = substitute(l:l, l:mx, '\1', '')
    let l:temp = substitute(l:l, l:mx, '\2', '')
    "silent execute ':e ../../'.l:module.'/templates/_'.l:temp.'.php'
    call s:splitWindow(a:t)
    silent edit `=b:sf_root_dir.'/apps/'.s:GetApp().'/'.l:module.'templates/_'.l:tmp.'php'`
  else
    let l:file = expand('%:r')
    let l:file = l:file[1:]
    call s:splitWindow(a:t)
    silent edit `=b:sf_root_dir.'/apps/'.s:GetApp().'/modules/'.s:GetModule().'/actions/components.class.php'`
    call s:SearchWordInFileAndMove('execute'.toupper(l:file[0:0]).l:file[1:])
  endif
endfunction

"find and edit partial template
function! s:SymfonyPartial(arg, line1, line2, t)
  if a:arg != ""
    let tmp = @@
    silent normal gvy
    let selected = @@
    let @@ = tmp

    let argList = matchlist(a:arg, '\(.\{-}\)/\(.*\)')
    let moduleName = get(argList, 1)
    let fileName   = get(argList, 2)
    if (moduleName == "0" || fileName == "0")
        let moduleName = s:GetModule()
        let fileName = a:arg
    endif

    call append(a:line1-1, '<?php include_partial("'.moduleName.'/'.fileName.'") ?>')
    execute a:line1 + 1
    execute 'delete'.(a:line2 - a:line1 + 1)
    let _path = b:sf_root_dir.'/apps/'.s:GetApp().'/modules/'.moduleName.'/templates/_'.fileName.'.php'
    if a:t == '' || a:t == 'S'
      silent new `=_path`
    elseif a:t == 'V'
      silent vnew `=_path`
    endif
    call append(0, split(selected, '\n'))
  else
    let l:word = matchstr(getline('.'), 'include_partial(["''].\{-}["'']')
    let l:tmp = l:word[17:-2]
    if l:tmp[0:5] == "global"
      call s:splitWindow(a:t)
      silent edit `=b:sf_root_dir.'/apps/'.s:GetApp().'/templates/_'.l:tmp[7:].'.php'`
    elseif l:tmp =~ "/"
      let l:list = matchlist(l:tmp, '\(.*\)/\(.*\)')
      call s:splitWindow(a:t)
      silent edit `=b:sf_root_dir.'/apps/'.s:GetApp().'/modules/'.l:list[1].'/templates/_'.l:list[2].'.php'`
    else
      call s:splitWindow(a:t)
      silent edit `=b:sf_root_dir.'/apps/'.s:GetApp().'/modules/'.s:GetModule().'/templates/_'.l:tmp.'.php'`
    endif
  end
endfunction

"find symfony helper
function! s:SymfonyHelper(word, t)
  if a:word == ""
    let l:word = expand('<cword>')
  else
    let l:word = a:word
  endif
  if l:word !~ "Helper\.php"
    let l:word = l:word."Helper\.php"
  endif

  if filereadable(b:sf_root_dir."/lib/helper/".l:word)
    call s:splitWindow(a:t)
    silent edit `=b:sf_root_dir."/lib/helper/".l:word`
  else
    call s:error("not find ".l:word)
  endif
endfunction

"set symfony home project directory
function! SymfonyProject(word)
  if isdirectory(a:word.'/apps') && isdirectory(a:word.'/web') && isdirectory(a:word.'/lib')
    let b:sf_root_dir = a:word
    call s:SetSymfonyVersion()
    call s:SetModelPath()
    call s:SetDefaultApp()
    call s:SetBufferCommand()
    call s:SetPath()
    "reference rails.vim 
    if exists('g:loaded_snippet')
      runtime! ftplugin/symfony_snippets.vim
      " filetype snippets need to come last for higher priority
      exe "silent! runtime! ftplugin/".&filetype."_snippets.vim"
    endif
    silent doautocmd User Symfony
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
  if !exists("b:sf_default_app")
    let b:sf_default_app = 0
  end
endfunction

function! s:SetSymfonyVersion()
  if filereadable(b:sf_root_dir."/config/ProjectConfiguration.class.php")
    if isdirectory(b:sf_root_dir."/web/sfProtoculousPlugin") 
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

function! s:SetPath()
  let _path = &l:path
  let &l:path=_path.','.b:sf_root_dir.'/lib/,'.b:sf_root_dir.'/lib/model/*/om/'.','.b:sf_root_dir.'/lib/model/om/,'.b:sf_root_dir.'/lib/action/,'.b:sf_root_dir.'/lib/helper/,'
  setlocal includeexpr=substitute(v:fname,'$','.php','') 
endfunction

function! s:GetSymfonyActionList(A,L,P)
  if exists("b:sf_root_dir")
    let words = split(a:L)
    if len(words) == 4 || (len(words) == 3 && a:A == "")
      let list = split(s:gsub(glob(b:sf_root_dir."/apps/".words[1]."/modules/".words[2].'/actions/*Action\.class\.php'), s:escapeback(b:sf_root_dir.'[/\]apps[/\]'.words[1].'[/\]modules[/\]'.words[2].'[/\]actions[/\](.{-})Action.class.php'), '\1'), "\n")
    elseif len(words) == 3 || (len(words) == 2 && a:A == "")
      let list = split(s:gsub(glob(b:sf_root_dir."/apps/".words[1]."/modules/*"), s:escapeback(b:sf_root_dir.'[/\]apps[/\]'.words[1].'[/\]modules[/\]'), ""), "\n")
      let list += split(s:gsub(glob(b:sf_root_dir."/apps/*/modules/".words[1].'/actions/*Action\.class\.php'), s:escapeback(b:sf_root_dir.'[/\]apps[/\].\{-}[/\]modules[/\]'.words[1].'[/\]actions[/\](.{-})Action.class.php'), ''), "\n")
    elseif len(words) <= 2 
      let list = split(s:gsub(glob(b:sf_root_dir."/apps/*"), s:escapeback(b:sf_root_dir.'[/\]apps[/\]'), ""), "\n")
      let list += split(s:gsub(glob(b:sf_root_dir."/apps/".s:GetApp()."/modules/*"), s:escapeback(b:sf_root_dir.'[/\]apps[/\].{-}[/\]modules[/\]'), ""), "\n")
    endif
    return filter(list, 'v:val =~ "^".a:A')
  else
    call s:error("not set symfony root dir")
  endif
endfunction

function! s:GetSymfonyViewList(A,L,P)
  if exists("b:sf_root_dir")
    let words = split(a:L)
    if len(words) == 4 || (len(words) == 3 && a:A == "")
      let list = split(s:gsub(glob(b:sf_root_dir."/apps/".words[1]."/modules/".words[2].'/templates/*'), s:escapeback(b:sf_root_dir.'[/\]apps[/\]'.words[1].'[/\]modules[/\]'.words[2].'[/\]templates[/\]'), ""), "\n")
    elseif len(words) == 3 || (len(words) == 2 && a:A == "")
      let list = split(s:gsub(glob(b:sf_root_dir."/apps/".words[1]."/modules/*"), s:escapeback(b:sf_root_dir.'[/\]apps[/\]'.words[1].'[/\]modules[/\]'), ""), "\n")
      let list += split(s:gsub(glob(b:sf_root_dir."/apps/".words[1]."/templates/*"), s:escapeback(b:sf_root_dir.'[/\]apps[/\]'.words[1].'[/\]templates[/\]'), ""), "\n")
    elseif len(words) <= 2
      let list = split(s:gsub(glob(b:sf_root_dir."/apps/*"), s:escapeback(b:sf_root_dir.'[/\]apps[/\]'), ""), "\n")
      let list += split(s:gsub(glob(b:sf_root_dir."/apps/".s:GetApp()."/modules/".s:GetModule()."/templates/*"), s:escapeback(b:sf_root_dir.'[/\]apps[/\]'.s:GetApp().'[/\]modules[/\]'.s:GetModule().'[/\]templates[/\]'), ""), "\n")
    endif
    return filter(list, 'v:val =~ "^".a:A')
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

function! s:SymfonyOpenConfigFile(word, t)
  if exists("s:sf_complete_session")
    unlet s:sf_complete_session
  endif
  let path = a:word
  if a:word[0:5] != "config"
    let path = "apps/".a:word
  endif
  call s:splitWindow(a:t)
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
    return split(substitute(glob(b:sf_root_dir."/lib/form/".a:A."*"),s:escapeback(b:sf_root_dir.'[/\]lib[/\]form[/\]'),"","g"), "\n")
  else
    call s:error("not set symfony root dir")
  endif
endfunction

function! s:GetSymfonyHelperList(A, L, P)
  if exists("b:sf_root_dir")
    return split(substitute(glob(b:sf_root_dir."/lib/helper/".a:A."*\.php"),s:escapeback(b:sf_root_dir.'[/\]lib[/\]helper[/\]'),"","g"), "\n")
  else
    call s:error("not set symfony root dir")
  endif
endfunction

function! s:SymfonyOpenLibFile(word, t)
    call s:splitWindow(a:t)
  silent edit `=b:sf_root_dir.'/lib/'.a:word`
endfunction

"search argument word in current buffer and move this line
function! s:SearchWordInFileAndMove(str)
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

function! s:SymfonyCommand(...)
   execute '!'.b:sf_root_dir."/symfony ".join(a:000, " ")
endfunction

function! s:GetSymfonyCommandList(A, L, P)
  let words = split(a:L)
  if exists("b:sf_version") && len(words) <= 2 
    if b:sf_version == 10
      let list = ['clear-cache', 'clear-controllers', 'disable', 'downgrade', 'enable', 'fix-perms', 'freeze', 'init-app', 'init-batch', 'init-controller',
            \ 'init-module', 'init-project', 'log-purge', 'log-rotate', 'plugin-install', 'plugin-list', 'plugin-uninstall', 'plugin-upgrade', 'propel-build-all',
            \ 'propel-build-all-load', 'propel-build-db', 'propel-build-model', 'propel-build-schema', 'propel-build-sql', 'propel-convert-xml-schema',
            \ 'propel-convert-yml-schema', 'propel-dump-data', 'propel-generate-crud', 'propel-init-admin', 'propel-init-crud', 'propel-insert-sql',
            \  'propel-load-data', 'sync', 'test-all', 'test-functional', 'test-unit', 'unfreeze', 'upgrade', 'app', 'batch', 'cc', 'controller', 'module', 'new']
    elseif b:sf_version == 11
      let list = ['help', 'list', 'configure:author', 'configure:database', 'generate:app', 'generate:module', 'generate:project', 'generate:task',
            \ 'i18n:extract', 'i18n:find', 'log:clear', 'log:rotate', 'plugin:add-channel', 'plugin:install', 'plugin:list', 'plugin:uninstall', 'plugin:upgrade', 'project:clear-controllers',
            \ 'prom:deploy', 'project:disable', 'project:enable', 'project:freeze', 'project:permissions', 'project:unfreeze', 'project:upgrade1.1', 'propel:build-all', 'propel:build-all-load',
            \ 'propel:build-db', 'propel:build-forms', 'propel:build-schema', 'propel:build-sql', 'propel:data-dump', 'propel:data-load', 'propel:generate-crud', 'propel:init-admin', 'propel:insert-sql',
            \ 'propel:schema-to-xml', 'propel:schema-to-yml', 'test:all', 'test:functional', 'test:unit']

    elseif b:sf_version == 12
      let list = ['help', 'list', 'app:routes', 'cache:clear', 'configure:author', 'configure:database', 'generate:app', 'generate:module', 'generate:project',
            \ 'generate:task', 'i18n:extract', 'i18n:find', 'log:clear', 'log:rotate', 'plugin:add-channel', 'plugin:install', 'plugin:list', 'plugin:publish-assets',
            \ 'plugin:uninstall', 'plugin:upgrade', 'project:clear-controllers', 'project:deploy', 'project:disable', 'project:enable', 'project:freeze', 
            \ 'project:permissions', 'project:unfreeze', 'project:upgrade1.1', 'project:upgrade1.2', 'propel:build-all', 'propel:build-all-load', 'propel:build-filters',
            \ 'propel:build-forms', 'propel:build-model', 'propel:build-schema', 'propel:build-sql', 'propel:data-dump', 'propel:data-load', 'propel:generate-admin',
            \ 'propel:generate-module', 'propel:generate-module-for-route', 'propel:graphviz', 'propel:init-admin', 'propel:insert-sql', 'propel:schema-to-xml',
            \ 'propel:schema-to-yml', 'test:all', 'test:coverage', 'test:functional', 'test:unit']
    endif
    return filter(list, 'v:val =~ "^".a:A')
  else
    let command = words[1]
    if command == 'init-module' || command == 'generate:module'
      let list = split(substitute(glob(b:sf_root_dir."/apps/*"), s:escapeback(b:sf_root_dir.'[/\]apps[/\]'), "", "g"), "\n")
      return filter(list, 'v:val =~ "^".a:A')
    else
      return []
    endif
  endif
endfunction

function! s:SetBufferCommand()
  command! -buffer -nargs=* -complete=customlist,<SID>GetSymfonyViewList Sview :call <SID>SymfonyView(<q-args>, '')
  command! -buffer -nargs=* -complete=customlist,<SID>GetSymfonyViewList SSview :call <SID>SymfonyView(<q-args>, 'S')
  command! -buffer -nargs=* -complete=customlist,<SID>GetSymfonyViewList SVview :call <SID>SymfonyView(<q-args>, 'V')

  command! -buffer -nargs=* -complete=customlist,<SID>GetSymfonyActionList Saction :call <SID>SymfonyAction(<q-args>, '')
  command! -buffer -nargs=* -complete=customlist,<SID>GetSymfonyActionList SSaction :call <SID>SymfonyAction(<q-args>, 'S')
  command! -buffer -nargs=* -complete=customlist,<SID>GetSymfonyActionList SVaction :call <SID>SymfonyAction(<q-args>, 'V')

  command! -buffer -nargs=? -complete=customlist,<SID>GetSymfonyModelList Smodel :call <SID>SymfonyModel(<q-args>, '')
  command! -buffer -nargs=? -complete=customlist,<SID>GetSymfonyModelList SSmodel :call <SID>SymfonyModel(<q-args>, 'S')
  command! -buffer -nargs=? -complete=customlist,<SID>GetSymfonyModelList SVmodel :call <SID>SymfonyModel(<q-args>, 'V')

  command! -buffer -nargs=? -complete=customlist,<SID>GetSymfonyFormList Sform :call <SID>SymfonyForm(<q-args>, '')
  command! -buffer -nargs=? -complete=customlist,<SID>GetSymfonyFormList SSform :call <SID>SymfonyForm(<q-args>, 'S')
  command! -buffer -nargs=? -complete=customlist,<SID>GetSymfonyFormList SVform :call <SID>SymfonyForm(<q-args>, 'V')

  command! -buffer -range -nargs=? Spartial :call <SID>SymfonyPartial(<q-args>, <line1>, <line2>, '')
  command! -buffer -range -nargs=? SSpartial :call <SID>SymfonyPartial(<q-args>, <line1>, <line2>, 'S')
  command! -buffer -range -nargs=? SVpartial :call <SID>SymfonyPartial(<q-args>, <line1>, <line2>, 'V')

  command! -buffer -nargs=0 Scomponent :call <SID>SymfonyComponent('')
  command! -buffer -nargs=0 SScomponent :call <SID>SymfonyComponent('S')
  command! -buffer -nargs=0 SVcomponent :call <SID>SymfonyComponent('V')
  "command! -buffer -complete=file -nargs=1 SymfonyProject :call s:SymfonyProject(<f-args>)
  command! -buffer -nargs=* -complete=customlist,<SID>GetSymfonyCommandList Symfony :call <SID>SymfonyCommand(<f-args>)

  command! -buffer -nargs=? -complete=custom,<SID>GetSymfonyConfigList Sconfig :call <SID>SymfonyOpenConfigFile(<f-args>, '')
  command! -buffer -nargs=? -complete=custom,<SID>GetSymfonyConfigList SSconfig :call <SID>SymfonyOpenConfigFile(<f-args>, 'S')
  command! -buffer -nargs=? -complete=custom,<SID>GetSymfonyConfigList SVconfig :call <SID>SymfonyOpenConfigFile(<f-args>, 'V')

  command! -buffer -nargs=? -complete=customlist,<SID>GetSymfonyLibList Slib :call <SID>SymfonyOpenLibFile(<f-args>, '')
  command! -buffer -nargs=? -complete=customlist,<SID>GetSymfonyLibList SSlib :call <SID>SymfonyOpenLibFile(<f-args>, 'S')
  command! -buffer -nargs=? -complete=customlist,<SID>GetSymfonyLibList SVlib :call <SID>SymfonyOpenLibFile(<f-args>, 'V')

  command! -buffer -nargs=? -complete=customlist,<SID>GetSymfonyHelperList Shelper :call <SID>SymfonyHelper(<q-args>, '')
  command! -buffer -nargs=? -complete=customlist,<SID>GetSymfonyHelperList SShelper :call <SID>SymfonyHelper(<q-args>, 'S')
  command! -buffer -nargs=? -complete=customlist,<SID>GetSymfonyHelperList SVhelper :call <SID>SymfonyHelper(<q-args>, 'V')
endfunction
