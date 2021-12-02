//
//  OTPCryptUtil.m
//  oc-developer-protocol
//
//  Created by Huasali on 2021/11/25.
//

#import "OTPCryptUtil.h"

@implementation OTPCryptUtil


#define VALID_KEY_LEN           (5u)
#define OTP_LEN                 (12u)

+ (NSDictionary *)inputData{
    return @{@"data":@"1638434393",
             @"key":@"12345678"};
}
+ (NSDictionary *)outputData{
    return @{@"data":@"928747999684"};
}

+ (void)cryptTest:(void(^)(NSString *log))callback{
    //test1
    callback(DataLog(@"------------test------------"));
    {
        uint32_t timestamp = [[[self inputData] valueForKey:@"data"] intValue];
        NSData *pswdData = [[[self inputData] valueForKey:@"key"] dataUsingEncoding:NSASCIIStringEncoding];
        callback(DataLog(@"timestamp = 0x%08x",timestamp));
        callback(DataLog(@"pswd = %@",[CryptHelper bytesStringFromData:pswdData]));
        NSData *hashData = [self otpHashWithPWD:pswdData time:timestamp key:0x00010203];
        NSString *hashKey = [CryptHelper stringFromData:hashData];
        callback(DataLog(@"hashKey = %@",hashKey));
        if ([hashKey isEqualToString:[self outputData][@"data"]]) {
            callback(DataLog(@"Test Success"));
        }
        else{
            callback(DataLog(@"Test failed"));
        }
    }
}

