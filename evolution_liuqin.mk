#
# Copyright (C) 2023 The Evolution X Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit from liuqin device
$(call inherit-product, device/xiaomi/liuqin/device.mk)

# Inherit some common Evolution X stuff.
$(call inherit-product, vendor/evolution/config/common_full_tablet_wifionly.mk)

TARGET_BOOT_ANIMATION_RES := 1080
TARGET_SUPPORTS_QUICK_TAP := true

PRODUCT_NAME := evolution_liuqin
PRODUCT_DEVICE := liuqin
PRODUCT_MANUFACTURER := Xiaomi
PRODUCT_BRAND := Xiaomi
PRODUCT_MODEL := Pad 6 Pro

PRODUCT_GMS_CLIENTID_BASE := android-xiaomi
