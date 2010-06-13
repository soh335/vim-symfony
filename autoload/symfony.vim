"Name: vim-symfony
"Author: soh kitahara <sugarbabe335@gmail.com>

let s:symfony = {}
let s:is_debug = 0
let s:open_cmds = { 'edit': 'E', 'split': 'S', 'vsplit': 'V', 'tabnew': 'T' }

" util functions {{{
function! s:debug(str)
  if s:is_debug == 1
    echo a:str
  endif
endfunction

function! s:error(str)
  echohl ErrorMsg
  echomsg a:str
  echohl None
endfunction

function! s:sub(str,pat,rep)
  return substitute(a:str,'\v\C'.a:pat,a:rep,'')
endfunction

function! s:gsub(str,pat,rep)
  return substitute(a:str,'\v\C'.a:pat,a:rep,'g')
endfunction

function! s:add_method(dict, key, func_name)
  let a:dict[a:key] = function(a:func_name)
endfunction

function! s:add_methods(dict, funcs)
  for func in a:funcs
    call s:add_method(a:dict, func[0], func[1])
  endfor
endfunction

function! s:autocmd(name)
  execute 'silent doautocmd User '.a:name
endfunction

function! s:firstStrLower(str)
  return tolower(a:str[0:0]).a:str[1:]
endfunction

function! s:firstStrUpper(str)
  return toupper(a:str[0:0]).a:str[1:]
endfunction

function! s:open(open_cmd, file)
  execute a:open_cmd . ' `=a:file`'
endfunction

function! s:getLineByWord(path, word)
  let num = 1
  for line in readfile(a:path)
    if line =~ '\v\C'.a:word
      return num
    endif
    let num = num + 1
  endfor
  return 0
endfunction

function! s:hasLineByWord(path, word)
  if filereadable(a:path) == 0
    return 0
  endif

  return s:getLineByWord(a:path, a:word)
endfunction

function! symfony#glob(pattern)
  if !exists('s:symfony_glob_func')
    if has('win32')
     let s:symfony_glob_func = function("pathogen#glob")
    else
      let s:symfony_glob_func = function("glob")
    endif
  endif
  return call(s:symfony_glob_func, [a:pattern])
endfunction

function! s:escpath(path)
  return s:gsub(a:path, '[/\\]', '[/\\\\]')
endfunction
"}}}

" autoload functions {{{
function! symfony#symfony()
  return s:symfony
endfunction

function! symfony#projectInit(root_path)
  call s:debug("buf init")
  call s:symfony.root_path(a:root_path)

  call s:autocmd('SymfonyBufInit')
  call s:autocmd('Symfony'.s:symfony.version())
endfunction

function! symfony#find(open_cmd)
endfunction

function! symfony#command(...)
  execute '!'.s:symfony.root_path()."/symfony ".join(a:000, " ")
endfunction

function! symfony#alternate(open_cmd)

  let type = s:symfony.type()

  if type == 'action'
    execute 'Sview success'
  elseif type == 'view'
    execute 'Saction'
  elseif type == 'model'
    execute 'Smodel '. s:symfony.model().alternate_name()
  endif

endfunction

"}}}

"dictionaries function {{{
function! s:symfony.setvar(key, value)
  setlocal a:key = a:value
endfunction

function! s:symfony.root_path(...) dict
  if a:0 == 0 "get
    return b:symfony_root_path
  else "set
    let b:symfony_root_path = get(a:000, 0)
  endif
endfunction

function! s:symfony.path(...) dict
  let t = '%:p'
  if a:0 != 0
    let t = t . a:1
  endif
  return expand(t)
endfunction

function! s:symfony.version() dict
  if !self.cache.has(self.root_path(), 'version')
    if g:vim_symfony_autocmd_version == 0
      let v = ''
    else
      let v = system(self.root_path() . '/symfony --version')
      if v =~ "Fatal error"
        let v = ''
      else
        let v = s:sub(s:sub(v, '^symfony\sversion\s(\d\.\d).*', '\1'), '\.', '')
      endif
    endif
    call self.cache.set(self.root_path(), 'version', v)
  endif
  return self.cache.get(self.root_path(), 'version')
endfunction

function! s:symfony.app() dict
  let f = self.path()
  if f =~ 'apps[/\\\\]'
    return s:sub(f, '.*[/\\\\]apps[/\\\\](.{-})[/\\\\].*', '\1')
  endif
  return ''
