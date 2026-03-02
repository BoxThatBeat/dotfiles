# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

#run ls when we change directory
chpwd() {
  ls
}

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

eval "$(zoxide init zsh)"
alias cd="z"
alias vim="nvim"
alias vi='nvim'
alias lzg='lazygit'
alias lzn='lazynpm'
alias ai='opencode'
alias cat='batcat'
alias lsblk='lsblk | cat -l conf -p'
alias ps='ps aux | cat -l conf'
alias tw='taskwarrior-tui'


# SSH Agent forwarding fix for tmux + 1Password
# This ensures a stable SSH_AUTH_SOCK path across reconnections

# Function to update the SSH agent symlink
_update_ssh_agent() {
    # If SSH_AUTH_SOCK is set and points to a real socket (not our symlink)
    if [ -n "$SSH_AUTH_SOCK" ] && [ -S "$SSH_AUTH_SOCK" ] && [ "$SSH_AUTH_SOCK" != "$HOME/.ssh/ssh_auth_sock" ]; then
        /bin/ln -sf "$SSH_AUTH_SOCK" "$HOME/.ssh/ssh_auth_sock"
        return 0
    fi
    
    # If the symlink is broken, try to find a valid socket
    if [ ! -S "$HOME/.ssh/ssh_auth_sock" ]; then
        local newest_socket=$(find /tmp/ssh-* -name "agent.*" -type s -printf "%T@ %p\n" 2>/dev/null | sort -rn | head -n1 | cut -d' ' -f2)
        if [ -n "$newest_socket" ] && [ -S "$newest_socket" ]; then
            /bin/ln -sf "$newest_socket" "$HOME/.ssh/ssh_auth_sock"
            return 0
        fi
    fi
    return 1
}

# Update symlink on shell init
_update_ssh_agent

# Always use the stable symlink
export SSH_AUTH_SOCK="$HOME/.ssh/ssh_auth_sock"

# Manual fix command
fixssh() {
    if _update_ssh_agent; then
        echo "SSH agent updated to: $(readlink $HOME/.ssh/ssh_auth_sock)"
        ssh-add -l
    else
        echo "No SSH agent socket found. Are you connected via SSH with agent forwarding?"
        return 1
    fi
}

# Auto-fix on command not found (if it's an ssh/git command)
command_not_found_handler() {
    if [[ "$1" =~ ^(ssh|git) ]] && ! [ -S "$HOME/.ssh/ssh_auth_sock" ]; then
        echo "SSH agent socket broken, attempting to fix..."
        if _update_ssh_agent; then
            echo "Retrying command..."
            command "$@"
            return $?
        fi
    fi
    echo "zsh: command not found: $1" >&2
    return 127
}

#ZSH_THEME="catppuccin"
#CATPPUCCIN_FLAVOR="macchiato" # Required! Options: mocha, flappe, macchiato, latte
#CATPPUCCIN_SHOW_TIME=true  # Optional! If set to true, this will add the current time to the prompt.
#CATPPUCCIN_SHOW_HOSTNAME="never"  # Optional! Options: never, always, ssh

export XDG_CONFIG_HOME="$HOME/.config"
export TASKRC=~/.config/task/taskrc

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export PATH="$HOME/.local/bin:$PATH"

# opencode
export PATH=/home/developer/.opencode/bin:$PATH
# Bugwarrior aliases (avoid adding venv python to PATH)
alias bugwarrior="$HOME/.venv/bugwarrior/bin/bugwarrior"
alias bugwarrior-pull="$HOME/.venv/bugwarrior/bin/bugwarrior-pull"
alias bugwarrior-uda="$HOME/.venv/bugwarrior/bin/bugwarrior-uda"
alias bugwarrior-vault="$HOME/.venv/bugwarrior/bin/bugwarrior-vault"

# Rust Apps
export PATH="$HOME/.cargo/bin:$PATH"
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
