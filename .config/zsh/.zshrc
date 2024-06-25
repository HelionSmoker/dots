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
# value (-1) means a past date and a positive value (+1) means a
# future date. No arguments means the current date.
function je() {
	jr                 # Open the journal root directory
	cd "$(date +'%Y')" # Open the current year directory

	local date_fmt="%m.%d"
	local date

	if [[ -z "$1" ]]; then
		# For some reason, '-d " days"' (missing value) defaults to tomorrow,
		# so we need an explicit check for no arguments.
		date=$(date +"$date_fmt")
	else
		date=$(date -d "$1 days" +"$date_fmt")
	fi

	$EDITOR "$date.md"
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
