let s:save_cpo = &cpo
set cpo&vim

function! s:open_window(vcs, type)
    let bufname = '__committia_' . a:type . '__'
    execute g:committia_{a:type}_window_opencmd bufname
    let winnr = bufwinnr(bufname)
    let bufnr = bufnr('%')
    call append(0, call('committia#' . a:vcs . '#' . a:type, []))
    execute 0
    setlocal nonumber bufhidden=wipe readonly nobuflisted noswapfile nomodifiable nomodified

    return [winnr, bufnr]
endfunction

function! s:open_diff_window(vcs)
    let window_info = s:open_window(a:vcs, 'diff')
    setlocal ft=diff
    return window_info
endfunction

function! s:open_status_window(vcs)
    let [status_winnr, status_bufnr] = s:open_window(a:vcs, 'status')
    set ft=gitcommit
    let status_winheight = winheight(status_bufnr)
    if line('$') < winheight(status_bufnr)
        execute 'resize' line('$')
    endif

    return [status_winnr, status_bufnr]
endfunction

function! committia#open(vcs)
    if winwidth(0) < g:committia_min_window_width
        if has_key(g:committia_hooks, 'post_open')
            call call(g:committia_hooks.post_open, [winnr(), commit_bufnr, diff_winnr, diff_bufnr, status_winnr, status_bufnr])
        endif
        return
    endif

    let commit_bufnr = bufnr('%')

    let [diff_winnr, diff_bufnr] = s:open_diff_window(a:vcs)
    wincmd p
    let [status_winnr, status_bufnr] = s:open_status_window(a:vcs)
    wincmd p

    execute 0
    call search('^\%(\s*$\|\s*#\)', 'cW')
    normal! dG
    execute 0
    vertical resize 80
    if has_key(g:committia_hooks, 'post_open')
        call call(g:committia_hooks.post_open, [],
                    \ {
                    \   'vcs' : a:vcs,
                    \   'edit_winnr' : commit_bufnr,
                    \   'edit_bufnr' : winnr(),
                    \   'diff_winnr' : diff_winnr,
                    \   'diff_bufnr' : diff_bufnr,
                    \   'status_winnr' : status_winnr,
                    \   'status_bufnr' : status_bufnr
                    \ })
    endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo