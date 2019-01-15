//
//  MXAvroLogValidator.m
//  MXAvroLogValidator
//
//  Created by heke on 2018/10/12.
//  Copyright © 2018 MX. All rights reserved.
//

#import "MXAvroLogValidator.h"

#define KRootSchema     @"KRootSchema"

#define KAvroTypeBOOL   @"boolean"
#define KAvroTypeInt    @"int"
#define KAvroTypeLong   @"long"
#define KAvroTypeFloat  @"float"
#define KAvroTypeDouble @"double"
#define KAvroTypeBytes  @"bytes"
#define KAvroTypeString @"string"

#define KAvroTypeRecord @"record"
#define KAvroTypeEnum   @"enum"
#define KAvroTypeArray  @"array"
#define KAvroTypeMap    @"map"
#define KAvroTypeFixed  @"fixed"

#define KAvroDataNULL   @"null"

NSString *const avroRootPath = @"->";

@interface MXAvroType : NSObject

//base type meta info
@property (nonatomic, copy)   NSObject     *type;//schema存在这里，非basetype，需做次映射
@property (nonatomic, copy)   NSString     *name;
@property (nonatomic, copy)   NSObject     *schema;

@property (nonatomic, copy)   NSArray      *fields;
@property (nonatomic, strong) NSArray      *symbols;//for enum
@property (nonatomic, strong) NSObject     *items;  //for array
@property (nonatomic, strong) MXAvroType *itemsType;
@property (nonatomic, strong) NSObject     *values; //for map
@property (nonatomic, strong) MXAvroType *valuesType;
@property (nonatomic, assign) NSInteger    size;    //for fixed

@property (nonatomic, assign, getter=isRootSchema) BOOL rootSchema;

@property (nonatomic, assign, getter=isOptional)   BOOL optional;
@property (nonatomic, assign, getter=isBaseType)   BOOL baseType;

@property (nonatomic, assign, getter=isRecord)     BOOL record;
@property (nonatomic, assign, getter=isArray)      BOOL array;
@property (nonatomic, assign, getter=ismap)        BOOL map;

@end

@implementation MXAvroType

- (instancetype)init
{
    self = [super init];
    if (self) {
        _optional = NO;
        _baseType = YES;
        _rootSchema = NO;
    }
    return self;
}

- (BOOL)isBaseType {
    NSArray *baseTypes = @[KAvroTypeBOOL,
                           KAvroTypeInt,
                           KAvroTypeLong,
                           KAvroTypeFloat,
                           KAvroTypeDouble,
                           KAvroTypeBytes,
                           KAvroTypeEnum,
                           KAvroTypeString];
    
    if ([_type isKindOfClass:[NSString class]] && [baseTypes containsObject:_type] ) {
        return YES;
    }
    return NO;
}

+ (BOOL)isAvroType:(NSObject *)avroDataType {
    NSArray *baseTypes = @[KAvroTypeBOOL,
                           KAvroTypeInt,
                           KAvroTypeLong,
                           KAvroTypeFloat,
                           KAvroTypeDouble,
                           KAvroTypeBytes,
                           KAvroTypeString,
                           KAvroTypeArray,
                           KAvroTypeEnum,
                           KAvroTypeFixed,
                           KAvroTypeMap];
    if ([baseTypes containsObject:avroDataType]) {
        return YES;
    }
    return NO;
}

- (BOOL)isRecord {
    if ([_type isKindOfClass:[NSString class]] &&
        [(NSString *)_type isEqualToString:KAvroTypeRecord]) {
        return YES;
    }
    return NO;
}

- (BOOL)isArray {
    if ([_type isKindOfClass:[NSString class]] &&
        [(NSString *)_type isEqualToString:KAvroTypeArray]) {
        return YES;
    }
    return NO;
}

- (BOOL)ismap {
    if ([_type isKindOfClass:[NSString class]] &&
        [(NSString *)_type isEqualToString:KAvroTypeMap]) {
        return YES;
    }
    return NO;
}

@end

@interface MXAvroLogValidator()

