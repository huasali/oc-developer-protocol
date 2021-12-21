//
//  DHCryptUtil.m
//  oc-developer-protocol
//
//  Created by Huasali on 2021/12/3.
//

#import "DHCryptUtil.h"
#import <openssl/bn.h>
#import <openssl/dh.h>
#import <openssl/md5.h>

@implementation DHCryptUtil

unsigned char data[] = {
    0xcf,0x5c,0xf5,0xc3,0x84,0x19,0xa7,0x24,0x95,0x7f,0xf5,0xdd,0x32,0x3b,0x9c,0x45,0xc3,0xcd,0xd2,0x61,0xeb,0x74,0x0f,0x69,0xaa,0x94,0xb8,0xbb,0x1a,0x5c,0x96,0x40,0x91,0x53,0xbd,0x76,0xb2,0x42,0x22,0xd0,0x32,0x74,0xe4,0x72,0x5a,0x54,0x06,0x09,0x2e,0x9e,0x82,0xe9,0x13,0x5c,0x64,0x3c,0xae,0x98,0x13,0x2b,0x0d,0x95,0xf7,0xd6,0x53,0x47,0xc6,0x8a,0xfc,0x1e,0x67,0x7d,0xa9,0x0e,0x51,0xbb,0xab,0x5f,0x5c,0xf4,0x29,0xc2,0x91,0xb4,0xba,0x39,0xc6,0xb2,0xdc,0x5e,0x8c,0x72,0x31,0xe4,0x6a,0xa7,0x72,0x8e,0x87,0x66,0x45,0x32,0xcd,0xf5,0x47,0xbe,0x20,0xc9,0xa3,0xfa,0x83,0x42,0xbe,0x6e,0x34,0x37,0x1a,0x27,0xc0,0x6f,0x7d,0xc0,0xed,0xdd,0xd2,0xf8,0x63,0x73 };

+ (void)cryptTest:(void(^)(NSString *log))callback{
    int g = 2;
    NSData *p = [NSData dataWithBytes:data length:sizeof(data)];
    callback(StringFrom(@"g:%d",g));
    callback(StringFrom(@"p:%@",[CryptHelper logStringFromObject:p]));
    NSDictionary *DHDictionaryServer = [self generateDHKeyFromG:g p:p];
    callback(StringFrom(@"Server:%@",[CryptHelper logStringFromObject:DHDictionaryServer]));
    NSDictionary *DHDictionaryClient = [self generateDHKeyFromG:g p:p];
    callback(StringFrom(@"Client:%@",[CryptHelper logStringFromObject:DHDictionaryClient]));
    NSDictionary *securtDictionaryServer = [self generateSecurtKey:DHDictionaryClient[@"pub"] privKey:DHDictionaryServer[@"priv"] g:g p:p];
    NSDictionary *securtDictionaryClient = [self generateSecurtKey:DHDictionaryServer[@"pub"]  privKey:DHDictionaryClient[@"priv"] g:g p:p];
    callback(StringFrom(@"Server:%@",[CryptHelper logStringFromObject:securtDictionaryServer]));
    callback(StringFrom(@"Client:%@",[CryptHelper logStringFromObject:securtDictionaryClient]));
    if ([securtDictionaryServer[@"sharekeyMD5"] isEqualToData:securtDictionaryClient[@"sharekeyMD5"]]) {
        callback(StringFrom(@"Test Success"));
    }
    else{
        callback(StringFrom(@"Test failed"));
    }
}
+ (NSDictionary *)generateDHKeyFromG:(int)gNumber p:(NSData *)pNumber{
    NSMutableDictionary *DHDictionary = [NSMutableDictionary dictionary];
    DH *dhStruct = DH_new();
    BIGNUM *g = BN_new();
    BIGNUM *p = BN_bin2bn(pNumber.bytes, (int)pNumber.length, NULL);
    BN_set_word(g, gNumber);
    DH_set0_pqg(dhStruct,p,NULL,g);
    if(DH_generate_key(dhStruct)){
        int i;
        int ret = DH_check(dhStruct,&i);
        if(ret != 1){
            printf("DH_check err!\n");
            if(i&DH_CHECK_P_NOT_PRIME)printf("p value is not prime\n");
            if(i&DH_CHECK_P_NOT_SAFE_PRIME)printf("p value is not a safe prime\n");
            if(i&DH_UNABLE_TO_CHECK_GENERATOR)printf("unable to check the generator value\n");
            if(i&DH_NOT_SUITABLE_GENERATOR)printf("the g value is not a generator\n");
        }
        const BIGNUM *pub_key  = BN_new();
        const BIGNUM *priv_key = BN_new();
        DH_get0_key(dhStruct,&pub_key,&priv_key);
        NSString *pubString  = [NSString stringWithCString:BN_bn2hex(pub_key) encoding:NSUTF8StringEncoding];
        NSString *privString = [NSString stringWithCString:BN_bn2hex(priv_key) encoding:NSUTF8StringEncoding];
        [DHDictionary setValue:[CryptHelper dataFromBytesString:pubString] forKey:@"pub"];
        [DHDictionary setValue:[CryptHelper dataFromBytesString:privString] forKey:@"priv"];
    }
    return DHDictionary;
}
+ (NSDictionary *)generateSecurtKey:(NSData *)publicKey privKey:(NSData *)privKey g:(int)gNumber p:(NSData *)pNumber {
    NSMutableDictionary *securtDictionary = [NSMutableDictionary dictionary];
    unsigned char sharekey[128];
    unsigned char MD5result[16];
    BIGNUM *pubkey  = BN_bin2bn([publicKey bytes], (int)publicKey.length, NULL);
    BIGNUM *privkey = BN_bin2bn([privKey bytes], (int)privKey.length, NULL);
    DH *dhStruct = DH_new();
    BIGNUM *g = BN_new();
    BIGNUM *p = BN_bin2bn(pNumber.bytes, (int)pNumber.length, NULL);
    BN_set_word(g, gNumber);
    DH_set0_pqg(dhStruct,p,NULL,g);
    DH_set0_key(dhStruct, NULL, privkey);
    if (DH_compute_key(sharekey, pubkey,dhStruct)) {
        BIGNUM *sharekeyBG = BN_bin2bn(sharekey, sizeof(sharekey), NULL);
        NSString *sharekeyStr = [NSString stringWithCString:BN_bn2hex(sharekeyBG) encoding:NSUTF8StringEncoding];
        [securtDictionary setValue:sharekeyStr forKey:@"sharekey"];
        MD5_CTX md5_ctx;
        MD5_Init(&md5_ctx);
        MD5_Update(&md5_ctx, sharekey, 128);
        MD5_Final(MD5result, &md5_ctx);
        [securtDictionary setValue:[NSData dataWithBytes:MD5result length:16] forKey:@"sharekeyMD5"];
    }
    return securtDictionary;
}

@end
