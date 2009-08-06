if !exists('loaded_snippet') || &cp
  finish
endif

let st = g:snip_start_tag
let et = g:snip_end_tag
let cd = g:snip_elem_delim

exec "Snippet req $this->getRequestParameter('".st.et."');<CR>".st.et
exec "Snippet fw $this->forward('".st.et."', '".st.et."');"
exec "Snippet red $this->redirect('".st.et."');"
exec "Snippet verror return sfView::ERROR;".st.et
exec "Snippet serror $this->getRequest()->setError('".st.et."', '".st.et."');<CR>".st.et

exec "Snippet partial <?php include_partial('".st.et."'".st.et.") ?>"
exec "Snippet component <?php include_component('".st.et."', '".st.et."'".st.et.") ?>"
exec "Snippet slot <?php include_slot('".st.et."') ?><CR>".st.et."<CR><?php end_slot() ?>"

exec "Snippet newc $c = new Criteria();<CR>".st.et
exec "Snippet add $c->add(".st.et.", ".st.et.");"
exec "Snippet desc $c->addDescendingOrderByColumn(".st.et.");"
exec "Snippet asc $c->addAscendingOrderByColumn(".st.et.");"
exec "Snippet lim $c->setLimit(".st.et.");"
exec "Snippet dos ".st."self".et."::doSelect($c);".st.et
exec "Snippet doo ".st."self".et."::doSelectOne($c);".st.et
exec "Snippet doc ".st."self".et."::doCount($c);".st.et

exec "Snippet ceq Criteria::EQUAL".st.et
exec "Snippet cne Criteria::NOT_EQUAL".st.et
exec "Snippet cgt Criteria::GREATER_THAN".st.et
exec "Snippet clt Criteria::LESS_THAN".st.et
exec "Snippet cge Criteria::GREATER_EQUAL".st.et
exec "Snippet cle Criteria::LESS_EQUAL".st.et
exec "Snippet cli Criteria::LIKE".st.et
exec "Snippet cnl Criteria::NOT_LIKE".st.et
exec "Snippet cin Criteria::IN".st.et
exec "Snippet ccu Criteria::CUSTOM".st.et

exec "Snippet action <?php<CR><CR>class ".st."index".et."Action extends sfAction<CR>{<CR><Tab>public function execute($request) {<CR><Tab>".st.et."<CR><BS>}<CR><BS>}"
