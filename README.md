Evolution X device configuration for Xiaomi Pad 6 Pro (liuqin)
=========================================

The Xiaomi Pad 6 Pro is a flagship tablet from Xiaomi.

It was released in April 2023.

## Build

This tree targets **Evolution X 17.0** on Android 17 (`cp2a` release config, SDK 37):

```
repo init -u https://github.com/Evolution-X/manifest -b cnb
# copy local_manifest.xml to .repo/local_manifests/liuqin.xml
breakfast lineage_liuqin
repo sync -j8
mka bacon
```

The `lineage_` product prefix and the `vendor/lineage` path are Evolution X's
own build-system naming -- `vendor/lineage` is where the `vendor_evolution`
repo is mounted, and the `vendor.lineage.*` HALs are interfaces Evolution X
ships. None of them are renameable: Evolution X's own device trees use the
same convention.

## Device specifications

Basic   | Spec Sheet
-------:|:-------------------------
SoC     | Qualcomm SM8475 Snapdragon 8+ Gen 1 (4 nm)
CPU     | Octa-core (1x3.00 GHz Cortex-X2 & 3x2.50 GHz Cortex-A710 & 4x1.80 GHz Cortex-A510)
GPU     | Adreno 730
Memory  | 128GB 8GB RAM, 256GB 8GB RAM, 256GB 12GB RAM, 512GB 12GB RAM
Shipped Android Version | Android 13
Battery | Li-Po 8600 mAh, non-removable
Display | IPS TFT LCD, 1B colors, 144Hz, HDR10, 550 nits (CSOT)

## Device picture

![liuqin](https://cdn.cnbj0.fds.api.mi-img.com/b2c-shopapi-pms/pms_1681708013.08067335.png "liuqin")

## Copyright

```
#
# Copyright (C) 2023 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#
```
