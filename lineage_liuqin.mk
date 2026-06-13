#
# Copyright (C) 2023 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit some common Lineage stuff.
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

# Inherit from liuqin device
$(call inherit-product, device/xiaomi/liuqin/device.mk)

PRODUCT_NAME := lineage_liuqin
PRODUCT_DEVICE := liuqin
PRODUCT_MANUFACTURER := Xiaomi
PRODUCT_BRAND := Xiaomi
PRODUCT_MODEL := liuqin

PRODUCT_CHARACTERISTICS := tablet


BUILD_FINGERPRINT := "Xiaomi/liuqin/liuqin:13/TKQ1.221114.001/V14.0.5.0.TMBMIXM:user/release-keys" \