endfunction

function! s:symfony.app_list() dict
  let path = s:escpath(self.root_path().'/apps/')
  return map(split(glob(self.root_path().'/apps/*'), '\n'), 's:sub(v:val, path, "")')
endfunction

function! s:symfony.module() dict
  let f = self.path()
  if f =~ '\v\Capps[/\\\\].{-}[/\\\\]modules[/\\\\]'
    return s:sub(f, '.*\apps[/\\\\].{-}[/\\\\]modules[/\\\\](.{-})[/\\\\].*', '\1')
  endif
  return ''
endfunction

function! s:symfony.module_list(...) dict
  let app = get(a:000, 0, 0) != '' ? get(a:000, 0) : '*'
  let path = s:escpath(self.root_path().'/apps/'.app.'/modules/')
  return map(split(glob(self.root_path().'/apps/'.app.'/modules/*'), '\n'), 's:sub(v:val, path, "")')
endfunction

function! s:symfony.type() dict
  let t = self.path(':h:t')
  if t == 'actions'
    let t = self.path(':t:r')
    if t =~ 'action'
      return 'action'
    elseif t =~ 'component'
      return 'component'
    endif
  elseif t == 'templates'
    return 'view'
  elseif self.path() =~ '\vlib/model'
    return 'model'
  elseif self.path() =~ '\vlib/filter'
    return 'filter'
  elseif self.path() =~ '\vlib/form'
    return 'form'
  endif
endfunction

function! s:symfony.action() dict

  let t = {}

  function t.name_list(...) dict
    if a:0 == 0
      let app = s:symfony.app()
      let module = s:symfony.module()
    elseif a:0 == 1
      let app = s:symfony.app()
      let module = get(a:000, 0)
    elseif a:0 == 2
      let app = get(a:000, 0)
      let module = get(a:000, 1)
    endif

    let path = s:escpath(s:symfony.root_path().'/apps/'.app.'/modules/'.module.'/actions/')
    return map(split(glob(s:symfony.root_path().'/apps/'.app.'/modules/'.module.'/actions/*')), 's:sub(v:val, path.''(\S{-})(Action|Component)*\.class\.php'', ''\1'')')
  endfunction

  function! t.suffix() dict
    return '.class.php'
  endfunction

  function! t.separated_name() dict
    if s:symfony.type() != 'action' && s:symfony.type() != "component"
      return ''
    endif
    if s:symfony.path(':t') =~ '\v\C(actions|components)' . self.suffix()
      return ''
    endif
      return s:sub(s:symfony.path(':t'), '(\S{-})(Action|Component)\.class\.php', '\1')
  endfunction

  function! t.execute_name(search_direction) dict

    "if s:symfony.type() != 'action'
    "  call s:error("when no args, will you in action file")
    "  return
    "endif

    let line_num = line('.')
    let stop = a:search_direction == 1 ? 0 : line('$')

    while line_num != stop
      let line = getline(line_num)
      if line =~ '\vfunction\s+execute\S*'
        break
      endif
      if stop == 0
        let line_num = line_num - 1
      else
        let line_num = line_num + 1
      endif
    endwhile

    if line_num == stop
      throw /notfind/
    endif

    let separated_name = self.separated_name()
    if separated_name != ''
      let name = s:firstStrLower(separated_name)
    else
      let n = s:sub(getline(line_num), '.*function\s+execute(\S{-})\(.*', '\1')
      let name = s:firstStrLower(n)
    endif

    if s:symfony.type() == "action"
      return name
    elseif s:symfony.type() == "component"
      return '_'.name
    endif

  endfunction

  let self.action = t
endfunction

call s:symfony.action()


