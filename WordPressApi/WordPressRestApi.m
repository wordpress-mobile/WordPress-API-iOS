//
//  WordPressRestApi.m
//  WordPressApiExample
//
//  Created by Jorge Bernal on 2/20/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AFNetworking/AFNetworking.h>

#import "WordPressRestApi.h"
#import "WordPressRestApiJSONRequestOperation.h"
#import "WPComOAuthController.h"

NSString *const WordPressRestApiEndpointURL = @"https://public-api.wordpress.com/rest/v1/";
NSString *const WordPressRestApiErrorDomain = @"WordPressRestApiError";
NSString *const WordPressRestApiErrorCodeKey = @"WordPressRestApiErrorCodeKey";

@implementation WordPressRestApi {
    NSString *_token;
    NSString *_siteId;
    AFHTTPClient *_client;
}

static NSString *WordPressRestApiClient = nil;
static NSString *WordPressRestApiSecret = nil;
static NSString *WordPressRestApiRedirectUrl = nil;

+ (void)signInWithOauthWithSuccess:(void (^)(NSString *authToken, NSString *siteId))success failure:(void (^)(NSError *error))failure {
    [[WPComOAuthController sharedController] setCompletionBlock:^(NSString *token, NSString *blogId, NSString *blogUrl, NSString *scope, NSError *error) {
        if (error) {
            failure(error);
        } else {
            success(token, blogId);
        }
    }];
    [[WPComOAuthController sharedController] present];
}

+ (void)signInWithJetpackUsername:(NSString *)username password:(NSString *)password success:(void (^)(NSString *authToken))success failure:(void (^)(NSError *error))failure {
    NSAssert(NO, @"Not implemented yet");
}

- (id<WordPressBaseApi>)initWithOauthToken:(NSString *)authToken siteId:(NSString *)siteId {
    self = [super init];
    if (self) {
        _token = authToken;
        _siteId = siteId;
        _client = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:WordPressRestApiEndpointURL]];
        [_client registerHTTPOperationClass:[WordPressRestApiJSONRequestOperation class]];
        [_client setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"Bearer %@", _token]];
    }
    return self;
}

+ (BOOL)handleOpenURL:(NSURL *)url {
    return [[WPComOAuthController sharedController] handleOpenURL:url];
}

+ (void)setWordPressComClient:(NSString *)clientId {
    WordPressRestApiClient = clientId;
    [[WPComOAuthController sharedController] setClient:clientId];
}

+ (void)setWordPressComSecret:(NSString *)secret {
    WordPressRestApiSecret = secret;
    [[WPComOAuthController sharedController] setSecret:secret];
}

+ (void)setWordPressComRedirectUrl:(NSString *)redirectUrl {
    WordPressRestApiRedirectUrl = redirectUrl;
    [[WPComOAuthController sharedController] setRedirectUrl:redirectUrl];
}

#pragma mark - WordPressBaseApi methods

- (void)publishPostWithText:(NSString *)content title:(NSString *)title success:(void (^)(NSUInteger postId, NSURL *permalink))success failure:(void (^)(NSError *error))failure {

}

- (void)publishPostWithImage:(UIImage *)image description:(NSString *)content title:(NSString *)title success:(void (^)(NSUInteger postId, NSURL *permalink))success failure:(void (^)(NSError *error))failure {
    if (image == nil) {
        [self publishPostWithText:content title:title success:success failure:failure];
    }

    NSData *imageData = UIImageJPEGRepresentation(image, 1.f);
    NSDictionary *parameters = @{
                                 @"title": title,
                                 @"content": content
                                 };
    NSURLRequest *request = [_client multipartFormRequestWithMethod:@"POST"
                                                               path:[self sitePath:@"posts/new"]
                                                         parameters:parameters
                                          constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                              [formData appendPartWithFileData:imageData name:@"media[]" fileName:@"image.jpg" mimeType:@"image/jpeg"];
                                          }];
    AFHTTPRequestOperation *operation = [_client HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSUInteger postId = [[responseObject objectForKey:@"ID"] unsignedIntegerValue];
        NSURL *permalink = [NSURL URLWithString:[responseObject objectForKey:@"URL"]];
        success(postId, permalink);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
    [_client enqueueHTTPRequestOperation:operation];
}

- (void)publishPostWithGallery:(NSArray *)images description:(NSString *)content title:(NSString *)title success:(void (^)(NSUInteger postId, NSURL *permalink))success failure:(void (^)(NSError *error))failure {

}

- (void)publishPostWithVideo:(NSString *)videoPath description:(NSString *)content title:(NSString *)title success:(void (^)(NSUInteger postId, NSURL *permalink))success failure:(void (^)(NSError *error))failure {

}

- (void)getPosts:(NSUInteger)count success:(void (^)(NSArray *posts))success failure:(void (^)(NSError *error))failure {

}

#pragma mark - API Helpers

- (NSString *)sitePath:(NSString *)path {
    return [NSString stringWithFormat:@"sites/%@/%@", _siteId, path];
}

@end
