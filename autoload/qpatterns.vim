
let s:path = expand('<sfile>:p:h')


"'''''''''''''''''''' BUFFER SEARCH FUNCTIONS:

"''''''''''''''''''''     function! qpatterns#find(pattern, direction)
" Finds the next match of a given pattern in the current buffer, and moves
" the cursor on it.
" For now, it starts the search at the cursor pos, and stops it at end of
" file.
function! qpatterns#find(pattern, direction)
	let l:match = qpatterns#get_next_match(a:pattern, 0, a:direction)
	if !empty(l:match)
		call s:move_to_qmatch(l:match)
	endif
	return l:match
endf


"''''''''''''''''''''     function! qpatterns#select(pattern, direction)
" Selects the next match of a given pattern in the current buffer.
" For now, it starts the search at the cursor pos, and stops it at end of
" file.
function! qpatterns#select(pattern, direction)
	let l:match = qpatterns#get_next_match(a:pattern, 0, a:direction)
	if !empty(l:match)
		call s:select_qmatch(l:match)
	endif
	return l:match
endf


"''''''''''''''''''''     function! qpatterns#inline_find(pattern)
" Find a pattern in the current line, starting the search at the begin of
" the line.
function! qpatterns#inline_find(pattern)
	let l:match = qpatterns#get_next_match(a:pattern, 1, 0)  " Last arg is not used
	if !empty(l:match)
		call s:move_to_qmatch(l:match)
	endif
	return l:match
endf


"''''''''''''''''''''     function! qpatterns#inline_select(pattern)
" Selects the first match of a given pattern in the current line.
function! qpatterns#inline_select(pattern)
	let l:match = qpatterns#get_next_match(a:pattern, 1, 0)  " Last arg is not used
	if !empty(l:match)
		call s:select_qmatch(l:match)
	endif
	return l:match
endf


"''''''''''''''''''''     function! qpatterns#find_prev()
" Moves the cursor to the previous match.
function! qpatterns#find_prev()
	return qpatterns#find(g:qpatterns_cur_search, 0)
endf


"''''''''''''''''''''     function! qpatterns#find_next()
" Moves the cursor to the next match.
function! qpatterns#find_next()
	return qpatterns#find(g:qpatterns_cur_search, 1)
endf


"''''''''''''''''''''     function! qpatterns#find_down()
" Moves to the first match below the current line.
function! qpatterns#find_down()
	return qpatterns#find(g:qpatterns_cur_search, 1)
endf


"''''''''''''''''''''     function! qpatterns#select_prev()
" Selects the previous match.
function! qpatterns#select_prev()
	return qpatterns#select(g:qpatterns_cur_search, 0)
endf


"''''''''''''''''''''     function! qpatterns#select_next()
" Selects the next match.
function! qpatterns#select_next()
	return qpatterns#select(g:qpatterns_cur_search, 1)
endf




"'''''''''''''''''''' TEXT SEARCH FUNCTIONS:

"''''''''''''''''''''     function! qpatterns#search(text, pattern)
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
function! qpatterns#search(text, pattern)
	return s:call_search_method(a:text, a:pattern, 'qpatterns_search()')
endf

"''''''''''''''''''''     function! qpatterns#searchstr(text, pattern)
" Searches a:pattern inside a:text, and returns a list of the matched
" strings.
function! qpatterns#searchstr(text, pattern)
	return s:call_search_method(a:text, a:pattern, 'qpatterns_searchstr()')
endf




"'''''''''''''''''''' INTERFACE:

"''''''''''''''''''''     function! s:input(prompt, show_cur_search)
" Performs a user input/prompt to get a new pattern, and returns the string
" typed.
" If a:show_cur_search=1, tries to pre-fill the input line with the
" current (last defined) search pattern.
function! s:input(prompt, show_cur_search)
	if a:show_cur_search && exists('g:qpatterns_cur_search')
		let l:text = g:qpatterns_cur_search
	else
		let l:text = ''
	endif

	let l:input = input(a:prompt, l:text)
	redraw
	return l:input
endf


"''''''''''''''''''''     function! qpatterns#prompt_find(show_cur_search, one_line_search, direction)
" Opens a prompt to ask for a new pattern, and the performs a search given
" this pattern.
"
" - If a:show_cur_search=1, tries to pre-fill the input line with the
" current (last defined) search pattern.
" - If a:one_line_search=1, performs the search in the current line only.
" - a:direction is 1 for forward search, 0 for backward search.
function! qpatterns#prompt_find(show_cur_search, one_line_search, direction)
	let l:pattern = s:input('q/', a:show_cur_search)
	if l:pattern != ''
		call s:set_current_search(l:pattern)

		if a:one_line_search
			return qpatterns#inline_find(l:pattern)
		else
			return qpatterns#find(l:pattern, a:direction)
		endif
	endif
endf


"''''''''''''''''''''     function! qpatterns#prompt_select(show_cur_search, one_line_search, direction)
" Opens a prompt to ask for a new pattern, and selects the first found match.
"
" - If a:show_cur_search=1, tries to pre-fill the input line with the
" current (last defined) search pattern.
" - If a:one_line_search=1, performs the search in the current line only.
" - a:direction is 1 for forward search, 0 for backward search.
function! qpatterns#prompt_select(show_cur_search, one_line_search, direction)
	let l:pattern = s:input('q/', a:show_cur_search)
	if l:pattern != ''
		call s:set_current_search(l:pattern)

		if a:one_line_search
			return qpatterns#inline_select(l:pattern)
		else
			return qpatterns#select(l:pattern, a:direction)
		endif
	endif
