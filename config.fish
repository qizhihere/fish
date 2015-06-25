########################
# basic functions
########################

function run-if -d "run function if condition."
    # check arguments
    if [ ! (count $argv) -eq 2 ]
        echo "error arguments: $argv"
        echo "Usage: runif func condition"
        return 1
    end

    if eval $argv[2]
        eval $argv[1]
        return
    else
        return 1
    end
end

function y-or-n-p -d "ask yes or no and return input test result."
    if [ (count $argv) -gt 0 ]
        echo $argv
    end

    set -l __input_str
    read __input_str

    if echo $__input_str | grep -i "^y" >/dev/null
        return 0
    else
        return 1
    end
end

function command-exist-p -d "check if a command is existed in system."
    return (type $argv[1] >/dev/null 2>&1)
end

function export -d "bash export porting."
    for i in $argv
        set -l __export_var (echo $i | grep -o '^[^=]*' >/dev/null)
        if [ "$__export_var" = "$i" ]
            set -gx $__export_var $$__export_var
        else
            set -g -x $__export_var (echo -n $i | sed -e 's/^[^=]*=//')
        end
    end
end

function load -d "source file if it does exist."
    if [ -f "$argv" ]
        . $argv
        return
    end
    return 1
end

function load-first -d "source the first existed file in file list."
    for i in $argv
        load "$i"; and return 0
    end
    return 1
end


########################
# fish basic settings
########################

# update completion
if [ ! -e ~/.config/fish/generated_completions ]
    echo "Updating completions..."
    fish_update_completions
end

# disable startup greeting
set fish_greeting ""

# Load oh-my-fish configuration.
set fish_path $HOME/.oh-my-fish
if load $fish_path/oh-my-fish.fish
    Theme "cbjohnson"
    Plugin "jump"
end


########################
# normal basic settings
########################

# environment variables
set PATH $PATH $HOME/.gem/ruby/2.2.0/bin $HOME/scripts/bin $HOME/.composer/vendor/bin $HOME/.emacs.d/utils/bin
#term 256 color support
set -gx TERM screen-256color
set -gx EDITOR "vim"


########################
# third-party program
########################

# GNU ls colors
[ -f ~/.dircolors ]; and eval (dircolors -c ~/.dircolors)

# autojump
alias j "autojump"
set AUTOJUMP_ERROR_PATH /dev/null  # fix bug
load-first \
  ~/.autojump/share/autojump/autojump.fish \
  /usr/share/autojump/autojump.fish \
  /etc/profile.d/autojump.fish



########################
# my alias
########################

# cd and ls
alias - "cd -"
alias ... "cd ../../"
alias .... "cd ../../../"
alias ..... "cd ../../../../"
alias ...... "cd ../../../../../"

alias l 'ls -lah'
alias la 'ls -lAh'
alias ll 'ls -lh'
alias ls 'ls --color=tty'

# process
alias psp "ps -A -o user,comm | sort -k2 | uniq -c | sort -k1 -n"
alias psm "ps -eo rss,pmem,pcpu,vsize,comm | sort -k 1 -n"
alias psc "ps -eo rss,pmem,pcpu,vsize,comm | sort -k 2 -n"

# device
alias lsdev "lsblk -o NAME,LABEL,FSTYPE,RM,SIZE,MOUNTPOINT,UUID"

# system managment
alias homebak "sudo snapper -c homefs create"
alias rootbak "sudo snapper -c rootfs create"

alias ppi "sudo pacman -S"
alias ppr "sudo pacman -Rsc"
alias pps "sudo pacman -Ss"
alias pai "sudo pacaur -S"
alias par "sudo pacaur -Rsc"
alias pas "sudo pacaur -Ss"
alias pls 'expac -H M -s "%-3! %-25n  -> %-10v %-10m %l <%+5r>  ::%d"'

# network
alias xyw "sudo ~/Softs/rj/rjsupplicant.sh"
alias ss "sudo sslocal -c /etc/shadowsocks/config.json"
alias px "proxychains4"
alias dstat "dstat -cdlmnpsy"
alias down 'axel -n50 -a -v'
alias iftop "sudo iftop"

# edit
alias v 'vim'
alias sv 'sudoedit'

# docker
alias d "sudo docker"
alias docker-pid "sudo docker inspect --format '{{.State.Pid}}'"
alias docker-ip "sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}'"
alias dim "sudo docker images"
alias dci "sudo docker commit"
alias dps "sudo docker ps -a"
alias drm "sudo docker rm"
alias drmi "sudo docker rmi"
alias drun "sudo docker run"

# git
alias gin "git init"
alias gdf "git diff"
alias gs "git status"
alias gl "git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias grl "git reflog"
alias gc "git checkout"
alias gm "git merge --no-ff"
alias gcb "git checkout -b"
alias gci "git commit -a -m"
alias gps "git push -u origin master"
alias t "tig status"

# nginx
alias ngtest "sudo nginx -c /etc/nginx/nginx.conf -t"
alias ngrel "sudo nginx -s reload";

# Others
alias resys "tmuxomatic ~/.tmuxomatic/sys"
alias now 'date +"%Y-%m-%d %H:%M:%S"'
alias getpost 'cat ~/sync/Dropbox/drafts/template.md | xclip -se c'
alias cb 'xclip -ib'
alias cbpwd 'pwd | cb'
alias C 'clear'
alias fixdropbox 'echo fs.inotify.max_user_watches=100000 | sudo tee -a /etc/sysctl.conf; sudo sysctl -p'
alias mongo "mongo --quiet"
alias : "percol"


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
            echo $argv | read __content
    end

    # copy to system clipboard
    if command-exist-p xsel
        echo $__content | xsel -bi
    else if command-exist-p xclip
        echo $__content | xclip -selection clipboard -i
    end
end

function cbo -d "paste content from system clipboard."
    if command-exist-p xsel
        xsel -bo
    else if command-exist-p xclip
        xclip -selection clipboard -o
    end
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


# fish
function rel
    source ~/.config/fish/config.fish
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

#xrdb -merge $HOME/.Xresources

man-less-colors
