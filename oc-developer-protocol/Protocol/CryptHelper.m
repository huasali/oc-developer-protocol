//
//  CryptHelper.m
//  oc-developer-protocol
//
//  Created by Huasali on 2021/11/25.
//

#import "CryptHelper.h"
#import <objc/runtime.h>
#import <dlfcn.h>
#import <mach-o/ldsyms.h>

@implementation CryptHelper

+ (NSData *)appendCountPadding:(NSData *)data{
    int count = 16 - data.length%16;
    NSMutableData *appendData = [NSMutableData dataWithData:data];
    [appendData appendData:[self countPaddingData:count]];
    return appendData;
}
+ (NSData *)countPaddingData:(int)count{
    Byte byte[count];
    for (int i = 0; i < count; i++) {
        byte[i] = count;
    }
    return [NSData dataWithBytes:byte length:sizeof(byte)];
}
+ (NSData *)subCountPaddingData:(NSData *)data{
    if (data.length > 0) {
        Byte *dataByte = (Byte *)data.bytes;
        int length = dataByte[data.length - 1];
        if (data.length > length) {
            return  [data subdataWithRange:NSMakeRange(0, data.length - length)];
        }
    }
    return  data;
}
+ (NSString *)jsonStringFromDictionary:(NSDictionary *)dic{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    if (!jsonString) {
        jsonString = @"";
    }
    return jsonString;
}
+ (NSDictionary *)dictionaryFromJsonString:(NSString *)string{
    if (string) {
        NSError* error = nil;
        NSString *jsonString = [string stringByReplacingOccurrencesOfString:@"\0" withString:@""];
        NSData  *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        return dic;
    }
    else{
        return @{};
    }
}
+ (NSData *)dataFromBytesString:(NSString *)string{
    NSString *jsonString = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSMutableData* data = [NSMutableData data];
    int idx;
    for (idx = 0; idx+2 <= jsonString.length; idx+=2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [jsonString substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    return data;
}
+ (NSString *)bytesStringFromData:(NSData *)data{
    if (data) {
        Byte *byte = (Byte *)[data bytes];
        NSString *string = [NSString new];
        for (int i=0; i<data.length; i++) {
            NSString *tempStr = [NSString stringWithFormat:@"%02X",byte[i]];
            string = [string stringByAppendingString:tempStr];
        }
        return string;
    }
    return @"";
}
+ (NSString *)stringFromData:(NSData *)data{
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}
+ (NSData *)dataFromString:(NSString *)string{
    return [string dataUsingEncoding:NSUTF8StringEncoding];;
}
+ (NSString *)logStringFromObject:(id)data{
    if (!data) {
        return @"";
    }
    NSString *jsonString = @"";
    if ([data isKindOfClass:[NSDictionary class]]) {
        NSMutableArray *tempDataArr = [NSMutableArray array];
        for (NSString *key in data) {
            [tempDataArr addObject:[NSString stringWithFormat:@"%@:%@",key,[self logStringFromObject:data[key]]]];
        }
        jsonString = [NSString stringWithFormat:@"{%@}",[tempDataArr componentsJoinedByString:@","]];
    }
    else if ([data isKindOfClass:[NSArray class]]){
        NSMutableArray *tempDataArr = [NSMutableArray array];
        for (id object in data) {
            [tempDataArr addObject:[self logStringFromObject:object]];
        }
        jsonString = [NSString stringWithFormat:@"(%@)",[tempDataArr componentsJoinedByString:@","]];
    }
    else{
        jsonString = [NSString stringWithFormat:@"%@",data];
    }
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\0" withString:@""];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@" " withString:@""];
    return jsonString;
}
+ (NSArray <Class> *)classesInfo{
    NSMutableArray *resultArray = [NSMutableArray array];
    unsigned int classCount;
    const char **classes;
    Dl_info info;
    dladdr(&_mh_execute_header, &info);
    classes = objc_copyClassNamesForImage(info.dli_fname, &classCount);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    dispatch_apply(classCount, dispatch_get_global_queue(0, 0), ^(size_t index) {
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        NSString *className = [NSString stringWithCString:classes[index] encoding:NSUTF8StringEncoding];
        if ([className hasSuffix:@"CryptUtil"]&&className.length>@"CryptUtil".length) {
            [resultArray addObject:className];
        }
        dispatch_semaphore_signal(semaphore);
    });
    return resultArray.mutableCopy;
}

@end
