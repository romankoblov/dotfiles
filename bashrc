# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Source giobal configuration file
if [ -f ~/dotfiles/dotfilesrc ] ; then
	. ~/dotfiles/dotfilesrc
fi

# Source local configuration file
if [ -f ~/.dotfilesrc ] ; then
	. ~/.dotfilesrc
fi

# User specific aliases and functions

### prompt stuff
function git_branch {
	branch=`git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'`
	if [ $branch ] ; then
		echo " "$branch
	fi
}

function venv {
	if [ $VENV -eq 1 ] ; then
		if [ $VIRTUAL_ENV ] ; then
			echo "(`basename $VIRTUAL_ENV`) "
		fi
	else
		echo ""
	fi
}


function prompt_command {
	# colors (numbers are from http://misc.flogisoft.com/_media/bash/colors_format/256_colors_fg.png)
	RED=$(tput setaf 196)
	GREEN=$(tput setaf 154)
	BLUE=$(tput setaf 61)
	LIGHTBLUE=$(tput setaf 55)
	NORMAL=$(tput sgr0)

	GIT_STATUS=$(git status --porcelain 2>/dev/null)
	if [[ -n $GIT_STATUS ]] ; then
		GIT_DIRTY=1
	else
		GIT_DIRTY=0
	fi
	if [ $GIT_DIRTY -eq 1 ] ; then
		export PS1='\[${BLUE}\]$(venv)\[${NORMAL}\]\[${LIGHTBLUE}\]\[${NORMAL}\][\u@\h \W\[${RED}\]$(git_branch)\[${NORMAL}\]]$ '
	else
		export PS1='\[${BLUE}\]$(venv)\[${NORMAL}\]\[${LIGHTBLUE}\]\[${NORMAL}\][\u@\h \W\[${GREEN}\]$(git_branch)\[${NORMAL}\]]$ '
	fi
	echo -ne "\033]0;${USER}@${HOSTNAME%%.*}: ${PWD/#$HOME/~}\007"
}

export PROMPT_COMMAND=prompt_command

### screen-specific stuff
function fixagent {
	eval export SSH_AUTH_SOCK=`find /tmp/ssh* -type s -user $USER -name 'agent.*' 2> /dev/null`
}

function screen_reattach {
	if [ $SSH_TTY ] && [ ! $STY ] ; then
		screen_check=`screen -ls | wc -l`
		if [ $screen_check -gt 2 ] ; then
			screen -dr
		fi
	fi
}

### variables
export EDITOR=vim
export PAGER=less
export HISTCONTROL=ignoredups
export TERM=xterm-256color

alias g=vim
alias nr='npm run'
### OSX-specific stuff
if [ `uname` == "Darwin" ] ; then
	alias less="less -R"
	alias jq="jq -C"
	alias ls="ls -G"
	alias top="top -s1 -o cpu -R -F"
	alias tor-ssh='ssh -o ProxyCommand="nc -X 4 -x localhost:9150 %h %p"'
	alias osxlock="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"
	alias g="mvim"
	alias nocolor='gsed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g"'
	export LSCOLORS=ExGxFxDxCxHxHxCbCeEbEb
	export LANG=en_US.UTF-8
	export LC_ALL=en_US.UTF-8
	export PATH=/usr/local/sbin:/usr/local/bin:$HOME/dotfiles/bin:/usr/local/share/npm/bin:$PATH
	## homebrew (https://github.com/mxcl/homebrew) stuff
	brew=`brew --prefix`
	brew_python=$(brew --prefix)/opt/python@3.10/libexec/bin
	export PATH=$brew_python:$PATH
	# bash completion
	if [ -f $brew/Cellar/bash-completion/1.3/etc/bash_completion ]; then
		. $brew/Cellar/bash-completion/1.3/etc/bash_completion
	fi

fi

### autostart
#fixagent
screen_reattach



PERL_MB_OPT="--install_base \"/Users/penpen/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/Users/penpen/perl5"; export PERL_MM_OPT;

test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"
source /Users/penpen/.rack/bash_autocomplete
source /Users/penpen/.cargo/env
#export OPENSSL_INCLUDE_DIR=`brew --prefix openssl`/include
#export OPENSSL_LIB_DIR=`brew --prefix openssl`/lib
#export DEP_OPENSSL_INCLUDE=`brew --prefix openssl`/include

export PATH="$HOME/.cargo/bin:$PATH"
source $HOME/.cargo/env

export PATH
export GPG_TTY=$(tty)
