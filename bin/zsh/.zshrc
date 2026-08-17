export PATH="/opt/homebrew/opt/sqlite/bin:$PATH"

alias python="python3"

# git completion
zstyle ':completion:*:*:git:*' script ~/.zsh/git-completion.bash
fpath=(~/.zsh $fpath)
autoload -Uz compinit && compinit

# git helpers
alias gs='git status'
ga(){
    case $1 in
        mod)
            git add -u
            ;;
        new)
            git add .
            ;;
        all)
            git add -A
            ;;
        *)
            echo "ga mod - add all modified files"
            echo "ga new - add all new files"
            echo "ga all - add all files"
            ;;
    esac
}
gb(){
    case $1 in
        all)
            git branch
            ;;
        cur)
            git rev-parse --abbrev-ref HEAD
            ;;
        new)
            if [ -z "$2" ];
                then echo "no origin specified. please include an origin. 'gb' for help"
            elif [ -z "$3" ];
                then echo "no branch name to create. please include a branch name. 'gb' for help"
            else
                git fetch && git checkout -b "$3" "origin/$2"
            fi
            ;;
        *)
            echo "gb all - list all branches"
            echo "gb cur - list current branch"
            echo "gb new <origin> <branch> - create a new branch from an origin"
            ;;
    esac
}

gc(){
    if [ -z "$1" ];
        then echo "no commit message. please include a commit message. 'gc' for help"
    else
        git commit -m "$1"
    fi
}

gp(){
    branch=$(gb cur)
    git push origin $branch
}

alias codedir='cd ~/Documents/GitHub'
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:$(go env GOPATH)/bin"
