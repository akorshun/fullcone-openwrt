# fullcone-openwrt

FullCone NAT (NAT1) for **official OpenWrt 25.12.5 images**, as standalone apk
packages built against the official SDK. No custom firmware, no kernel patch.

| package | what |
|---|---|
| `kmod-nft-fullcone` | nftables `fullcone` expression ([nft-fullcone](https://github.com/fullcone-nat-nftables/nft-fullcone)) |
| `libnftnl11`, `nftables-json`, `nftables-nojson` | the official versions + fullcone expression support |
| `firewall4` | the official version + `defaults.fullcone` / `fullcone6` |
| `luci-app-fullcone`, `luci-i18n-fullcone-ru` | Network → Firewall → FullCone NAT |

Targets: `mediatek/filogic` (`fullcone-25.12.5-filogic-rN` releases).

## How it is built

The workflow unpacks the official SDK, applies the patches in `overlay/` to the
SDK's own base-feed `libnftnl`, `nftables` and `firewall4`
(`scripts/apply-overlay.sh`), raises their `PKG_RELEASE` by 100 so they outrank
the official packages, and builds them together with `package/`.

The patches and the `fullconenat-nft` package come from ImmortalWrt's
`openwrt-25.12` branch, which carries exactly the package versions OpenWrt
25.12.5 ships (libnftnl 1.3.1, nftables 1.1.6, firewall4 b6e51575). The only
change: the firewall4 patch no longer edits the default `/etc/config/firewall`,
so installing the packages switches nothing on.

`luci-app-fullcone` is a separate tab rather than a patched
`luci-app-firewall`: the luci feed of a release keeps getting rebuilt, and a
replaced `luci-app-firewall` would sooner or later collide with it.

## Limitation

nft-fullcone needs conntrack events. The official kernel has
`CONFIG_NF_CONNTRACK_EVENTS=y`, but not ImmortalWrt's chain-events hack, so
there is one event notifier: `nf_conntrack_netlink` (`conntrack -E`, some QoS
and statistics tools) and `nft_fullcone` cannot both use it.

## Install

See the release notes.
