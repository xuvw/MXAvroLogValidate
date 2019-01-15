//
//  MXAvroLogValidator.h
//  MXAvroLogValidator
//
//  Created by heke on 2018/10/12.
//  Copyright © 2018 MX. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const avroRootPath;
typedef void(^avroLogValidateHandler)(BOOL validateResult,NSDictionary *invalidatePathDic);

@interface MXAvroLogValidator : NSObject

/**
 filePath  schema文件路径
 */
+ (void)configWithRootSchema:(NSString *)rootSchema subSchemas:(NSArray *)fileNameList;

+ (void)validate:(NSDictionary *)avroLog
 completeHandler:(avroLogValidateHandler)handler;

@end

NS_ASSUME_NONNULL_END
