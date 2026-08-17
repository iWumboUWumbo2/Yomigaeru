#import "YGRSourceService.h"
#import "YGRManga.h"
#import "YGRNetworkManager.h"
#import "YGRSource.h"

@implementation YGRSourceService

#pragma mark - Sources

- (void)fetchAllSourcesWithCompletion:(void (^)(NSArray *sources, NSError *error))completion
{
    AFHTTPClient *jsonClient = [[YGRNetworkManager sharedManager] jsonClientInstance];
    NSString *path = @"source/list";

    [jsonClient getPath:path
        parameters:nil
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSArray *jsonArray = (NSArray *) responseObject;
            NSMutableArray *sources = [NSMutableArray arrayWithCapacity:jsonArray.count];

            for (NSDictionary *dict in jsonArray)
            {
                [sources addObject:[[YGRSource alloc] initWithDictionary:dict]];
            }

            completion(sources, nil);
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            completion(nil, error);
        }];
}

- (void)fetchSourceWithId:(NSString *)sourceId
               completion:(void (^)(YGRSource *source, NSError *error))completion
{
    AFHTTPClient *jsonClient = [[YGRNetworkManager sharedManager] jsonClientInstance];
    NSString *path = [NSString stringWithFormat:@"source/%@", sourceId];

    [jsonClient getPath:path
        parameters:nil
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
            YGRSource *source = [[YGRSource alloc] initWithDictionary:responseObject];
            completion(source, nil);
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            completion(nil, error);
        }];
}

#pragma mark - Manga Listings

/**
 *  Fetches a paginated manga listing from an arbitrary source endpoint
 *  (popular, latest, or search) and parses the common response shape they
 *  all share. Backs the public listing methods, which each just supply a
 *  different endpoint path.
 *
 *  @param endpoint The relative path to fetch, already containing any
 *  query parameters.
 *  @param completion Called with the parsed `YGRManga` array and whether a
 *  further page is available on success, or `nil`/`NO` and an error on
 *  failure.
 */
- (void)fetchMangaListFromEndpoint:(NSString *)endpoint
                        completion:(void (^)(NSArray *mangaList, BOOL hasNextPage,
                                             NSError *error))completion
{
    AFHTTPClient *jsonClient = [[YGRNetworkManager sharedManager] jsonClientInstance];

    [jsonClient getPath:endpoint
        parameters:nil
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *jsonDict = (NSDictionary *) responseObject;

            NSArray *jsonMangaList = jsonDict[@"mangaList"];
            NSMutableArray *mangaList = [NSMutableArray arrayWithCapacity:jsonMangaList.count];

            for (NSDictionary *dict in jsonMangaList)
            {
                [mangaList addObject:[[YGRManga alloc] initWithDictionary:dict]];
            }

            BOOL hasNextPage = [jsonDict[@"hasNextPage"] boolValue];

            completion(mangaList, hasNextPage, nil);
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            completion(nil, NO, error);
        }];
}

- (void)fetchPopularMangaFromSourceId:(NSString *)sourceId
                              pageNum:(NSUInteger)pageNum
                           completion:(void (^)(NSArray *mangaList, BOOL hasNextPage,
                                                NSError *error))completion
{
    NSString *endpoint = [NSString stringWithFormat:@"source/%@/popular/%tu", sourceId, pageNum];

    [self fetchMangaListFromEndpoint:endpoint completion:completion];
}

- (void)fetchLatestMangaFromSourceId:(NSString *)sourceId
                             pageNum:(NSUInteger)pageNum
                          completion:(void (^)(NSArray *mangaList, BOOL hasNextPage,
                                               NSError *error))completion
{
    NSString *endpoint = [NSString stringWithFormat:@"source/%@/latest/%tu", sourceId, pageNum];

    [self fetchMangaListFromEndpoint:endpoint completion:completion];
}

- (void)searchMangaInSourceId:(NSString *)sourceId
                   searchTerm:(NSString *)searchTerm
                      pageNum:(NSUInteger)pageNum
                   completion:
                       (void (^)(NSArray *mangaList, BOOL hasNextPage, NSError *error))completion
{
    NSString *encoded = [searchTerm stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    NSString *endpoint = [NSString
        stringWithFormat:@"source/%@/search?searchTerm=%@&pageNum=%tu", sourceId, encoded, pageNum];

    [self fetchMangaListFromEndpoint:endpoint completion:completion];
}

@end
