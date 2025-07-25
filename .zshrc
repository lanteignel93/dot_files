# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# ZSH_THEME="powerlevel10k/powerlevel10k"
# ZSH_THEME="gruvbox"
SOLARIZED_THEME="dark"
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
ENABLE_CORRECTION="true"

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
#
export VIRTUALENVWRAPPER_PYTHON=$(which python3)
plugins=(
    git
    virtualenvwrapper
  )
plugins=(zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases

# zsh_virtualenv_prompt() {
#    # If not in a virtualenv, print nothing
#    [[ "$VIRTUAL_ENV" == "" ]] && return
#
#    # Distinguish between the shell where the virtualenv was activated
#    # and its children
#    local venv_name="${VIRTUAL_ENV##*/}"
#    if typeset -f deactivate >/dev/null; then
#        echo "[%F{green}${venv_name}%f] "
#    else
#        echo "<%F{green}${venv_name}%f> "
#    fi
#}

setopt PROMPT_SUBST PROMPT_PERCENT

# Display a "we are in a virtualenv" indicator that works in child shells too
#VIRTUAL_ENV_DISABLE_PROMPT=1
#RPS1='$(zsh_virtualenv_prompt)'#
#
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
#typeset -g POWERLEVEL9K_INSTANT_PROMPT=off

alias zshconfig="nvim ~/.zshrc"
alias ohmyzsh="nvim ~/.oh-my-zsh"
plugins=(zsh-autosuggestions)

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
fpath+=${ZDOTDIR:-~}/.zsh_functions

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

alias ls="exa -al --sort newest"
alias tell="whoami; hostname; pwd"
alias dir="ls -l | grep ^d" 
alias d="df -h | awk '{print \$6}' | cut -c1-4"
alias onedrivesync="rclone --vfs-cache-mode writes mount OneDrive: ~/OneDrive &"
export PATH="$PATH:/opt/nvim/bin"
alias vim="/usr/local/bin/nvim"
alias v="/usr/local/bin/nvim"
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completioni
alias python=python3
source ~/powerlevel10k/powerlevel10k.zsh-theme
# source <(fzf --zsh)

alias f="xdg-open ."
alias dots=~/scripts/dotfiles.sh
alias obs_update=~/scripts/git_obsidian.sh
alias obs='xdg-open "obsidian://open?vault=Personal" &'
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
NVIM_THEME="darkvoid"
alias leet="nvim leetcode.nvim"
alias countlnpy='find -type f -name "*.py" | xargs wc -l'
alias mute='amixer -D pulse sset Master mute'
alias unmute='amixer -D pulse sset Master unmute'

notify_phone() {
  # Check if a message argument was provided
  if [ -z "$1" ]; then
    echo "Usage: notify_phone \"Your message here\""
    return 1 # Return an error code if no message is given
  fi

  # Assign the first argument (the message) to a variable for clarity
  local message="$1"


  # The ntfy.sh topic URL
  local ntfy_topic="ntfy.sh/laurent-phone-to-computer-182764129"

  # Use curl to send the message as POST data (-d) to the ntfy topic
  # -s makes curl silent (no progress meter)
  echo "Sending notification: \"${message}\" to ${ntfy_topic}"
  curl -s -d "${message}" "${ntfy_topic}"

  # Check the exit status of curl
  if [ $? -eq 0 ]; then
    echo "Notification sent successfully."
  else
    echo "Error sending notification."
    return 1 # Return an error code if curl failed
  fi

  return 0 # Return success
}
export PYTHONBREAKPOINT="ipdb.set_trace"
source "$HOME/.p10k.zsh"
#
# Start and manage ssh-agent automatically
#
local agent_env_file="$XDG_RUNTIME_DIR/ssh-agent.env"

# Source the agent's environment file if it exists
if [[ -f "$agent_env_file" ]]; then
  source "$agent_env_file" >/dev/null
fi

# If we can't connect to the agent, start a new one.
# `ssh-add -l` returns an error if it cannot connect.
if ! ssh-add -l >/dev/null; then
  # Remove the old, invalid environment file
  rm -f "$agent_env_file"
  # Start a new agent and write its info to the file
  ssh-agent > "$agent_env_file"
  # Source the new environment file
  source "$agent_env_file" >/dev/null
fi