function! s:symfony.view() dict

  let t = {}

  function! t.name() dict
    let n = s:sub(s:symfony.path(':t'), '(.{-})\.php', '\1')
    return s:sub(n, '(.{-})(Success|Error)', '\1')
  endfunction

  function! t.name_list(...) dict
    if a:0 == 0
      let app = s:symfony.app()
      let module = s:symfony.module()
    elseif a:0 == 1
      let app = s:symfony.app()
      let module = get(a:000, 0)
    elseif a:0 == 2
      let app = get(a:000, 0)
      let module = get(a:000, 1)
    endif

    return map(filter(split(glob(s:symfony.root_path().'/apps/'.app.'/modules/'.module.'/templates/*')), 'v:val !~ ''\^'''), 's:sub(v:val, s:symfony.root_path()."/apps/".app."/modules/".module.''/templates/(\S{-})(Success|Error)\.php'', ''\1'')')
  endfunction

  function! t.suffix(...) dict
    if s:symfony.type() == "action"
      if a:0 == 1 && a:1 =~ '^e'
        return 'Error.php'
      else
        return 'Success.php'
      endif
    elseif s:symfony.type() == "component"
      return '.php'
    endif
  endfunction

  function! t.alternate_action_name_and_num() dict

    let view_name = s:symfony.view.name()

    if view_name[0:0] == '_' "if component
      return s:searchAndGetNameAndNum(view_name[1:], 'Component', 'components')
    else "if action
      return s:searchAndGetNameAndNum(view_name, 'Action', 'actions')
    endif
  endfunction

  let self.view = t
endfunction

function! s:searchAndGetNameAndNum(view_name, single_file_name, base_file_name)
  let path = s:symfony.root_path() . '/apps/' . s:symfony.app() . '/modules/'
        \ . s:symfony.module() . '/actions/'
  let num = s:hasLineByWord(path.a:view_name.a:single_file_name.s:symfony.action.suffix(), 'function\s+execute\(')

  if num != 0
    let name = a:view_name.a:single_file_name
  else
    let num = s:hasLineByWord(path.a:base_file_name.s:symfony.action.suffix(),'function\s+execute'.s:firstStrUpper(a:view_name).'\(')
    if num == 0
      throw "notfind"
    else
      let name = a:base_file_name
    endif
  endif

  return { 'name' : name , 'num' : num }
endfunction

call s:symfony.view()


function! s:symfony.form() dict
  let t = {}

  function! t.name(...) dict
    let f = a:0 == 0 ? s:symfony.path(':t') : a:1
    return s:sub(f, '(.{-})\.class\.php', '\1')
  endfunction

  function! t.dir_path() dict
    if s:symfony.model().type() == 'doctrine'
      return s:symfony.root_path().'/lib/form/doctrine'
    elseif s:symfony.model().type() == 'propel'
      return s:symfony.root_path().'/lib/form'
    endif
  endfunction

  function! t.path(...) dict
    return get(split(glob(self.dir_path().'/**/' . join(a:000, '/') . self.suffix())), 0, 0)
  endfunction

  function! t.suffix() dict
    return '.class.php'
  endfunction

  let self.form = t
endfunction

call s:symfony.form()


function! s:symfony.filter() dict
  let t = {}

  function! t.name(...) dict
    let f = a:0 == 0 ? s:symfony.path(':t') : a:1
    return s:sub(f, '(.{-})\.class\.php', '\1')
  endfunction

  function! t.dir_path() dict
    if s:symfony.model().type() == 'doctrine'
      return s:symfony.root_path().'/lib/filter/doctrine'
    elseif s:symfony.model().type() == 'propel'
      return s:symfony.root_path().'/lib/filter'
    endif
  endfunction

  function! t.path(...) dict
      return get(split(glob(self.dir_path().'/**/' . join(a:000, '/') . self.suffix())), 0, 0)
  endfunction

  function! t.suffix() dict
    return '.class.php'
  endfunction

  let self.filter = t
endfunction

call s:symfony.filter()

"}}}

function! s:symfony.model() dict
  if !self.cache.has(self.root_path(), 'model')
    let f = printf('%s/%s/%s/%s', self.root_path(), 'config', 'doctrine', 'schema.yml')
    if filereadable(f)
      call self.cache.set(self.root_path(), 'model', DoctrineModel())
    else
      call self.cache.set(self.root_path(), 'model', PropelModel())
    endif
  endif
  return self.cache.get(self.root_path(), 'model')
endfunction

"model function {{{
function! DoctrineModel() 
  let t = {}

  function! t.name(...) dict
    let n = a:0 == 0 ? s:symfony.path(':t') : a:1
    return s:sub(n, '(.{-})\.class\.php', '\1')
  endfunction

  function! t.type() dict
    return 'doctrine'
  endfunction

  function! t.dir_path() dict
    return s:symfony.root_path().'/lib/model/doctrine'
  endfunction

  function! t.path(...) dict
    let f = self.dir_path() .'/**/'. join(a:000, '/') . self.suffix()
    let file = get(split(glob(f)), 0, 0)
    return file
  endfunction

  function! t.suffix() dict
    return  '.class.php'
  endfunction

  function! t.is_row() dict
    if self.name() =~ 'Table$'
      return 0
    else
      return 1
    endif
  endfunction

  function t.alternate_name() dict
    if self.is_row()
      return self.name() . 'Table'
    else
      return s:sub(self.name(), '(\S{-})Table$', '\1')
    endif
  endfunction

  return t
