# Default Nushell Environment Config File
# These "sensible defaults" are set before the user's `env.nu` is loaded
#
# version = "0.101.1"

$env.PROMPT_COMMAND = $env.PROMPT_COMMAND? | default {||
    let dir = match (do -i { $env.PWD | path relative-to $nu.home-path }) {
        null => $env.PWD
        '' => '~'
        $relative_pwd => ([~ $relative_pwd] | path join)
    }

    let path_color = (if (is-admin) { ansi red_bold } else { ansi green_bold })
    let separator_color = (if (is-admin) { ansi light_red_bold } else { ansi light_green_bold })
    let path_segment = $"($path_color)($dir)(ansi reset)"

    $path_segment | str replace --all (char path_sep) $"($separator_color)(char path_sep)($path_color)"
}

$env.PROMPT_COMMAND_RIGHT = $env.PROMPT_COMMAND_RIGHT? | default {||
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

# custom
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
