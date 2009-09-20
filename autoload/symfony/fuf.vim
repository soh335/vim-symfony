if exists('g:loaded_autoload_fuf_symfony') || v:version < 702
  finish
endif
let g:loaded_autoload_fuf_symfony = 1

let s:listener = {}

function! symfony#fuf#SmodelFinder()
  let list = split(substitute(glob(b:sf_model_dir.'**'),symfony#escapeback(b:sf_root_dir),"","g"), "\n")
  call fuf#callbackitem#launch('', 0, '>model>', s:listener, list, 1)
endfunction

function! symfony#fuf#SviewFinder()
  let list = split(substitute(glob(b:sf_root_dir.'/apps/*/modules/*/templates/*'),symfony#escapeback(b:sf_root_dir),"","g"), "\n")
  call fuf#callbackitem#launch('', 0, '>view>', s:listener, list, 1)
endfunction

function! symfony#fuf#SformFinder()
  let list = split(substitute(glob(b:sf_root_dir.'/lib/form/*'),symfony#escapeback(b:sf_root_dir),"","g"), "\n")
  call fuf#callbackitem#launch('', 0, '>form>', s:listener, list, 1)
endfunction

function! symfony#fuf#SlibFinder()
  let list = split(substitute(glob(b:sf_root_dir.'/lib/**'),symfony#escapeback(b:sf_root_dir),"","g"), "\n")
  let list += split(substitute(glob(b:sf_root_dir.'/apps/*/lib/*'),symfony#escapeback(b:sf_root_dir),"","g"), "\n")
  let list += split(substitute(glob(b:sf_root_dir.'/apps/*/modules/*/lib/*'),symfony#escapeback(b:sf_root_dir),"","g"), "\n")
  call fuf#callbackitem#launch('', 0, '>lib>', s:listener, list, 1)
endfunction

function! symfony#fuf#SconfigFinder()
  let list = split(substitute(glob(b:sf_root_dir.'/apps/*/modules/*/config/*'),symfony#escapeback(b:sf_root_dir),"","g"), "\n")
  let list += split(substitute(glob(b:sf_root_dir.'/apps/*/config/*'),symfony#escapeback(b:sf_root_dir),"","g"), "\n")
  let list += split(substitute(glob(b:sf_root_dir.'/config/*'),symfony#escapeback(b:sf_root_dir),"","g"), "\n")
  call fuf#callbackitem#launch('', 0, '>config>', s:listener, list, 1)
endfunction

function! symfony#fuf#SactionFinder()
  let list = split(substitute(glob(b:sf_root_dir.'/apps/*/modules/*/actions/*'),symfony#escapeback(b:sf_root_dir),"","g"), "\n")
  call fuf#callbackitem#launch('', 0, '>action>', s:listener, list, 1)
endfunction

function! symfony#fuf#ShelperFinder()
  let list = split(substitute(glob(b:sf_root_dir.'/lib/helper/*'),symfony#escapeback(b:sf_root_dir),"","g"), "\n")
  call fuf#callbackitem#launch('', 0, '>helper>', s:listener, list, 1)
endfunction

function s:listener.onComplete(item, method)
  silent edit `=b:sf_root_dir.a:item`
endfunction

function s:listener.onAbort()
endfunction
