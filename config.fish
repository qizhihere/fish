########################
# oh-my-fish settings
########################
if [ -d $HOME/.oh-my-fish ]
    # Load oh-my-fish configuration.
    set fish_path $HOME/.oh-my-fish
    . $fish_path/oh-my-fish.fish

    Theme "cbjohnson"
    Plugin "jump"
    Plugin "balias"

    # check plugin installation
    omf install >/dev/null 2>&1
end

########################
# basic functions
########################
function randpw -d "generate a random password with the specified length(default 12)."
    set -l len $argv[1] 12
    tr -dc _A-Za-z0-9 < /dev/urandom | head -c$len[1];echo
end

function in-arr -d "test if an element is in an array."
    if echo $argv[2..-1] | grep $argv[1] >/dev/null
        return 0
    else
        return 1
    end
end

function try-run -d "run command if it has not been run."
    pgrep -u $USER -x $argv[1] >/dev/null; or eval $argv
end

function y-or-n -d "ask yes or no and return input test result."
    read -l -n1 -p"echo -n '$argv [y/n/Y/N] '" __input_str

    if echo $__input_str | grep -i "^y" >/dev/null
        return 0
    else
        return 1
    end
end

function exist -d "check if a command is existed in system."
    for i in $argv
        type $argv[1] >/dev/null 2>&1; or return 1
    end
    return 0
end

function export -d "bash export porting."
    for i in $argv
        set -l __export_var (echo $i | grep -o '^[^=]*')
        if [ "$__export_var" = "$i" ]
            set -gx $__export_var $$__export_var
        else
            set -gx $__export_var (echo -n $i | sed -r 's/^[^=]*=//')
        end
    end
end

function ialias -d "set alias in an intelligent way."
    # if the current user is root, then there is no need to keep a
    # `sudo` prefix in commands.
    [ (id -u) -eq 0 ]; and set argv[2] (echo $argv[2] | sed -r 's/sudo\s+//')
    if exist 'balias'
        balias $argv 2>/dev/null
    else
        alias $argv
    end
end

function p2abs -d "convert paths to absolute paths."
    read -lz items
    for i in (echo -ne $items | tr -d "\n")
        echo (realpath $i)
    end
end

function ff -d "interactively quickly file pick."
    find . -type f -iwholename "*$argv*" 2>/dev/null | percol | p2abs | read -lz files
    echo -n $files | cbi
    echo -n $files
end

function fd -d "interactively quickly directory pick."
    find . -type d -iwholename "*$argv*" 2>/dev/null | percol | p2abs | read -lz dirs
    echo -n $dirs | cbi
    echo -n $dirs
end

function gd -d "interactively quickly directory change."
    find . -type d -iwholename "*$argv*" 2>/dev/null | percol | p2abs | read -l dir
    [ -d $dir ]; and cd $dir
end

if not exist "realpath"
    ialias realpath "readlink -f"
end

# setting for emacs
function fish_title
    true
end

# set prompt for tramp
switch $TERM
    case "dumb"
        function fish_prompt
            echo "> "
        end
end


########################
# fish basic settings
########################
# update completion
[ -z "$XDG_DATA_HOME" ]; and set -l XDG_DATA_HOME "$HOME/.local/share"
if begin exist python sudo; and [ ! -e "$XDG_DATA_HOME/fish/generated_completions" ]; end
    echo "Updating completions..."
    fish_update_completions
end

# disable startup greeting
set fish_greeting ""


########################
# normal basic settings
########################
# environment variables
set -l PATHS $HOME/.gem/ruby/2.2.0/bin $HOME/scripts/bin \
             $HOME/.composer/vendor/bin $HOME/.emacs.d/utils/bin \
             /usr/bin/core_perl $HOME/.local/bin /usr/local/bin \
             $HOME/.local/bin
for i in $PATHS
    not in-arr $i $PATH; and [ -d $i ]; and set PATH $PATH $i
end

#term 256 color support
set -gx TERM screen-256color
set -gx EDITOR "vim"


########################
# third-party program
########################
# ls colors
[ -f ~/.dircolors ]; and eval (dircolors -c ~/.dircolors)

# autojump
ialias j "autojump"
set -g AUTOJUMP_ERROR_PATH /dev/null  # fix bug
set -g AUTOJUMP_DATA_DIR /tmp
for i in /usr/share/autojump/autojump.fish \
         /etc/profile.d/autojump.fish
    [ -f "$i" ]; and . "$i"; and break
end

# percol
if begin not exist percol; and exist sudo pip2; end
    sudo pip2 install percol --upgrade
end

# change vagrant path
if begin exist vagrant; and [ -d "/mnt/E/VMs" ]; end
    mkdir -p "/mnt/E/VMs/Vagrant/vagrant.d"; and \
    set -gx VAGRANT_HOME "/mnt/E/VMs/Vagrant/vagrant.d"
end

