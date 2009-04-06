"{{{ for symfony 
"Name: vim-symfony
"Author: soh kitahara <sugarbabe335@gmail.com>
"URL: http://github.com/soh335/vim-symfony/tree/master
"Description:
"   vim-symfony offers some convenient methods when you develp symfony project
"   in vim
"
"   :SymfonyView
"       move to template/xxxSuccess.php from action file.
"       Even if Action file name is not actions.class.php but
"       xxxAction.class.php, it can move to xxxSuccess.php.
"       In case of actions.class.php it judges from the line of the cursor
"       position, in case of xxxAction.class.php it judges from filename.
"
"   :SymfonyView error
"       If argument nameed error is passed to SymfonyView, move to
"       template/xxxError.php.
"
"   :SymfonyAction
"       move to actions/xxxAction.class.php or actions.class.php from
"       templates/xxxSuccess.php or templates/xxxError.php.
"       Find executeXXX or execute line and move this line number
"
"   :SymfonyAction ...
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
"   :SymfonyModel
"       move to lib/model/xxx.php or lib/model/xxxPeer.php from anywhere.
"       Also in lib/model/---/xxx.php or xxxPeer.php, it corrensponds.
"       It judges from word under cursor.
"       It it necessary to do :SymfonyProject first.
"
"   :SymfonyPartial
"       move to partial template file. It judges from line.
"       Also in global/xxx, it corresponds.
"
"   :SymfonyComponent
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
"   :SymfonyConfig
"       It is shortcut to config/* files.
"
"   :SymfonyLib
"       It is shortcut to lib/* files.


"echo errormsg func
function! s:error(str)
    echohl ErrorMsg
    echomsg a:str
    echohl None
endfunction

" open template file function
function! s:openTemplateFile(file)
if finddir("templates","./../") != ""
    silent exec ":e ". finddir("templates", expand('%:p:h')."/../"). "/".a:file
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
        if finddir("actions","./../") != "" && substitute(expand('%:p:h'),'.*/','','') == "templates"
            let l:prefix = substitute(expand('%:t'),l:view,"","") 
            let l:file = l:prefix."Action.class.php"
            if findfile(l:file,"./../actions/") != ""
                silent execute ':e ./../actions/'.l:file
                call s:searchWordInFileAndMove('execute')
            elseif findfile("actions.class.php", "./../actions") != ""
                silent execute ':e ./../actions/actions.class.php'
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
            if !exists("g:sf_root_dir")
                call s:error("not set root dir")
            endif
            if s:OpenExistFile(l:list[0]."Action.class.php", "./") != 0
            elseif s:OpenExistFile("actions.class.php", "../../".l:list[0]."/actions/")
            elseif s:OpenExistFile("actions.class.php", g:sf_root_dir."apps/".g:sf_default_app."/modules/".l:list[0]."/actions/")
            else
                call s:error("Not find")
            endif
        elseif len(l:list) == 2
            if s:OpenExistFile(l:list[1]."Action.class.php", "../../".l:list[0]."/actions/") != 0
            elseif s:OpenExistFile("actions.class.php", g:sf_root_dir."apps/".l:list[0]."/modules/".l:list[1]."/actions/") != 0
            else
                call s:error("Not find")
            endif
        elseif len(l:list) == 3
            if s:OpenExistFile(l:list[2]."Action.class.php", g:sf_root_dir."apps/".l:list[0]."/modules/".l:list[1]."/actions/") != 0
            else
                call s:error("Not find")
            endif
        endif
    endif
endfunction

function! s:OpenExistFile(file, path)
    if findfile(a:file, a:path) != ""
        silent execute ':e '.a:path.a:file
        return 1
    endif
    return 0
endfunction

"find model class
"word under cursor is required
function! s:SymfonyModel(word)
    if a:word == ""
        let l:word = expand('<cword>')
    else
        let l:word = a:word
    endif
    "if findfile(l:word.".php", g:sf_root_dir."lib/model/") != ""
    if findfile(l:word.".php", b:sf_model_dir) != ""
        silent execute ':e '.b:sf_model_dir.l:word.".php"
    else
        if findfile(l:word.".php", b:sf_model_dir) != ""
            silent execute ':e '. findfile(l:word.".php", b:sf_model_dir)
        else
            call s:error("not find ".l:word.".php")
        endif
    endif
endfunction

function! s:SymfonyComponent()
    let l:mx = 'include_component(["'']\(.\{-}\)["''].\{-}["'']\(.\{-}\)["'']'
    let l:l = matchstr(getline('.'), l:mx)
    if l:l != ""
        let l:module = substitute(l:l, l:mx, '\1', '')
        let l:temp = substitute(l:l, l:mx, '\2', '')
        silent execute ':e ../../'.l:module.'/templates/_'.l:temp.'.php'
    else
        let l:file = expand('%:r')
        let l:file = l:file[1:]
        silent execute ':e ../actions/components.class.php'
        call s:searchWordInFileAndMove('execute'.toupper(l:file[0:0]).l:file[1:])
    endif
endfunction

"find and edit partial template
function! s:SymfonyPartial()
    let l:word = matchstr(getline('.'), 'include_partial(["''].\{-}["'']')
    let l:tmp = l:word[17:-2]
    if l:tmp[0:5] == "global"
        silent execute ':e '.g:sf_root_dir.'apps/'.s:GetNowApp().'/templates/_'.l:tmp[7:].'.php'
    elseif l:tmp =~ "/"
        echo l:tmp
        let l:list = matchlist(l:tmp, '\(.*\)/\(.*\)')
        silent execute ':e ../../'.l:list[1].'/templates/_'.l:list[2].'.php'
    else
        silent execute ':e _'.l:tmp.'.php'
    endif
endfunction


