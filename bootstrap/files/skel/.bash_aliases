#ALIASES
#alias ls='ls -h --color=auto'
#alias ll='ls --color=auto -lah'
#alias la='ls --color=auto -lah'
#alias lls='ls -lah --color=auto --sort=size --reverse'
#alias llt='ls -lah --color=auto --sort=time --reverse' 
#alias cp='cp -v'
#alias mv='mv -v'
#alias rm='rm -v'
#alias df='df -ha'
#alias du='du -hc'
#alias grep='grep --color=auto'
#alias zgrep='zgrep --color=auto'
#alias nano='nano -wm'
#alias vim='vim -p'
#
alias psgrep="ps aux | grep -v 'grep --color=auto -e %MEM' | grep -e %MEM -e" 
alias modgrep="lsmod | grep -v 'grep --color=auto -e %MEM' | grep -e %MEM -e" 
#
#alias dirs="dirs -v"
#alias free="free -m" 
#
#alias tarz='tar -zxvvf'
#alias tarj='tar -jxvvf'
#
alias hist='history | grep $1' #Requires one input
#
#alias findf=_findf #find files
#alias findbig=_findbig #find large files
#
#function _findf
#{
#        find . | grep -i "$@"
#}
#
## finds big files (50MB with no parameter)
#function _findbig()
#{
#  local meg="${1-50}"
#  find -size +$(($meg*1024))k -exec du -h {} \; 2>/dev/null
#}
