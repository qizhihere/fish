########################
# basic functions
########################
function has -d "check if a command is existed in system."
    for i in $argv
        type -a "$i" >/dev/null 2>&1; or return 1
    end
    return 0
end

function has_proc -d "check if process with specific command exists."
    set -l res (pgrep -f "^$argv")
    [ "$res" ]; or return 1
end

function in-arr -d "test if an element is in an array."
    echo "$argv[2..-1]" | grep -q "\(^\| \)$argv[1]\( \|\$\)" 2>/dev/null; or return 1
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

function add_paths -d "add paths to \$PATH."
    for i in $argv
        not in-arr $i $PATH; and [ -d $i ]; and set -gx PATH $PATH $i
    end
end

function ialias -d "set alias in an intelligent way."
    # if the current user is root, then there is no need to keep a
    # `sudo` prefix in commands.
    [ (id -u) -eq 0 ]; and set argv[2] (echo $argv[2] | sed -r 's/sudo\s+//')
    eval "function $argv[1]; $argv[2..-1] \$argv; end"
end

function p2abs -d "convert paths to absolute paths."
    read -lz items
    for i in (echo -ne $items | tr -d "\n")
        echo (realpath $i)
    end
end

function randpw -d "generate a random password with the specified length(default 12)."
    set -l len $argv[1] 12
    tr -dc _A-Za-z0-9 < /dev/urandom | head -c$len[1];echo
end

if not has "realpath"
    ialias realpath "readlink -f"
end


########################
# fish basic settings
########################
#term 256 color support
export INIT_TERM="$TERM"
export TERM="screen-256color"

export EMACSCLISOCK=/tmp/emacs/cli.sock # WARNING: The sock path must contains no spaces!
export EMACSCLIENT="emacsclient -s $EMACSCLISOCK -nw -c"
if has emacsclient; and has_proc "emacs +.*--daemon=$EMACSCLISOCK"
    export EDITOR="$EMACSCLIENT"
else if has vim
    export EDITOR="vim"
end
export VISUAL="$EDITOR"

# disable startup greeting
set fish_greeting ""

# setup for Emacs
if test "$INIT_TERM" = "dumb"
    function fish_prompt; echo "\$ "; end
    function fish_title; end
end
if test -n "INSIDE_EMACS"
    function fish_title; end
end

# java environment
export JAVA_HOME=(eval "ls -dr1 /usr/lib/jvm/java-*-openjdk" 2>/dev/null | head -1)

# environment variables
add_paths $HOME/.rbenv/bin \
          $HOME/scripts/bin $HOME/.composer/vendor/bin \
          $HOME/.emacs.d/bin /usr/bin/core_perl \
          $HOME/.local/bin /usr/local/bin \
          /usr/sbin /sbin /usr/local/sbin \
          $JAVA_HOME/bin

# setup docker daemon env
set -gx DOCKER_HOST "unix:///var/run/docker.sock"

# maybe use rbenv
if has rbenv
    . (rbenv init -|psub)
else
    # bundler install path
    set -gx BUNDLE_PATH $HOME/.gem/ruby/2.4.0
    add_paths $HOME/.gem/ruby/2.4.0/bin
end

# update completion
if has python sudo
    set -l _exist
    for x in $fish_complete_path
        [ -e "$x" ]; and set _exist yes
    end

    if [ -z "$_exist" ]
        echo "Updating completions..."
        fish_update_completions
    end
end


########################
# third-party program
########################
# ls colors
[ -f ~/.dircolors ]; and eval (dircolors -c ~/.dircolors)

# autojump
ialias j "fasd"

# simple http server
ialias server "python2 -mSimpleHTTPServer"


########################
# my balias
########################
# basic commands
ialias - "cd -"
ialias ... "cd ../../"
ialias .... "cd ../../../"
ialias ..... "cd ../../../../"
ialias ...... "cd ../../../../../"

ialias CP "rsync -aP"

ialias l 'ls -lah'
ialias la 'ls -lAh'
ialias ll 'ls -lh'
ialias ls 'command ls --color=tty'

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
ialias sudo "command sudo -E"
ialias timesync "sudo ntpdate -u cn.pool.ntp.org; sudo hwclock -w"

ialias ppi "sudo pacman -S"
ialias ppr "sudo pacman -Rsc"
ialias pps "sudo pacman -Ss"
ialias pai "pacaur -S --noedit --noconfirm"
ialias par "pacaur -Rsc"
ialias pas "pacaur -Ss"
ialias pau "pacaur -Syu"
ialias pay "pacaur -Syy"
ialias pls 'expac -H M -s "%-3! %-25n  -> %-10v %-10m %l <%+5r>  ::%d"'

# network
ialias xyw "sudo ~/Softs/rj/rjsupplicant.sh"
ialias px "proxychains4"
ialias spx "sudo proxychains4"
ialias dstat "command dstat -cdlmnpsy"
ialias iftop "sudo iftop"
ialias wifispot "sudo create_ap wlp8s0 wlp8s0"
ialias wirespot "sudo create_ap wlp8s0 enp9s0"

# edit
ialias v "vim"
ialias sv "env SUDO_EDITOR=vim sudoedit"
ialias e "$EMACSCLIENT"
ialias ec "emacsclient -nc"
function se -d "Edit files as root via emacsclient."
    set -l files
    for x in $argv
        set files "$files \"/sudo::$x\""
    end
    eval "e $files"
end

# git
ialias gin "git init"
ialias gdf "git diff"
ialias gis "git status"
ialias gil "git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
ialias grl "git reflog"
ialias gic "git checkout"
ialias gim "git merge --no-ff"
ialias gcb "git checkout -b"
ialias gci "git commit -m"
ialias gps "git push -u origin master"

