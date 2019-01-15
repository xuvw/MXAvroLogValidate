//
//  NSDictionary+MXAvro.m
//  MXAvroLogValidator
//
//  Created by heke on 2018/10/12.
//  Copyright © 2018 MX. All rights reserved.
//

#import "NSDictionary+MXAvro.h"

@implementation NSDictionary (MXAvro)

- (void)validateAvroLogWith:(avroLogValidateHandler)handler {
    [MXAvroLogValidator validate:self completeHandler:handler];
}

@end
