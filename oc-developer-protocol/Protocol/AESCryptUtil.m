//
//  AESCryptUtil.m
//  oc-developer-protocol
//
//  Created by Huasali on 2021/11/25.
//

#import "AESCryptUtil.h"
#import <openssl/aes.h>
#import <CommonCrypto/CommonCryptor.h>

@implementation AESCryptUtil

+ (void)cryptTest:(void(^)(NSString *log))callback{
    //test1
    callback(@"------------test1------------");
    {
        NSData *data = [CryptHelper dataFromString:[[self inputData] valueForKey:@"data"]];
        NSData *key  = [CryptHelper dataFromBytesString:[[self inputData] valueForKey:@"key"]];
        NSData *iv   = [CryptHelper dataFromString:[[self inputData] valueForKey:@"iv"]];
        callback(StringFrom(@"data:%@",[CryptHelper bytesStringFromData:data]));
        callback(StringFrom(@"key:%@",[CryptHelper bytesStringFromData:key]));
        callback(StringFrom(@"iv:%@",[CryptHelper bytesStringFromData:iv]));
        NSData *encryptData = [self aescbcEncryptData:data key:key iv:iv];
        callback(StringFrom(@"encryptData:%@",[CryptHelper bytesStringFromData:encryptData]));
        NSData *decryptData = [self aescbcDecryptData:encryptData key:key iv:iv];
        callback(StringFrom(@"decryptData:%@",[CryptHelper bytesStringFromData:decryptData]));
        NSString *decryptString = [CryptHelper stringFromData:decryptData];
        callback([NSString stringWithFormat:@"decryptString:%@",decryptString]);
        if ([[[self inputData] valueForKey:@"data"] isEqualToString:decryptString]) {
            callback(StringFrom(@"Test Success"));
        }
        else{
            callback(StringFrom(@"Test failed"));
        }
    }
    //test2
    callback(StringFrom(@"------------test2------------"));
    {
        NSData *data = [CryptHelper dataFromString:[[self inputData] valueForKey:@"data"]];
        NSData *key  = [CryptHelper dataFromBytesString:[[self inputData] valueForKey:@"key"]];
        callback(StringFrom(@"data:%@",[CryptHelper bytesStringFromData:data]));
        callback(StringFrom(@"key:%@",[CryptHelper bytesStringFromData:key]));
        NSData *encryptData = [self aes128cbcEncryptData:data key:key];
        callback(StringFrom(@"encryptData:%@",[CryptHelper bytesStringFromData:encryptData]));
        NSData *decryptData = [self aes128cbcDecryptData:encryptData key:key];
        callback(StringFrom(@"decryptData:%@",[CryptHelper bytesStringFromData:decryptData]));
        NSString *decryptString = [CryptHelper stringFromData:decryptData];
        callback([NSString stringWithFormat:@"decryptString:%@",decryptString]);
        if ([[[self inputData] valueForKey:@"data"] isEqualToString:decryptString]) {
            callback(StringFrom(@"Test Success"));
        }
        else{
            callback(StringFrom(@"Test failed"));
        }
    }
    //test3
    callback(StringFrom(@"------------test3------------"));
    {
        NSData *data = [CryptHelper dataFromString:[[self inputData] valueForKey:@"data"]];
        NSData *key  = [CryptHelper dataFromBytesString:[[self inputData] valueForKey:@"key"]];
        callback(StringFrom(@"data:%@",[CryptHelper bytesStringFromData:data]));
        callback(StringFrom(@"key:%@",[CryptHelper bytesStringFromData:key]));
        NSData *encryptData = [self aes128cfbEncryptData:data key:key];
        callback(StringFrom(@"encryptData:%@",[CryptHelper bytesStringFromData:encryptData]));
        NSData *decryptData = [self aes128cfbDecryptData:encryptData key:key];
        callback(StringFrom(@"decryptData:%@",[CryptHelper bytesStringFromData:decryptData]));
        NSString *decryptString = [CryptHelper stringFromData:decryptData];
        callback([NSString stringWithFormat:@"decryptString:%@",decryptString]);
        if ([[[self inputData] valueForKey:@"data"] isEqualToString:decryptString]) {
            callback(StringFrom(@"Test Success"));
        }
        else{
            callback(StringFrom(@"Test failed"));
        }
    }
}