# nginx
ialias ngtest "sudo nginx -c /etc/nginx/nginx.conf -t"
ialias ngrel "sudo nginx -c /etc/nginx/nginx.conf -t; and sudo nginx -s reload";

# Others
ialias resys "tmuxomatic ~/.tmuxomatic/sys"
ialias now 'date +"%Y-%m-%d %H:%M:%S %A"'
ialias cb 'xclip -ib'
ialias cbpwd 'pwd | cb'
ialias C 'clear'
ialias fixdropbox 'echo fs.inotify.max_user_watches=1000000 | sudo tee -a /etc/sysctl.conf; sudo sysctl -p'
ialias cfe "coffee"
ialias cfc "coffee -c"
ialias : "percol"
ialias po "percol"
ialias xo "xdg-open"
ialias rel ". ~/.config/fish/config.fish"


########################
# extended functions
########################
function t -d "youdao dictionary"
    if has fanyi
        fanyi "$argv[1]"
    else
        wget -qO- \
        "http://fanyi.youdao.com/openapi.do?keyfrom=sudotry&key=1865874386&type=data&doctype=json&version=1.1&q=$argv[1]" |\
        grep --color=auto -oP '(?<="explains":\[")[^"]*'
    end
end

# history
function h -d "search history and selectively copy to system clipboard."
    set -l __keyword ""
    if [ "$argv" ]
        set __keyword $argv
    end

    history | grep "$__keyword" | sed '1!G;h;$!d' | percol | sed 's/^ *[0-9][0-9]* *//p' | tr -d '\n' | cbi
end


function colorize-man-less -d "setup syntax highlight for less and man page."
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
    if has xsel
        echo -n $__content | xsel -bi
    else if has xclip
        echo -n $__content | xclip -selection clipboard -i
    end
end

function cbo -d "paste content from system clipboard."
    if has xsel
        xsel -bo
    else if has xclip
        xclip -selection clipboard -o
    end
end


# downloader
if has aria2c
    function down -d "Download resources with aria2."
        aria2c \
        --file-allocation=none \
        --header="User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36\
        (KHTML, like Gecko) Chrome/51.0.2704.63 Safari/537.36" \
        -x16 $argv
    end
end


function setup-ssh-agent -d "setup ssh agent and its environment vars."
    if has ssh-agent
        # if no ssh agent running, start one
        if not [ (ps -hp $SSH_AGENT_PID 2>/dev/null) ]
            eval (ssh-agent -c|sed -E '/^echo[^;]*;/d')
            # expose to global scope
            for x in SSH_AGENT_PID SSH_AUTH_SOCK
                set -Ux $x $$x
            end
        end

        # import ssh agent environment from universal scope
        for x in SSH_AGENT_PID SSH_AUTH_SOCK
            set -gx $x (set -U|awk '$1 ~ /'$x'/ {print $2}')
        end
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


# easily extract and compress
function extract -d "automatically extract from archive according to extension."
    if [ -f "$argv" ]
        switch $argv
            case '*.tar.bz2' '*.tbz2'
                tar xvpjf $argv
            case '*.tar.gz' '*.tgz'
                tar xvpzf $argv
            case '*.bz2'
                bunzip2 $argv
            case '*.rar'
                rar x $argv
            case '*.gz'
                gunzip $argv
            case '*.tar'
                tar xvpf $argv
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
                tar cvpf $argv[1] $argv[2..-1]
            case '*.tar.bz2'
                tar cvpjf $argv[1] $argv[2..-1]
            case '*.tar.gz' '*.tgz'
                tar cvpzf $argv[1] $argv[2..-1]
            case '*.zip'
                zip -r $argv[1] $argv[2..-1]
            case '*.rar'
                rar a -r $argv[1] $argv[2..-1]
        end
    end
end


# docker
ialias d "sudo docker"
ialias pd "sudo proxychains docker"
ialias dco "sudo docker-compose"
ialias dps "d ps -a"
ialias dim "d images"
ialias drm "d rm"
ialias drmi "d rmi"
ialias drun "d run"
ialias docker-tree "drun --rm -v /var/run/docker.sock:/var/run/docker.sock nate/dockviz images -t"
ialias docker-pid "d inspect --format '{{.State.Pid}}'"
ialias docker-ip "d inspect --format '{{.NetworkSettings.IPAddress}}'"

function docker-clean
    for x in (sudo docker ps -aq -f "status=dead" -f "status=exited")
        sudo docker rm -v $x
    end
end

function docker-cleani
    for x in (sudo docker images | grep -i '<none>' | awk '{print $3}')
        sudo docker rmi $x
    end
end

ialias den docker-enter
function docker-enter
    sudo docker exec -it "$argv" sh
end

ialias denv docker-env
function docker-env
    sudo docker inspect --format '{{range $x := .Config.Env}}{{println $x}}{{end}}' $argv | sed '/^$/d'
end

ialias dpo docker-ports
function docker-ports
    sudo docker inspect --format '{{json .NetworkSettings.Ports}}' $argv | python -mjson.tool
end

function drum
    sudo docker run --rm -it -v (realpath ./):/host $argv sh
end

function drumf
    sudo docker run --rm -it -v (realpath ./):/host $argv env TERM=xterm-256color fish
end

function maybe-startx
    if has startx
        read -n1 -p "set_color green; echo -n 'Run startx? [y/n] '; set_color normal" ok
        if [ "$ok" = y ]
            exec startx -- -keeptty
        end
    end
end

colorize-man-less
setup-ssh-agent

if status --is-login; and [ -z "$DISPLAY" -a "$XDG_VTNR" = 1 ]
    maybe-startx
end