"set symfony home project directory
function! s:SymfonyProject(word)
    if finddir('apps', a:word) != "" && finddir('web' , a:word) != "" && finddir('lib', a:word) != ""
        let l:tmp = finddir('apps', a:word)
        if l:tmp == "apps"
            let g:sf_root_dir =substitute(expand('%:p'),"/apps.*","", "")."/"
        else
            let g:sf_root_dir = finddir('apps',a:word)[:-5]
        endif
        call s:SetDefaultApp()
        echon "set symfony home"
        call s:SetModelPath()
    else
        call s:error("nof find apps, web, lib dir")
    endif
endfunction

function! s:SetDefaultApp()
    if exists("g:sf_root_dir") && filereadable(g:sf_root_dir."web/index.php")
        for l:line in readfile(g:sf_root_dir."web/index.php")
            if l:line =~ 'define(.*SF_APP.*)'
                let l:app = substitute(l:line,'define.*SF_APP.*,.\{-}["'']','','')
                let l:app = substitute(l:app,'["''].*','','')
                let g:sf_default_app = l:app
            endif
        endfor
    endif
endfunction

function! s:SetModelPath()
    if exists("g:sf_root_dir")
        if glob(g:sf_root_dir."lib/model/*Peer.php") != ""
            let b:sf_model_dir = g:sf_root_dir."lib/model/"
        elseif glob(g:sf_root_dir."lib/model/*/*Peer.php") != ""
            let b:sf_model_dir = g:sf_root_dir."lib/model/*/"
        endif
    endif
endfunction

"execute symfony clear cache
function! s:SymconyCC()
    if exists("g:sf_root_dir")
        silent execute '!'.g:sf_root_dir."symfony cc"
        echo "cache clear"
    else
        call s:error("not set symfony root dir")
    endif
endfunction

"execute symfony init-app 
function! s:SymfonyInitApp(app)
    if exists("g:sf_root_dir")
        silent execute '!'.g:sf_root_dir."symfony init-app ".a:app
        echo "init app ".a:app
    else
        call s:error("not set symfony root dir")
    endif
endfunction

"get now app
function! s:GetNowApp()
    let l:t = substitute(expand('%:p'), g:sf_root_dir, '', '')
    if l:t[0:3] == "apps"
        let l:app = matchstr(l:t[5:], '\(.\{-}\)/')
        return l:app[:-2]
    endif
    return 0
endfunction

"execute symfony init-module
function! s:SymfonyInitModule(app, module)
    if exists("g:sf_root_dir")
        silent execute '!'.g:sf_root_dir."symfony init-module ".a:app." ".a:module
        echo "init module ".a:app." ".a:module
    else
        call s:error("not set symfony root dir")
    endif
endfunction

"execute symfony propel-init-admin    
function! s:SymfonyPropelInitAdmin(app, module, model)
    if exists("g:sf_root_dir")
        silent execute '!'.g:sf_root_dir."symfony propel-init-admin ".a:app." ".a:module." ".a:model
        echo "propel-init-admin ".a:app." ".a:module." ".a:model
    else
        call s:error("not set symfony root dir")
    endif
endfunction

"open symfonyProject/config/* file
function! s:GetSymfonyConfigList(A,L,P)
    if exists("g:sf_root_dir")
        return split(substitute(glob(g:sf_root_dir."config/".a:A."*"),g:sf_root_dir."config/","","g"), "\n")
    else
        call s:error("not set symfony root dir")
    endif
endfunction

function! s:SymfonyOpenConfigFile(word)
    silent execute ':e '.g:sf_root_dir."config/".a:word
endfunction

"open symfonyProject/lib* file
function! s:GetSymfonyLibList(A,L,P)
    if exists("g:sf_root_dir")
        return split(substitute(glob(g:sf_root_dir."lib/".a:A."*"),g:sf_root_dir."lib/","","g"), "\n")
    else
        call s:error("not set symfony root dir")
    endif
endfunction

function! s:GetSymfonyModelList(A, L, P)
    if exists("b:sf_model_dir")
    else
        call s:error("not set symfony model path")
    endif
endfunction

function! s:SymfonyOpenLibFile(word)
    silent execute ':e '.g:sf_root_dir."lib/".a:word
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
    if exists("g:sf_root_dir")
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

"{{{ auto
augroup symfonyPluginDetect
    autocmd!
    autocmd BufNewFile,BufRead * call s:Detect(expand("<afile>:p"))
augroup END
"}}}

"{{{ map
command! -nargs=? SymfonyView :call s:SymfonyView(<q-args>)
command! -nargs=* SymfonyAction :call s:SymfonyAction(<q-args>)
"command! -nargs=0 SymfonyModel :call s:SymfonyModel(expand('<cword>'))
command! -nargs=? -complete=customlist,s:GetSymfonyModelList SymfonyModel :call s:SymfonyModel(<q-args>)
command! -nargs=0 SymfonyPartial :call s:SymfonyPartial()
command! -nargs=0 SymfonyComponent :call s:SymfonyComponent()
command! -complete=file -nargs=1 SymfonyProject :call s:SymfonyProject(<f-args>)
command! -nargs=0 Symfonycc :call s:SymconyCC()
command! -nargs=1 SymfonyInitApp :call s:SymfonyInitApp(<f-args>)
command! -nargs=+ SymfonyInitModule :call s:SymfonyInitModule(<f-args>)
command! -nargs=+ SymfonyPropelInitAdmin :call s:SymfonyPropelInitAdmin(<f-args>)
command! -nargs=? -complete=customlist,s:GetSymfonyConfigList SymfonyConfig :call s:SymfonyOpenConfigFile(<f-args>)
command! -nargs=? -complete=customlist,s:GetSymfonyLibList SymfonyLib :call s:SymfonyOpenLibFile(<f-args>)
"}}}
