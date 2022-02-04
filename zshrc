#!/usr/bin/env zsh

curr="$HOME/dotfiles"

# Load main files.
# echo "Load start\t" $(gdate "+%s-%N")
source "$curr/zsh/startup.sh"
# echo "$curr/zsh/startup.sh"
source "$curr/zsh/completion.sh"
source "$curr/zsh/highlight.sh"
# echo "Load end\t" $(gdate "+%s-%N")

autoload -U colors && colors

# Load and execute the prompt theming system.
fpath=("$curr/zsh" $fpath)

autoload -Uz promptinit && promptinit
prompt 'paulmillr'

path=(/usr/local/opt/ruby/bin $HOME/.cargo/bin $path) # changing .zshenv doesn't work

export PATH=/usr/local/sbin:/usr/local/bin:$HOME/dotfiles/bin:/usr/local/share/npm/bin:$PATH
export GPG_TTY=$(tty) # For git commit signing

alias cl='clear'

# Some MacOS-only stuff.
if [[ "$OSTYPE" == darwin* ]]; then
  # Remove all items safely, to Trash (`brew install trash`).
  [[ -z "$commands[trash]" ]] || alias rm='trash' 2>&1 > /dev/null

  # Lock current session and proceed to the login screen.
  alias lock='/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend'

  # Sniff network info.
  alias sniff="sudo ngrep -d 'en1' -t '^(GET|POST) ' 'tcp and port 80'"

  # Process grep should output full paths to binaries.
  alias pgrep='pgrep -fli'
else
  # Process grep should output full paths to binaries.
  alias pgrep='pgrep -fl'
fi

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

alias code='code -ng'
alias nr='npm run'
alias jq="jq -C"
alias ls="ls -G"
alias top="top -s1 -o cpu -R -F"
alias tor-ssh='ssh -o ProxyCommand="nc -X 4 -x localhost:9150 %h %p"'
alias osxlock="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"
alias serve='python -m SimpleHTTPServer'
alias nocolor='gsed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g"'
export LSCOLORS=ExGxFxDxCxHxHxCbCeEbEb
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# $ git log --no-merges --pretty=format:"%ae" | stats
# # => 514 a@example.com
# # => 200 b@example.com
alias stats='sort | uniq -c | sort -r'
# Lists the ten most used commands.
alias history-stats="history 0 | awk '{print \$2}' | stats | head"

# Checks whether connection is up.
alias net="ping google.com | grep -E --only-match --color=never '[0-9\.]+ ms'"

# ==================================================================
# = Functions =
# ==================================================================
# Opens file in EDITOR.
function edit() {
  local dir=$1
  [[ -z "$dir" ]] && dir='.'
  $EDITOR $dir
}
alias e=edit

# Execute commands for each file in current directory.
function each() {
  for dir in *; do
    # echo "${dir}:"
    cd $dir
    $@
    cd ..
  done
}

# Find files and exec commands at them.
# $ find-exec .coffee cat | wc -l
# # => 9762
function find-exec() {
  find . -type f -iname "*${1:-}*" -exec "${2:-file}" '{}' \;
}

# Better find(1)
function ff() {
  find . -iname "*${1:-}*"
}

# Count code lines in some directory.
# $ loc py js css
# # => Lines of code for .py: 3781
# # => Lines of code for .js: 3354
# # => Lines of code for .css: 2970
# # => Total lines of code: 10105
function loc() {
  local total
  local firstletter
  local ext
  local lines
  total=0
  for ext in $@; do
    firstletter=$(echo $ext | cut -c1-1)
    if [[ firstletter != "." ]]; then
      ext=".$ext"
    fi
    lines=`find-exec "*$ext" cat | wc -l`
    lines=${lines// /}
    total=$(($total + $lines))
    echo "Lines of code for ${fg[blue]}$ext${reset_color}: ${fg[green]}$lines${reset_color}"
  done
  echo "${fg[blue]}Total${reset_color} lines of code: ${fg[green]}$total${reset_color}"
}

function _calcram() {
  local sum
  sum=0
  for i in `ps aux | grep -i "$1" | grep -v "grep" | awk '{print $6}'`; do
    sum=$(($i + $sum))
  done
  sum=$(echo "scale=2; $sum / 1024.0" | bc)
  echo $sum
}

# Show how much RAM application uses.
# $ ram safari
# # => safari uses 154.69 MBs of RAM
function ram() {
  local sum
  local app="$1"
  if [ -z "$app" ]; then
    echo "First argument - pattern to grep from processes"
    return 0
  fi

  sum=$(_calcram $app)
  if [[ $sum != "0" ]]; then
    echo "${fg[blue]}${app}${reset_color} uses ${fg[green]}${sum}${reset_color} MBs of RAM"
  else
    echo "No active processes matching pattern '${fg[blue]}${app}${reset_color}'"
  fi
}

# Same, but tracks RAM usage in realtime. Will run until you stop it.
# $ rams safari
function rams() {
  local sum
  local app="$1"
  if [ -z "$app" ]; then
    echo "First argument - pattern to grep from processes"
    return 0
  fi

  while true; do
    sum=$(_calcram $app)
    if [[ $sum != "0" ]]; then
      echo -en "${fg[blue]}${app}${reset_color} uses ${fg[green]}${sum}${reset_color} MBs of RAM\r"
    else
      echo -en "No active processes matching pattern '${fg[blue]}${app}${reset_color}'\r"
    fi
    sleep 1
  done
}

# $ size dir1 file2.js
function size() {
  # du -scBM | sort -n
  du -shck "$@" | sort -rn | awk '
      function human(x) {
          s="kMGTEPYZ";
          while (x>=1000 && length(s)>1)
              {x/=1024; s=substr(s,2)}
          return int(x+0.5) substr(s,1,1)
      }
      {gsub(/^[0-9]+/, human($1)); print}'
}

# Shortcut for searching commands history.
# hist git
alias hist='history 0 | grep'


# Load all CPU cores at once.
function maxcpu() {
  cores=$(sysctl -n hw.ncpu)
  dn=/dev/null
  i=0
  while (( i < $((cores)) )); do
    yes > $dn &
    (( ++i ))
  done
  echo "Loaded $cores cores. To stop: 'killall yes'"
}

# $ retry ping google.com
function retry() {
  echo Retrying "$@"
  $@
  sleep 1
  retry $@
}

function remove-node-modules() {
  find . -name 'node_modules' -type d -prune -exec rm -rf '{}' +
}

function update-debian() {
  sudo apt update && sudo apt upgrade -y && sudo apt dist-upgrade -y
}

function update-mac() {
  brew update && brew upgrade
}

if [ -f "/opt/homebrew/bin/brew" ]; then
  export PATH="/opt/homebrew/opt/ruby/bin:/usr/local/opt/python@3.8/bin:$PATH"
  eval $(/opt/homebrew/bin/brew shellenv)
fi
