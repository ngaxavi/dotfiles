# Path to Oh My Fish install.
set -gx OMF_PATH "/home/username/.local/share/omf"

# Customize Oh My Fish configuration path.
#set -gx OMF_CONFIG "/home/username/.config/omf"

# Load oh-my-fish configuration.
source $OMF_PATH/init.fish


# Base16 Shell
# Check base16 on github
eval sh $HOME/.config/base16-shell/base16-default.dark.sh

# Path
#set -U fish_user_paths $fish_user_paths /usr/lib/python3.5/site-packages/powerline

# Powerline
#set fish_function_path $fish_function_path "/usr/lib/python3.5/site-packages/powerline/bindings/fish" powerline-setup

# If not running interactively, do not do anything
#if status --is-interactive
#   if test -z (echo $TMUX)
#	tmux
#   end
#end
