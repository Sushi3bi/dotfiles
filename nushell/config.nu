# env
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
  $env.config = ($env.config | upsert hooks.env_change.PWD {
      [{
              condition: {|before, after| [.nvmrc .node-version] | path exists | any { |it| $it }}
	      code: {|before, after|
                if ('FNM_DIR' in $env) {
	          fnm use # Personally I prefer to use fnm --log-level=quiet use
		}
	      }
	  }]
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
  | append $env.CARGO_PATH
  | append $env.USR_BIN
  | append $env.DOT_NET
  | append $env.JDK
  | append $"(pyenv root)/shims"
  | uniq)

$env.PYENV_ROOT = "~/.pyenv" | path expand
if (( $"($env.PYENV_ROOT)/bin" | path type ) == "dir") {
  $env.PATH = $env.PATH | prepend $"($env.PYENV_ROOT)/bin" }
$env.PATH = $env.PATH | prepend $"(pyenv root)/shims"

# todo set into private file
$env.OPENAI_API_KEY = (do { security find-generic-password -w -s 'OPEN_API' -a 'ACCESS_KEY'} | complete).stdout
$env.HOMEBREW_GITHUB_API_TOKEN = (do { security find-generic-password -w -s 'GITHUB' -a 'HOMEBREW_GITHUB_API_TOKEN' } | complete).stdout


$env.EDITOR = "nvim"
$env.VISUAL = "zed"


# config
$env.config.buffer_editor = "nvim"
$env.config.show_banner = false

source ~/.cache/starship/init.nu

$env.TRANSIENT_PROMPT_COMMAND = ^starship module character
$env.TRANSIENT_PROMPT_INDICATOR = ""
$env.TRANSIENT_PROMPT_INDICATOR_VI_INSERT = ""
$env.TRANSIENT_PROMPT_INDICATOR_VI_NORMAL = ""
$env.TRANSIENT_PROMPT_MULTILINE_INDICATOR = ""

$env.TRANSIENT_PROMPT_COMMAND_RIGHT = { ||
    (
        ^/opt/homebrew/bin/starship module time
    )
}

source ~/.config/broot/launcher/nushell/br
$env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'
source ~/.cache/carapace/init.nu
source ~/.zoxide.nu
