########################
# basic functions
########################
function run-once -d "run command if it has not been run."
	pgrep -u $USER -x $argv[1] >/dev/null; or eval $argv
end

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
	set -l __export_var (echo $i | grep -o '^[^=]*')
	if [ "$__export_var" = "$i" ]
		set -gx $__export_var $$__export_var
	else
		set -gx $__export_var (echo -n $i | sed -e 's/^[^=]*=//')
	end
	end
end

if not command-exist-p "realpath"
	alias realpath "readlink -f"
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
. $fish_path/oh-my-fish.fish

Theme "cbjohnson"
Plugin "jump"
Plugin "balias"

# check install
omf install >/dev/null 2>&1

########################
# normal basic settings
########################

# environment variables
set PATH $PATH $HOME/.gem/ruby/2.2.0/bin $HOME/scripts/bin \
	 $HOME/.composer/vendor/bin $HOME/.emacs.d/utils/bin \
	 /usr/bin/core_prel
#term 256 color support
set -gx TERM screen-256color
set -gx EDITOR "vim"


########################
# third-party program
########################

# GNU ls colors
[ -f ~/.dircolors ]; and eval (dircolors -c ~/.dircolors)

# autojump
balias j "autojump"
set AUTOJUMP_ERROR_PATH /dev/null  # fix bug
[ -f /usr/share/autojump/autojump.fish ]; and . /usr/share/autojump/autojump.fish


########################
# my balias
########################

# cd and ls
balias - "cd -"
balias ... "cd ../../"
balias .... "cd ../../../"
balias ..... "cd ../../../../"
balias ...... "cd ../../../../../"

balias l 'ls -lah'
balias la 'ls -lAh'
balias ll 'ls -lh'
balias ls 'ls --color=tty'

# process
balias psp "ps -A -o user,comm | sort -k2 | uniq -c | sort -k1 -n"
balias psm "ps -eo rss,pmem,pcpu,vsize,comm | sort -k 1 -n"
balias psc "ps -eo rss,pmem,pcpu,vsize,comm | sort -k 2 -n"

# device
balias lsdev "lsblk -o NAME,LABEL,FSTYPE,RM,SIZE,MOUNTPOINT,UUID"

# system managment
balias homebak "sudo snapper -c homefs create"
balias rootbak "sudo snapper -c rootfs create"

balias ppi "sudo pacman -S"
balias ppr "sudo pacman -Rsc"
balias pps "sudo pacman -Ss"
balias pai "pacaur -S"
balias par "pacaur -Rsc"
balias pas "pacaur -Ss"
balias pau "pacaur -Syu"
balias pay "pacaur -Syy"
balias pls 'expac -H M -s "%-3! %-25n  -> %-10v %-10m %l <%+5r>  ::%d"'

# network
balias xyw "sudo ~/Softs/rj/rjsupplicant.sh"
balias ss "sudo sslocal -c /etc/shadowsocks/config.json"
balias px "proxychains4"
balias dstat "dstat -cdlmnpsy"
balias down 'axel -n50 -a -v'
balias iftop "sudo iftop"
balias wifispot "sudo create_ap wlp8s0 wlp8s0"
balias wirespot "sudo create_ap wlp8s0 enp9s0"

# edit
balias v 'vim'
balias sv 'sudoedit'

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
balias dexe "sudo docker exec"
balias dcom "sudo docker-compose"
balias dpu "sudo docker push"
balias dpua "for i in littleqz/{nginx,redis,php,mariadb}; sudo docker push \$i; end"
balias dpla "for i in littleqz/{nginx,redis,php,mariadb}; sudo docker pull \$i; end"

# git
balias gin "git init"
balias gdf "git diff"
balias gs "git status"
balias gl "git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
balias grl "git reflog"
balias gc "git checkout"
balias gm "git merge --no-ff"
balias gcb "git checkout -b"
balias gci "git commit -a -m"
balias gps "git push -u origin master"
balias t "tig status"

# nginx
balias ngtest "sudo nginx -c /etc/nginx/nginx.conf -t"
balias ngrel "sudo nginx -s reload";

# Others
balias resys "tmuxomatic ~/.tmuxomatic/sys"
balias now 'date +"%Y-%m-%d %H:%M:%S"'
balias getpost 'cat ~/sync/Dropbox/drafts/template.md | xclip -se c'
balias cb 'xclip -ib'
balias cbpwd 'pwd | cb'
balias C 'clear'
balias fixdropbox 'echo fs.inotify.max_user_watches=1000000 | sudo tee -a /etc/sysctl.conf; sudo sysctl -p'
balias mongo "mongo --quiet"
balias cfe "coffee"
balias cfc "coffee -c"
balias : "percol"
balias po "percol"
balias R "env EDITOR='"(realpath ~)"/scripts/emacsclient.sh' ranger"
balias emacs "env LC_CTYPE=zh_CN.UTF-8 emacs"
balias gmacs "env LC_CTYPE=zh_CN.UTF-8 emacs >/dev/null 2>&1 &; /bin/false"
balias xo "xdg-open"


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
	emacs --daemon
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
	if command-exist-p xsel
	echo -n $__content | xsel -bi
	else if command-exist-p xclip
	echo -n $__content | xclip -selection clipboard -i
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
	sudo docker exec -it $argv[1] env TERM=xterm-256color fish
end

function drum
	sudo docker run --rm -it -v (realpath ./):/host $argv sh
end

function drumf
	sudo docker run --rm -it -v (realpath ./):/host $argv env TERM=xterm-256color fish
end

#xrdb -merge $HOME/.Xresources

man-less-colors
sed -i "/rm/d" ~/.config/fish/fish_history
