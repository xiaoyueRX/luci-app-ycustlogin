include $(TOPDIR)/rules.mk

LUCI_TITLE:=YCUST Campus Network Auto-Login
LUCI_DEPENDS:=+curl
LUCI_PKGARCH:=all

PKG_NAME:=luci-app-ycustlogin
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

include ../../luci.mk

define Package/$(PKG_NAME)/postinst
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] && exit 0
chmod +x /usr/bin/ycust_autologin.sh
exit 0
endef
