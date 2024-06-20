#!/bin/bash

BOOKMARKS_FILE="$HOME/.cd_plus_bookmarks"

# Create bookmarks file if it doesn't exist
if [ ! -f "$BOOKMARKS_FILE" ]; then
  touch "$BOOKMARKS_FILE"
fi

# Function to save a bookmark
save_bookmark() {
  local name="$1"
  local dir="$(pwd)"
  echo "$name|$dir" >> "$BOOKMARKS_FILE"
  echo "Bookmark '$name' saved."
}

# Function to list bookmarks using dialog
list_bookmarks_dialog() {
  local options=()
    local i=1
    while read -r bookmark; do
      options+=("$i" "${bookmark}")
      i=$((i + 1))
    done < "$BOOKMARKS_FILE"

    if [ ${#options[@]} -eq 0 ]; then
      echo "No bookmarks available. Add bookmarks with save argument and shortcut name. Example: [./cd+.sh save \"home\"]"
      return
    fi

    local selection=$(dialog --menu "Select a directory to navigate:" 22 76 16 "${options[@]}" 3>&1 1>&2 2>&3)
    local exit_status=$?

    if [ $exit_status -eq 0 ]; then
      local selected_val="${options[$((selection * 2 - 1))]}"
      local selected_dir=$(echo "${selected_val}" | cut -d'|' -f2)
      cd "$selected_dir" || return
      clear
      echo "Switched to $selected_dir"
    else
      clear
      echo "Cancelled."
    fi
}

# Function to list bookmarks using select
list_bookmarks_select() {
  local options=()
  while read -r bookmark; do
      options+=("${bookmark}")
    done < "$BOOKMARKS_FILE"

  if [ ${#options[@]} -eq 0 ]; then
    echo "No bookmarks available."
    return
  fi

  PS3="Select a directory to navigate: "
    select opt in "${options[@]}" "Cancel"; do
      case "$REPLY" in
        [1-$((${#options[@]}))])
          local selected_val="${options[$REPLY-1]}"
          local selected_dir=$(echo "${selected_val}" | cut -d'|' -f2)
          cd "$selected_dir" || return
          echo "Switched to $selected_dir"
          break
          ;;
        $((${#options[@]} + 1)))
          echo "Cancelled."
          break
          ;;
        *)
          echo "Invalid option."
          ;;
      esac
    done
}

# Function to list bookmarks and handle navigation
list_bookmarks() {
  if command -v dialog &> /dev/null; then
    list_bookmarks_dialog
  else
    list_bookmarks_select
  fi
}

# Main script logic
case "$1" in
  save)
    if [ -z "$2" ]; then
      echo "Usage: cd+ save <shortcut name>"
      exit 1
    fi
    save_bookmark "$2"
    ;;
  *)
    list_bookmarks
    ;;
esac
