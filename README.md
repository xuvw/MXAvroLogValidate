# MXAvroLogValidate

[![CI Status](https://img.shields.io/travis/xuvw/MXAvroLogValidate.svg?style=flat)](https://travis-ci.org/xuvw/MXAvroLogValidate)
[![Version](https://img.shields.io/cocoapods/v/MXAvroLogValidate.svg?style=flat)](https://cocoapods.org/pods/MXAvroLogValidate)
[![License](https://img.shields.io/cocoapods/l/MXAvroLogValidate.svg?style=flat)](https://cocoapods.org/pods/MXAvroLogValidate)
[![Platform](https://img.shields.io/cocoapods/p/MXAvroLogValidate.svg?style=flat)](https://cocoapods.org/pods/MXAvroLogValidate)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

MXAvroLogValidate is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'MXAvroLogValidate'
```

##Usage
```objective-c
NSArray *schemas = @[@"BaseLog",
                         @"CreateHotelOrder",
                         @"SubmitCarOrder",
                         @"CarOrder",
                         @"EventType",
                         @"SubmitHotelOrder",
                         @"Client",
                         @"HotelOrder",
                         @"UserInfo",
                         @"CreateCarOrder",
                         @"Order"];
    [MXAvroLogValidator configWithRootSchema:@"BaseLog" subSchemas:schemas];
    NSDictionary *dic = jsonObject;
    [dic validateAvroLogWith:^(BOOL validateResult, NSDictionary * _Nonnull invalidatePathDic) {
        if (!validateResult) {
            NSLog(@"校验失败:%@",invalidatePathDic);
        }else {
            NSLog(@"校验成功");
        }
    }];
```

## Author

xuvw, smileshitou@hotmail.com

## License

MXAvroLogValidate is available under the MIT license. See the LICENSE file for more info.
