
" When g:qpatterns_dev_mode=1, it's possible to reload the script:
let s:dev_mode = exists('g:qpatterns_dev_mode') && g:qpatterns_dev_mode == 1


if (exists('g:loaded_qpatterns') || &cp) && !s:dev_mode
	finish
endif
let g:loaded_qpatterns = 1
let s:save_cpo = &cpo
set cpo&vim


"''''''''''''''''''''     function! s:default(var_name, default_val)
" Set a variable, unless it was already defined.
function! s:default(var_name, default_val)
	if !exists(a:var_name)
		execute 'let' a:var_name '=' string(a:default_val)
	endif
endf


" Set the default leader key to '<leader>':
call s:default('g:qpatterns_leader', '<leader>')
" Set the default visual-mode leader key to g:qpatterns_leader:
call s:default('g:qpatterns_visual_leader', g:qpatterns_leader)

" Enable default mappings by default:
call s:default('g:qpatterns_enable_mappings', 1)

" Enable global functions by default:
call s:default('g:qpatterns_enable_functions', 1)




""""""""""""""""""""" MAPPINGS:

""""""""""""""""""""" Mapping utils:

"''''''''''''''''''''     function! s:map(map_command, map, rhs)
" Maps a key
function! s:map(map_command, map, rhs)
	let l:whole_mapping = g:qpatterns_leader . a:map
	execute  a:map_command  '<silent> <nowait>'  l:whole_mapping  a:rhs
endf

"''''''''''''''''''''     function! s:install_mappings(map_command, mappings)
" Installs the list of mappings given as argument
function! s:install_mappings(map_command, mappings)
	for l:map in a:mappings
		call s:map(a:map_command, l:map[0], l:map[1])
	endfor
endf

""""""""""""""""""""" KEY MAPPINGS:

" If mappings are enabled:
if g:qpatterns_enable_mappings
	" ALL THE FOLLOWING MAPPINGS WILL BE PREFIXED WITH THE LEADER KEY:

	" The list of normal mappings to map (to plug mappings):
	let s:normal_mappings = [
		\ [ '/', '<plug>QpatternsFind' ],
		\ [ '?', '<plug>QpatternsRevFind' ],
		\ [ '&', '<plug>QpatternsInlineFind' ],
		\ [ '@', '<plug>QpatternsInlineLast' ],
		\ [ '<left>', '<plug>QpatternsPrevMatch' ],
		\ [ '<right>', '<plug>QpatternsNextMatch' ],
	\ ]
	call s:install_mappings('nmap', s:normal_mappings)

	" The list of visual/operator-pending mappings to map (to plug mappings):
	let s:visual_op_mappings = [
		\ [ '/', '<plug>QpatternsSelect' ],
		\ [ '?', '<plug>QpatternsRevSelect' ],
		\ [ '&', '<plug>QpatternsInlineSelect' ],
		\ [ '@', '<plug>QpatternsInlineLast' ],
		\ [ '<left>', '<plug>QpatternsPrevSelect' ],
		\ [ '<right>', '<plug>QpatternsNextSelect' ],
	\ ]
	call s:install_mappings('xmap', s:visual_op_mappings)
	call s:install_mappings('omap', s:visual_op_mappings)
endif

""""""""""""""""""""" PLUG MAPPINGS:

nnoremap <plug>QpatternsFind :call qpatterns#prompt_find(0,0,1)<cr>
nnoremap <plug>QpatternsEditFind :call qpatterns#prompt_find(1,0,1)<cr>
nnoremap <plug>QpatternsRevFind :call qpatterns#prompt_find(0,0,0)<cr>
nnoremap <plug>QpatternsRevEditFind :call qpatterns#prompt_find(1,0,0)<cr>
nnoremap <plug>QpatternsInlineFind :call qpatterns#prompt_find(0,1,1)<cr>
nnoremap <plug>QpatternsInlineLast :call qpatterns#inline_find(g:qpatterns_cur_search)<cr>
nnoremap <plug>QpatternsPrevMatch :call qpatterns#find_prev()<cr>
nnoremap <plug>QpatternsNextMatch :call qpatterns#find_next()<cr>

xnoremap <plug>QpatternsSelect :<c-u>call qpatterns#prompt_select(0,0,1)<cr>
onoremap <plug>QpatternsSelect :<c-u>call qpatterns#prompt_select(0,0,1)<cr>
xnoremap <plug>QpatternsRevSelect :<c-u>call qpatterns#prompt_select(0,0,0)<cr>
onoremap <plug>QpatternsRevSelect :<c-u>call qpatterns#prompt_select(0,0,0)<cr>
xnoremap <plug>QpatternsInlineSelect :<c-u>call qpatterns#prompt_select(0,1,1)<cr>
onoremap <plug>QpatternsInlineSelect :<c-u>call qpatterns#prompt_select(0,1,1)<cr>
xnoremap <plug>QpatternsInlineLast :call qpatterns#inline_select(g:qpatterns_cur_search)<cr>
onoremap <plug>QpatternsInlineLast :call qpatterns#inline_select(g:qpatterns_cur_search)<cr>
xnoremap <plug>QpatternsNextSelect :<c-u>call qpatterns#select_next()<cr>
xnoremap <plug>QpatternsPrevSelect :<c-u>call qpatterns#select_prev()<cr>




""""""""""""""""""""" PUBLIC FUNCTIONS:

if g:qpatterns_enable_functions

	"''''''''''''''''''''     function! QSearch(text, pattern)
	" Searches a:pattern inside a:text, and returns a list of dictionnaries,
	" with this format:
	"   [ {
	"       'match': 'text',       " the matched text content
	"       'start': 5,            " the 0-based start pos (inclusive)
	"       'end': 9,              " the 0-based end pos (exclusive)
	"       'source': 'some text'  " the source text: equals to a:text
	"     },
	"     { ... }
	"   ]
	function! QSearch(text, pattern)
		return qpatterns#search(a:text, a:pattern)
	endf


	"''''''''''''''''''''     function! QSearchStr(text, pattern)
	" Searches a:pattern inside a:text, and returns a list of the matched
	" strings.
	function! QSearchStr(text, pattern)
		return qpatterns#searchstr(a:text, a:pattern)
	endf

endif


let &cpo = s:save_cpo
unlet s:save_cpo

