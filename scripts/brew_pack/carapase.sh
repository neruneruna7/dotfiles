# シェル補完？ ctrl+spaceで動作する
brew install carapace
mkdir ~/.cache/carapace
carapace _carapace nushell | save --force ~/.cache/carapace/init.nu
nu 