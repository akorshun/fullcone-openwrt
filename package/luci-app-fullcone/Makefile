# SPDX-License-Identifier: Apache-2.0

include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI page for FullCone NAT (fw4 + nft-fullcone)
LUCI_DEPENDS:=+luci-base +luci-app-firewall +firewall4 +kmod-nft-fullcone
LUCI_PKGARCH:=all

PKG_LICENSE:=Apache-2.0

# Its own package instead of a patched luci-app-firewall: the luci feed of a
# release keeps moving, and a replaced luci-app-firewall would either be
# overtaken by the next official build or block it. A separate tab conflicts
# with nothing.
include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
