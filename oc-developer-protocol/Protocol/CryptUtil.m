//
//  CryptUtil.m
//  oc-developer-protocol
//
//  Created by Huasali on 2021/11/25.
//

#import "CryptUtil.h"

@implementation CryptUtil

+ (NSDictionary *)inputData{
    return @{@"data":@"1234567890abcd_ @😁",
             @"key":@"B77331A8705A7D788E74ECFC44F74423",
             @"iv":@"LM2Uc6PXE3F6xfru"};
}
+ (NSDictionary *)outputData{
    return @{@"data":@"1046235D48F35BED5F27D65661B4715577B57EBBB8B908E77395B7BDE03B1ECF"};
}

+ (void)cryptTest:(void(^)(NSString *log))callback{
  
}

@end
