//
//  CryptHelper.h
//  oc-developer-protocol
//
//  Created by Huasali on 2021/11/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define DataLog(fmt, ...) [NSString stringWithFormat:fmt,##__VA_ARGS__]

@interface CryptHelper : NSObject

+ (NSData *)appendCountPadding:(NSData *)data;
+ (NSData *)subCountPaddingData:(NSData *)data;

/// 字典转字符串
/// @param dic 字典
+ (NSString *)jsonStringFromDictionary:(NSDictionary *)dic;

/// 字符串转字典
/// @param string 字符串
+ (NSDictionary *)dictionaryFromJsonString:(NSString *)string;

/// 字节字符串转data
/// @param string 字节字符串
+ (NSData *)dataFromBytesString:(NSString *)string;

/// data转字节字符串
/// @param data data
+ (NSString *)bytesStringFromData:(NSData *)data;

/// data按utf-8转字符串
/// @param data data
+ (NSString *)stringFromData:(NSData *)data;

/// 字符传按utf-8转data
/// @param string 字符串
+ (NSData *)dataFromString:(NSString *)string;

/// Description 任意类型转字符串
/// @param data 任意数据
+ (NSString *)logStringFromObject:(id)data;

+ (NSArray <Class> *)classesInfo;

@end

NS_ASSUME_NONNULL_END