endf




"'''''''''''''''''''' UTILS, LOWER LEVEL:

"''''''''''''''''''''     function! s:move_to_col(pos)
" Moves the cursor to an absolute column, counting by characters, not bytes.
function! s:move_to_col(pos)
	normal! 0
	if a:pos > 1
		exe printf("normal! %il", a:pos - 1)
	endif
endf


"''''''''''''''''''''     function! s:select(start, end)
" Select a charwise region in a line, counting by characters, not bytes.
function! s:select(start, end)
	let l:end = a:end
	if a:end < a:start
		let l:end = a:start
	endif

	call s:move_to_col(a:start)
	normal! v
	call s:move_to_col(l:end)
endf


"''''''''''''''''''''     function! s:select_qmatch(qmatch)
" Selects a charwise region given a certain a:qmatch,
" returned by the search functions.
function! s:select_qmatch(qmatch)
	if has_key(a:qmatch, 'linenr')
		call cursor(a:qmatch['linenr'], 0)
	endif
	call s:select(a:qmatch['start'] + 1, a:qmatch['end'])
endf


"''''''''''''''''''''     function! s:move_to_qmatch(match)
" Move the cursor on the beginning of a match (line and column).
" The match is an object returned by the qpatterns#get_next_match() function
" (a match dictionnary, extended with the line number)
function! s:move_to_qmatch(qmatch)
	if has_key(a:qmatch, 'linenr')
		call cursor(a:qmatch['linenr'], 0)
	endif
	call s:move_to_col(a:qmatch['start'] + 1)
endf


"''''''''''''''''''''     function! s:set_current_search(pattern)
" Saves the current search pattern
function! s:set_current_search(pattern)
	let g:qpatterns_cur_search = a:pattern
endf


"''''''''''''''''''''     function! qpatterns#get_next_match(pattern, one_line_search, direction)
" Finds the next match of a given pattern in the current buffer, and returns 
" the found match in a dictionnary similar to qpatterns#search(), but with a
" 'linenr' key added.
" Doesn't move the cursor.
" a:direction is 1 for forward search, 0 for backward search.
" If there's no match, returns an empty dict.
" For now, the search starts at the cursor position, and stops at end of
" file.
" TODO: writing this func in Python would speed it up consequently (only
" one pattern parse instead of one parse per line)
function! qpatterns#get_next_match(pattern, one_line_search, direction)
	" Inline search (starts the search from the beginning of the line):
	if a:one_line_search == 1
		" Performs the search on the current line:
		let l:matches = qpatterns#search(getline('.'), a:pattern)

		if !empty(l:matches)
			let l:match = l:matches[0]
			" Extends the match infos with the line number:
			let l:match['linenr'] = line('.')
			return l:match
		else
			return {}
		endif
	endif

	" Buffer search:
	let l:cur_col = getcurpos()[2]

	" Choose the right range, according to the given search direction:
	let l:range = a:direction == 1 ?
		\ range(line('.'), line('$')) :
		\ range(line('.'), 1, -1)

	for l:linenr in l:range
		" Performs the search on each line:
		let l:matches = qpatterns#search(getline(l:linenr), a:pattern)

		if empty(l:matches)
			continue
		endif

		if a:direction == 0
			call reverse(l:matches)
		endif

		for l:match in l:matches
			" Skip matches before the current col (only for the cur line):
			" TODO: move this stuff outside the 'l:linenr' for-loop
			if l:linenr == line('.')
				if a:direction == 1 && (
					   \ l:cur_col >= l:match['start']+1
				       \   ||
				       \ l:cur_col == col('$')-1
				\ ) || a:direction == 0 &&
					   \ l:cur_col <= l:match['start']+1
					continue
				endif
			endif

			" Extends the match infos with the line number:
			let l:match['linenr'] = l:linenr
			return l:match
		endfor
	endfor
	return {}
endf





"'''''''''''''''''''' PYTHON LIBRARY BINDINGS:
"''''''''''''''''''''

" Python part of ... the bridge between the python lib and vim:

execute "py3file" s:path.'/qpatterns/vimbind.py'


" Vim part of ... the bridge between the python lib and vim:

"''''''''''''''''''''     function! s:call_search_method(text, pattern, method)
" Calls a given python qpatterns search method (qpatterns_search() or
" qpatterns_searchstr()), and returns the results of the call.
function! s:call_search_method(text, pattern, method)
	if empty(a:pattern) && exists('g:qpatterns_cur_search')
		let l:pattern = g:qpatterns_cur_search
	else
		let l:pattern = a:pattern
	endif

	if has('nvim')
		if a:method == 'qpatterns_search()'
			return QpatternsNvimSearch(a:text, a:pattern)
		else
			return QpatternsNvimSearchStr(a:text, a:pattern)
		endif
	else
		let l:return = []
		call py3eval(a:method)
		return l:return
	endif
endf


"''''''''''''''''''''     function! qpatterns#reload_library()
" dev: reloads the python qpatterns library
function! qpatterns#reload_library()
	py3 qpatterns_reload_library()
	echo "qpatterns reloaded"
endf


