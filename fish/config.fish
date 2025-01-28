# ~/.config/fish/config.fish

starship init fish | source


set -U fish_greeting

# Set Theme Directory
set -xg THEME_DIR /usr/share/themes/Catppuccin-Mocha-Standard-Blue-Dark

# NIX
set -x PATH $PATH /run/current-system/sw/bin

#NPM
set -x PATH $PATH $HOME/.npm-global/bin

# NVM
set -gx NVM_DIR $HOME/.nvm
set -U nvm_default_version lts

# Fuck alias
thefuck --alias | source

# Set up fzf key bindings
fzf --fish | source

# Yubikey
set -gx SSH_SK_PROVIDER /usr/local/lib/sk-libfido2.dylib

# GPG
set -gx GPG_TTY (tty)

# ll comand
if type -q exa
  alias ll "exa -lah -g --icons"
  alias lla "ll -a"
end

alias ls "exa"
alias tree "exa --tree"
alias cat "bat"
# Go Path
set -x PATH $PATH $HOME/go/bin

#LIBVIRT
set -gx LIBVIRT_DEFAULT_URI qemu:///system

#Snap
set -x PATH $PATH /var/lib/snapd/snap/bin


# Set Kubeconfig
set -gx KUBECONFIG (echo (find ~/.kube -type f -name config.\*.yaml) | sed 's/[[:space:]]/:/g')


# Alias
alias vim 'nvim'
#alias pbcopy 'xsel --clipboard --input'
#alias pbpaste 'xsel --clipboard --output'
alias ns 'kubens'
alias kx 'kubectx'
alias gpb 'git checkout -'

# Kubernetes Abbreviations
alias k "kubectl"
alias kd 'kubectl describe'
alias kdno 'kubectl describe nodes'
alias kdns 'kubectl describe namespaces'
alias kdpo 'kubectl describe pods'
alias kex 'kubectl exec -i -t'
alias kg 'kubectl get'
alias kga 'kubectl get all'
alias kgd 'kubectl get deploy'
alias kgi 'kubectl get ingress'
alias kgno 'kubectl get nodes'
alias kgns 'kubectl get namespaces'
alias kgow 'kubectl get -o=wide'
alias kgoy 'kubectl get -o=yaml'
alias kgpo 'kubectl get pods'
alias kgs 'kubectl get service'
alias klo 'kubectl logs -f'
alias kp 'kubectl proxy'
alias krm 'kubectl delete'
alias krmpo 'kubectl delete pods'
alias kap 'kubectl apply -f'
alias kdel 'kubectl delete'

# System Abbreviations
abbr orphans "sudo pacman -Rns (pacman -Qtdq) $argv"
abbr p "sudo pacman"
abbr pacins "sudo pacman -S"
abbr pacup "sudo pacman -Syu"
abbr aurup "yay -Syua"
abbr ss "sudo systemctl"
abbr sdn "sudo shutdown -h now"
abbr lsp "sudo pacman -Qett --color=always | less"

# The rest of my fun git abbres
abbr gpl "git pull --no-rebase"
abbr gpm "git push origin main"
abbr gl "git pull --prune"
abbr glog "git log --graph --pretty=format:'%Cred%h%Creset %an: %s - %Creset %C(yellow)%d%Creset %Cgreen(%cr)%Creset' --abbrev-commit --date=relative"
abbr gp "git push"
abbr gpu "git push -u origin"

# Remove `+` and `-` from start of diff lines; just rely upon color.
abbr gd 'git diff --color | sed "s/^\([^-+ ]*\)[-+ ]/\\1/" | less -r'

#abbr gc "git commit"
abbr gca "git commit -a"
abbr gco "git checkout"
abbr gnb "git checkout -b"
abbr gcb "git copy-branch-name"
abbr gb "git branch"
abbr gs "git status -sb" # upgrade your git if -sb breaks for you. it's fun.
abbr gac "git add -A && git commit"
