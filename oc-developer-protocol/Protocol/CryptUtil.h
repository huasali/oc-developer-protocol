//
//  CryptUtil.h
//  oc-developer-protocol
//
//  Created by Huasali on 2021/11/25.
//

#import <Foundation/Foundation.h>
#import "CryptHelper.h"

NS_ASSUME_NONNULL_BEGIN

@interface CryptUtil : NSObject

+ (NSMutableDictionary *)inputData;
+ (NSMutableDictionary *)outputData;
/// 测试数据
/// @param callback log回调
+ (void)cryptTest:(void(^)(NSString *log))callback;

@end

NS_ASSUME_NONNULL_END
