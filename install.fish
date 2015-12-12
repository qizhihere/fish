#!/usr/bin/env fish

function has -d "check if a command is existed in system."
    for i in $argv
        type -a $argv[1] >/dev/null 2>&1; or return 1
    end
    return 0
end

if begin not has omf; and [ "$OMF_STATUS" != "installing" ]; end
    # install oh my fish
    set -gx OMF_STATUS "installing"
    curl -L https://github.com/oh-my-fish/oh-my-fish/raw/master/bin/install | fish
    set -gx OMF_STATUS "installed"

    # create shortcuts
    ln -sf ~/.config/omf/init.fish ~/.fishrc
end