@property (nonatomic, copy)   NSString     *rootSchemaName;
@property (nonatomic, strong) NSDictionary *schemaMap;

@end

static inline NSDictionary * validateAvroLog(NSObject *avroLog,
                                             NSObject *logSchema,
                                             NSString *path);

@implementation MXAvroLogValidator

static inline NSDictionary *loadSchema(NSString *schemaBundleFileName);

+ (void)configWithRootSchema:(NSString *)rootSchema subSchemas:(NSArray *)fileNameList {
    
    MXAvroLogValidator *lv = [MXAvroLogValidator sharedInstance];
    lv.rootSchemaName = rootSchema;
    NSMutableDictionary *dic = @{}.mutableCopy;
    [dic setObject:loadSchema(rootSchema) forKey:rootSchema];
    [fileNameList enumerateObjectsUsingBlock:^(NSString *_Nonnull fileName, NSUInteger idx, BOOL * _Nonnull stop) {
        [dic setObject:loadSchema(fileName) forKey:fileName];
    }];
    lv.schemaMap = dic;
    
}

#pragma mark - 验证入口
+ (void)validate:(NSDictionary *)avroLog
 completeHandler:(avroLogValidateHandler)handler {
    
    MXAvroLogValidator *lv = [MXAvroLogValidator sharedInstance];
    NSDictionary  *schema = [lv.schemaMap objectForKey:lv.rootSchemaName];
    
    NSDictionary *invalidatePath = validateAvroLog(avroLog, schema, avroRootPath);
    if (invalidatePath.count < 1) {
        handler(YES, @{});
    }else {
        handler(NO, invalidatePath);
    }
}

#pragma mark - private:
+ (instancetype)sharedInstance {
    static MXAvroLogValidator *avroLogValidate = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        avroLogValidate = [[MXAvroLogValidator alloc] init];
    });
    return avroLogValidate;
}

@end

/**
 http://avro.apache.org/docs/1.8.2/spec.html#schema_primitive
 */

static inline MXAvroType * avroTypeFrom(NSObject *field);
static inline NSString * validFixed(NSObject *fixedObj, MXAvroType *at);
static inline NSString * validBytes(NSObject *fixedObj, MXAvroType *at);

#define isLongLong(obj) strcmp([(NSValue *)obj objCType], @encode(long long)) == 0
#define isFloat(obj)    strcmp([(NSValue *)obj objCType], @encode(double)) == 0
#define isBOOL(obj)     strcmp([(NSValue *)obj objCType], @encode(char)) == 0

