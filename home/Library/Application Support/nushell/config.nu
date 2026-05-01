$env.config = ($env.config | merge {
  show_banner: false
})

export-env {
  $env.STARSHIP_SHELL = "nu"
  $env.PROMPT_SHELL_TAG = "nu"
  load-env {
    STARSHIP_SESSION_KEY: (random chars -l 16)
    PROMPT_MULTILINE_INDICATOR: (^/opt/homebrew/bin/starship prompt --continuation)
    PROMPT_INDICATOR: ""
    PROMPT_COMMAND: {||
      let cmd_duration = if $env.CMD_DURATION_MS == "0823" { 0 } else { $env.CMD_DURATION_MS }
      (^/opt/homebrew/bin/starship prompt --cmd-duration $cmd_duration $"--status=($env.LAST_EXIT_CODE)" --terminal-width (term size).columns ...(
        if (which "job list" | where type == built-in | is-not-empty) {
          ["--jobs", (job list | length)]
        } else {
          []
        }
      ))
    }
    PROMPT_COMMAND_RIGHT: {||
      let cmd_duration = if $env.CMD_DURATION_MS == "0823" { 0 } else { $env.CMD_DURATION_MS }
      (^/opt/homebrew/bin/starship prompt --right --cmd-duration $cmd_duration $"--status=($env.LAST_EXIT_CODE)" --terminal-width (term size).columns ...(
        if (which "job list" | where type == built-in | is-not-empty) {
          ["--jobs", (job list | length)]
        } else {
          []
        }
      ))
    }
  }
}