endfunction


function! PropelModel() 

  let t = {}

  function! t.name(...) dict
    let n = a:0 == 0 ? s:symfony.path(':t') : a:1
    return s:sub(n, '(.{-})\.php', '\1')
  endfunction

  function! t.type() dict
    return 'propel'
  endfunction

  function! t.dir_path() dict
    return s:symfony.root_path() . '/lib/model'
  endfunction

  function! t.path(...) dict
    let f = self.dir_path() .'/**/'. join(a:000, '/') . self.suffix()
    let file = get(split(glob(f)), 0, 0)
    return file
  endfunction

  function! t.suffix() dict
    return '.php'
  endfunction

  function! t.is_row() dict
    if self.name() =~ 'Peer$'
      return 0
    else
      return 1
    endif
  endfunction

  function t.alternate_name() dict
    if self.is_row()
      return self.name() . 'Peer'
    else
      return s:sub(self.name(), '(\S{-})Peer$', '\1')
    endif
  endfunction

  return t
endfunction
"}}}

"{{{ cache
function! s:symfony.cache() dict

  let s:cache_prototype = {}
  let t = {}

  function! t.clear(...) dict
    if a:0 == 0
      let s:cache_prototype = {}
    elseif a:0 == 1
      unlet! s:cache_prototype[a:1]
    else
      unlet! s:cache_prototype[a:1][a:2]
    endif
  endfunction

  function! t.get(namespace, key) dict
    call self.create_namespace(a:namespace)
    return s:cache_prototype[a:namespace][a:key]
  endfunction

  function! t.has(namespace, key) dict
    call self.create_namespace(a:namespace)
    return has_key(s:cache_prototype[a:namespace], a:key)
  endfunction

  function! t.set(namespace, key, value) dict
    call self.create_namespace(a:namespace)
    let s:cache_prototype[a:namespace][a:key] = a:value
  endfunction

  function t.clone() dict
    return deepcopy(s:cache_prototype)
  endfunction

  function! t.create_namespace(namespace) dict
    if !has_key(s:cache_prototype, a:namespace)
      let s:cache_prototype[a:namespace] = {}
    endif
  endfunction

  let self.cache = t
endfunction

call s:symfony.cache()
"}}}

augroup SymfonyBufInit
  autocmd!
  autocmd User SymfonyBufInit call s:SymfonyBufInit()
augroup END


"{{{ edit functions
function! s:actionEdit(open_cmd, ...)

  try
    if a:0 == 0

      let t = s:symfony.view.alternate_action_name_and_num()
      let name = t.name
      let num = t.num
      let app = s:symfony.app()
      let module = s:symfony.module()

    elseif a:0 == 2

      let app = get(a:000, 0, 0)
      let module = get(a:000, 1, 0)
      let name = 'actions'
      let num = 1

    elseif a:0 >= 3

      let app = get(a:000, 0, 0)
      let module = get(a:000, 1, 0)
      let name = get(a:000, 2) != "actions" ? get(a:000, 2) . 'Action' : 'actions'
      let num = 1

    endif

    let file = s:symfony.root_path() . '/apps/' . app . '/modules/'
          \ . module . '/actions/' . name . s:symfony.action.suffix()

    call s:open(a:open_cmd, file)

    execute num
  catch /notfind/
    call s:error("not exists associated (action|component) file")
  endtry

endfunction

function! s:viewEdit(open_cmd, search_direction, ...)

  try 
    if a:0 == 0

      let name = s:symfony.action.execute_name(a:search_direction)
      let app = s:symfony.app()
      let module = s:symfony.module()
      let suffix = s:symfony.view.suffix()

    elseif a:0 == 1 || a:0 == 2

      let name = get(a:000, 0, 0)
      let app = s:symfony.app()
      let module = s:symfony.module()
      let suffix = s:symfony.view.suffix(get(a:000, 1))

    else

      let app = get(a:000, 0, 0)
      let module = get(a:000, 1, 0)
      let name = get(a:000, 2, 0)
      let suffix = s:symfony.view.suffix(get(a:000, 3))

    endif

    let file = s:symfony.root_path() . '/apps/' . app . '/modules/' . module
          \ . '/templates/' . name . suffix

    call s:open(a:open_cmd, file)
  catch /notfind/
    call s:error("can't find executeXXX")
  endtry
