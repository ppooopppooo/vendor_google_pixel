#!/bin/bash
#
# Copyright (C) 2018 The LineageOS Project
# Copyright (C) 2021 YAAP
#
# SPDX-License-Identifier: Apache-2.0
#

set -e

DEVICE=pixel
VENDOR=google

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

ANDROID_ROOT="${MY_DIR}/../../.."

HELPER="${ANDROID_ROOT}/tools/extract-utils/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

# Default to sanitizing the vendor folder before extraction
CLEAN_VENDOR=true

KANG=
SECTION=

while [ "${#}" -gt 0 ]; do
    case "${1}" in
        -n | --no-cleanup )
                CLEAN_VENDOR=false
                ;;
        -k | --kang )
                KANG="--kang"
                ;;
        -s | --section )
                SECTION="${2}"; shift
                CLEAN_VENDOR=false
                ;;
        * )
                SRC="${1}"
                ;;
    esac
    shift
done

if [ -z "${SRC}" ]; then
    SRC="adb"
fi

{
    GMS0="\"com.google.android.gms"\"
    STR1="allow-unthrottled-location package=$GMS0"
    STR2="allow-ignore-location-settings package=$GMS0"
    STR3="allow-in-power-save package=$GMS0"
    STR4="allow-in-data-usage-save package=$GMS0"
}

function blob_fixup() {
    case "${1}" in
    product/etc/sysconfig/pixel.xml)
        sed -i "/$STR1/d;/$STR2/d;/$STR3/d;/$STR4/d" "${2}"
        ;;
    esac
}

# Initialize the helper
setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" false "${CLEAN_VENDOR}"

extract "${MY_DIR}/proprietary-files.txt" "${SRC}" "${KANG}" --section "${SECTION}"

"${MY_DIR}/setup-makefiles.sh"
