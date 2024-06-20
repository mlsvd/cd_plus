# cd_plus
`cd_plus` is a bash script that enhances directory navigation by allowing you to save and quickly navigate to bookmarked directories using intuitive shortcuts.

# Features
- Bookmarking: Save current directory with a custom shortcut name.
- Navigation: Quickly switch to bookmarked directories using simple commands.
- User-Friendly Interface: Choose directories interactively with a menu (via dialog or select).

![Script showcase](assets/example.gif)

# Installation
1. Download cd_plus.sh script or clone the repository:
```bash
git clone https://github.com/mlsvd/cd_plus.git
```
2. Adding as an Alias (Optional but recommended)

- Open your shell configuration file using a text editor:
```bash
nano ~/.bashrc
```
- Add the following line at the end of the file:
```bash
alias cd+='/path/to/cd_plus.sh'
```
- Save and close the file. Then, reload the shell configuration:
```bash
source ~/.bashrc
```

# Usage
## Saving Bookmarks
Navigate into directory, which needs to be bookmarked and execute cd_plus script with following arguments: `save <shortcut name>`:

```bash
cd /home/user/custom-directory
cd+ save "custom-shortcut"
```
of in case when alias is not configured:
```bash
cd /home/user/custom-directory
./path/to/cd_plus.sh save "custom-shortcut"
```

## Navigating to Bookmarks
Simply run the script without any arguments to select and navigate to a bookmarked directory.
```bash
cd+
```
of in case when alias is not configured:
```bash
./path/to/cd_plus.sh
```
A list of bookmarks will be displayed. If `dialog` lib is installed in the system, the list will be rendered using dialog lib.

## Manual Bookmark Modification
The bookmarks file ($HOME/.cd_plus_bookmarks) can be modified manually by the user to add, remove, or edit bookmarks directly.

# Dependencies
`dialog` (optional): Used for interactive menu (install with sudo apt-get install dialog on Debian-based systems).

If dialog is not available, bookmarks are listed using the select command.

Each bookmark is stored in $HOME/.cd_plus_bookmarks in the format <shortcut>|<directory>.

# License
This project is licensed under the MIT License. See the [LICENSE](LICENSE.md) file for details.

