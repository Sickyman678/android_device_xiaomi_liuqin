#               2022 The Evolution X Project
#
# SPDX-License-Identifier: Apache-2.0




# Inherit product specific makefiles
$(call inherit-product, device/xiaomi/liuqin/device.mk)
$(call inherit-product, vendor/xiaomi/liuqin/liuqin-vendor.mk)

PRODUCT_MANUFACTURER := Xiaomi
PRODUCT_BRAND := Xiaomi
PRODUCT_NAME := evolution_liuqin
PRODUCT_DEVICE := liuqin
PRODUCT_MODEL := Tab 6 Pro

# Inherit some common EvolutionX stuff
$(call inherit-product, vendor/evolution/config/common_full_tablet_wifionly.mk)

# All components inherited here go to vendor image
#
# TODO(b/136525499): move *_vendor.mk into the vendor makefile later
$(call inherit-product, $(SRC_TARGET_DIR)/product/handheld_vendor.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/telephony_vendor.mk)


# Device Identifyer 
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)

# GMS
PRODUCT_GMS_CLIENTID_BASE := android-xiaomi
