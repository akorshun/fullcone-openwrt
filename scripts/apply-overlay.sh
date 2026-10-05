#!/bin/sh
# Turn the SDK's own base-feed libnftnl, nftables and firewall4 into the
# fullcone-capable builds. Run from the SDK root after `feeds update`.
#
# The patches are ImmortalWrt's, which carries the very same package versions
# as OpenWrt 25.12.5 (libnftnl 1.3.1, nftables 1.1.6, firewall4 b6e51575), so
# they go in unmodified - except firewall4's, which no longer rewrites the
# default /etc/config/firewall: installing these packages must not switch
# anything on by itself.
#
# Each package's PKG_RELEASE is raised by RELEASE_BUMP so that, installed on
# top of an official image, these outrank the base feed and `apk upgrade`
# never swaps them back for the unpatched ones.
set -eu

OVERLAY=${1:?usage: apply-overlay.sh <overlay dir>}
RELEASE_BUMP=${RELEASE_BUMP:-100}

pkgdir() {
	d=$(find feeds/base -maxdepth 3 -type d -name "$1" | head -1)
	[ -n "$d" ] && [ -f "$d/Makefile" ] || { echo "::error::$1 not found in the base feed" >&2; exit 1; }
	echo "$d"
}

for name in libnftnl nftables firewall4; do
	d=$(pkgdir "$name")
	mkdir -p "$d/patches"
	cp -v "$OVERLAY/$name"/*.patch "$d/patches/"

	old=$(sed -n 's/^PKG_RELEASE:=\([0-9]*\)$/\1/p' "$d/Makefile")
	[ -n "$old" ] || { echo "::error::no numeric PKG_RELEASE in $d/Makefile" >&2; exit 1; }
	new=$((old + RELEASE_BUMP))
	sed -i "s/^PKG_RELEASE:=$old\$/PKG_RELEASE:=$new/" "$d/Makefile"
	echo "$name: PKG_RELEASE $old -> $new"
done

# The libnftnl patch adds src/expr/fullcone.c to Makefile.am, so the
# tarball's generated Makefile.in is stale until autoreconf runs.
d=$(pkgdir libnftnl)
grep -q '^PKG_FIXUP:=autoreconf' "$d/Makefile" \
	|| sed -i '/^PKG_RELEASE:=/a PKG_FIXUP:=autoreconf' "$d/Makefile"

# firewall4 emits the fullcone statement, which needs the kernel module.
d=$(pkgdir firewall4)
grep -q 'kmod-nft-fullcone' "$d/Makefile" \
	|| sed -i 's/+kmod-nft-nat \/+kmod-nft-nat +kmod-nft-fullcone \/' "$d/Makefile"
grep -q 'kmod-nft-fullcone' "$d/Makefile" \
	|| { echo "::error::could not add the kmod-nft-fullcone dependency to firewall4" >&2; exit 1; }
