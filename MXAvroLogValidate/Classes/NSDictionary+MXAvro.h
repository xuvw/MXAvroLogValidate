//
//  NSDictionary+MXAvro.h
//  MXAvroLogValidator
//
//  Created by heke on 2018/10/12.
//  Copyright © 2018 MX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MXAvroLogValidator.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (MXAvro)

- (void)validateAvroLogWith:(avroLogValidateHandler)handler;

@end

NS_ASSUME_NONNULL_END
