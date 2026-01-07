//
//  YGRNetworkManager.m
//  Yomigaeru
//

#import "YGRNetworkManager.h"
#import "YGRSettingsManager.h"
#import <AFNetworking/AFNetworking.h>

@interface YGRNetworkManager ()

@property (nonatomic, strong) AFHTTPClient *jsonClient;
@property (nonatomic, strong) AFHTTPClient *httpClient;
@property (nonatomic, strong) AFHTTPClient *imageClient;
@property (nonatomic, strong) NSURL *currentBaseURL;

- (void)ensureClientsAreUpToDate;

@end

@implementation YGRNetworkManager

+ (instancetype)sharedManager
{
    static YGRNetworkManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:sharedInstance
                                                 selector:@selector(handleBaseURLChange)
                                                     name:@"YGRBaseURLDidChangeNotification"
                                                   object:nil];
    });
    return sharedInstance;
}

#pragma mark - Clients

- (AFHTTPClient *)jsonClientInstance
{
    [self ensureClientsAreUpToDate];
    return self.jsonClient;
}

- (AFHTTPClient *)httpClientInstance
{
    [self ensureClientsAreUpToDate];
    return self.httpClient;
}

- (AFHTTPClient *)imageClientInstance
{
    [self ensureClientsAreUpToDate];
    return self.imageClient;
}

#pragma mark - Client Management

- (void)ensureClientsAreUpToDate
{
    NSURL *baseURL = [YGRSettingsManager sharedInstance].apiBaseURL;

    if (![self.currentBaseURL isEqual:baseURL])
    {
        self.currentBaseURL = baseURL;

        // JSON client
        self.jsonClient = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
        [self.jsonClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
        [self.jsonClient setDefaultHeader:@"Accept" value:@"application/json"];

        // HTTP client
        self.httpClient = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
        [self.httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];

        // Image client
        self.imageClient = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
        [self.imageClient registerHTTPOperationClass:[AFImageRequestOperation class]];
        [self.imageClient setDefaultHeader:@"Accept" value:@"image/*"];
    }
}

@end