+ (NSData *)aescbcEncryptData:(NSData *)data
                          key:(NSData *)keyData
                           iv:(NSData *)ivData{
    data = [CryptHelper appendCountPadding:data];
    NSData *tempIVData = [ivData mutableCopy];
    Byte *crypt_data = (Byte *)[data bytes];
    int crypt_len = (int)data.length;
    unsigned char *keyResult=(Byte*)[keyData bytes];
    AES_KEY aes_key;
    unsigned char *outByte = NULL;
    outByte = (unsigned char *)malloc(crypt_len+1);
    memset(outByte, 0, crypt_len+1);
    AES_set_encrypt_key(keyResult, 128, &aes_key);
    unsigned char *ivResult = (Byte*)[tempIVData bytes];
    AES_cbc_encrypt(crypt_data, outByte,crypt_len, &aes_key,ivResult, AES_ENCRYPT);
    return [NSData dataWithBytes:outByte length:crypt_len];
}

+ (NSData *)aescbcDecryptData:(NSData *)encryptData
                          key:(NSData *)keyData
                           iv:(NSData *)ivData{
    unsigned char *keyResult = (Byte*)[keyData bytes];
    NSData *tempIVData = [ivData mutableCopy];
    AES_KEY aes_key;
    int crypt_len = (int)encryptData.length;;
    Byte *crypt_data = (Byte *)[encryptData bytes];
    AES_set_decrypt_key(keyResult, 128, &aes_key);
    unsigned char *ivResult = (Byte*)[tempIVData bytes];
    AES_cbc_encrypt(crypt_data, crypt_data,crypt_len, &aes_key,ivResult, AES_DECRYPT);
    return [CryptHelper subCountPaddingData:[NSData dataWithBytes:crypt_data length:crypt_len]];
}

+ (NSData *)aes128cbcEncryptData:(NSData *)data key:(NSData *)keyData{
    int number = 0;
    NSData *ivData = [NSData dataWithBytes:&number length:1];
    size_t bufferSize = [data length] + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptorStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                            [keyData bytes], kCCKeySizeAES128,
                                            [ivData bytes],
                                            [data bytes], [data length],
                                            buffer, bufferSize,
                                            &numBytesEncrypted);
    NSData *tempData = [NSData data];
    if(cryptorStatus == kCCSuccess){
        tempData = [NSData dataWithBytes:buffer length:numBytesEncrypted];
    }
    free(buffer);
    return tempData;
}
+ (NSData *)aes128cbcDecryptData:(NSData *)data key:(NSData *)keyData{
    if (data&&keyData) {
      int number = 0;
      NSData *ivData = [NSData dataWithBytes:&number length:1];
      size_t bufferSize = [data length] + kCCBlockSizeAES128;
      void *buffer = malloc(bufferSize);
      size_t numBytesEncrypted = 0;
      CCCryptorStatus cryptorStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                              [keyData bytes], kCCKeySizeAES128,
                                              [ivData bytes],
                                              [data bytes], [data length],
                                              buffer, bufferSize,
                                              &numBytesEncrypted);
      NSData *tempData = [NSData data];
      if(cryptorStatus == kCCSuccess){
          tempData = [NSData dataWithBytes:buffer length:numBytesEncrypted];
      }
      free(buffer);
      return tempData;
    }
    return [NSData data];
}

+ (NSData *)aes128cfbEncryptData:(NSData *)data key:(NSData *)keyData{
    unsigned char *keyBytes = (Byte*)[keyData bytes];
    Byte *dataBytes = (Byte *)[data bytes];
    int length = (int)data.length;
    AES_KEY aes_key;
    AES_set_encrypt_key(keyBytes, 128, &aes_key);
    int iv_offset = 0;
    uint8_t iv0[16]={0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00};
    AES_cfb128_encrypt(dataBytes, dataBytes, length, &aes_key, iv0, &iv_offset, AES_ENCRYPT);
    return [NSData dataWithBytes:dataBytes length:length];
}
+ (NSData *)aes128cfbDecryptData:(NSData *)data key:(NSData *)keyData{
    unsigned char *keyBytes = (Byte*)[keyData bytes];
    Byte *dataBytes = (Byte *)[data bytes];
    int length = (int)data.length;
    AES_KEY aes_key;
    AES_set_encrypt_key(keyBytes, 128, &aes_key);
    int iv_offset = 0;
    uint8_t iv0[16]={0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00};
    AES_cfb128_encrypt(dataBytes, dataBytes, length, &aes_key, iv0, &iv_offset, AES_DECRYPT);
    return [NSData dataWithBytes:dataBytes length:length];
}

@end
