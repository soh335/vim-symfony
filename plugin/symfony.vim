"{{{
"for symfony
" open template file function
function! s:error(str)
    echohl ErrorMsg
    echomsg a:str
    echohl None
endfunction

function! s:openTemplateFile(file)
if finddir("templates","./../") != ""
    silent exec ":e ". finddir("templates", expand('%:p:h')."/../"). "/".a:file
else
    call s:error("error not find  templates directory")
endif
endfunction

"find and edit view file (yet only Success file
function! s:SymfonyView(word)
    if a:word =~ 'execute' && strlen(a:word)>7
        let file = tolower(a:word[7:7]).a:word[8:]."Success.php"
        call s:openTemplateFile(file)
        unlet file
    elseif expand('%:t') =~ 'Action.class.php' && a:word == 'execute'
        "if action file is separeted
        let file = substitute(expand('%:t'),"Action.class.php","","")."Success.php"
        call s:openTemplateFile(file)
        unlet file
    else
        echo "not execute string"
    endif
endfunction

" find and edit action class file
function! s:SymfonyAction()
    if expand('%:t') =~ 'Success.php'
        let l:view = 'Success.php'
    elseif expand('%:t') =~ 'Error.php'
        let l:view = 'Error.php'
    endif
    if finddir("actions","./../") != "" && substitute(expand('%:p:h'),'.*/','','') == "templates"
        let file = substitute(expand('%:t'),l:view,"","")."Action.class.php"
        if findfile(file,"./../actions/") != ""
            silent execute ':e ./../actions/'.file
        elseif findfile("actions.class.php", "./../actions") != ""
            silent execute ':e ./../actions/actions.class.php'
        else
            echo "not exist action class file"
        endif
    else
        echo "not exitst action dir"
    endif
endfunction

"find model class
function! s:SymfonyModel(word)
    if findfile(a:word.".php", g:sf_root_dir."lib/model") != ""
        silent execute ':e '.g:sf_root_dir."lib/model/".a:word.".php"
    else
        if findfile(a:word.".php", g:sf_root_dir."lib/model/*") != ""
            silent execute ':e '. findfile(a:word.".php", g:sf_root_dir."lib/model/*")
        else
            echo "not find ".a:word.".php"
        endif
    endif
endfunction

"set symfony home project directory
function! s:SymfonyProject(word)
    if finddir('apps', a:word) != "" && finddir('web' , a:word) != "" && finddir('lib', a:word) != ""
        let g:sf_root_dir = finddir('apps',a:word)[:-5]
        echo "set symfony home"
    else
        echo "nof find apps, web, lib dir"
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

"execute symfony init-module
function! s:SymfonyInitModule(app, module)
    if exists("g:sf_root_dir")
        silent execute '!'.g:sf_root_dir."symfony init-module ".a:app." ".a:module
        echo "init module ".a:app." ".a:module
    else
        call s:error("not set symfony root dir")
    endif
endfunction
    
"open symfonyProject/config/* file
function! s:GetSymfonyConfigList(A,L,P)
    return split(substitute(glob(g:sf_root_dir."config/*"),g:sf_root_dir."config/","","g"), "\n")
endfunction

function! s:SymfonyOpenConfigFile(word)
    silent execute ':e '.g:sf_root_dir."config/".a:word
endfunction
"}}}


"{{{ map
nnoremap <silent><space>sv :call s:SymfonyView(expand('<cword>'))<CR>
nnoremap <silent><space>sa :call s:SymfonyAction()<CR>
noremap <silent><space>sm :call s:SymfonyModel(expand('<cword>'))<CR>
command! -complete=file -nargs=1 SymfonyProject :call s:SymfonyProject(<f-args>)
command! -nargs=0 Symfonycc :call s:SymconyCC()
command! -nargs=1 SymfonyInitApp :call s:SymfonyInitApp(<f-args>)
command! -nargs=* SymfonyInitModule :call s:SymfonyInitModule(<f-args>)
command! -nargs=? -complete=customlist,s:GetSymfonyConfigList SymfonyConfig :call s:SymfonyOpenConfigFile(<f-args>)
"}}}
