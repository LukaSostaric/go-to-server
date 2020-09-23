# go-to-server completion                                       -*- shell-script -*-

_go-to-server()
{
    local cur prev cword
    _init_completion || return

    fword=${COMP_WORDS[0]}
    if [[ ( $fword == "go-to-server" || $fword == "copy-from-server" || $fword == "copy-to-server" ) && $cword -eq 1 ]] ; then
        COMPREPLY=( $(compgen -W "$(cat "SRVLISTPATH" | cut -d ';' -f1)" -- "$cur") )
    elif [[  ( $fword == "copy-from-server" || $fword == "copy-to-server" ) && $cword -gt 1 && $cword -lt 3 ]] ; then
        _filedir
    fi


} &&
complete -F _go-to-server go-to-server copy-to-server copy-from-server

# ex: filetype=sh