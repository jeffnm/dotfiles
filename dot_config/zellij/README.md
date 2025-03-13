# Zellij Auto-Layout System

This directory contains custom zellij layouts and an auto-layout system that automatically selects the appropriate layout based on the current directory.

## Available Layouts

- **dev.kdl**: Development layout with editor, terminal, git, files, and monitoring panes
- **dotfiles.kdl**: Specialized layout for working with chezmoi dotfiles
- **notes.kdl**: Layout optimized for note-taking and documentation
- **project.kdl**: General project layout with flexible panes
- **salt.kdl**: SaltStack project layout with specialized Salt and SSH tabs

For other directories, zellij's built-in default layout will be used.

## Layout Templating

The layouts are managed using chezmoi's templating system, which allows for reusing common components across multiple layouts:

- **zellij-git-tab.tmpl**: A shared template for the Git tab that provides a consistent Git interface across all layouts
  - Features a prominent Git Shell pane (60% width) with instructions and Git alias reference
  - Includes Status, Diff, Log, and Branch information panes arranged vertically

To modify layouts:

1. Edit the `.kdl.tmpl` files in the chezmoi source directory
2. Apply changes with `chezmoi apply ~/.config/zellij/layouts/`

To add new shared components:

1. Create a new template in the `.chezmoitemplates` directory
2. Include it in your layouts with `{{ template "template-name.tmpl" . }}`

## Auto-Layout Script

The `auto_layout.sh` script provides several functions to streamline your zellij workflow:

### Main Commands

1. `zj [directory]`: Smart session management
   - If no directory is specified, uses the current directory
   - If a session for the directory already exists, attaches to it
   - Otherwise, creates a new session with the appropriate layout:
     - Uses `dotfiles` layout in chezmoi directories
     - Uses `salt` layout in SaltStack project directories
     - Uses `notes` layout in note-taking directories
     - Uses `dev` layout in directories with package.json, Cargo.toml, or git+Makefile
     - Uses `project` layout in git repositories
     - Uses zellij's built-in default layout elsewhere

2. `zjs`: Interactive session selector
   - Lists all active sessions
   - Allows you to select a session to attach to
   - Uses `fzf` for fuzzy finding if available, otherwise shows a numbered menu

3. `zja`: Attach or create
   - If no sessions exist, creates a new one for the current directory
   - If sessions exist, shows the interactive session selector

## Usage Examples

```bash
# Start/attach to a session for the current directory
zj

# Start/attach to a session for a specific directory
zj ~/projects/my-project

# Select and attach to an existing session
zjs

# Attach to an existing session or create a new one
zja
```

## Layout Details

### Development Layout (dev.kdl)

- **Editor Tab**: Main editor with terminal and build/test panes
- **Terminal Tab**: Multiple shell panes for running commands
- **Files Tab**: File browser using yazi with find and grep helpers
- **Git Tab**:
  - Interactive Git Shell with Git alias reference
  - Status, Diff, Log, and Branch information panes
- **Monitoring Tab**: Process monitoring with htop, disk usage, and network tools

### Project Layout (project.kdl)

- **Project Tab**: Main workspace with secondary and utility panes
- **Terminal Tab**: Multiple shell panes for running commands
- **Files Tab**: File browser using yazi with find and grep helpers
- **Git Tab**:
  - Interactive Git Shell with Git alias reference
  - Status, Diff, Log, and Branch information panes
- **Notes Tab**: Scratch pad for taking notes

### Notes Layout (notes.kdl)

- **Notes Tab**: Main editor with preview and search panes  
- **Files Tab**: File browser with file information and operations
- **References Tab**: Helpful references and tag management tools

### Dotfiles Layout (dotfiles.kdl)

- **Dotfiles Tab**: Editor with auto-refreshing chezmoi status
- **Chezmoi Tab**: Chezmoi diff, managed files, and data
- **Git Tab**:
  - Interactive Git Shell with Git alias reference
  - Status, Diff, Log, and Branch information panes

### SaltStack Layout (salt.kdl)

- **Editor Tab**: Main editor with terminal
- **SSH Tab**: SSH connections to remote servers with Salt command reference
- **Files Tab**: File browser using yazi
- **Git Tab**:
  - Interactive Git Shell with Git alias reference
  - Status, Diff, Log, and Branch information panes

## Custom Directory Rules

The auto-layout system detects the appropriate layout based on directory contents:

- **dotfiles layout**: Used in directories containing `.local/share/chezmoi` or with `dotfiles` in the name
- **salt layout**: Used in directories with `salt` and `pillar` subdirectories, or with `Saltfile`, or with `srv/salt` subdirectory, or with `salt` in the directory name
- **notes layout**: Used in directories with `notes` in the name
- **dev layout**: Used in directories with `package.json`, `Cargo.toml`, or `.git` + `Makefile`
- **project layout**: Used in directories with `.git`
- **default zellij layout**: Used in all other directories

## Customization

To add more layout detection rules, edit the `auto_layout.sh` script and modify the conditions in the `detect_layout()` function.

You can also use zellij's built-in layout switching capabilities with `Ctrl+p` followed by `Space` to cycle through available layouts.
