# Aliases
source ~/.zsh_aliases

# Plugin Paths
fpath+=~/.zsh/plugins/zsh-completions

# Load Plugins
source ~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
autoload -Uz compinit && compinit

# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# Ctrl + Arrrows
bindkey "^[[1;5D" backward-word
bindkey "^[[1;5C" forward-word

eval "$(starship init zsh)"
