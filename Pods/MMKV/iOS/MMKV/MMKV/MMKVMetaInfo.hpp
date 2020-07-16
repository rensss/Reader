/*
 * Tencent is pleased to support the open source community by making
 * MMKV available.
 *
 * Copyright (C) 2018 THL A29 Limited, a Tencent company.
 * All rights reserved.
 *
 * Licensed under the BSD 3-Clause License (the "License"); you may not use
 * this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 *       https://opensource.org/licenses/BSD-3-Clause
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef MMKV_MMKVMETAINFO_H
#define MMKV_MMKVMETAINFO_H
<<<<<<< HEAD:Pods/MMKV/iOS/MMKV/MMKV/MMKVMetaInfo.hpp
=======
#ifdef __cplusplus
>>>>>>> update pod:Pods/MMKVCore/Core/MMKVMetaInfo.hpp

#include "AESCrypt.h"
#include <cassert>
#include <cstdint>
#include <cstring>

struct MMKVMetaInfo {
    uint32_t m_crcDigest = 0;
    uint32_t m_version = 1;
    uint32_t m_sequence = 0; // full write-back count
<<<<<<< HEAD:Pods/MMKV/iOS/MMKV/MMKV/MMKVMetaInfo.hpp
    unsigned char m_vector[AES_KEY_LEN] = {0};

    void write(void *ptr) {
        assert(ptr);
        memcpy(ptr, this, sizeof(MMKVMetaInfo));
    }

=======
    uint8_t m_vector[AES_KEY_LEN] = {};
    uint32_t m_actualSize = 0;

    // confirmed info: it's been synced to file
    struct {
        uint32_t lastActualSize = 0;
        uint32_t lastCRCDigest = 0;
        uint32_t _reserved[16] = {};
    } m_lastConfirmedMetaInfo;

    void write(void *ptr) const {
        MMKV_ASSERT(ptr);
        memcpy(ptr, this, sizeof(MMKVMetaInfo));
    }

    void writeCRCAndActualSizeOnly(void *ptr) const {
        MMKV_ASSERT(ptr);
        auto other = (MMKVMetaInfo *) ptr;
        other->m_crcDigest = m_crcDigest;
        other->m_actualSize = m_actualSize;
    }

>>>>>>> update pod:Pods/MMKVCore/Core/MMKVMetaInfo.hpp
    void read(const void *ptr) {
        assert(ptr);
        memcpy(this, ptr, sizeof(MMKVMetaInfo));
    }
};

#endif //MMKV_MMKVMETAINFO_H
