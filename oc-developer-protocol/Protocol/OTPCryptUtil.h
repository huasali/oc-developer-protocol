//
//  OTPCryptUtil.h
//  oc-developer-protocol
//
//  Created by Huasali on 2021/11/25.
//

#import <Foundation/Foundation.h>
#import "CryptUtil.h"

NS_ASSUME_NONNULL_BEGIN

@interface OTPCryptUtil : CryptUtil

/// One-Time Password
/// @param pwdData 密码
/// @param time 时间
/// @param key key
+ (NSData *)otpHashWithPWD:(NSData *)pwdData time:(uint32_t)time key:(uint32_t)key;

@end

NS_ASSUME_NONNULL_END
