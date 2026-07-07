#
# SPDX-FileCopyrightText: 2023 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from liuqin device
$(call inherit-product, device/xiaomi/liuqin/device.mk)

# Inherit some common Lineage stuff (WiFi-only tablet)
$(call inherit-product, vendor/lineage/config/common_full_tablet_wifionly.mk)

# Inherit Google Apps (MindTheGapps, arm64) when the vendor/gapps tree is synced.
# inherit-product-if-exists keeps the build vanilla if it isn't present.
$(call inherit-product-if-exists, vendor/gapps/arm64/arm64-vendor.mk)

# Lindroid (Linux-on-droid): run GNU/Linux (Ubuntu, etc.) containers with GPU
# passthrough. Forward-ported from lindroid-21 (A14) to our A16 tree.
# NOTE: actually starting a container needs a from-source kernel with the
# namespace/cgroup configs enabled (see vendor/lindroid/README.md and the
# lindroid_defconfig fragment); the prebuilt kernel lacks USER_NS/PID_NS/etc.
$(call inherit-product-if-exists, vendor/extra/product.mk)

PRODUCT_NAME := lineage_liuqin
PRODUCT_DEVICE := liuqin
PRODUCT_BRAND := Xiaomi
PRODUCT_MODEL := Xiaomi Pad 6 Pro
PRODUCT_MANUFACTURER := Xiaomi

PRODUCT_GMS_CLIENTID_BASE := android-xiaomi
