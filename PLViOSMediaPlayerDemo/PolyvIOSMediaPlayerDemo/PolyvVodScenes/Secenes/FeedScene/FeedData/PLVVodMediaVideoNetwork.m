//
//  PLVVodMediaVideoNetwork.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/11/8.
//

#import "PLVVodMediaVideoNetwork.h"
#import <PolyvMediaPlayerSDK/PolyvMediaPlayerSDK.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

#define PLV_HM_POST @"POST"
#define PLV_HM_GET @"GET"

NSString *PLVVodMediaNetworkingErrorDomain = @"net.polyv.mediaplayer.error.networking";

@implementation PLVVodMediaVideoNetwork

/// 请求账户下的视频列表
+ (void)requestAccountVideoWithPageCount:(NSInteger)pageCount page:(NSInteger)page completion:(void (^)(NSArray<NSDictionary *> *accountVideos))completion; {
    PLVVodMediaSettings *settings = [PLVVodMediaSettings sharedSettings];
    NSString *url = [NSString stringWithFormat:@"https://api.polyv.net/v2/video/%@/list", settings.userid];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"userid"] = settings.userid;
    params[@"ptime"] = [self timestamp];
    params[@"numPerPage"] = @(pageCount);
    params[@"pageNum"] = @(page);
    
    NSMutableURLRequest *request = [self requestWithUrl:url method:PLV_HM_GET params:[self addSign:params]];
    [self requestData:request success:^(NSDictionary * _Nonnull dic) {
        NSArray *videos = dic[@"data"];
        NSMutableArray *accountVideos = [NSMutableArray array];
        for (NSDictionary *videoDic in videos) {
            NSMutableDictionary *dict  = [[NSMutableDictionary alloc] init];
            NSInteger status = [[videoDic objectForKey:@"status"] intValue];
            if (status >= 60){
                [dict setObject:videoDic[@"vid"] forKey:@"vid"];
                [accountVideos addObject:dict];
            }
        }
        !completion ?: completion(accountVideos);
    } failure:nil];
}

/// 时间戳
+ (NSString *)timestamp {
    float timeInterval = [NSDate date].timeIntervalSince1970 * 1000;
    NSString *timeStr = [NSString stringWithFormat:@"%.0f", timeInterval];
    return timeStr;
}

/// 快速生成Request
+ (NSMutableURLRequest *)requestWithUrl:(NSString *)url method:(NSString *)HTTPMethod params:(NSDictionary *)paramDic {
    NSString *urlString = url.copy;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    if (paramDic.count) {
        NSString *parameters = [self convertDictionaryToSortedString:paramDic];
        if ([PLV_HM_GET isEqualToString:HTTPMethod]) {
            urlString = [NSString stringWithFormat:@"%@?%@", urlString, parameters];
        }else if ([PLV_HM_POST isEqualToString:HTTPMethod]){
            NSData *bodyData = [parameters dataUsingEncoding:NSUTF8StringEncoding];
            request.HTTPBody = bodyData;
        }
    }
    
    NSURL *URL = [NSURL URLWithString:urlString];
    request.URL = URL;
    request.HTTPMethod = HTTPMethod;
    request.timeoutInterval = 10;
    
    //NSString *userAgent = [NSString stringWithFormat:@"polyv-ios-sdk_%@", PLVVodMediaSdkVersion];
    //[request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    return request;
}


+ (void)requestData:(NSURLRequest *)request
            success:(void (^)(NSDictionary *dic))successHandler
            failure:(void (^)(NSError *error))failureHandler {
    [self requestData:request completion:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error) {
            !failureHandler ?: failureHandler(error);
            return;
        }
        
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        if (error){
            NSLog(@"JSONReading error = %@", error.localizedDescription);
            NSLog(@"%@ - 请求结果 = \n%@", request.URL, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            !failureHandler ?: failureHandler(error);
            return;
        }
        
        NSInteger code = [responseDic[@"code"] integerValue];
        if (code != 200) {
            NSString *status = responseDic[@"status"];
            NSString *message = responseDic[@"message"];
            NSLog(@"%@, %@", status, message);
            !failureHandler ?: failureHandler(nil);
            return;
        }
        
        !successHandler ?: successHandler(responseDic);
    }];
}

+ (void)requestData:(NSURLRequest *)request completion:(void (^)(NSData *data, NSError *error))completion {
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSInteger httpStatusCode = httpResponse.statusCode;
        if (error) { // 网络错误
            if (completion) completion(nil, error);
            NSLog(@"网络错误: %@", error);
        } else if (httpStatusCode != 200) { // 服务器错误
            NSString *errorMessage = [NSString stringWithFormat:@"服务器响应失败，状态码:%zd",httpResponse.statusCode];
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:errorMessage forKey:NSLocalizedDescriptionKey];
            NSError *serverError = [NSError errorWithDomain:PLVVodMediaNetworkingErrorDomain code:httpStatusCode userInfo:userInfo];
            if (completion) completion(nil, serverError);
            NSLog(@"%@，服务器错误: %@", request.URL.absoluteString, serverError);
        } else {
            if (completion) completion(data, nil);
        }
    }] resume];
}

+ (NSDictionary *)addSign:(NSDictionary *)params {
    NSMutableDictionary *resultParams = [[NSMutableDictionary alloc] initWithDictionary:params];
    
    NSString *paramString = [self convertDictionaryToSortedString:params];
#ifdef PLVSupportSubAccount
    NSMutableString *plainSign = [NSMutableString stringWithFormat:@"%@%@", paramString, PLVVodMediaSecretKey];
#else
    NSMutableString *plainSign = [NSMutableString stringWithFormat:@"%@%@", paramString, [PLVVodMediaSettings sharedSettings].secretkey];

#endif
    resultParams[@"sign"] = [self getSha1WithString:plainSign].uppercaseString;
    return [resultParams copy];
}

+ (NSString *)convertDictionaryToSortedString:(NSDictionary *)params {
    NSArray *keys = [params allKeys];
    keys = [keys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2 options:NSCaseInsensitiveSearch];
    }];
    NSMutableString *paramStr = [NSMutableString string];
    for (int i = 0; i < keys.count; i ++) {
        NSString *key = keys[i];
        [paramStr appendFormat:@"%@=%@", key, params[key]];
        if (i == keys.count - 1) break;
        [paramStr appendString:@"&"];
    }
    return [paramStr copy];
}

+ (NSString *)getSha1WithString:(NSString *)string {
    const char *cstr = [string cStringUsingEncoding:NSUTF8StringEncoding];
    
    NSData *data = [NSData dataWithBytes:cstr length:string.length];
    //使用对应的CC_SHA1,CC_SHA256,CC_SHA384,CC_SHA512的长度分别是20,32,48,64
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    //使用对应的CC_SHA256,CC_SHA384,CC_SHA512
    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}

@end