########################
# my balias
########################
# cd/ls
ialias - "cd -"
ialias ... "cd ../../"
ialias .... "cd ../../../"
ialias ..... "cd ../../../../"
ialias ...... "cd ../../../../../"

ialias l 'ls -lah'
ialias la 'ls -lAh'
ialias ll 'ls -lh'
ialias ls 'ls --color=tty'

# process
ialias pss "ps aux | percol | awk '{ print \$2 }'"
ialias psk "pss | xargs kill -9"
ialias psp "ps -A -o user,comm | sort -k2 | uniq -c | sort -k1 -n"
ialias psm "ps -eo rss,pmem,pcpu,vsize,comm | sort -k 1 -n"
ialias psc "ps -eo rss,pmem,pcpu,vsize,comm | sort -k 2 -n"
ialias lps "sudo netstat -tulnp"

# device
ialias lsdev "lsblk -o NAME,LABEL,FSTYPE,RM,SIZE,MOUNTPOINT,UUID"

# system managment
ialias homebak "sudo snapper -c homefs create -d"
ialias rootbak "sudo snapper -c rootfs create -d"

ialias sudo "sudo -E"

ialias ppi "sudo pacman -S"
ialias ppr "sudo pacman -Rsc"
ialias pps "sudo pacman -Ss"
ialias pai "pacaur -S"
ialias par "pacaur -Rsc"
ialias pas "pacaur -Ss"
ialias pau "pacaur -Syu"
ialias pay "pacaur -Syy"
ialias pls 'expac -H M -s "%-3! %-25n  -> %-10v %-10m %l <%+5r>  ::%d"'

# network
ialias xyw "sudo ~/Softs/rj/rjsupplicant.sh"
ialias ss "sudo sslocal -c /etc/shadowsocks/config.json"
ialias px "proxychains4"
ialias dstat "dstat -cdlmnpsy"
ialias down 'axel -n50 -a -v'
ialias iftop "sudo iftop"
ialias wifispot "sudo create_ap wlp8s0 wlp8s0"
ialias wirespot "sudo create_ap wlp8s0 enp9s0"

# edit
ialias v 'vim'
ialias sv 'sudoedit'

# docker
ialias d "sudo docker"
ialias dco "sudo docker-compose"
ialias docker-pid "d inspect --format '{{.State.Pid}}'"
ialias docker-ip "d inspect --format '{{ .NetworkSettings.IPAddress }}'"
ialias dim "d images"
ialias dci "d commit"
ialias dps "d ps -a"
ialias drm "d rm"
ialias drmi "d rmi"
ialias drun "d run"
ialias dexe "d exec"
ialias dlog "d logs"
ialias dcrun "dco run --rm"
ialias dcli "dcrun cli"
ialias dclog "dco logs"
ialias dpu "d push"
ialias dpua "for i in littleqz/{nginx,redis,php,mariadb,nodejs}; d push \$i; end"
ialias dpla "for i in littleqz/{nginx,redis,php,mariadb,nodejs}; d pull \$i; end"

# kubernetes
ialias k "kubectl"
ialias kg "k get"
ialias kgp "kg pods"
ialias kgr "kg rc"
ialias kgs "kg services"
ialias kd "k delete"

# git
ialias gin "git init"
ialias gdf "git diff"
ialias gis "git status"
ialias gil "git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
ialias grl "git reflog"
ialias gic "git checkout"
ialias gim "git merge --no-ff"
ialias gcb "git checkout -b"
ialias gci "git commit -a -m"
ialias gps "git push -u origin master"
ialias t "tig status"

# nginx
ialias ngtest "sudo nginx -c /etc/nginx/nginx.conf -t"
ialias ngrel "sudo nginx -c /etc/nginx/nginx.conf -t; and sudo nginx -s reload";

# Others
ialias resys "tmuxomatic ~/.tmuxomatic/sys"
ialias now 'date +"%Y-%m-%d %H:%M:%S"'
ialias cb 'xclip -ib'
ialias cbpwd 'pwd | cb'
ialias C 'clear'
ialias fixdropbox 'echo fs.inotify.max_user_watches=1000000 | sudo tee -a /etc/sysctl.conf; sudo sysctl -p'
ialias mongo "mongo --quiet"
ialias cfe "coffee"
ialias cfc "coffee -c"
ialias : "percol"
ialias po "percol"
ialias R "env EDITOR='"(realpath ~)"/scripts/emacsclient.sh' ranger"
ialias emacs "env LC_CTYPE=zh_CN.UTF-8 emacs"
ialias gmacs "env LC_CTYPE=zh_CN.UTF-8 emacs >/dev/null 2>&1 &; /bin/false"
ialias xo "xdg-open"


########################
# extended functions
########################
# history
function h -d "search history and selective copy to system clipboard."
    set -l __keyword ""
    if [ "$argv" ]
        set __keyword $argv
    end

    history | grep "$__keyword" | sed '1!G;h;$!d' | percol | sed 's/^ *[0-9][0-9]* *//p' | tr -d '\n' | cbi
