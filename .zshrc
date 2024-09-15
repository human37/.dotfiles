# add asdf
. /opt/homebrew/opt/asdf/libexec/asdf.sh

# add starship
eval "$(starship init zsh)"

# add zioxide
eval "$(zoxide init zsh)"

# load in aliases
source ~/.dotfiles/alias.sh

# load secrets into env
source ~/.dotfiles/secrets.sh

# source all scripts in the .dotfiles directory
for script in ~/.dotfiles/scripts/*.sh; do
  source "$script"
done
