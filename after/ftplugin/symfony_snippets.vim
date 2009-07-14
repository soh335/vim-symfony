if !exists('loaded_snippet') || &cp
  finish
endif

let st = g:snip_start_tag
let et = g:snip_end_tag
let cd = g:snip_elem_delim

exec "Snippet request $this->getRequestParameter('".st."param".et. "');<CR>"
exec "Snippet verror return sfView::ERROR;<CR>"
exec "Snippet forward $this->forward('".st."module".et."', '".st."action".et."');<CR>"
exec "Snippet redirect $this->redirect('".st."param".et."');<CR>"
exec "Snippet serror $this->getRequest()->setError('".st."name".et."', '".st."text".et."');<CR>"
exec "Snippet isxml $this->getRequest()->isXmlHttpRequest()"
