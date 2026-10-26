{
  system,
  rev,
  version,
  hash,
}:
# 0749024's recorded Darwin hash does not match its updated Bun lockfile tree
# on this host. Unmodified upstream and the concurrency-limited build produce
# the same measured hash. Never carry this correction into another revision.
if
  system
  == "aarch64-darwin"
  && rev == "0749024f0d6f6bb3014850a820d06677b7c37120"
  && version == "2.1.4+0749024"
  && hash == "sha256-TO9ubp4SLWrzWJY1BgDKOy/S8Tcws+Z2k+I6ba/TkWk="
then "sha256-3EGfe+K2yM4atFT70JcwY66i/wFvHPO6/ewiIa2SB5Q="
else hash
