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

#import <Foundation/Foundation.h>

#ifdef __cplusplus

<<<<<<< HEAD:Pods/MMKV/iOS/MMKV/MMKV/MiniPBEncodeItem.h
enum MiniPBEncodeItemType {
=======
#include "MMBuffer.h"
#include <cstdint>
#include <memory.h>

namespace mmkv {

enum PBEncodeItemType {
>>>>>>> update pod:Pods/MMKVCore/Core/PBEncodeItem.hpp
    PBEncodeItemType_None,
    PBEncodeItemType_NSString,
    PBEncodeItemType_NSData,
    PBEncodeItemType_NSDate,
    PBEncodeItemType_NSContainer,
};

struct MiniPBEncodeItem {
    MiniPBEncodeItemType type;
    int32_t compiledSize;
    int32_t valueSize;
    union {
        void *objectValue;
        void *tmpObjectValue; // this object should release on dealloc
    } value;

<<<<<<< HEAD:Pods/MMKV/iOS/MMKV/MMKV/MiniPBEncodeItem.h
    MiniPBEncodeItem() : type(PBEncodeItemType_None), compiledSize(0), valueSize(0) {
        memset(&value, 0, sizeof(value));
    }

    MiniPBEncodeItem(const MiniPBEncodeItem &other)
        : type(other.type)
        , compiledSize(other.compiledSize)
        , valueSize(other.valueSize)
        , value(other.value) {
        if (type == PBEncodeItemType_NSString) {
            if (value.tmpObjectValue != nullptr) {
                CFRetain(value.tmpObjectValue);
            }
        }
    }

    MiniPBEncodeItem &operator=(const MiniPBEncodeItem &other) {
        if (this != &other) {
            type = other.type;
            compiledSize = other.compiledSize;
            valueSize = other.valueSize;
            value = other.value;

            if (type == PBEncodeItemType_NSString) {
                if (value.tmpObjectValue != nullptr) {
                    CFRetain(value.tmpObjectValue);
                }
            }
        }

        return *this;
=======
    PBEncodeItem() : type(PBEncodeItemType_None), compiledSize(0), valueSize(0) { memset(&value, 0, sizeof(value)); }

#ifndef MMKV_APPLE
    // opt std::vector.push_back() on slow_path
    PBEncodeItem(PBEncodeItem &&other) = default;
#else
    // opt std::vector.push_back() on slow_path
    PBEncodeItem(PBEncodeItem &&other)
        : type(other.type), compiledSize(other.compiledSize), valueSize(other.valueSize), value(other.value) {
        // omit unnecessary CFRetain() & CFRelease()
        other.type = PBEncodeItemType_None;
>>>>>>> update pod:Pods/MMKVCore/Core/PBEncodeItem.hpp
    }

    ~MiniPBEncodeItem() {
        if (type == PBEncodeItemType_NSString) {
            if (value.tmpObjectValue) {
                CFRelease(value.tmpObjectValue);
            }
        }
    }
<<<<<<< HEAD:Pods/MMKV/iOS/MMKV/MMKV/MiniPBEncodeItem.h
=======
#endif // MMKV_APPLE
>>>>>>> update pod:Pods/MMKVCore/Core/PBEncodeItem.hpp
};

#endif
