#!/bin/bash

set -e -u

function create_window() {   # name command1 command2 command3
	local name=$1
	local command="$2"
	if ! (tmux list-window -F '#{window_name}' | grep -qx "$name") ; then
		local wid=$( tmux new-window -d -P -n "$name" "$command" )
		shift 2
		while (( "$#" )) ; do
			command="$1"
			tmux split-window -t $wid "$command"
			shift
		done
	fi
}

function session_name() {
	tmux display-message -p "#{session_name}"
}

function vim_server() {
	local session=$(session_name)
	if !(mvim --serverlist | grep -qi "$session") ; then 
		reattach-to-user-namespace mvim --servername "$session"
	fi
}
