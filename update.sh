#!/bin/bash

OS=`uname`

function dotfile {
	if [ -f $HOME/.$1 ] ; then
		if [ -L $HOME/.$1 ] ; then
			echo "File already linked: $1"
		else
			echo "File exists: $1. Probably you want to remove it and run update.sh again."
		fi
	else
		ln -s $HOME/dotfiles/$1 $HOME/.$1
		echo "Linking file $1"
	fi
}

function dotdir {
	if [ -d $HOME/.$1 ] ; then
		if [ -L $HOME/.$1 ] ; then
			echo "Directory already linked: $1"
		else
			echo "Directory exists: $1. Probably you want to remove it and run update.sh again."
		fi
	else
		ln -s $HOME/dotfiles/$1 $HOME/.$1
		echo "Linking directory $1"
	fi
}

# Common
dotfile vimrc
dotfile gitconfig
dotfile bashrc
dotfile screenrc
dotfile zshrc
dotfile zshenv
dotfile zlogin
dotdir vim

[ "${SHELL##/*/}" != "zsh" ] && echo 'You might need to change default shell to zsh: `chsh -s /bin/zsh`'


# Darwin-specific
if [ $OS == "Darwin" ] && [ ! -e $HOME/.bash_profile ] ; then
	ln -s $HOME/.bashrc $HOME/.bash_profile
fi

# Linux-specific
if [ $OS == "Linux" ] ; then
	dotfile Xresources
	dotdir mplayer
fi

# Configuration file
if [ ! -f ~/.dotfilesrc ] ; then
	echo
	echo "===== WARNING ====="
	echo "You don't have a local configuration file."
	echo "Probably you want one. See ~/dotfiles/dotfilesrc for instructions."
	echo
fi

link() {
  from="$1"
  to="$2"
  echo "Linking '$from' to '$to'"
  rm -f "$to"
  ln -s "$from" "$to"
}


if [ `uname` == 'Darwin' ]; then
  link "$dotfiles/vscode/settings.json" "$HOME/Library/Application Support/Code/User/settings.json"
else
  link "$dotfiles/vscode/settings.json" "$HOME/.vscode/settings.json"
fi
