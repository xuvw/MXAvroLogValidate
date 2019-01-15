//
//  MXAppDelegate.m
//  MXAvroLogValidate
//
//  Created by xuvw on 01/15/2019.
//  Copyright (c) 2019 xuvw. All rights reserved.
//

#import "MXAppDelegate.h"
@import MXAvroLogValidate;

@implementation MXAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
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
    
    NSString *json = @"{\"eventType\":\"createCarOrder\",\"userId\":\"userId\",\"traceId\":\"traceId\",\"distinctId\":\"distinctId\",\"project\":\"project\",\"uri\":\"uri\",\"host\":\"host\",\"startTime\":-1000,\"endTime\":-1000,\"status\":-1000,\"client\":{\"clientType\":\"clientType\",\"accessKey\":\"accessKey\",\"manufacturer\":\"manufacturer\",\"model\":\"model\",\"os\":\"os\",\"osVersion\":\"osVersion\",\"ip\":\"ip\",\"browser\":\"browser\",\"browserVersion\":\"browserVersion\",\"appVersion\":\"appVersion\"},\"userInfo\":{\"uname\":\"uname\",\"userType\":\"userType\",\"userToken\":\"userToken\"},\"order\":{\"hotelOrder\":{\"createHotelOrder\":{\"orderNo\":\"orderNo\",\"hotelId\":-1000,\"hotelName\":\"hotelName\"},\"submitHotelOrder\":{\"orderNo\":\"orderNo\",\"priceActual\":-1000}},\"carOrder\":{\"createCarOrder\":{\"orderNo\":\"orderNo\",\"goodNo\":\"goodNo\",\"orderType\":\"orderType\"},\"submitCarOrder\":{\"orderNo\":\"orderNo\",\"goodNo\":\"goodNo\",\"orderType\":\"orderType\",\"priceActual\":-1000}}}}";
    NSData *rawData = [json dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error = nil;
    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:rawData options:NSJSONReadingMutableContainers error:&error];
    
    NSDictionary *dic = jsonObject;
    [dic validateAvroLogWith:^(BOOL validateResult, NSDictionary * _Nonnull invalidatePathDic) {
        if (!validateResult) {
            NSLog(@"校验失败:%@",invalidatePathDic);
        }else {
            NSLog(@"校验成功");
        }
    }];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