end


# man page and less
function man-less-colors -d "set syntax for less and man page."
    # use gnu source-highlight to replace less
    if test -e "/usr/bin/src-hilite-lesspipe.sh"
        set -gx LESSOPEN "| /usr/bin/src-hilite-lesspipe.sh %s"
        set -gx LESS ' -R '
    end
    # change man page colors(less), more info reference:
    #   http://misc.flogisoft.com/bash/tip_colors_and_formatting#terminals_compatibility
    set -gx LESS_TERMCAP_mb (printf '\e[01;31m')                 # begin blinking
    set -gx LESS_TERMCAP_md (printf '\e[01;38;5;202m')           # begin bold
    set -gx LESS_TERMCAP_me (printf '\e[0m')                     # end mode
    set -gx LESS_TERMCAP_se (printf '\e[0m')                     # end standout-mode
    set -gx LESS_TERMCAP_so (printf '\e[01;48;5;38;38;5;231m')   # begin standout-mode - info box
    set -gx LESS_TERMCAP_ue (printf '\e[0m')                     # end underline
    set -gx LESS_TERMCAP_us (printf '\e[04;38;5;41m')            # begin underline
end


# emacs
function e -d "use emacsclient to edit file."
    if not pgrep -fa "emacs.*?daemon" >/dev/null
        emacs -nw --daemon
    end
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

function pe -d "use proxy version emacsclient to edit."
    eval "set -gx EMACS_PROXY proxychains; e $argv; set -gx EMACS_PROXY"
end


# system clipboard
function cbi -d "copy content to system clipboard."
    # get content according to number of arguments
    set -l __content ""
    switch (count $argv)
        case 0
            read __content
        case 1
            [ -f $argv[1] -a -r $argv[1] ]; and set __content (cat $argv[1])
        case '*'
            set __content "$argv"
    end

    # copy to system clipboard
    if exist xsel
        echo -n $__content | xsel -bi
    else if exist xclip
        echo -n $__content | xclip -selection clipboard -i
    end
end

function cbo -d "paste content from system clipboard."
    if exist xsel
        xsel -bo
    else if exist xclip
        xclip -selection clipboard -o
    end
end


# nginx
function ngls
    set -l ava_dir /etc/nginx/sites-available/
    set -l ena_dir /etc/nginx/sites-enabled/;
    ls $ava_dir $ena_dir $argv; echo ""; diff -u $ava_dir $ena_dir;
end

function ngln
    for i in $argv
        set -l conf_dir /etc/nginx
        set -l command "sudo ln -sf $conf_dir/sites-available/$i $conf_dir/sites-enabled/$i"
        echo $command
        eval $command
    end
end

function ngrm
    for i in $argv
        set -l conf_dir /etc/nginx
        set -l command "sudo rm -f $conf_dir/sites-enabled/$i"
        echo $command
        eval $command
    end
end


# fish
function rel
    . ~/.config/fish/config.fish
end


# easy extract and compress
function extract -d "automatically extract from archive according to extension."
    if [ -f "$argv" ]
        switch $argv
            case '*.tar.bz2' '*.tbz2'
                tar xvjf $argv
            case '*.tar.gz' '*.tgz'
                tar xvzf $argv
            case '*.bz2'
                bunzip2 $argv
            case '*.rar'
                rar x $argv
            case '*.gz'
                gunzip $argv
            case '*.tar'
                tar xvf $argv
            case '*.zip' '*.apk' '*.epub' '*.xpi' '*.war' '*.jar'
                unzip $argv
            case '*.Z'
                uncompress $argv
            case '*.7z'
                7z x $argv
            case '*'
                echo "don't know how to extract '$argv'..."
        end
    end
end

function compress
    if [ (count $argv) -ge 2 ]
        switch $argv[1]
            case '*.tar'
                tar cf $argv[1] $argv[2..-1]
            case '*.tar.bz2'
                tar cjf $argv[1] $argv[2..-1]
            case '*.tar.gz' '*.tgz'
                tar czf $argv[1] $argv[2..-1]
            case '*.zip'
                zip $argv[1] $argv[2..-1]
            case '*.rar'
                rar $argv[1] $argv[2..-1]
        end
    end
end



# docker
function docker-enter
    sudo nsenter --target (docker-pid $argv[1]) --mount --uts --ipc --net --pid $argv[2..-1]
end

function den
    sudo docker exec -it $argv[1] sh
end

function denf
    sudo docker exec -it $argv[1] env TERM=xterm fish
end

function drum
    sudo docker run --rm -it -v (realpath ./):/host $argv sh
end

function drumf
    sudo docker run --rm -it -v (realpath ./):/host $argv env TERM=xterm-256color fish
end

#xrdb -merge $HOME/.Xresources

man-less-colors
# delete evil command histories which contain rm
sed -i "/rm/d" ~/.config/fish/fish_history
