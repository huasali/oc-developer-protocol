//
//  OTPCryptUtil.m
//  oc-developer-protocol
//
//  Created by Huasali on 2021/11/25.
//

#import "OTPCryptUtil.h"


static Byte *hash_table;
static Byte *otp_table;
static Byte *encode_table;

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
    callback(StringFrom(@"------------test------------"));
    {
        hash_table   = (Byte *)[[CryptHelper randPaddingData:256] bytes];
        otp_table    = (Byte *)[[CryptHelper randPaddingData:256] bytes];
        encode_table = (Byte *)[[CryptHelper randPaddingData:10]  bytes];
        callback(StringFrom(@"hash_table   = %@",[NSData dataWithBytes:hash_table   length:256]));
        callback(StringFrom(@"otp_table    = %@",[NSData dataWithBytes:otp_table    length:256]));
        callback(StringFrom(@"encode_table = %@",[NSData dataWithBytes:encode_table length:10]));
        uint32_t timestamp = [[[self inputData] valueForKey:@"data"] intValue];
        NSData *pswdData = [[[self inputData] valueForKey:@"key"] dataUsingEncoding:NSASCIIStringEncoding];
        callback(StringFrom(@"timestamp = 0x%08x",timestamp));
        callback(StringFrom(@"pswd = %@",[CryptHelper bytesStringFromData:pswdData]));
        NSData *hashData = [self otpHashWithPWD:pswdData time:timestamp key:0x00010203];
        NSString *hashKey = [CryptHelper stringFromData:hashData];
        callback(StringFrom(@"hashKey = %@",hashData));
        if ([hashKey isEqualToString:[self outputData][@"data"]]) {
            callback(StringFrom(@"Test Success"));
        }
        else{
            callback(StringFrom(@"Test failed"));
        }
    }
}

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
