" Vim plugin to return the name of the function that is currently being edited
" Maintainer:   Gregor Uhlenheuer <kongo2002@googlemail.com>
" Version:      0.1
" Last Change:  Sat 23 Oct 2010 06:11:30 PM CEST

if exists('g:loaded_findfunc')
    finish
endif
let g:loaded_findfunc = 1

if !exists('g:findfunc_debug')
    let g:findfunc_debug = 0
endif

let s:save_cpo = &cpo
set cpo&vim

let s:FiletypeMap = {
    \ 'python': { 'func': 's:SearchPython' },
    \ 'vim': { 'args': ['^\s*func\%[tion]', ''] }
    \ }

function! FindFunctionName(filetype)
    let func = 's:DefaultSearch'
    let args = ['', '']
    if has_key(s:FiletypeMap, a:filetype)
        let ft = s:FiletypeMap[a:filetype]
        if has_key(ft, 'func')
            let func = ft['func']
            if has_key(ft, 'args')
                let args = ft['args']
            else
                let args = []
            endif
        elseif has_key(ft, 'args')
            let args = ft['args']
        endif
    endif
    if g:findfunc_debug
        echom 'Call "'.func.'" with arguments: '.string(args)
    endif
    return call(func, args)
endfunction

function! s:DefaultSearch(search, name)
    let def_search = '^\w\+\s\+\w\+.*\n*\s*[(){:].*[,)]*\s*$'
    let def_name = '^[^(){}]*\s\+\zs\w\+'
    let rgx = (a:search != '' ? a:search : def_search)

    let line_no = search(rgx, 'bnW')
    j
    if line_no > 0
        let rgx = (a:name != '' ? a:name : def_name)
        return matchstr(getline(line_no), rgx)
    elseif g:findfunc_debug
        echom 'Regex "'.rgx.'" found no matches'
    endif

    return ''
endfunction

function! s:SearchPython()
    let candidates = []
    call add(candidates, search('^\s*def\s\+.*:\s*$', 'bnW'))
    call add(candidates, search('^\s*class\s\+.*:\s*$', 'bnW'))
    call add(candidates, search('^\s*if\s\+.*__name__.*__main__', 'bnW'))

    return getline(max(candidates))
endfunction

com! FindFunction echo FindFunctionName(&ft)

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set et sw=4 sts=4:
