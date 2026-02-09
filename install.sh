#!/usr/bin/env bash

# install.sh — Deploy despicable-agents to ~/.claude/agents/
#
# Usage:
#   ./install.sh         # install (create symlinks)
#   ./install.sh install # install (create symlinks)
#   ./install.sh uninstall # remove symlinks created by this project

set -euo pipefail

# Determine script directory (absolute path)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Target directory for Claude Code agents
AGENTS_DIR="${HOME}/.claude/agents"

# Color output for better readability
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[0;33m'
COLOR_RED='\033[0;31m'
COLOR_RESET='\033[0m'

# Print colored message
print_msg() {
  local color="$1"
  local message="$2"
  echo -e "${color}${message}${COLOR_RESET}"
}

# Install agents by creating symlinks
install_agents() {
  print_msg "$COLOR_GREEN" "Installing despicable-agents to ${AGENTS_DIR}/"

  # Create agents directory if it doesn't exist
  if [[ ! -d "$AGENTS_DIR" ]]; then
    mkdir -p "$AGENTS_DIR"
    print_msg "$COLOR_YELLOW" "Created directory: ${AGENTS_DIR}"
  fi

  local installed_count=0

  # Install gru
  if [[ -f "${SCRIPT_DIR}/gru/AGENT.md" ]]; then
    ln -sf "${SCRIPT_DIR}/gru/AGENT.md" "${AGENTS_DIR}/gru.md"
    print_msg "$COLOR_GREEN" "  ✓ gru.md"
    ((installed_count++))
  fi

  # Install nefario
  if [[ -f "${SCRIPT_DIR}/nefario/AGENT.md" ]]; then
    ln -sf "${SCRIPT_DIR}/nefario/AGENT.md" "${AGENTS_DIR}/nefario.md"
    print_msg "$COLOR_GREEN" "  ✓ nefario.md"
    ((installed_count++))
  fi

  # Install all minions
  for agent_file in "${SCRIPT_DIR}"/minions/*/AGENT.md; do
    if [[ -f "$agent_file" ]]; then
      # Extract minion name from path (e.g., minions/edge-minion/AGENT.md -> edge-minion)
      local minion_name
      minion_name=$(basename "$(dirname "$agent_file")")
      ln -sf "$agent_file" "${AGENTS_DIR}/${minion_name}.md"
      print_msg "$COLOR_GREEN" "  ✓ ${minion_name}.md"
      ((installed_count++))
    fi
  done

  print_msg "$COLOR_GREEN" "\nInstalled ${installed_count} agents successfully."
}

# Uninstall agents by removing symlinks
uninstall_agents() {
  print_msg "$COLOR_YELLOW" "Uninstalling despicable-agents from ${AGENTS_DIR}/"

  local removed_count=0

  # Remove gru
  if [[ -L "${AGENTS_DIR}/gru.md" ]]; then
    # Verify it points to our project before removing
    local target
    target=$(readlink "${AGENTS_DIR}/gru.md")
    if [[ "$target" == "${SCRIPT_DIR}/gru/AGENT.md" ]]; then
      rm "${AGENTS_DIR}/gru.md"
      print_msg "$COLOR_YELLOW" "  ✗ gru.md"
      ((removed_count++))
    fi
  fi

  # Remove nefario
  if [[ -L "${AGENTS_DIR}/nefario.md" ]]; then
    local target
    target=$(readlink "${AGENTS_DIR}/nefario.md")
    if [[ "$target" == "${SCRIPT_DIR}/nefario/AGENT.md" ]]; then
      rm "${AGENTS_DIR}/nefario.md"
      print_msg "$COLOR_YELLOW" "  ✗ nefario.md"
      ((removed_count++))
    fi
  fi

  # Remove all minions
  for agent_file in "${SCRIPT_DIR}"/minions/*/AGENT.md; do
    if [[ -f "$agent_file" ]]; then
      local minion_name
      minion_name=$(basename "$(dirname "$agent_file")")
      local symlink="${AGENTS_DIR}/${minion_name}.md"

      if [[ -L "$symlink" ]]; then
        # Verify it points to our project before removing
        local target
        target=$(readlink "$symlink")
        if [[ "$target" == "$agent_file" ]]; then
          rm "$symlink"
          print_msg "$COLOR_YELLOW" "  ✗ ${minion_name}.md"
          ((removed_count++))
        fi
      fi
    fi
  done

  if [[ $removed_count -eq 0 ]]; then
    print_msg "$COLOR_YELLOW" "\nNo agents were installed (nothing to remove)."
  else
    print_msg "$COLOR_YELLOW" "\nRemoved ${removed_count} agents successfully."
  fi
}

# Main script logic
main() {
  local action="${1:-install}"

  case "$action" in
    install)
      install_agents
      ;;
    uninstall)
      uninstall_agents
      ;;
    *)
      print_msg "$COLOR_RED" "Unknown command: $action"
      echo ""
      echo "Usage:"
      echo "  $0 install   — create symlinks to ~/.claude/agents/ (default)"
      echo "  $0 uninstall — remove symlinks from ~/.claude/agents/"
      exit 1
      ;;
  esac
}

main "$@"
