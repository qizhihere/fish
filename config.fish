# env var
set PATH $PATH $HOME/.gem/ruby/2.2.0/bin $HOME/scripts/bin $HOME/.composer/vendor/bin
#set -gx WORKON_HOME $HOME/.virtualenvs
#eval (python2.7 -m virtualfish)
#if set -q VIRTUAL_ENV
#    echo -n -s (set_color -b blue white) "(" (basename "$VIRTUAL_ENV") ")" (set_color normal) " "
#end

#term 256 color support
set -gx TERM xterm-256color
# GNU ls colors
#eval (dircolors -c ~/.dircolors)

# teamocil
set -gx EDITOR "vim"

# disable startup greeting
set fish_greeting ""

# Path to your oh-my-fish.
set fish_path $HOME/.oh-my-fish

# Theme
set fish_theme cbjohnson
#set fish_theme beloglazov

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-fish/plugins/*)
# Custom plugins may be added to ~/.oh-my-fish/custom/plugins/
# Example format: set fish_plugins autojump bundler
set fish_plugins jump better-alias balias

# Path to your custom folder (default path is $FISH/custom)
#set fish_custom $HOME/dotfiles/oh-my-fish

# Load oh-my-fish configuration.
. $fish_path/oh-my-fish.fish

# plugins
# autojump
balias j "autojump"
# fix bug
set AUTOJUMP_ERROR_PATH /dev/null
if test -e ~/.autojump/share/autojump/autojump.fish
    . ~/.autojump/share/autojump/autojump.fish
end
if test -e /usr/share/autojump/autojump.fish
    . /usr/share/autojump/autojump.fish
end
if test -e /etc/profile.d/autojump.fish
    . /etc/profile.d/autojump.fish
end

# balias
# cd
balias - "cd -"
balias ..1 "cd ~"
balias ..2 "cd ../../"
balias ..3 "cd ../../../"
balias ..4 "cd ../../../../"
balias ..5 "cd ../../../../../"
balias ... "cd ../../"
balias .... "cd ../../../"
balias ..... "cd ../../../../"
balias ...... "cd ../../../../../"

# ls and search
balias l 'ls -lah'
balias la 'ls -lAh'
balias ll 'ls -lh'
balias ls 'ls --color=tty'
balias lsa 'ls -lah'
balias lsdev 'lsblk -o NAME,LABEL,FSTYPE,SIZE,MOUNTPOINT,UUID'
balias chp 'echo find $argv ! -type d -regex ".*\/\.git.*" -a ! -regex ".*\/\.svn.*" -exec sudo chmod 755 \'{}\' \;;echo find $argv ! -type f -regex ".*\/\.git.*" -a ! -regex ".*\/\.svn.*" -exec sudo chmod 664 \'{}\' \; \#'

# system
balias homebak "sudo snapper -c homefs create"
balias rootbak "sudo snapper -c rootfs create"

# pacman
balias ppi "sudo pacman -S"
balias ppr "sudo pacman -Rsc"
balias pps "sudo pacman -Ss"
balias ppup "sudo pacman -Syy"
balias sysupgrade "sudo snp pacman -Syu"
balias plist 'expac -H M -s "%-3! %-25n  -> %-10v %-10m %l <%+5r>  ::%d"'
balias pls 'expac -H M -s "%-3! %-20n  > %-10v %-10m %l"'

# Network
balias gae "sudo python2.7 ~/Softs/goagent-v3.2.1/local/proxy.py"
balias ss "sudo sslocal -c /etc/shadowsocks/config.json"
balias xyw "sudo ~/Softs/Su_for_Linux_V1.31/rjsupplicant.sh"
balias p "proxychains4"
balias dstat "dstat -cdlmnpsy"

# Others
balias lsdev "lsblk -o NAME,LABEL,FSTYPE,RM,SIZE,MOUNTPOINT,UUID"
balias psprc "ps -A -o user,comm | sort -k2 | uniq -c | sort -k1 -n"
balias psmem "ps -eo rss,pmem,pcpu,vsize,comm | sort -k 1 -n"
balias pscpu "ps -eo rss,pmem,pcpu,vsize,comm | sort -k 2 -n"
balias iftop "sudo iftop"
balias resys "tmuxomatic ~/.tmuxomatic/sys"
balias d 'dirs -v | head -10'
balias down 'axel -n50 -a -v'
balias v 'vim'
balias sv 'sudo vim'
balias e 'emacsclient -t -a vim'
balias se 'sudo emacsclient -t -a vim'
balias now 'date +"%Y-%m-%d %H:%M:%S"'
balias getpost 'cat ~/sync/Dropbox/drafts/template.md | xclip -se c'
balias cb 'xclip -selection c'
balias cbpwd 'pwd | cb'
balias cbssh 'cbf ~/.ssh/id_rsa.pub'
balias catssh 'cat ~/.ssh/id_rsa.pub'
balias vnew 'virtualenv'
balias act '. bin/activate.fish'
balias deact 'deactivate'
balias cl 'clear'
balias renm 'sudo systemctl restart NetworkManager'
balias fixdropbox 'echo fs.inotify.max_user_watches=100000 | sudo tee -a /etc/sysctl.conf; sudo sysctl -p'
balias docker-pid "sudo docker inspect --format '{{.State.Pid}}'"
balias docker-ip "sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}'"

# git and tig
balias gin "git init"
balias gdf "git diff"
balias gs "git status"
balias gl "git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
balias grl "git reflog"
balias gc "git checkout"
balias gm "git merge --no-ff"
balias gcb "git checkout -b"
balias gci "git commit -a -m"

balias t "tig status"


# functions
function rel
    source ~/.config/fish/config.fish
end

function cbf
    cat $argv | cb
end

function b
    bash -c $argv
end

function sb
    sudo bash -c $argv
end

function docker-enter
    sudo nsenter --target (docker-pid $argv[1]) --mount --uts --ipc --net --pid $argv[2..-1]
end

#xrdb -merge $HOME/.Xresources

# show system info on startup
#alsi
#tmux

