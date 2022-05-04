#!/bin/sh

# Define tmux window set up coroutine
layout_window() {
    # If preferred name is not available, derive from path
    BASENAME=$2
    if [ -z "$BASENAME" ]; then
        BASENAME=$(basename $1)
    fi
    tmux new-window -n $BASENAME -c $1     # New window with name at second arg
    
    # Main pane (vim)
    tmux split-window -h -p 75 -c $1 # Horizontal split, new right pane will be for vim
    tmux send-keys "vim" C-m         # First pane is dedicated to vim

    # Side panes
    tmux select-pane -t 0            # Move back to first pane
    # tmux split-window -v -p 66 -c $1 # Vertical split, new bottom pane will be 66% of height
    tmux split-window -v -p 50 -c $1 # Vertical split, new bottom pane will be 50% of 66% -> 33%
    tmux select-pane -t 0            # Move back to first pane
}

# Create a new session, passing in window size info so that window splits will work properly
tmux new-session -d -s 'skymux' -x "$(tput cols)" -y "$(tput lines)"

# TODO: Dynamically generate this list.
# Layout panes for aircams
layout_window ~/aircam ac0
# layout_window ~/aircam1 ac1
# layout_window ~/aircam2 ac2
# layout_window ~/aircam3 ac3

# Clean up unused window
tmux select-window -t ^ 
tmux send-keys "exit" C-m

# Move back to first window
tmux select-window -t 1

# Attach to session
tmux -2 attach-session -d
