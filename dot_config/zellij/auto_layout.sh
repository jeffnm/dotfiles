#!/bin/bash

# Auto-select zellij layout based on current directory
# Usage: source this file in your .zshrc or .bashrc
# Then use 'zj' command to start zellij with the appropriate layout

# Helper function to detect the appropriate layout for a directory
detect_layout() {
  local DIR="$1"
  local LAYOUT=""
  
  # Save current directory to return to it later
  local CURRENT_DIR=$(pwd)
  
  # Change to the target directory temporarily to check its contents
  cd "$DIR" 2>/dev/null || return 1
  
  # Debug information
  echo "Detecting layout for directory: $DIR" >&2
  
  # Check if we're in a chezmoi directory
  if [[ "$DIR" == *".local/share/chezmoi"* ]] || [[ "$DIR" == *"dotfiles"* ]]; then
    LAYOUT="dotfiles"
    echo "Detected layout: dotfiles" >&2
  
  # Check for SaltStack projects
  elif [[ -d "salt" && -d "pillar" ]] || [[ -f "Saltfile" ]] || [[ -d "srv/salt" ]] || [[ "$DIR" == *"salt"* ]]; then
    LAYOUT="salt"
    echo "Detected layout: salt" >&2
  
  # Check for notes directories - more comprehensive detection
  elif [[ "$DIR" == *"/notes"* ]] || [[ "$DIR" == *"/Notes"* ]] || [[ "$(basename "$DIR")" == "notes" ]] || [[ "$(basename "$DIR")" == "Notes" ]]; then
    LAYOUT="notes"
    echo "Detected layout: notes" >&2
  
  # Check for development projects with common patterns
  elif [[ -f "package.json" ]] || [[ -f "Cargo.toml" ]] || [[ -d ".git" && -f "Makefile" ]]; then
    LAYOUT="dev"
    echo "Detected layout: dev" >&2
  
  # Default to project layout for other directories with .git
  elif [[ -d ".git" ]]; then
    LAYOUT="project"
    echo "Detected layout: project" >&2
  else
    echo "No specific layout detected, using default" >&2
  fi
  
  # Return to original directory
  cd "$CURRENT_DIR"
  
  echo "$LAYOUT"
}

# Helper function to strip ANSI color codes from text
strip_colors() {
  # Remove ANSI escape sequences (color codes)
  sed 's/\x1B\[[0-9;]*[JKmsu]//g'
}

# Function to get clean list of sessions
get_sessions() {
  # Get sessions and strip color codes
  zellij list-sessions | strip_colors
}

# Function to check if a session exists
session_exists() {
  local SESSION_NAME="$1"
  # Get clean session list and check for exact match
  get_sessions | grep -q "^${SESSION_NAME}[[:space:]]"
  return $?
}

# Main function to manage zellij sessions
zj() {
  local TARGET_DIR="${1:-.}"
  local ABS_TARGET_DIR=$(cd "$TARGET_DIR" 2>/dev/null && pwd)
  
  if [[ -z "$ABS_TARGET_DIR" ]]; then
    echo "Error: Directory '$TARGET_DIR' does not exist"
    return 1
  fi
  
  local SESSION_NAME=$(basename "$ABS_TARGET_DIR")
  local LAYOUT=$(detect_layout "$ABS_TARGET_DIR")
  
  echo "Target directory: $ABS_TARGET_DIR" >&2
  echo "Session name: $SESSION_NAME" >&2
  echo "Selected layout: $LAYOUT" >&2
  
  # Check if already in a zellij session
  if [[ -n "$ZELLIJ" ]]; then
    # If already in a session, add a new tab with the layout if specified
    if [[ -n "$LAYOUT" ]]; then
      echo "Adding new tab with layout: $LAYOUT" >&2
      zellij action new-tab --layout "$LAYOUT"
    else
      echo "Adding new tab with default layout" >&2
      zellij action new-tab
    fi
    return 0
  fi
  
  # Check if session already exists
  if session_exists "$SESSION_NAME"; then
    echo "Attaching to existing session: $SESSION_NAME" >&2
    zellij attach "$SESSION_NAME"
  else
    # Start a new session with the layout and a meaningful name
    echo "Creating new session: $SESSION_NAME" >&2
    if [[ -n "$LAYOUT" ]]; then
      echo "Using layout: $LAYOUT" >&2
      # Use --new-session-with-layout to create a new session with the layout
      (cd "$ABS_TARGET_DIR" && zellij --new-session-with-layout "$LAYOUT" --session "$SESSION_NAME")
    else
      echo "Using default layout" >&2
      # Just create a new session with the default layout
      (cd "$ABS_TARGET_DIR" && zellij --session "$SESSION_NAME")
    fi
  fi
}

# Function to list and select a session to attach to
zjs() {
  local SESSIONS=$(get_sessions)
  
  if [[ -z "$SESSIONS" ]]; then
    echo "No active sessions"
    return 1
  fi
  
  # If fzf is available, use it for interactive selection
  if command -v fzf >/dev/null 2>&1; then
    local SELECTED=$(echo "$SESSIONS" | fzf --height 40% --reverse --header="Select a session to attach to:")
    if [[ -n "$SELECTED" ]]; then
      # Extract just the session name (first word)
      local SESSION_NAME=$(echo "$SELECTED" | awk '{print $1}')
      echo "Attaching to session: $SESSION_NAME"
      zellij attach "$SESSION_NAME"
    fi
  else
    # Simple numbered menu if fzf is not available
    echo "Available sessions:"
    local i=1
    local SESSION_NAMES=()
    
    while IFS= read -r line; do
      echo "[$i] $line"
      # Extract just the session name (first word)
      SESSION_NAMES+=("$(echo "$line" | awk '{print $1}')")
      ((i++))
    done <<< "$SESSIONS"
    
    echo -n "Enter session number to attach to [1-$((i-1))]: "
    read -r choice
    
    if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice < i )); then
      local SESSION_NAME="${SESSION_NAMES[$((choice-1))]}"
      echo "Attaching to session: $SESSION_NAME"
      zellij attach "$SESSION_NAME"
    else
      echo "Invalid selection"
      return 1
    fi
  fi
}

# Function to attach to existing session or create a new one with auto layout
zja() {
  local SESSIONS=$(get_sessions)
  
  if [[ -z "$SESSIONS" ]]; then
    # No sessions exist, create a new one
    zj
  else
    # Sessions exist, let user select one
    zjs
  fi
}

# Function to create a new session with auto layout using zoxide to find the intended directory
zji() {
  # Store the current directory
  local ORIGINAL_DIR=$(pwd)
  
  # Run zi which will change the current directory
  zi
  
  # Get the new current directory
  local TARGET_DIR=$(pwd)
  
  # Only run zj if we actually changed directories
  if [[ "$TARGET_DIR" != "$ORIGINAL_DIR" ]]; then
    zj "$TARGET_DIR"
  else
    echo "No directory selected with zoxide"
  fi
  
  # Return to the original directory
  cd "$ORIGINAL_DIR"
}
