#!/usr/bin/env bash
set -euo pipefail

TMP_PREFIX="/tmp/hyprland-show-desktop"

workspace_target() {
  local workspace="$1"
  if [[ "$workspace" =~ ^-?[0-9]+$ ]]; then
    printf '%s' "$workspace"
  else
    printf 'name:%s' "$workspace"
  fi
}

toggle_workspace() {
  local workspace="$1"
  local tmp_file="${TMP_PREFIX}-${workspace}"
  local cmds=""
  local tmp_address=""
  local address
  local target

  target="$(workspace_target "$workspace")"

  if [ -f "$tmp_file" ]; then
    mapfile -t ADDRESS_ARRAY < "$tmp_file"
    for address in "${ADDRESS_ARRAY[@]}"; do
      [ -n "$address" ] || continue
      cmds+="dispatch movetoworkspacesilent ${target},address:${address};"
    done
    [ -n "$cmds" ] && hyprctl --batch "$cmds"
    rm -f "$tmp_file"
    return 0
  fi

  mapfile -t ADDRESS_ARRAY < <(
    hyprctl clients -j | jq -r --arg CW "$workspace" '.[] | select(.workspace.name == $CW) | .address'
  )

  for address in "${ADDRESS_ARRAY[@]}"; do
    [ -n "$address" ] || continue
    tmp_address+="${address}"$'\n'
    cmds+="dispatch movetoworkspacesilent special:desktop,address:${address};"
  done

  [ -n "$cmds" ] && hyprctl --batch "$cmds"
  printf "%s" "$tmp_address" | sed -e '/^$/d' > "$tmp_file"
}

if [[ "${1:-}" == "all" ]]; then
  tmp_dir="$(dirname "$TMP_PREFIX")"
  tmp_base="$(basename "$TMP_PREFIX")-"
  mapfile -t RESTORE_FILES < <(
    find "$tmp_dir" -maxdepth 1 -type f -name "${tmp_base}*" 2>/dev/null | sort
  )

  # If there are saved files, restore all of them regardless of current active workspaces.
  if [ "${#RESTORE_FILES[@]}" -gt 0 ]; then
    for file in "${RESTORE_FILES[@]}"; do
      ws="${file#${TMP_PREFIX}-}"
      [ -n "$ws" ] || continue
      toggle_workspace "$ws"
    done
    exit 0
  fi

  # Otherwise hide windows from active workspaces on all monitors.
  mapfile -t WORKSPACES < <(
    hyprctl monitors -j | jq -r '.[].activeWorkspace.name' | awk 'NF && !seen[$0]++'
  )
  [ "${#WORKSPACES[@]}" -gt 0 ] || exit 1
  for ws in "${WORKSPACES[@]}"; do
    toggle_workspace "$ws"
  done
  exit 0
fi

CURRENT_WORKSPACE="$(
  hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .activeWorkspace.name' | head -n1
)"
[ -n "$CURRENT_WORKSPACE" ] || exit 1
toggle_workspace "$CURRENT_WORKSPACE"