endfunction

function! s:modelEdit(open_cmd, ...)

  if a:0 == 0
    let name = [expand('<cword>')]
  else
    let name = a:000
  endif

  let file = call(s:symfony.model().path, name, s:symfony.model())
  
  if file != ''
    call s:open(a:open_cmd, file)
  else
    call s:error("can't find")
  endif
endfunction

function! s:formEdit(open_cmd, ...)

  if a:0 == 0
    let name = [expand('<cword>')]
  else
    let name = a:000
  endif

  let file = call(s:symfony.form.path, name, s:symfony.form)

  if file != ''
    call s:open(a:open_cmd, file)
  else
    call s:error("can't find")
  endif
endfunction

function! s:filterEdit(open_cmd, ...)

  if a:0 == 0
    let name = [expand('<cword>')]
  else
    let name = a:000
  endif

  let file = call(s:symfony.filter.path, name, s:symfony.filter)

  if file != ''
    call s:open(a:open_cmd, file)
  else
    call s:error("can't find")
  endif
endfunction

function! s:partialEdit(open_cmd, line1, line2, count, ...)

  if a:count == 0

    let l = s:sub(getline('.'), '.*include_partial\(\s*["''](\S{-})["''].*', '\1')
    if l !~ '/'
      let file = s:symfony.root_path() . '/apps/' . s:symfony.app() . '/modules/'
            \ . s:symfony.module() . '/templates/_' . l . '.php'
    else
      let ls = split(l, '/')
      if ls[0] == 'global'
        let file = s:symfony.root_path() . '/apps/'. s:symfony.app() . '/templates/_'
              \ . ls[1] . '.php'
      else
        let file = s:symfony.root_path() . '/apps/' . s:symfony.app() . '/modules/'
              \ . ls[0] . '/templates/_' . ls[1] . '.php'
      endif
    endif
    call s:open(a:open_cmd, file)

  else

    let tmp = @@
    silent normal gvy
    let selected = @@
    let @@ = tmp

    if a:0 == 1
      let module = s:symfony.module()
      let name = get(a:000, 0)
    elseif a:0 == 2
      let module = get(a:000, 0)
      let name = get(a:000, 1)
    else
      call s:error("can't find")
      return
    endif

    call append(a:line1-1, '<?php include_partial("'.module.'/'.name.'") ?>')
    execute a:line1 + 1
    execute 'delete'.(a:line2 - a:line1 + 1)
    let file = s:symfony.root_path() . '/apps/' . s:symfony.app(). '/modules/'
          \ . module . '/templates/_' . name . '.php'

    call s:open(a:open_cmd, file)
    call append(0, split(selected, '\n'))
  endif

endfunction

function! s:componentEdit(open_cmd, line1, line2, count, ...)

  if a:count == 0

    let l = s:sub(getline('.'), '.*include_component\((.*)\).*', '\1')
    let ls = split(l, ',')

    if len(ls) < 2
      call s:error("error")
    endif

    let ls[0] = s:sub(ls[0], '\s*["'']\s*(.*)\s*["'']\s*', '\1')
    let ls[1] = s:sub(ls[1], '\s*["'']\s*(.*)\s*["'']\s*', '\1')

    let file = s:symfony.root_path() . '/apps/' . s:symfony.app() . '/modules/'
             \ . ls[0] . '/templates/_' . ls[1] . '.php'
    call s:open(a:open_cmd, file)

  else

    let tmp = @@
    silent normal gvy
    let selected = @@
    let @@ = tmp

    if a:0 == 1
      let module = s:symfony.module()
      let name = get(a:000, 0)
    elseif a:0 == 2
      let module = get(a:000, 0)
      let name = get(a:000, 1)
    else
      call s:error("can't find")
      return
    endif

    call append(a:line1-1, '<?php include_component("'.module.'", "'.name.'") ?>')
    execute a:line1 + 1
    execute 'delete'.(a:line2 - a:line1 + 1)
    let file = s:symfony.root_path() . '/apps/' . s:symfony.app(). '/modules/'
          \ . module . '/templates/_' . name . '.php'

    call s:open(a:open_cmd, file)
    call append(0, split(selected, '\n'))

  endif

