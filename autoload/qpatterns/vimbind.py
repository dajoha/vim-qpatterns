
import importlib

import qpatterns


#-------------------- def qpatterns_search()
# Called by the function qpatterns#search(text, pattern).
# Make the bridge between the real python lib and vim.
def qpatterns_search():
    qpatterns_call_search_method(qpatterns.searchdict)


#-------------------- def qpatterns_search()
# Called by the function qpatterns#searchstr(text, pattern).
# Make the bridge between the real python lib and vim.
def qpatterns_searchstr():
    qpatterns_call_search_method(qpatterns.searchstr)



# Internal:

#-------------------- def qpatterns_call_search_method(method)
def qpatterns_call_search_method(method):
    vim_return = vim.bindeval('l:return')

    pattern = vim.eval('l:pattern')
    text = vim.eval('a:text')

    try:
        vim_return.extend(method(text, pattern))
    except Exception as e:
        vim.command("echo '{}'".format(e))

#-------------------- def qpatterns_reload_library()
def qpatterns_reload_library():
    importlib.reload(qpatterns)

