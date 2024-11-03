# Nushell Environment Config File
#
# version = "0.98.0"

def create_left_prompt [] {
    let dir = match (do --ignore-shell-errors { $env.PWD | path relative-to $nu.home-path }) {
        null => $env.PWD
        '' => '~'
        $relative_pwd => ([~ $relative_pwd] | path join)
    }

    let path_color = (if (is-admin) { ansi red_bold } else { ansi green_bold })
    let separator_color = (if (is-admin) { ansi light_red_bold } else { ansi light_green_bold })
    let path_segment = $"($path_color)($dir)(ansi reset)"

    $path_segment | str replace --all (char path_sep) $"($separator_color)(char path_sep)($path_color)"
}

def create_right_prompt [] {
    # create a right prompt in magenta with green separators and am/pm underlined
    let time_segment = ([
        (ansi reset)
        (ansi magenta)
        (date now | format date '%x %X') # try to respect user's locale
    ] | str join | str replace --regex --all "([/:])" $"(ansi green)${1}(ansi magenta)" |
        str replace --regex --all "([AP]M)" $"(ansi magenta_underline)${1}")

    let last_exit_code = if ($env.LAST_EXIT_CODE != 0) {([
        (ansi rb)
        ($env.LAST_EXIT_CODE)
    ] | str join)
    } else { "" }

    ([$last_exit_code, (char space), $time_segment] | str join)
}

# Use nushell functions to define your right and left prompt
$env.PROMPT_COMMAND = {|| create_left_prompt }
# FIXME: This default is not implemented in rust code as of 2023-09-08.
$env.PROMPT_COMMAND_RIGHT = {|| create_right_prompt }

# The prompt indicators are environmental variables that represent
# the state of the prompt
$env.PROMPT_INDICATOR = {|| "> " }
$env.PROMPT_INDICATOR_VI_INSERT = {|| ": " }
$env.PROMPT_INDICATOR_VI_NORMAL = {|| "> " }
$env.PROMPT_MULTILINE_INDICATOR = {|| "::: " }

# If you want previously entered commands to have a different prompt from the usual one,
# you can uncomment one or more of the following lines.
# This can be useful if you have a 2-line prompt and it's taking up a lot of space
# because every command entered takes up 2 lines instead of 1. You can then uncomment
# the line below so that previously entered commands show with a single `🚀`.
# $env.TRANSIENT_PROMPT_COMMAND = {|| "🚀 " }
# $env.TRANSIENT_PROMPT_INDICATOR = {|| "" }
# $env.TRANSIENT_PROMPT_INDICATOR_VI_INSERT = {|| "" }
# $env.TRANSIENT_PROMPT_INDICATOR_VI_NORMAL = {|| "" }
# $env.TRANSIENT_PROMPT_MULTILINE_INDICATOR = {|| "" }
# $env.TRANSIENT_PROMPT_COMMAND_RIGHT = {|| "" }

# Specifies how environment variables are:
# - converted from a string to a value on Nushell startup (from_string)
# - converted from a value back to a string when running external commands (to_string)
# Note: The conversions happen *after* config.nu is loaded
$env.ENV_CONVERSIONS = {
    "PATH": {
        from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
    "Path": {
        from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
}

# Directories to search for scripts when calling source or use
# The default for this is $nu.default-config-dir/scripts
$env.NU_LIB_DIRS = [
    ($nu.default-config-dir | path join 'scripts') # add <nushell-config-dir>/scripts
    ($nu.data-dir | path join 'completions') # default home for nushell completions
]

# Directories to search for plugin binaries when calling register
# The default for this is $nu.default-config-dir/plugins
$env.NU_PLUGIN_DIRS = [
    ($nu.default-config-dir | path join 'plugins') # add <nushell-config-dir>/plugins
]

# To add entries to PATH (on Windows you might use Path), you can use the following pattern:
# $env.PATH = ($env.PATH | split row (char esep) | prepend '/some/path')
# An alternate way to add entries to $env.PATH is to use the custom command `path add`
# which is built into the nushell stdlib:
# use std "path add"
# $env.PATH = ($env.PATH | split row (char esep))
# path add /some/path
# path add ($env.CARGO_HOME | path join "bin")
# path add ($env.HOME | path join ".local" "bin")
# $env.PATH = ($env.PATH | uniq)

# To load from a custom file you can use:
# source ($nu.default-config-dir | path join 'custom.nu')


$env.RANCHER_DESKTOP_PATH = '~/.rd/bin'
$env.CARGO_PATH = '~/.cargo/bin'
$env.USR_BIN = '/usr/local/bin/'
$env.DOT_NET = '/usr/local/share/dotnet/'
$env.MONO_PATH = '/Library/Frameworks/Mono.framework/Versions/Current/bin/'
$env.JDK = '/opt/homebrew/opt/openjdk/bin'
$env.CPPFLAGS = '-I/opt/homebrew/opt/openjdk/include'
$env.NODE_EXTRA_CA_CERTS = '/System/Volumes/Data/opt/homebrew/etc/ca-certificates/cert.pem'
$env.LT_LOAD_ONLY = 'en,uk,ja'

$env.PATH = ($env.PATH | split row (char esep)
    | prepend '/opt/homebrew/bin'
    | prepend '/opt/homebrew/sbin'
    | prepend '~/.cargo/bin'
    | uniq)

#load-env (fnm env --shell bash | lines | str replace 'export ' '' | str replace -a '"' '' | split column = | rename name value | where name != "FNM_ARCH" and name != "PATH" | reduce -f {} {|it, acc| $acc | upsert $it.name $it.value })

load-env (/opt/homebrew/bin/brew shellenv
    | lines
    | str replace 'export ' ''
    | str replace -a '"' ''
    | split column '='
    | rename name value
    | where name != "PATH"
    | reduce -f {} {|it, acc| $acc | upsert $it.name $it.value }
)

export-env {
  $env.config = ($env.config | upsert hooks {
      env_change: {
          PWD: ($env.config.hooks.env_change.PWD ++
            [{
              condition: {|before, after| [.nvmrc .node-version] | path exists | any { |it| $it }}
	      code: {|before, after|
                if ('FNM_DIR' in $env) {
	          fnm use # Personally I prefer to use fnm --log-level=quiet use
		}
	      }
	  }]
        )
      }
  })
}


if not (which fnm | is-empty) {
  ^fnm env --json | from json | load-env
  # Checking `Path` for Windows
  let path = if 'Path' in $env { $env.Path } else { $env.PATH }
  let node_path = $"($env.FNM_MULTISHELL_PATH)/bin"
  $env.PATH = ($path | prepend [ $node_path ])
}

$env.PATH = ($env.PATH | split row (char esep)
  | append $"($env.FNM_MULTISHELL_PATH)/bin"
  | append $env.RANCHER_DESKTOP_PATH
  | append $env.CARGO_PATH
  | append $env.USR_BIN
  | append $env.DOT_NET
  | append $env.JDK
  | append $"(pyenv root)/shims"
  | uniq)

# todo set into private file
$env.OPENAI_API_KEY = (do { security find-generic-password -w -s 'OPEN_API' -a 'ACCESS_KEY'} | complete).stdout
$env.HOMEBREW_GITHUB_API_TOKEN = (do { security find-generic-password -w -s 'GITHUB' -a 'HOMEBREW_GITHUB_API_TOKEN' } | complete).stdout



$env.EDITOR = "nvim"
$env.VISUAL = "code"