endfunction
"}}} 

" {{{ completation functions
function! s:CompleteActionList(a, l, p)
  let args = split(s:sub(a:l, a:a.'$', '') )
  let args = args[1:]

  if len(args) == 0
    let list = s:symfony.app_list()
  elseif len(args) == 1
    let list = s:symfony.module_list(args[0])
  elseif len(args) == 2
    let list = s:symfony.action.name_list(args[0], args[1])
  endif

  return filter(list, 'v:val =~ "^".a:a')
endfunction

function! s:CompleteViewList(a, l, p)
  let args = split(s:sub(a:l, a:a.'$', '') )
  let args = args[1:]

  if len(args) == 0
    let list = s:symfony.app_list()
  elseif len(args) == 1
    let list = s:symfony.module_list(args[0])
  elseif len(args) == 2
    let list = s:symfony.view.name_list(args[0], args[1])
  elseif len(args) == 3
    let list = ["success", "error"]
  endif

  return filter(list, 'v:val =~ "^".a:a')
endfunction

function! s:CompleteModelList(a, l, p)
  let args = split(s:sub(a:l, a:a.'$', '') )
  let args = args[1:]
  let path = join(args, '/')

  let list = map(split(glob(s:symfony.model().dir_path() . '/' . path . '/*')), 's:symfony.model().name(fnamemodify(v:val, '':t''))')

  return filter(list, 'v:val =~ "^".a:a')
endfunction

function! s:CompleteFormList(a, l, p)
  let args = split(s:sub(a:l, a:a.'$', '') )
  let args = args[1:]
  let path = join(args, '/')

  let list = map(split(glob(s:symfony.form.dir_path() . '/' . path . '/*')), 's:symfony.form.name(fnamemodify(v:val, '':t''))')

  return filter(list, 'v:val =~ "^".a:a')
endfunction

function! s:CompleteFilterList(a, l, p)
  let args = split(s:sub(a:l, a:a.'$', '') )
  let args = args[1:]
  let path = join(args, '/')

  let list = map(split(glob(s:symfony.filter.dir_path() . '/' . path . '/*')), 's:symfony.filter.name(fnamemodify(v:val, '':t''))')

  return filter(list, 'v:val =~ "^".a:a')
endfunction
" }}}

function! s:DefineEditCommand(name, ...)
  if a:0 == 0
    let args = ''
  else
    let args = "," . join(get(a:000, 0), ", ")
  endif
  for [key, value] in items(s:open_cmds)
    execute 'command! -buffer -range=0 -nargs=* -complete=customlist,<SID>Complete'.s:firstStrUpper(a:name).'List S'.value.a:name.' :call <SID>'.a:name.'Edit("' . key .'"' . args.')'
  endfor
  if exists("g:vim_symfony_".a:name."_default_open_cmd")
    let cmd = g:vim_symfony_{a:name}_default_open_cmd
  endif
    let cmd = 'edit'
  execute 'command! -buffer -range=0 -nargs=* -complete=customlist,<SID>Complete'.s:firstStrUpper(a:name).'List S'.a:name.' :call <SID>'.a:name.'Edit("' . cmd .'"' . args .')'
endfunction

function! s:DefineCommand()
  call s:DefineEditCommand('action', ['<f-args>'])
  call s:DefineEditCommand('view', ['g:vim_symfony_default_search_action_top_direction', '<f-args>'])
  call s:DefineEditCommand('model', ['<f-args>'])
  call s:DefineEditCommand('form', ['<f-args>'])
  call s:DefineEditCommand('filter', ['<f-args>'])
  call s:DefineEditCommand('partial', ['<line1>', '<line2>', '<count>', '<f-args>'])
  call s:DefineEditCommand('component', ['<line1>', '<line2>', '<count>', '<f-args>'])
  command! -buffer -nargs=0 Salternate call symfony#alternate('edit')
  command! -buffer -nargs=0 Sfind call symfony#find('edit')
  command! -buffer -nargs=* Symfony call symfony#command(<f-args>)
endfunction

function! s:SymfonyBufInit()
  call s:DefineCommand()
endfunction
