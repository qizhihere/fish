#!/usr/bin/env fish

function has -d "check if a command is existed in system."
    for i in $argv
        type -a $argv[1] >/dev/null 2>&1; or return 1
    end
    return 0
end

# install oh my fish
if begin not has omf; and [ -z "$OMF_BOOTSTRAP" ]; end
    curl -L https://github.com/oh-my-fish/oh-my-fish/raw/master/bin/install | env OMF_BOOTSTRAP=yes fish
end

# create shortcuts
ln -sf ~/.config/omf/init.fish ~/.fishrc
ln -sf ~/.config/omf/.dircolors ~/
