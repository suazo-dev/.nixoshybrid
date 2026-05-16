$env.GOPATH = "/opt/go"

let path_additions = [
  ($env.HOME | path join ".local" "bin")
  "/usr/local/bin"
  ($env.HOME | path join ".pixi" "bin")
  "/home/suazo/.pixi/bin"
  ($env.GOPATH | path join "bin")
  ($env.HOME | path join ".cargo" "bin")
  ($env.HOME | path join ".opencode" "bin")
  "/home/suazo/.opencode/bin"
]

$env.PATH = ($path_additions ++ $env.PATH | uniq)

$env.EDITOR = "nvim"
$env.VISUAL = "nvim"
$env.GIT_EDITOR = "nvim"
$env.SUDO_EDITOR = "nvim"
$env.STARSHIP_CONFIG = ($env.HOME | path join ".config" "starship.toml")