static inline NSDictionary * validateAvroLog(NSObject *avroLog, NSObject *logSchema, NSString *path) {
    NSLog(@"%@",path);
    NSMutableDictionary *invalidatePathes = @{}.mutableCopy;
    
    MXAvroType *rootAt = avroTypeFrom(logSchema);
    rootAt.rootSchema = YES;
    if ([path isEqualToString:avroRootPath]) {
        if (rootAt.fields.count < 1) {
            NSLog(@"Avro ----- 无法验证");
            [invalidatePathes setObject:@"root avro can not be validate" forKey:path];
            return invalidatePathes;
        }
    }
    NSString *currentPath = [NSString stringWithFormat:@"%@.%@",path,rootAt.name];
    if ([rootAt.type isKindOfClass:[NSString class]] && avroLog) {
        
        if ([(NSString *)rootAt.type isEqualToString:KAvroTypeBOOL]) {
            if ([avroLog respondsToSelector:@selector(objCType)] && isBOOL(avroLog)) {
                //
            }else {
                [invalidatePathes setObject:@"invalid neen bool" forKey:currentPath];
            }
        }else if ([(NSString *)rootAt.type isEqualToString:KAvroTypeInt]) {
            if ([avroLog respondsToSelector:@selector(objCType)] && isLongLong(avroLog)) {
                //
            }else {
                [invalidatePathes setObject:@"invalid neen long" forKey:currentPath];
            }
        }else if ([(NSString *)rootAt.type isEqualToString:KAvroTypeLong]) {
            if ([avroLog respondsToSelector:@selector(objCType)] && isLongLong(avroLog)) {
                //
            }else {
                [invalidatePathes setObject:@"invalid neen long" forKey:currentPath];
            }
        }else if ([(NSString *)rootAt.type isEqualToString:KAvroTypeFloat]) {
            if ([avroLog respondsToSelector:@selector(objCType)] && isFloat(avroLog)) {
                //
            }else {
                [invalidatePathes setObject:@"invalid neen float" forKey:currentPath];
            }
        }else if ([(NSString *)rootAt.type isEqualToString:KAvroTypeDouble]) {
            if ([avroLog respondsToSelector:@selector(objCType)] && isFloat(avroLog)) {
                //
            }else {
                [invalidatePathes setObject:@"invalid neen float" forKey:currentPath];
            }
        }else if ([(NSString *)rootAt.type isEqualToString:KAvroTypeBytes]) {//字典
            NSString *result = validBytes(avroLog, rootAt);
            if (result.length > 0) {
                [invalidatePathes setObject:result forKey:currentPath];
            }
        }else if ([(NSString *)rootAt.type isEqualToString:KAvroTypeString]) {
            if ([avroLog isKindOfClass:[NSString class]]) {
                //
            }else {
                [invalidatePathes setObject:@"invalid neen string" forKey:currentPath];
            }
        }else if ([(NSString *)rootAt.type isEqualToString:KAvroTypeRecord]) {
            [invalidatePathes addEntriesFromDictionary:validateAvroLog(avroLog, rootAt.schema, currentPath)];
        }else if ([(NSString *)rootAt.type isEqualToString:KAvroTypeEnum]) {
            if ([avroLog isKindOfClass:[NSString class]] && rootAt.symbols.count > 0) {
                if ([rootAt.symbols containsObject:(NSString *)avroLog]) {
                    //
                }else {
                    [invalidatePathes setObject:@"enum flag not exist" forKey:currentPath];
                }
            }else {
                [invalidatePathes setObject:@"enum flag not exist" forKey:currentPath];
            }
        }else if ([(NSString *)rootAt.type isEqualToString:KAvroTypeArray]) {
            if ([avroLog isKindOfClass:[NSArray class]]) {
                NSArray *avroLogArr = (NSArray *)avroLog;
                NSString *tempPath = nil;
                for (NSInteger i = 0; i < avroLogArr.count; ++i) {
                    tempPath = [NSString stringWithFormat:@"%@[%li]",currentPath,i];
                    [invalidatePathes addEntriesFromDictionary:validateAvroLog(avroLogArr[i], rootAt.items, tempPath)];
                }
            }
        }else if ([(NSString *)rootAt.type isEqualToString:KAvroTypeMap]) {
            if ([avroLog isKindOfClass:[NSDictionary class]]) {
                NSDictionary *avroLogDic = (NSDictionary *)avroLog;
                NSArray *keys = [avroLogDic allKeys];
                NSString *tempPath = nil;
                for (NSString *key in keys) {
                    tempPath = [NSString stringWithFormat:@"%@[%@]",currentPath,key];
                    [invalidatePathes addEntriesFromDictionary:validateAvroLog([avroLogDic objectForKey:key], rootAt.values, tempPath)];
                }
            }
        }else if ([(NSString *)rootAt.type isEqualToString:KAvroTypeFixed]) {//数组
            NSString *result = validFixed(avroLog, rootAt);
            if (result.length > 0) {
                [invalidatePathes setObject:result forKey:currentPath];
            }
        }else {
            [invalidatePathes setObject:@"not avro type" forKey:currentPath];
        }
    }else {
        if (!avroLog && !rootAt.isOptional) {
            [invalidatePathes setObject:@"path not optional..." forKey:currentPath];
        }
    }
    
    NSDictionary *avroLogDic = (NSDictionary *)avroLog;
    
    for (NSDictionary *field in rootAt.fields) {
        MXAvroType *at = avroTypeFrom(field);
        NSObject *log = [avroLogDic objectForKey:at.name];
        if (!log && at.isOptional) {
            continue;
        }
        NSString *tmpPath = [NSString stringWithFormat:@"%@.%@",currentPath,at.name];
        [invalidatePathes addEntriesFromDictionary:validateAvroLog(log, at.type, tmpPath)];
    }
    
    return invalidatePathes;
}

