# Detect if the site is active.
function isSite() {
  echo "$(a2query -s | awk '{print $1}' | egrep "^$1$")"
}
