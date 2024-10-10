#!/bin/bash
# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
if [ "$IS_WSL_BASH" = "" ]; then
    case $- in
    *i*) ;;
    *) return ;;
    esac
fi

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=-1
HISTFILESIZE=-1
HISTFILE="$HOME/.bash_history"
HISTCONTROL='ignoredups'
HISTIGNORE='exit:history:l:l[1als]:lla:lal:la+(.)'

# timestamp
HISTTIMEFORMAT="%Y/%m/%d %H:%M:%S "

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# set to append every line to history individually
PROMPT_COMMAND='history -a'

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
xterm-color | *-256color) color_prompt=yes ;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
fi

# The following block is surrounded by two delimiters.
# These delimiters must not be modified. Thanks.
# START KALI CONFIG VARIABLES
PROMPT_ALTERNATIVE=twoline
NEWLINE_BEFORE_PROMPT=yes
# STOP KALI CONFIG VARIABLES

if [ "$color_prompt" = yes ]; then
    # override default virtualenv indicator in prompt
    VIRTUAL_ENV_DISABLE_PROMPT=1

    prompt_color='\[\033[;32m\]'
    info_color='\[\033[1;34m\]'
    prompt_symbol=㉿
    if [ "$EUID" -eq 0 ]; then # Change prompt colors for root user
        prompt_color='\[\033[;94m\]'
        info_color='\[\033[1;31m\]'
        # Skull emoji for root terminal
        prompt_symbol=💀
    fi
    case "$PROMPT_ALTERNATIVE" in
    twoline)
        PS1=$prompt_color'┌──${debian_chroot:+($debian_chroot)──}${VIRTUAL_ENV:+(\[\033[0;1m\]$(basename $VIRTUAL_ENV)'$prompt_color')}('$info_color'\u'$prompt_symbol'\h'$prompt_color')-[\[\033[0;1m\]\w'$prompt_color']\n'$prompt_color'└─'$info_color'\$\[\033[0m\] '
        ;;
    oneline)
        PS1='${VIRTUAL_ENV:+($(basename $VIRTUAL_ENV)) }${debian_chroot:+($debian_chroot)}'$info_color'\u@\h\[\033[00m\]:'$prompt_color'\[\033[01m\]\w\[\033[00m\]\$ '
        ;;
    backtrack)
        PS1='${VIRTUAL_ENV:+($(basename $VIRTUAL_ENV)) }${debian_chroot:+($debian_chroot)}\[\033[01;31m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
        ;;
    esac
    unset prompt_color
    unset info_color
    unset prompt_symbol
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm* | rxvt* | Eterm | aterm | kterm | gnome* | alacritty)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*) ;;
esac

[ "$NEWLINE_BEFORE_PROMPT" = yes ] && PROMPT_COMMAND="PROMPT_COMMAND=echo"

# enable color support of ls, less and man, and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    export LS_COLORS="$LS_COLORS:ow=30;44:" # fix ls color for folders with 777 permissions

    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
    alias diff='diff --color=auto'
    alias ip='ip --color=auto'

    export LESS_TERMCAP_mb=$'\E[1;31m'  # begin blink
    export LESS_TERMCAP_md=$'\E[1;36m'  # begin bold
    export LESS_TERMCAP_me=$'\E[0m'     # reset bold/blink
    export LESS_TERMCAP_so=$'\E[01;33m' # begin reverse video
    export LESS_TERMCAP_se=$'\E[0m'     # reset reverse video
    export LESS_TERMCAP_us=$'\E[1;32m'  # begin underline
    export LESS_TERMCAP_ue=$'\E[0m'     # reset underline
fi

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# enter client hostname to be ignored
ignored_hostnames=("examplehostname1" "examplehostname2")

# Get the current hostname
current_hostname=$(hostname)

# Check if the current host is in the array
ignored_hostname=false
for this_hostname in "${ignored_hostnames[@]}"; do
    echo "checking if $this_hostname == $current_hostname; ignored_hostname=$ignored_hostname"
    if [ "$this_hostname" == "$current_hostname" ]; then
        ignored_hostname=true
        echo "ignoring $this_hostname; ignored_hostname=$ignored_hostname"
        break
    fi
done

# Check if we are on the host system not client
if [ "$ignored_hostname" == false ]; then
    # Cleanup any extra ssh-agent processes
    for pid in $(pgrep -u "$USER" ssh-agent); do
        echo "found ssh-agent $pid running with SSH_AUTH_SOCK=$SSH_AUTH_SOCK"
        if [ -n "$SSH_AGENT_PID" ] && [ "$SSH_AGENT_PID" -ne "$pid" ] || [ -z "$SSH_AUTH_SOCK" ]; then
            # Kill extra ssh-agents or those without $SSH_AUTH_SOCK set properly
            kill -9 "$pid"
            echo "killed ssh-agent $pid"
        fi
    done
    # Check if an ssh-agent is already running
    if ! pgrep -u "$USER" ssh-agent > /dev/null; then
        # Start a new ssh-agent if no valid agent is running
        echo "Starting ssh-agent..."
        eval "$(ssh-agent -s)"
        ssh-add ~/.ssh/id_rsa # Add the private key
    else
        # Export SSH_AGENT_PID and SSH_AUTH_SOCK if not already set
        if [ -z "$SSH_AGENT_PID" ]; then
            # shellcheck disable=SC2155
            export SSH_AGENT_PID=$(pgrep -u "$USER" ssh-agent)
        fi
        if [ -z "$SSH_AUTH_SOCK" ]; then
            # shellcheck disable=SC2155
            export SSH_AUTH_SOCK=$(find /tmp -type s -user "$USER" -name 'agent.*' 2>/dev/null | head -n 1)
        fi
    fi

    # Check if variables are set correctly
    if [ -z "$SSH_AGENT_PID" ]; then
            echo "ssh-agent is not running"
    fi
    if [ -z "$SSH_AUTH_SOCK" ]; then
            echo "no socket found for ssh-agent $SSH_AGENT_PID"
    fi
    echo "SSH_AGENT_PID=$SSH_AGENT_PID"
    echo "SSH_AUTH_SOCK=$SSH_AUTH_SOCK"
else
    echo "ssh-agent not initialized for $current_hostname" 
fi

# some more ls aliases
alias l='ls -CF'
alias ll='ls -CFlh'
alias la='ls -CFAh'
alias lal='ls -CFalh'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

export PATH="$PATH:$HOME/.local/bin:$HOME/dvlw/scripts:$HOME/dvlw/dvlp/scripts"
export WSL_DISTRO_NAME=$WSL_DISTRO_NAME
export _WIN_USER=$_WIN_USER
export _AGL=${_AGL:-agl}
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1
export DOCKER_CLI_EXPERIMENTAL=enabled
export LFS
if sudo [ -d "$LFS" ]; then
    sudo bash dkms autoinstall --modprobe-on-install --kernelsourcedir "$LFS"
fi

alias cdir='source cdir.sh'
alias grep='grep --color=auto'
alias powershell=pwsh
alias vi="vi -c 'set verbose showmode'"
