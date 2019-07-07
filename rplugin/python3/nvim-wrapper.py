
import neovim
import qpatterns

@neovim.plugin
class QpatternsNvimWrapper(object):
    def __init__(self, vim):
        self.vim = vim

    @neovim.function('QpatternsNvimSearch', sync=True)
    def qpatterns_search(self, args):
        return qpatterns.searchdict(args[0], args[1])


    @neovim.function('QpatternsNvimSearchStr', sync=True)
    def qpatterns_searchstr(self, args):
        return qpatterns.searchstr(args[0], args[1])

