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
"   :Shelper
"       move to lib/helper/xxxHelper.php
"       if you call this method with no argument, judges from word under
"       cursor.
"
"   :Spartial
"       move to partial template file. It judges from line.
"       Also in global/xxx, it corresponds.
"       If you call this method after select lines by visual-mode, create new
"       partial file.
"       :'<,'>Spartial xxx
"
"
"   :Scomponent
"       move to component template file or components.class.php.
"       If you call this in 'include_component...', move to template file.
"       And when it is other than that, move to components.class.php file
"
"   :Symfony xxx
"       execute symfony task. 
"
"   :SConfig
"       It is shortcut to config/* files.
"
"   :SLib
"       It is shortcut to lib/* files.


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
    let fn = fnamemodify(ofn,':s?\(.*\)[\/]\(apps\|config\|data\|doc\|lib\|log\|plugins\|test\|web\)\($\|[\/].*$\)?\1?')
  endwhile
endfunction

"{{{ autoload
function! s:autoload()
  if !exists("g:autoloaded_symfony")
    echo "autoload"
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
augroup symfonyPluginDetect
  autocmd!
  autocmd BufNewFile,BufRead * call s:Detect(expand("<afile>:p"))
augroup END
"}}}
