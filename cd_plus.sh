#!/bin/bash

BOOKMARKS_FILE="$HOME/.cd_plus_bookmarks"

# Function to save a bookmark (updates existing entry if name already used)
save_bookmark() {
  local name="$1"
  local dir="$PWD"

  if [ -f "$BOOKMARKS_FILE" ]; then
    local tmp
    tmp=$(grep -v "^${name}|" "$BOOKMARKS_FILE")
    printf '%s\n' "$tmp" > "$BOOKMARKS_FILE"
  fi

  echo "$name|$dir" >> "$BOOKMARKS_FILE"
  echo "Bookmark '$name' saved."
}

# Function to delete a bookmark by name
delete_bookmark() {
  local name="$1"

  if [ ! -f "$BOOKMARKS_FILE" ]; then
    echo "No bookmarks file found."
    return 1
  fi

  if ! grep -q "^${name}|" "$BOOKMARKS_FILE"; then
    echo "Bookmark '$name' not found."
    return 1
  fi

  local tmp
  tmp=$(grep -v "^${name}|" "$BOOKMARKS_FILE")
  printf '%s\n' "$tmp" > "$BOOKMARKS_FILE"
  echo "Bookmark '$name' deleted."
}

# Function to list bookmarks using dialog
list_bookmarks_dialog() {
  local options=()
  local i=1
  while IFS= read -r bookmark; do
    [ -z "$bookmark" ] && continue
    options+=("$i" "$bookmark")
    i=$((i + 1))
  done < "$BOOKMARKS_FILE"

  if [ "${#options[@]}" -eq 0 ]; then
    echo "No bookmarks available. Add bookmarks with save argument and shortcut name. Example: [cd+ save \"home\"]"
    return
  fi

  local selection
  selection=$(dialog --menu "Select a directory to navigate:" 22 76 16 "${options[@]}" 3>&1 1>&2 2>&3)
  local exit_status=$?

  if [ "$exit_status" -eq 0 ]; then
    local selected_val="${options[$((selection * 2 - 1))]}"
    local selected_dir="${selected_val#*|}"
    if [ ! -d "$selected_dir" ]; then
      echo "Directory '$selected_dir' no longer exists."
      return 1
    fi
    cd "$selected_dir" || return
    echo "Switched to $selected_dir"
  else
    echo "Cancelled."
  fi
}

# Function to list bookmarks using select
list_bookmarks_select() {
  local options=()
  while IFS= read -r bookmark; do
    [ -z "$bookmark" ] && continue
    options+=("$bookmark")
  done < "$BOOKMARKS_FILE"

  if [ "${#options[@]}" -eq 0 ]; then
    echo "No bookmarks available."
    return
  fi

  PS3="Select a directory to navigate: "
  select opt in "${options[@]}" "Cancel"; do
    if [ "$REPLY" -ge 1 ] 2>/dev/null && [ "$REPLY" -le "${#options[@]}" ] 2>/dev/null; then
      local selected_val="${options[$REPLY-1]}"
      local selected_dir="${selected_val#*|}"
      if [ ! -d "$selected_dir" ]; then
        echo "Directory '$selected_dir' no longer exists."
        break
      fi
      cd "$selected_dir" || return
      echo "Switched to $selected_dir"
      break
    elif [ "$REPLY" -eq "$((${#options[@]} + 1))" ] 2>/dev/null; then
      echo "Cancelled."
      break
    else
      echo "Invalid option."
    fi
  done
}

# Function to list bookmarks and handle navigation
list_bookmarks() {
  if [ ! -f "$BOOKMARKS_FILE" ]; then
    echo "No bookmarks available."
    return
  fi

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
      return 1 2>/dev/null || exit 1
    fi
    save_bookmark "$2"
    ;;
  delete)
    if [ -z "$2" ]; then
      echo "Usage: cd+ delete <shortcut name>"
      return 1 2>/dev/null || exit 1
    fi
    delete_bookmark "$2"
    ;;
  "")
    list_bookmarks
    ;;
  *)
    echo "Unknown command: $1"
    echo "Usage: cd+ [save <name> | delete <name>]"
    return 1 2>/dev/null || exit 1
    ;;
esac
