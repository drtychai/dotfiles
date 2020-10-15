" Vim-Plug Plugins
call plug#begin('~/.vim/plugged')
" Tmux and Vim bars (currently on the bottom ones)
Plug 'itchyny/lightline.vim'
Plug 'bling/vim-bufferline'
Plug 'edkolev/tmuxline.vim'

Plug 'w0rp/ale'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

" Run git commands in vim, e.g.:`:G status`
Plug 'tpope/vim-fugitive'

" Shows the git diff [+/-] for modified files in a repo
Plug 'airblade/vim-gitgutter'

" Directory tree in adjecment window (in vim)
Plug 'scrooloose/nerdtree'

" Dsplays `ctags`-generated tags of the current file,
" ordered by their scope, in adjacment window (in vim)
Plug 'majutsushi/tagbar'

" Async Language Server Protocol plugin
Plug 'prabirshrestha/vim-lsp'
" LSP Automation Settings
Plug 'mattn/vim-lsp-settings'

" Language : Go
Plug 'fatih/vim-go'

" Language : Rust
Plug 'rust-lang/rust.vim'

" Language : Markdown
Plug 'jtratner/vim-flavored-markdown'

" Language : Swift
Plug 'keith/swift.vim'

" Language : TeX
Plug 'lervag/vimtex'

" Language : TeX function abstration
Plug 'sirver/ultisnips'

" Color scheme plug and config
Plug 'chriskempson/base16-vim'
call plug#end()


" Use previous color configuration, if present
if filereadable(expand("~/.vimrc_background"))
    let base16colorspace=256
    source ~/.vimrc_background
endif

" Use local config, if present
if filereadable($HOME . "/.vimrc.local")
    source ~/.vimrc.local
endif

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Match weird white space:
"   Lines ending with spaces:   
"   Lines with spaces AND tabs (in either order):
    	"
	    "

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Highlight trailing whitespace and spaces touching tabs
:highlight TrailingWhitespace ctermbg=darkred guibg=darkred
:let w:m2=matchadd('TrailingWhitespace', '\s\+$\| \+\ze\t\|\t\+\ze ')

" Remap <leader>
:let mapleader="\<Space>"

" Allow filetype-specific plugins
:filetype plugin on

" Read configurations from files
:set modeline
:set modelines=5

" Setup tags file
:set tags=./tags,tags;

" Set path to include the cwd and everything underneath
:set path=**
:set wildmenu

" Show the normal mode command as I type it
:set showcmd

" Expand tab to 4 spaces
:set tabstop=4 shiftwidth=4 expandtab

" Show line numbers
:set number

" NAVIGATION
" Jump to last cursor position unless it's invalid or in an event handler
autocmd BufReadPost *
  \ if line("'\"") > 0 && line("'\"") <= line("$") |
  \   exe "normal g`\"" |
  \ endif

" Disable arrow keys for navigation
:nnoremap <up> <nop>
:nnoremap <down> <nop>
:nnoremap <left> <nop>
:nnoremap <right> <nop>

" Make j and k move up and down better for wrapped lines
:noremap k gk
:noremap j gj
:noremap gk k
:noremap gj j

" Ctrl-<hjkl> to change splits
:noremap <C-h> <C-w>h
:noremap <C-j> <C-w>j
:noremap <C-k> <C-w>k
:noremap <C-l> <C-w>l

" <Tab> to cycle through splits
:noremap <Tab> <C-w>w

" Close the current split
:nmap <leader>x <C-w>c

" Jumping between buffers
:noremap <C-n> :bnext<CR>
:noremap <C-p> :bprev<CR>
:noremap <C-e> :b#<CR>

" Let <C-n> and <C-p> also filter through command history
:cnoremap <C-n> <Down>
:cnoremap <C-p> <Up>

" Start scrolling before my cursor reaches the bottom of the screen
set scrolloff=4

" Show relative line numbers with <leader>l
:nmap <leader>l :set number! relativenumber!<CR>

" Improve search
:set ignorecase
:set smartcase
:set infercase
:set hlsearch
:set noincsearch " Default on neovim, and I hate it

" Toggle search highlighting
:nmap <CR> :set hlsearch!<CR>

" Lazily redraw: Make macros faster
:set lazyredraw

" Turn off swap files
:set noswapfile
:set nobackup
:set nowritebackup

" Open new split panes to right and bottom
:set splitbelow
:set splitright

" allow hidden buffers
:set hidden

" always show the status bar
:set laststatus=2

" hide mode so it shows on the statusbar only
:set noshowmode

" short ttimeoutlen to lower latency to show current mode
:set ttimeoutlen=50

" Toggle cursor highlighting
:nmap <leader>x :set cursorline! cursorcolumn!<CR>

" Make cursor highlights more obvious
:hi CursorLine   cterm=NONE ctermbg=darkgreen ctermfg=black guibg=darkred guifg=white
:hi CursorColumn cterm=NONE ctermbg=darkgreen ctermfg=black guibg=darkred guifg=white

" Consistent backspace on all systems
:set backspace=2

" Leave insert mode with hh
:inoremap hh <ESC>

" Clear trailing whitespace
:nnoremap <leader>W :%s/\s\+$//<CR><C-o>

" Clear leading whitespace
":nnoremap <leader>w :%s/^\s\+$//e<CR><C-o>

" Convert tabs to spaces
:nnoremap <leader>T :%s/\t/    /g<CR>

