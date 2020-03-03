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

    void encrypt(const unsigned char *input, unsigned char *output, size_t length);

    void decrypt(const unsigned char *input, unsigned char *output, size_t length);

    void reset(const unsigned char *iv = nullptr, size_t ivLength = 0);

    // output must have [AES_KEY_LEN] space
    void getKey(void *output) const;

    static void fillRandomIV(unsigned char *vector);
};

#ifndef NDEBUG

// check if AESCrypt is encrypt-decrypt full-duplex
void testAESCrypt();

#endif

#endif /* AES_CRYPT_H_ */
