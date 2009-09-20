if exists('g:loaded_autoload_fuf_symfony') || v:version < 702
  finish
endif
let g:loaded_autoload_fuf_symfony = 1

let s:listener = {}

function! symfony#fuf#SmodelFinder()
  let list = split(substitute(glob(b:sf_model_dir.'**'),symfony#escapeback(b:sf_model_dir),"","g"), "\n")
  call fuf#callbackitem#launch('', 0, '>model>', s:listener, list, 1)
endfunction

function! symfony#fuf#SviewFinder()
endfunction

function! symfony#fuf#SformFinder()
endfunction

function! symfony#fuf#SlibFinder()
endfunction

function! symfony#fuf#SconfigFinder()
endfunction

function! symfony#fuf#SactionFinder()
endfunction

function! symfony#fuf#ShelperFinder()
endfunction

function s:listener.onComplete(item, method)
  silent edit `=b:sf_root_dir.'/lib/model/'.a:item`
endfunction

function s:listener.onAbort()
endfunction