" Toggle showing listchars
:nnoremap <leader><TAB> :set list!<CR>
if &encoding == "utf-8"
  exe "set listchars=eol:\u00ac,nbsp:\u2423,conceal:\u22ef,tab:\u25b8\u2014,precedes:\u2026,extends:\u2026"
else
  set listchars=eol:$,tab:>-,extends:>,precedes:<,conceal:+
endif

" Enable indent folding, but have it disabled by default
:set foldmethod=indent
:set foldlevel=99

" Select whole buffer
:nnoremap vaa ggvGg_

" Uppercase typed word from insert mode
:inoremap <C-u> <esc>mzgUiw`za

" Use braces to determine when to auto indent
:set smartindent

" Make Y act like D and C
nnoremap Y y$

" Unmap ex mode
nnoremap Q <nop>

" Special settings for some filetypes
:au Filetype ruby setl expandtab smarttab tabstop=4 shiftwidth=4 softtabstop=4
:au Filetype yaml setl expandtab smarttab tabstop=4 shiftwidth=4 softtabstop=4

" Use github-flavored markdown
:aug markdown
    :au!
    :au BufNewFile,BufRead *.md,*.markdown setlocal filetype=ghmarkdown
:aug END

" Open commonly edited files
:nmap <leader>ev :edit $MYVIMRC<CR>
:nmap <leader>et :edit $HOME/.tmux.conf<CR>
:nmap <leader>eb :edit $HOME/.bash_aliases<CR>
:nmap <leader>eg :edit $HOME/.gitaliases<CR>

" Reload vimrc
:nmap <leader>rv :source $MYVIMRC<CR>

" Close the current buffer
:nmap <leader>c :bp\|bd #<CR>

" Save
:nmap <leader>w :w<CR>

" Mappings for vimdiff
:nmap <leader>dg :diffget<CR>
:nmap <leader>dp :diffput<CR>
:nmap <leader>du :diffupdate<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" CONFIGURE PLUGINS
" Use deoplete.
let g:deoplete#enable_at_startup = 1

" Tmuxline (Configures Tmux's statusbar)
:let g:tmuxline_preset = 'powerline'
:let g:tmuxline_theme = 'zenburn'
":let g:tmuxline_file

" tagbar
:nnoremap <leader>z :TagbarToggle<CR>

" NERDTree
:nnoremap <leader>n :NERDTreeToggle<CR>
" NERDTress File highlighting
function! NERDTreeHighlightFile(extension, fg, bg, guifg, guibg)
  exec 'autocmd filetype nerdtree highlight ' . a:extension .' ctermbg='. a:bg .' ctermfg='. a:fg .' guibg='. a:guibg .' guifg='. a:guifg
  exec 'autocmd filetype nerdtree syn match ' . a:extension .' #^\s\+.*'. a:extension .'$#'
endfunction

call NERDTreeHighlightFile('jade', 'green', 'none', 'green', '#151515')
call NERDTreeHighlightFile('ini', 'yellow', 'none', 'yellow', '#151515')
call NERDTreeHighlightFile('md', 'blue', 'none', '#3366FF', '#151515')
call NERDTreeHighlightFile('yml', 'yellow', 'none', 'yellow', '#151515')
call NERDTreeHighlightFile('config', 'yellow', 'none', 'yellow','#151515')
call NERDTreeHighlightFile('conf', 'yellow', 'none', 'yellow', '#151515')
call NERDTreeHighlightFile('json', 'yellow', 'none', 'yellow', '#151515')
call NERDTreeHighlightFile('html', 'yellow', 'none', 'yellow', '#151515')
call NERDTreeHighlightFile('styl', 'cyan', 'none', 'cyan', '#151515')
call NERDTreeHighlightFile('css', 'cyan', 'none', 'cyan', '#151515')
call NERDTreeHighlightFile('coffee', 'Red', 'none', 'red', '#151515')
call NERDTreeHighlightFile('js', 'Red', 'none', '#ffa500', '#151515')
call NERDTreeHighlightFile('php', 'Magenta', 'none', '#ff00ff', '#151515')

" Fugitive
:nmap <leader>gb :Gblame<CR>
:nmap <leader>gd :Gdiff<CR>
:nmap <leader>gs :Gstatus<CR>

" FZF.vim
:nmap <leader>f :FZF<CR>
:nmap <leader>b :Buffers<CR>
:nmap <leader>t :Tags<CR>
:nmap <leader>s :Lines<CR>

" ALE
:let g:ale_lint_on_save = 1
:let g:ale_lint_on_text_changed = 0
:let g:ale_sign_column_always = 1

"" ALE : python
:let g:ale_python_pylint_options = '--max-line-length=150 --ignore=E265,E266,E501'
:let g:ale_python_mypy_options = '--ignore-missing-imports'

"" ALE : typescript
:let g:ale_linter_aliases = {'typescriptreact': 'typescript'}

" vimtex
:let g:tex_flavor='latex'
:let g:vimtex_view_method='zathura'
:let g:vimtex_quickfix_mode=0
:set conceallevel=1
:let g:tex_conceal='abdmg'

" ultisnips
:let g:UltiSnipsExpandTrigger = '<tab>'
:let g:UltiSnipsJumpForwardTrigger = '<tab>'
:let g:UltiSnipsJumpBackwardTrigger = '<s-tab>'

" vim-go
:let g:go_version_warning = 0

" rust.vim
:let g:autofmt_autosave = 1
:let g:rust_clip_command = 'pbcopy'

" Theme
:let base16colorspace=256
:syntax enable
:set background=dark
:silent! colorscheme base16-tomorrow-night
