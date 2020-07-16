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

#ifndef AES_CRYPT_H_
#define AES_CRYPT_H_
<<<<<<< HEAD:Pods/MMKV/iOS/MMKV/MMKV/aes/AESCrypt.h

#include "openssl/openssl_aes.h"
#include <cstddef>

constexpr size_t AES_KEY_LEN = 16;
constexpr size_t AES_KEY_BITSET_LEN = 128;

// a AES CFB-128 encrypt-decrypt full-duplex wrapper
class AESCrypt {
    unsigned char m_vector[AES_KEY_LEN] = {0};
    unsigned char m_key[AES_KEY_LEN] = {0};
    openssl::AES_KEY m_aesKey = {0};
    int m_number = 0;

public:
    AESCrypt(const unsigned char *key,
             size_t keyLength,
             const unsigned char *iv = nullptr,
             size_t ivLength = 0);
=======
#ifdef __cplusplus

#include "MMKVPredef.h"
#include <cstddef>

#ifdef MMKV_DISABLE_CRYPT

namespace mmkv {
class AESCrypt;
}

#else

namespace openssl {
struct AES_KEY;
}

namespace mmkv {

#pragma pack(push, 1)

struct AESCryptStatus {
    uint8_t m_number;
    uint8_t m_vector[AES_KEY_LEN];
};

#pragma pack(pop)

class CodedInputDataCrypt;

// a AES CFB-128 encrypt-decrypt full-duplex wrapper
class AESCrypt {
    bool m_isClone = false;
    uint32_t m_number = 0;
    openssl::AES_KEY *m_aesKey = nullptr;
    openssl::AES_KEY *m_aesRollbackKey = nullptr;
    uint8_t m_key[AES_KEY_LEN] = {};

public:
    uint8_t m_vector[AES_KEY_LEN] = {};

private:
    // for cloneWithStatus()
    AESCrypt(const AESCrypt &other, const AESCryptStatus &status);

public:
    AESCrypt(const void *key, size_t keyLength, const void *iv = nullptr, size_t ivLength = 0);
    AESCrypt(AESCrypt &&other) = default;
>>>>>>> update pod:Pods/MMKVCore/Core/aes/AESCrypt.h

    void encrypt(const unsigned char *input, unsigned char *output, size_t length);

    void decrypt(const unsigned char *input, unsigned char *output, size_t length);

<<<<<<< HEAD:Pods/MMKV/iOS/MMKV/MMKV/aes/AESCrypt.h
    void reset(const unsigned char *iv = nullptr, size_t ivLength = 0);
=======
    void decrypt(const void *input, void *output, size_t length);

    void getCurStatus(AESCryptStatus &status);
    void statusBeforeDecrypt(const void *input, const void *output, size_t length, AESCryptStatus &status);

    AESCrypt cloneWithStatus(const AESCryptStatus &status) const;

    void resetIV(const void *iv = nullptr, size_t ivLength = 0);
    void resetStatus(const AESCryptStatus &status);
>>>>>>> update pod:Pods/MMKVCore/Core/aes/AESCrypt.h

    // output must have [AES_KEY_LEN] space
    void getKey(void *output) const;

<<<<<<< HEAD:Pods/MMKV/iOS/MMKV/MMKV/aes/AESCrypt.h
    static void fillRandomIV(unsigned char *vector);
};
=======
    static void fillRandomIV(void *vector);

    // just forbid it for possibly misuse
    explicit AESCrypt(const AESCrypt &other) = delete;
    AESCrypt &operator=(const AESCrypt &other) = delete;
>>>>>>> update pod:Pods/MMKVCore/Core/aes/AESCrypt.h

    friend CodedInputDataCrypt;

#ifndef NDEBUG
    // check if AESCrypt is encrypt-decrypt full-duplex
    static void testAESCrypt();
#endif
};

<<<<<<< HEAD:Pods/MMKV/iOS/MMKV/MMKV/aes/AESCrypt.h
=======
} // namespace mmkv

#endif // MMKV_DISABLE_CRYPT
#endif // __cplusplus
>>>>>>> update pod:Pods/MMKVCore/Core/aes/AESCrypt.h
#endif /* AES_CRYPT_H_ */