const uint8_t hash_table[256] = {
    0x45, 0x7B, 0x65, 0x3F, 0xC9, 0x09, 0xFF, 0x38, 0x1F, 0x87, 0xED, 0x67, 0x03, 0x73, 0x95, 0x67,
    0xFC, 0xE3, 0xF6, 0x3C, 0xBF, 0xBE, 0x72, 0xAE, 0x72, 0x8E, 0x0C, 0xDD, 0x0A, 0xFF, 0xEC, 0xA6,
    0x48, 0xE0, 0x78, 0xE0, 0xAA, 0xBF, 0x3E, 0x70, 0xC7, 0xDF, 0x12, 0x58, 0xB0, 0xCD, 0x26, 0x96,
    0x1B, 0x27, 0x7C, 0x2B, 0x57, 0xDB, 0x68, 0x0B, 0xF9, 0x4A, 0x7D, 0xA9, 0xBE, 0x54, 0xAB, 0x5A,
    0xBB, 0x47, 0x73, 0x5A, 0xCA, 0xDA, 0x38, 0x93, 0x99, 0x9B, 0x99, 0xAB, 0xAD, 0xDC, 0x38, 0x93,
    0xB6, 0xD9, 0x34, 0x29, 0x8D, 0xD8, 0x45, 0xA2, 0x59, 0x9A, 0x4A, 0xD8, 0x62, 0x9B, 0xB5, 0xCD,
    0xDD, 0x24, 0x16, 0x9F, 0x5C, 0x7D, 0xD3, 0x32, 0x90, 0x99, 0x9B, 0x3B, 0x9B, 0x20, 0xF9, 0x38,
    0x81, 0x3C, 0x1D, 0xB5, 0x35, 0xA9, 0xDF, 0xAA, 0x5E, 0xDF, 0x95, 0xE8, 0x4C, 0x8D, 0x94, 0x6E,
    0xAD, 0x9F, 0xCA, 0xBC, 0x9A, 0x78, 0x67, 0x75, 0xF9, 0xAA, 0x59, 0xFA, 0x44, 0xAD, 0xDA, 0x6B,
    0xCB, 0x41, 0x5F, 0x96, 0x3B, 0xD5, 0x37, 0xE8, 0x1B, 0xF6, 0xCF, 0xFA, 0x46, 0x61, 0x15, 0x67,
    0x49, 0x9D, 0x5D, 0xA1, 0xDF, 0xA4, 0xA2, 0x16, 0xE5, 0xBB, 0xE7, 0x57, 0xD1, 0xF6, 0xF3, 0xD7,
    0x01, 0xA2, 0xE5, 0xFD, 0x26, 0x72, 0x17, 0x79, 0xBA, 0x3F, 0xAA, 0x78, 0x61, 0x35, 0xA9, 0x27,
    0xE3, 0x84, 0xB5, 0x51, 0x5B, 0x2C, 0x59, 0xC5, 0x0B, 0xD6, 0xC6, 0x44, 0xA7, 0xD4, 0x2F, 0xF5,
    0xAE, 0x20, 0xA0, 0x0D, 0x94, 0xB4, 0xCA, 0x03, 0x86, 0xB4, 0xF9, 0x80, 0x18, 0x58, 0x1E, 0xC8,
    0x97, 0xD0, 0xA5, 0x1B, 0x34, 0x1F, 0xF2, 0xB5, 0x6E, 0xD8, 0x93, 0x36, 0xCF, 0x6C, 0x2F, 0xD1,
    0xE9, 0x24, 0x6A, 0x9F, 0x6B, 0x66, 0xB3, 0xA9, 0xF4, 0x21, 0x6D, 0x71, 0x66, 0xAE, 0xAE, 0x2B
};
const uint8_t otp_table[256] = {
    56, 51, 48, 52, 49, 50, 57, 53, 54, 52, 53, 48, 57, 49, 50, 56,
    54, 49, 55, 56, 48, 51, 49, 57, 53, 55, 49, 52, 50, 56, 48, 51,
    53, 51, 48, 55, 48, 51, 50, 57, 52, 51, 48, 53, 56, 55, 55, 56,
    54, 55, 52, 57, 49, 52, 56, 53, 48, 51, 54, 51, 52, 57, 55, 49,
    56, 52, 57, 54, 53, 50, 56, 54, 48, 49, 52, 55, 55, 52, 48, 50,
    49, 51, 48, 54, 50, 57, 50, 53, 57, 55, 52, 56, 49, 56, 52, 55,
    50, 48, 55, 49, 50, 51, 57, 54, 48, 56, 56, 50, 49, 56, 54, 48,
    53, 49, 57, 54, 51, 48, 53, 56, 55, 49, 55, 52, 54, 51, 57, 53,
    56, 48, 57, 53, 55, 51, 52, 53, 48, 54, 56, 51, 52, 56, 49, 55,
    50, 57, 56, 57, 54, 53, 52, 49, 57, 55, 49, 56, 51, 54, 49, 52,
    57, 53, 51, 56, 49, 54, 57, 51, 53, 48, 50, 54, 48, 57, 51, 50,
    49, 55, 52, 50, 48, 54, 56, 55, 55, 54, 57, 53, 51, 49, 48, 50,
    55, 51, 53, 49, 52, 50, 53, 51, 57, 52, 49, 54, 55, 50, 50, 57,
    53, 50, 52, 56, 48, 54, 49, 51, 57, 55, 54, 53, 56, 48, 51, 52,
    53, 48, 55, 50, 50, 57, 52, 53, 49, 48, 54, 53, 54, 51, 52, 50,
    53, 49, 52, 50, 55, 50, 57, 55, 52, 50, 56, 54, 57, 54, 53, 56
};
const uint8_t encode_table[10] = { 52, 57, 55, 56, 51, 50, 48, 54, 49, 53 };
static void otp_hash(uint32_t input_Num, uint8_t* output_buf, uint8_t output_len){
    uint16_t start_index, jump_index, i;
    uint8_t prim[7] = {3,5,7,11,13,17,19};
    start_index = input_Num % sizeof(hash_table);
    jump_index = input_Num % sizeof(prim);
    for (i = 0; i < output_len; i++) {
        output_buf[i] = hash_table[(start_index + prim[jump_index] * i) % sizeof(hash_table)];
    }
}
+ (NSData *)otpHashWithPWD:(NSData *)pwdData time:(uint32_t)time key:(uint32_t)key{
    unsigned char *pswd =(Byte*)[pwdData bytes];
    unsigned char otp[OTP_LEN+1];
    uint32_t timestamp = time;
    uint8_t length = pwdData.length;
    uint8_t i, j;
    uint8_t otp_buf[OTP_LEN + 1];
    uint32_t hash_key;
    while(length) {
        key += (uint32_t)*pswd;
        otp_hash(key, (uint8_t*)&hash_key, 4);
        key = hash_key;
        ++pswd;
        length--;
    }
    key ^= timestamp;
    otp_hash(key, otp_buf, VALID_KEY_LEN);
    for(i = 0; i < VALID_KEY_LEN; i++) {
        otp_buf[i] = otp_table[otp_buf[i]];
    }
    for(j = 0 ; i < OTP_LEN; i++) {
        otp_buf[i] = encode_table[((timestamp % 10) + otp_buf[j] - 48) % sizeof(encode_table)];
        timestamp /= 10;
        ++j;
        if(j >= VALID_KEY_LEN) {
            j = 0;
        }
    }
    otp_buf[i] = 0;
    memcpy(otp, otp_buf, sizeof(otp_buf));
    return [NSData dataWithBytes:otp length:OTP_LEN];
}

@end
