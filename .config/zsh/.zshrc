# Luke's config for the Zoomer Shell

# Enable colors and change prompt:
autoload -U colors && colors # Load colors

PS1="%B%{$fg[red]%}[%{$fg[magenta]%}%~%{$fg[red]%}]%{$reset_color%}$%b "

# For multi-user systems, use this:
# PS1="%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%~%{$fg[red]%}]%{$reset_color%}$%b "
setopt autocd   # Automatically cd into typed directory.
stty stop undef # Disable ctrl-s to freeze terminal.
setopt interactive_comments

# History in cache directory:
HISTSIZE=100000
SAVEHIST=100000
HISTFILE="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/history"

# Load aliases and shortcuts if existent.
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/shortcutrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/shortcutrc"
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/aliasrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/aliasrc"
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/zshnameddirrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/zshnameddirrc"

# Basic auto/tab complete:
autoload -U compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots) # Include hidden files.

# vi mode
bindkey -v
export KEYTIMEOUT=1

# Use vim keys in tab complete menu:
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char

# Edit line in vim with ctrl-e:
autoload edit-command-line
zle -N edit-command-line
bindkey '^e' edit-command-line
bindkey -M vicmd '^[[P' vi-delete-char
bindkey -M vicmd '^e' edit-command-line
bindkey -M visual '^[[P' vi-delete

# Change cursor shape for different vi modes.
zle-keymap-select() {
	case $KEYMAP in
		vicmd) echo -ne '\e[1 q' ;;        # block
		viins | main) echo -ne '\e[5 q' ;; # beam
	esac
}
zle -N zle-keymap-select

zle-line-init() {
	# Initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
	zle -K viins
	echo -ne "\e[5 q"
}
zle -N zle-line-init

echo -ne '\e[5 q'                # Use beam shape cursor on startup.
preexec() { echo -ne '\e[5 q'; } # Use beam shape cursor for each new prompt.

# Open a journal entry based on the provided argument. A negative
# value (-1) means a past date and a positive value (1) means a
# future date. You can open a specific date by passing it in the format "MM.DD.YYYY".
# No arguments means the current date.
function je() {
    jr # Open the journal root directory
    local date_input="$1"
    local date_fmt="%m.%d.%Y"
    local date

    if [[ -z "$date_input" ]]; then
        # Handle no arguments: use current date
        date=$(date +"$date_fmt")
    elif [[ "$date_input" =~ ^[0-9]{2}\.[0-9]{2}\.[0-9]{4}$ ]]; then
        # Handle specific date input (format: MM.DD.YYYY)
        date="$date_input"
    else
        # Handle relative dates (like -1 or 1)
        date=$(date -d "$date_input days" +"$date_fmt")
    fi

    local year="${date:6:4}"
    cd "$year"

    $EDITOR "${date:0:5}.md"  # Open the file in the format MM.DD.md
}

function src-short() {
	shortcuts > /dev/null
	source ${XDG_CONFIG_HOME:-$HOME/.config}/shell/shortcutrc
	source ${XDG_CONFIG_HOME:-$HOME/.config}/shell/zshnameddirrc
	echo "Sourced shell shortcuts."
}

# Run a command on every 'Enter' (e.g. `run_loop cargo run`)
function run_loop {
	local cmd="$@"
	while true; do
		eval "$cmd"
		read
	done
}

function avds() {
	local avd="$(emulator -list-avds | grep -v "^INFO" | dmenu -i -l -1 -p "Select emulator")"
	emulator -avd "$avd"
}

bindkey -s '^f' 'fzfopen\n'

# Load syntax highlighting; should be last.
source /usr/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh 2> /dev/null
