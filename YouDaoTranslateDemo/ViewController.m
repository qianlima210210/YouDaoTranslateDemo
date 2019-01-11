//
//  ViewController.m
//  YouDaoTranslateDemo
//
//  Created by ma qianli on 2019/1/9.
//  Copyright © 2019 ma qianli. All rights reserved.
//

#import "ViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <CommonCrypto/CommonDigest.h>

@interface ViewController ()
@property (nonatomic, strong) NSURLSessionDataTask *task;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSString *from = @"AUTO";
    NSString *to = @"";
    ///////////////////
    
    NSString *q = @"1、本人总经理秘书，前几天老总老板娘还有几个同事私下吃饭，老总喝得高兴，看着我说：小兰啊，你该减肥了，公司食堂好，你也要控制埃没等我开口老板娘说话了，人家不胖，刚刚好，小兰别听他的。老总一激动说，还不胖？那天把我大腿差点坐折了。。。老板娘，你听我解释，那天是我绊了一跤刚好坐老总身上了，不是你想的那样的。。。";
    
    ///////////////////////
    NSString *url = @"http://fanyi.youdao.com/translate?smartresult=dict&smartresult=rule&smartresult=ugc";
    
    NSString *u = @"fanyideskweb";
    NSString *d = q;
    long ctime = (long)[NSDate date].timeIntervalSince1970 * 1000;
    NSString *f = [NSString stringWithFormat:@"%zd", ctime + rand() % 10 + 1];
    NSString *c = @"ebSeFb%=XZ%T[KZ)c(sy!";
    
    //String sign = md5(u + d + f + c);
    NSString *input = [NSString stringWithFormat:@"%@%@%@%@", u, d, f, c];
    NSString *sign = [self md5_32bit:input];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:q forKey:@"i"];
    [params setObject:from forKey:@"from"];
    [params setObject:to forKey:@"to"];
    [params setObject:@"dict" forKey:@"smartresult"];
    [params setObject:@"fanyideskweb" forKey:@"client"];
    [params setObject:f forKey:@"salt"];
    [params setObject:sign forKey:@"sign"];
    [params setObject:@"json" forKey:@"doctype"];
    [params setObject:@"2.1" forKey:@"version"];
    [params setObject:@"fanyi.web" forKey:@"keyfrom"];
    [params setObject:@"FY_BY_CLICKBUTTION" forKey:@"action"];
    [params setObject:@"true" forKey:@"typoResult"];
    
    __block NSMutableString *queryString = [NSMutableString new];
    [params enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *value = [self URLEncodedString:obj];
        [queryString appendFormat:@"%@=%@&", key, value];
    }];
    //删除最后一个“&”
    [queryString deleteCharactersInRange:NSMakeRange(queryString.length - 1, 1)];
    //url = [NSString stringWithFormat:@"%@&%@", url, queryString];

    
    NSURL *url1 = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url1 cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [queryString dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setValue:[NSString stringWithFormat:@"%@%zd",@"OUTFOX_SEARCH_USER_ID_NCOO=1537643834.9570553; OUTFOX_SEARCH_USER_ID=1799185238@10.169.0.83; fanyi-ad-id=43155; fanyi-ad-closed=1; JSESSIONID=aaaBwRanNsqoobhgvaHmw; _ntes_nnid=07e771bc10603d984c2dc8045a293d30,1525267244050; ___rl__test__cookies=", ctime] forHTTPHeaderField:@"Cookie"];
    
    [request setValue:@"http://fanyi.youdao.com/" forHTTPHeaderField:@"Referer"];
    [request setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:64.0) Gecko/20100101 Firefox/64.0" forHTTPHeaderField:@"User-Agent"];
    
     self.task = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
         NSLog(@"%@", responseObject);
         NSLog(@"%@", self.task);
         NSArray *array = responseObject[@"translateResult"];
         
         for (NSArray *subarray in array) {
             for (NSDictionary *dic in subarray) {
                 NSLog(@"%@, %@", dic[@"src"], dic[@"tgt"]);
             }
         }
    }];
    
    [self.task resume];
}

- (NSString *)md5_32bit:(NSString *)input {
    //传入参数,转化成char
    const char * str = [input UTF8String];
    //开辟一个16字节（128位：md5加密出来就是128位/bit）的空间（一个字节=8字位=8个二进制数）
    unsigned char md[CC_MD5_DIGEST_LENGTH];
    /*
     extern unsigned char * CC_MD5(const void *data, CC_LONG len, unsigned char *md)官方封装好的加密方法
     把str字符串转换成了32位的16进制数列（这个过程不可逆转） 存储到了md这个空间中
     */
    CC_MD5(str, (int)strlen(str), md);
    //创建一个可变字符串收集结果
    NSMutableString * ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        /**
         X 表示以十六进制形式输入/输出
         02 表示不足两位，前面补0输出；出过两位不影响
         printf("%02X", 0x123); //打印出：123
         printf("%02X", 0x1); //打印出：01
         */
        [ret appendFormat:@"%02X",md[i]];
    }
    //返回一个长度为32的字符串
    return ret;
}

/*
**
*  URLEncode
*/
- (NSString *)URLEncodedString: (NSString*)input
{
    // CharactersToBeEscaped = @":/?&=;+!@#$()~',*";
    // CharactersToLeaveUnescaped = @"[].";
    
    NSString *unencodedString = input;
    NSString *encodedString = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)unencodedString,
                                                              NULL,
                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                              kCFStringEncodingUTF8));
    
    return encodedString;
}

@end
