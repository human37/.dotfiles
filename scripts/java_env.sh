# set java home
. ~/.asdf/plugins/java/set-java-home.zsh

# add java to path
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"

# add lombok to nvim jdtls
export JDTLS_JVM_ARGS="-javaagent:$HOME/.local/share/java/lombok.jar -Dosgi.sharedConfiguration.area=/Users/ammon/.local/share/nvim/mason/packages/jdtls/config_mac_arm -Dosgi.sharedConfiguration.area.readOnly=true"
