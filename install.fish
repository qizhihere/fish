#!/usr/bin/env fish

function has -d "check if a command is existed in system."
    for i in $argv
        type -a $argv[1] >/dev/null 2>&1; or return 1
    end
    return 0
end

function verbose_do
    echo "$argv"
    eval "$argv"
end

# install oh my fish
if begin not has omf; and [ -z "$OMF_BOOTSTRAP" ]; end
    curl -L https://github.com/oh-my-fish/oh-my-fish/raw/master/bin/install | env OMF_BOOTSTRAP=yes fish
end

set CUR (realpath (dirname (status -f)))
set DST "$HOME/.config/omf"
if [ "$CUR" != "$DST" ]
    verbose_do "ln -s \"$CUR\" \"$DST\""
end

# create shortcuts
verbose_do "ln -sf ~/.config/omf/init.fish ~/.fishrc"
verbose_do "ln -sf ~/.config/omf/.dircolors ~/.dircolors"
