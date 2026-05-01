$env.EDITOR = "nvim"
$env.HOMEBREW_NO_ENV_HINTS = "1"
$env._ZO_FZF_OPTS = "--height=40% --layout=reverse --border --info=inline"
$env._ZO_RESOLVE_SYMLINKS = "1"

let homebrew_bin = "/opt/homebrew/bin"
if ($env.PATH | where {|entry| $entry == $homebrew_bin } | is-empty) {
  $env.PATH = ($env.PATH | prepend $homebrew_bin)
}

let go_bin = ($env.HOME | path join "go" "bin")
if ($go_bin | path exists) and ($env.PATH | where {|entry| $entry == $go_bin } | is-empty) {
  $env.PATH = ($env.PATH | prepend $go_bin)
}
