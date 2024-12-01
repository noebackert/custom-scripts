#!/bin/bash

#### Make a backup of the .bashrc file
echo "Making backup of .bashrc ..."
cp ~/.bashrc ~/.bashrc.bak
echo "Done"

if ! command -v tmux &>/dev/null; then
    echo "Installing tmux ..."
    sudo apt install -y tmux
fi


if dpkg -s xclip &>/dev/null; then
  echo "xclip is already installed."
else
echo "Installing xclip ..."
sudo apt install -y xclip
fi
echo "Done"

#### Customize bash prompt
echo "Exporting .bashrc conf ..."
if ! grep -qxF 'export PS1="-[\[$(tput sgr0)\]\[\033[38;5;10m\]\d\[$(tput sgr0)\]-\[$(tput sgr0)\]\[\033[38;5;10m\]\t\[$(tput sgr0)\]]-[\[$(tput sgr0)\]\[\033[38;5;214m\]\u\[$(tput sgr0)\]@\[$(tput sgr0)\]\[\033[38;5;196m\]\h\[$(tput sgr0)\]]-\n-[\[$(tput sgr0)\]\[\033[38;5;33m\]\w\[$(tput sgr0)\]]\\$ \[$(tput sgr0)\]"' ~/.bashrc; then
echo 'export PS1="-[\[$(tput sgr0)\]\[\033[38;5;10m\]\d\[$(tput sgr0)\]-\[$(tput sgr0)\]\[\033[38;5;10m\]\t\[$(tput sgr0)\]]-[\[$(tput sgr0)\]\[\033[38;5;214m\]\u\[$(tput sgr0)\]@\[$(tput sgr0)\]\[\033[38;5;196m\]\h\[$(tput sgr0)\]]-\n-[\[$(tput sgr0)\]\[\033[38;5;33m\]\w\[$(tput sgr0)\]]\\$ \[$(tput sgr0)\]"' >> ~/.bashrc
else 
echo ".bashrc already configured"
fi
echo "Done"

#### Clone Tmux-logging plugin
echo "Cloning Tmux-logging plugin..."
if [ ! -d "/opt/tmux-logging" ]; then
    sudo git clone https://github.com/tmux-plugins/tmux-logging.git /opt/tmux-logging
else
    echo "Tmux-logging plugin already exists. Skipping clone."
fi
echo "Done"

#### Export config of /etc/tmux.conf
echo "Exporting config of /etc/tmux.conf ..."
sudo bash -c 'cat <<EOF > /etc/tmux.conf
# Remap prefix to screens
set -g prefix C-a 
bind C-a send-prefix
unbind C-b

# Quality of line stuff
set -g history-limit 100000
set -g allow-rename off

set -g mouse on


# Copy selection to clipboard with Ctrl+C
bind-key -T copy-mode-vi C-c send -X copy-pipe-and-cancel "xclip -selection clipboard -i"
bind-key -T copy-mode-vi Enter send -X copy-pipe-and-cancel "xclip -selection clipboard -i"

## Join Windows
bind-key j command-prompt -p "join pane from:"  "join-pane -s '\''%%'\''"
bind-key s command-prompt -p "send pane to:"  "join-pane -t '\''%%'\''"


# Search Mode VI (default is emacs)
set-window-option -g mode-keys vi

set-option -g default-command "bash -l"

run-shell /opt/tmux-logging/logging.tmux
EOF'
echo "Done"

#### Config of .bash_profile
echo "Config of .bash_profile ..."
if ! grep -qxF 'if [ -f ~/.bashrc ]; then source ~/.bashrc; fi' ~/.bash_profile; then
    echo "if [ -f ~/.bashrc ]; then source ~/.bashrc; fi" >> ~/.bash_profile
else
echo ".bash_profile already configured"
fi
echo "Done"

#### Apply changes
echo "Reloading Bash and Tmux configurations..."
source ~/.bashrc
tmux source-file /etc/tmux.conf || echo "Tmux not running. Please restart Tmux to apply changes."
echo "Done"
