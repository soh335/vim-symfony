"{{{
"for symfony
" open template file function
function! s:openTemplateFile(file)
if finddir("templates","./../") != ""
    silent exec ":e ". finddir("templates", expand('%:p:h')."/../"). "/".a:file
else
    echohl ErrorMsg
    echomsg "error not find  templates directory"
    echohl None
endif
endfunction

"find and edit view file
function! FindView(word)
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
nnoremap <silent><space>sv :call FindView(expand('<cword>'))<CR>

" find and edit action class file
function! FindAction()
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
nnoremap <silent><space>sa :call FindAction()<CR>

"find model class
function! FindModel(word)
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
noremap <silent><space>sm :call FindModel(expand('<cword>'))<CR>

"set symfony home project directory
function! s:SetSymfonyProject(word)
    if finddir('apps', a:word) != "" && finddir('web' , a:word) != "" && finddir('lib', a:word) != ""
        let g:sf_root_dir = finddir('apps',a:word)[:-5]
        echo "set symfony home"
        "autocmd FileType php let g:AutoComplPop_CompleteOption += ',k~/.vim/dict/symfony10'
    else
        echo "nof find apps, web, lib dir"
    endif
endfunction
command! -complete=file -nargs=1 SetSymfonyProject :call s:SetSymfonyProject(<f-args>)

function! s:SymconyCC()
    if exists("g:sf_root_dir")
        silent execute '!'.g:sf_root_dir."symfony cc"
        echo "cache clear"
    else
        echo "not set symfony root dir"
    endif
endfunction
command! -nargs=0 Symfonycc :call s:SymconyCC()
    
function! s:SymfonyConfig(word)
    echo a:word
    execute ':e '."/Library/WebServer/Documents/kayac/_shaneil/".<tab>
endfunction
"command! -nargs=1 SymfonyConfig :call s:SymfonyConfig(<f-args>)
"
"}}}
