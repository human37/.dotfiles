# set java home
if [ -f ~/.asdf/plugins/java/set-java-home.zsh ]; then
    . ~/.asdf/plugins/java/set-java-home.zsh
fi

# add java to path
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"

# add lombok to nvim jdtls
export JDTLS_JVM_ARGS="-javaagent:$HOME/.local/share/java/lombok.jar -Dosgi.sharedConfiguration.area=/Users/ammon/.local/share/nvim/mason/packages/jdtls/config_mac_arm -Dosgi.sharedConfiguration.area.readOnly=true"
