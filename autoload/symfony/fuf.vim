if exists('g:loaded_autoload_fuf_symfony') || v:version < 702
  finish
endif
let g:loaded_autoload_fuf_symfony = 1

let s:listener = {}

function! s:model()
  let symfony = symfony#symfony()
  let list = split(glob(symfony.model().dir_path().'/**'))
  call fuf#callbackitem#launch('', 0, '>model>', s:listener, list, 1)
endfunction

function! s:view()
  let symfony = symfony#symfony()
  let list = split(glob(symfony.root_path().'/apps/**/templates/*'))
  call fuf#callbackitem#launch('', 0, '>view>', s:listener, list, 1)
endfunction

function! s:app_view()
  let symfony = symfony#symfony()
  let list = split(glob(symfony.root_path().'/apps/'.symfony.app().'/**/templates/*'))
  call fuf#callbackitem#launch('', 0, '>view>', s:listener, list, 1)
endfunction

function! s:module_view()
  let symfony = symfony#symfony()
  let list = split(glob(symfony.root_path().'/apps/'.symfony.app().'/modules/'.symfony.modle().'/templates/*'))
  call fuf#callbackitem#launch('', 0, '>view>', s:listener, list, 1)
endfunction

function! s:action()
  let symfony = symfony#symfony()
  let list = split(glob(symfony.root_path().'/apps/**/actions/*'))
  call fuf#callbackitem#launch('', 0, '>action>', s:listener, list, 1)
endfunction

function! s:app_action()
  let symfony = symfony#symfony()
  let list = split(glob(symfony.root_path().'/apps/'.symfony.app().'/**/actions/*'))
  call fuf#callbackitem#launch('', 0, '>actions>', s:listener, list, 1)
endfunction

function! s:module_action()
  let symfony = symfony#symfony()
  let list = split(glob(symfony.root_path().'/apps/'.symfony.app().'/modules/'.symfony.modle().'/actions/*'))
  call fuf#callbackitem#launch('', 0, '>action>', s:listener, list, 1)
endfunction

function! s:form()
  let symfony = symfony#symfony()
  let list = split(glob(symfony.form().dir_path.'/*'))
  call fuf#callbackitem#launch('', 0, '>form>', s:listener, list, 1)
endfunction

function! s:filter()
  let symfony = symfony#symfony()
  let list = split(glob(symfony.filter().dir_path.'/*'))
  call fuf#callbackitem#launch('', 0, '>filter>', s:listener, list, 1)
endfunction

function! symfony#fuf#define_command()
  command! -buffer -nargs=0 FufSymfonyModel call <SID>model()
  command! -buffer -nargs=0 FufSymfonyView call <SID>view()
  command! -buffer -nargs=0 FufSymfonyCurrentAppView call <SID>app_view()
  command! -buffer -nargs=0 FufSymfonyCurrentModuleView call <SID>module_view()
  command! -buffer -nargs=0 FufSymfonyAction call <SID>action()
  command! -buffer -nargs=0 FufSymfonyCurrentAppAction call <SID>app_action()
  command! -buffer -nargs=0 FufSymfonyCurrentModuleAction call <SID>module_action()
  command! -buffer -nargs=0 FufSymfonyForm call <SID>form()
  command! -buffer -nargs=0 FufSymfonyFilter call <SID>filter()
endfunction

