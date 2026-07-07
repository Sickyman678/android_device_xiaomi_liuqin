#
# SPDX-FileCopyrightText: 2023 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from liuqin device
$(call inherit-product, device/xiaomi/liuqin/device.mk)

# Inherit some common stuff (WiFi-only tablet).
# NOTE: Under Evolution X the "vendor/lineage" path is populated by
# vendor_evolution (see the EvoX manifest), so this pulls in the Evolution X
# product config rather than plain LineageOS.
$(call inherit-product, vendor/lineage/config/common_full_tablet_wifionly.mk)

# Google apps are provided by Evolution X itself: common_full_tablet_wifionly.mk
# defaults WITH_GMS ?= true and inherits vendor/gms. Do NOT inherit MindTheGapps
# here (as we do on the LineageOS branch) or the GMS packages collide.
# For a vanilla build, set WITH_GMS := false.

# Evolution X build type. Use "Unofficial" for personal/port builds;
# "Official" is reserved for sanctioned maintainer builds with OTA support.
EVO_BUILD_TYPE := Unofficial

PRODUCT_NAME := lineage_liuqin
PRODUCT_DEVICE := liuqin
PRODUCT_BRAND := Xiaomi
PRODUCT_MODEL := Xiaomi Pad 6 Pro
PRODUCT_MANUFACTURER := Xiaomi

PRODUCT_GMS_CLIENTID_BASE := android-xiaomi
