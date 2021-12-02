//
//  AESCryptUtil.h
//  oc-developer-protocol
//
//  Created by Huasali on 2021/11/25.
//

#import <Foundation/Foundation.h>
#import "CryptUtil.h"

NS_ASSUME_NONNULL_BEGIN

@interface AESCryptUtil : CryptUtil

/// AES128 CBC 加密 countPadding
+ (NSData *)aescbcEncryptData:(NSData *)data key:(NSData *)keyData iv:(NSData *)ivData;
/// AES128 CBC 解密 countPadding
+ (NSData *)aescbcDecryptData:(NSData *)encryptData key:(NSData *)keyData iv:(NSData *)ivData;

/// AES128 CBC 加密 PKCS7padding iv 0
+ (NSData *)aes128cbcEncryptData:(NSData *)data key:(NSData *)keyData;
/// AES128 CBC 解密PKCS7padding iv 0
+ (NSData *)aes128cbcDecryptData:(NSData *)data key:(NSData *)keyData;

/// AES128 CFB 加密 NOPadding iv 16字节0
+ (NSData *)aes128cfbEncryptData:(NSData *)data key:(NSData *)keyData;
/// AES128 CFB 解密 NOPadding iv 16字节0
+ (NSData *)aes128cfbDecryptData:(NSData *)data key:(NSData *)keyData;

@end

NS_ASSUME_NONNULL_END
