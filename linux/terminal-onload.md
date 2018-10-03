```
xed ~/.bashrc
```

# Util:

### My user
```sh
#-------------------
export JAVA_HOME=/usr/lib/jvm/default-java

export M2_HOME=/usr/share/maven
export M2=$M2_HOME/bin
export PATH=$M2:$PATH


export ORACLE_HOME=$HOME/Oracle/Oracle12c/osb
export MDS_PATH=$HOME/Documents/git/GTW_DEFINITIONS
export PS1="\W > "

alias git-a='git add'
alias git-aa='git add .'
alias git-c='git commit'
alias git-cm='git commit --message'
alias git-co='git checkout'
alias git-cob='git checkout -b'
alias git-com='git checkout master'
alias git-cod='git checkout develop'
alias git-p='git pull'
alias git-s='git status'
alias git-sv='git status -vv'

bind 'set completion-ignore-case on'
#-------------------
```


### Root
```sh
bind 'set completion-ignore-case on'
export PS1='${debian_chroot:+($debian_chroot)}\[\033[01;31m\]\W> \[\033[00m\] '


export ORACLE_HOME=$HOME/Oracle/Oracle12c/osb
export MDS_PATH=$HOME/Documents/git/GTW_DEFINITIONS
```