/*
 "fixedValue":[
 ]
 */
static inline NSString * validFixed(NSObject *fixedObj, MXAvroType *at) {//数组
    NSString *error = nil;
    if ([fixedObj isKindOfClass:[NSArray class]]) {
        if ([(NSArray *)fixedObj count] > at.size) {
            error = [NSString stringWithFormat:@"fixed value's length:%li > size:%li",[(NSArray *)fixedObj count],at.size];
        }
    }else {
        error = [NSString stringWithFormat:@"fixed value type error need array but you give %@",NSStringFromClass([fixedObj class])];
    }
    return error;
}

/*
 "byteValue":{
 "bytes":""
 }
 */
static inline NSString * validBytes(NSObject *bytesdObj, MXAvroType *at) {//字典
    
    NSString *error = nil;
    if (![bytesdObj isKindOfClass:[NSDictionary class]]) {
        error = [NSString stringWithFormat:@"bytes need dictionary type but you give:%@",NSStringFromClass([bytesdObj class])];
    }
    return error;
}

static inline MXAvroType * avroTypeFrom(NSObject *fieldType) {
    
    MXAvroType *avroType = [[MXAvroType alloc] init];
    if ([fieldType isKindOfClass:[NSString class]]) {
        NSString *typeString = (NSString *)fieldType;
        avroType.type = typeString;
        return avroType;
    }
    NSDictionary *field = (NSDictionary *)fieldType;
    
    avroType.name = [field objectForKey:@"name"];
    NSObject *type = [field objectForKey:@"type"];
    if ([type isKindOfClass:[NSArray class]]) {
        NSArray *typeArr = (NSArray *)type;
        NSInteger typeIndex = ([typeArr indexOfObject:KAvroDataNULL] + 1) % 2;
        avroType.type = typeArr[typeIndex];
        avroType.optional = YES;
    }else {
        avroType.optional = NO;
        avroType.type = type;
    }
    avroType.fields = [field objectForKey:@"fields"];
    
    if ([type isKindOfClass:[NSString class]]) {
        NSString *typeString = (NSString *)type;
        if ([typeString isEqualToString:KAvroTypeArray]) {
            avroType.items = [field objectForKey:@"items"];
        }else if ([typeString isEqualToString:KAvroTypeMap]) {
            avroType.values = [field objectForKey:@"values"];
        }else if ([typeString isEqualToString:KAvroTypeEnum]) {
            avroType.symbols = [field objectForKey:@"symbols"];
        }else if ([typeString isEqualToString:KAvroTypeFixed]) {
            avroType.size = [[field objectForKey:@"size"] integerValue];
        }
        
        if (![MXAvroType isAvroType:typeString]) {
            
            NSDictionary *schema = [[MXAvroLogValidator sharedInstance].schemaMap objectForKey:avroType.name];
            if (schema.count > 0) {
                avroType.type = schema;
            }else {
                schema = [[MXAvroLogValidator sharedInstance].schemaMap objectForKey:typeString];
                if (schema.count > 0) {
                    avroType.type = schema;
                }else {
                    NSLog(@"avro----type:%@",typeString);
                }
            }
            if (avroType.type && avroType.fields.count < 1) {
                avroType.fields = [(NSDictionary *)avroType.type objectForKey:@"fields"];
            }
        }
    }
    
    return avroType;
}

static inline NSDictionary *loadSchema(NSString *schemaBundleFileName) {
    NSString  *schemaFilePath = [[NSBundle mainBundle] pathForResource:schemaBundleFileName ofType:@"avsc"];
    NSData *rawData = [NSData dataWithContentsOfFile:schemaFilePath];
    
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:rawData options:NSJSONReadingMutableContainers error:&error];
    
    if (error != nil) {
        return @{};
    }
    
    return (NSDictionary *)jsonObject;
}
