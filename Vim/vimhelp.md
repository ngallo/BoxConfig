#VIM Commands

##Fiels
~/.vimrc        : Most settings go ehere
~/.gvimrc       : Graphic-only settings (font, window, size)
~/.vim/         : Plugins, language-specific options, color schemas

##Navigation
k               : UP
h               : LEFT
l               : RIGHT
j               : DOWN
12G             : Go to line 12
gg              : Go to the top of the file
G               : Go to the end of the file
0               : Start of the line
^               : First character of the line
$               : End of the line


##Search
:[ranges]s[ubstitute]/{pattern}/{string}/[flags][count]
c - Confirm or skip each match
i - Ignore case
I - Case sensitive
n - Show number of matched (non-destructive)
p - Print matching lines

:%s/search/replace/gc
% - Search the current buffer
g - Search for all occurences
c - Ask for confirmations

:%s/a/b         : A leading percent searches all lines in the current file
:s/a/b          : Omit the percent to search only the current line
:.,'a s/a/b/    : This searches from the cursor (.) to mark a

#Text Editing
I               : Move to first non blank character of line
a               : Move one character right
A               : Move to end of line
o               : Open a new line below
O               : Open a new line above
r               : Replace a single character
R               : Go into Replace mode

yy              : Yank line (copy)
p               : Past below cursor
P               : Past above cursor
i               : Insert text before cursor
a               : Append text after cursor
fN              : Jump forward to first 'N'
3fN             : Jump forward to thir 'N'
w               : Forward one word
3w              : Forward 3 words
c               : Change
cc              : Change a line (delete and enter insert mode). Also C
cw              : Change word
3cw             : Change 3 words
cw              : Change word
3cw             : Change 3 words
u               : Undo
dd              : Delete current line
d               : Delete
x               : Delete character under cursor
Ctrl-R          : Redo

##File
:w              : Write file
:w!             : Overwrite without confirmation
:q              : Quit
:wq!            : Write & Quit
:w !sudo tee %  : Write to the sudo command with the current filename

##Buffers
:b name         : Switch to buffer (try TAB and arrows as well)
:bp             : Previous buffer
:bn             : Next buffer
:bp             : Previous buffer
:bd             : Delete buffer (close file)
:ls             : List buffers (all open documents)
:b3             : Go to buffer by number (stays constant while application is running)

##Rueler & Status
:set ruler       : Show the cursor position in the status bar
:set number      : Show line number on side
:set laststatus=2: Always show the status bar

ma               : create a mark named a
`a               : Jump to exact line and column
'a               : Jump to beginning of marked line only

##Window Management
Ctrl-w s        : Split window horizontally
Ctrl-w v        : Split window vertically

Ctrl-w c        : Close window
Ctrl-w o        : Close all but current

Ctrl-w j        : Move focus down
Ctrl-w-k        : Move focus up

Ctrl-w w        : Cycle focus
Ctrl-w p        : Focus previous window

Ctrl-w J        : Move buffer up one window
Ctrl-w K        : Move buffer down one window

##Set
:set ignorecase
:set smartcase
:set incsearch

##Others
:nohl           : Undo highlight
:pwd            : Current working directory
:e .            : Explore current directory
