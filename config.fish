# env var
set PATH $PATH $HOME/.gem/ruby/2.2.0/bin $HOME/scripts/bin $HOME/.composer/vendor/bin $HOME/.emacs.d/utils/bin
#set -gx WORKON_HOME $HOME/.virtualenvs
#eval (python2.7 -m virtualfish)
#if set -q VIRTUAL_ENV
#    echo -n -s (set_color -b blue white) "(" (basename "$VIRTUAL_ENV") ")" (set_color normal) " "
#end

#term 256 color support
set -gx TERM screen-256color
# GNU ls colors
eval (dircolors -c ~/.dircolors)

# teamocil
set -gx EDITOR "vim"

# disable startup greeting
set fish_greeting ""

# Path to your oh-my-fish.
set fish_path $HOME/.oh-my-fish

# Load oh-my-fish configuration.
. $fish_path/oh-my-fish.fish

# Theme
Theme "cbjohnson"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-fish/plugins/*)
# Custom plugins may be added to ~/.oh-my-fish/custom/plugins/

Plugin "jump"
Plugin "balias"

# Path to your custom folder (default path is $FISH/custom)
#set fish_custom $HOME/dotfiles/oh-my-fish

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
# cd and ls
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

balias l 'ls -lah'
balias la 'ls -lAh'
balias ll 'ls -lh'
balias ls 'ls --color=tty'
balias lsdev 'lsblk -o NAME,LABEL,FSTYPE,SIZE,MOUNTPOINT,UUID'
balias lsdev "lsblk -o NAME,LABEL,FSTYPE,RM,SIZE,MOUNTPOINT,UUID"
balias psprc "ps -A -o user,comm | sort -k2 | uniq -c | sort -k1 -n"
balias psmem "ps -eo rss,pmem,pcpu,vsize,comm | sort -k 1 -n"
balias pscpu "ps -eo rss,pmem,pcpu,vsize,comm | sort -k 2 -n"

# system backup
balias homebak "sudo snapper -c homefs create"
balias rootbak "sudo snapper -c rootfs create"

# package manager
balias ppi "sudo pacman -S"
balias ppr "sudo pacman -Rsc"
balias pps "sudo pacman -Ss"
balias plist 'expac -H M -s "%-3! %-25n  -> %-10v %-10m %l <%+5r>  ::%d"'
balias pls 'expac -H M -s "%-3! %-20n  > %-10v %-10m %l"'

# Network
balias gae "sudo python2.7 ~/Softs/goagent-v3.2.1/local/proxy.py"
balias ss "sudo sslocal -c /etc/shadowsocks/config.json"
balias xyw "sudo ~/Softs/rj/rjsupplicant.sh"
balias px "proxychains4"
balias dstat "dstat -cdlmnpsy"
balias down 'axel -n50 -a -v'
balias iftop "sudo iftop"

# edit
balias v 'vim'
balias sv 'sudoedit'

# python
balias vnew 'virtualenv'
balias act '. bin/activate.fish'
balias deact 'deactivate'

# docker
balias d "sudo docker"
balias docker-pid "sudo docker inspect --format '{{.State.Pid}}'"
balias docker-ip "sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}'"
balias dim "sudo docker images"
balias dci "sudo docker commit"
balias dps "sudo docker ps -a"
balias drm "sudo docker rm"
balias drmi "sudo docker rmi"
balias drun "sudo docker run"

function drush
    sudo docker run -it $argv /bin/bash
end

# git and tig
alias gin "git init"
balias gdf "git diff"
balias gs "git status"
balias gl "git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
balias grl "git reflog"
balias gc "git checkout"
balias gm "git merge --no-ff"
balias gcb "git checkout -b"
balias gci "git commit -a -m"
balias t "tig status"

# nginx
balias ngtest "sudo nginx -c /etc/nginx/nginx.conf -t"
balias ngrel "sudo nginx -s reload";

# Others
balias resys "tmuxomatic ~/.tmuxomatic/sys"
balias now 'date +"%Y-%m-%d %H:%M:%S"'
balias getpost 'cat ~/sync/Dropbox/drafts/template.md | xclip -se c'
balias cb 'xclip -selection c'
balias cbpwd 'pwd | cb'
balias cls 'clear'
balias renm 'sudo systemctl restart NetworkManager'
balias fixdropbox 'echo fs.inotify.max_user_watches=100000 | sudo tee -a /etc/sysctl.conf; sudo sysctl -p'
balias mongo "mongo --quiet"
balias po "percol"


# functions
# less colors
function less-highlight
    # use gnu source-highlight to replace less
    if test -e "/usr/bin/src-hilite-lesspipe.sh"
        set -gx LESSOPEN "| /usr/bin/src-hilite-lesspipe.sh %s"
        set -gx LESS ' -R '
    end
    # change man page colors(less), more info reference:
    #   http://misc.flogisoft.com/bash/tip_colors_and_formatting#terminals_compatibility
    set -gx LESS_TERMCAP_mb (printf '\e[01;31m')
    set -gx LESS_TERMCAP_md (printf '\e[01;38;5;202m')
    set -gx LESS_TERMCAP_me (printf '\e[0m')
    set -gx LESS_TERMCAP_se (printf '\e[0m')
    set -gx LESS_TERMCAP_so (printf '\e[01;48;5;38;38;5;231m')
    set -gx LESS_TERMCAP_ue (printf '\e[0m')
    set -gx LESS_TERMCAP_us (printf '\e[04;38;5;41m')
end

# editors
function e
    if test -z "$argv"
        eval $EMACS_PROXY emacsclient -t -a vim
    else
        set path_list ""
        for i in $argv
            set cmd $cmd '-e "(find-file \"'(realpath "$i")'\")"'
        end
        eval $EMACS_PROXY emacsclient -t -a vim $cmd
    end
end

function pe
    eval "set -gx EMACS_PROXY proxychains; e $argv; set -gx EMACS_PROXY"
end

# video
# convert video to gif
function v2gif
    if math (count $argv)"<2" >/dev/null
        echo "Usage: v2gif input output size"
        echo "Arguments:"
        echo "input  : input video"
        echo "output : output gif path"
        echo "size   : resize width"
    end
    if set -q argv[3]
        set size $argv[3]
    else
        set size 600
    end
    echo "Convert video $argv[1] to $argv[2]($size wide)..."
    ffmpeg -i $argv[1] -vf scale="$size":-1 -r 11 -f image2pipe -vcodec ppm - | convert -delay 5 -loop 0 - gif:- | convert -layers Optimize - $argv[2]
    echo -e "\nFinished!"
end

# nginx
function ngls
    set ava_dir /etc/nginx/sites-available/
    set ena_dir /etc/nginx/sites-enabled/;
    ls $ava_dir $ena_dir $argv; echo ""; diff -u $ava_dir $ena_dir;
end

function ngln
    for i in $argv
        set conf_dir /etc/nginx
        set command "sudo ln -sf $conf_dir/sites-available/$i $conf_dir/sites-enabled/$i"
        echo $command
        eval $command
    end
end

function ngrm
    for i in $argv
        set conf_dir /etc/nginx
        set command "sudo rm -f $conf_dir/sites-enabled/$i"
        echo $command
        eval $command
    end
end

function rel
    source ~/.config/fish/config.fish
end

function docker-enter
    sudo nsenter --target (docker-pid $argv[1]) --mount --uts --ipc --net --pid $argv[2..-1]
end

#xrdb -merge $HOME/.Xresources

# show system info on startup
#alsi
#tmux

less-highlight
