// WordPressApi.h
//
// Copyright (c) 2011 Automattic.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.


#import "WordPressApi.h"
#import "AFXMLRPCClient.h"

@interface WordPressApi ()
@property (readwrite, nonatomic, retain) NSURL *xmlrpc;
@property (readwrite, nonatomic, retain) NSString *username;
@property (readwrite, nonatomic, retain) NSString *password;
@property (readwrite, nonatomic, retain) AFXMLRPCClient *client;

- (NSArray *)buildParametersWithExtra:(id)extra;

@end

@implementation WordPressApi {
    NSURL *_xmlrpc;
    NSString *_username;
    NSString *_password;
    AFXMLRPCClient *_client;
}
@synthesize xmlrpc = _xmlrpc;
@synthesize username = _username;
@synthesize password = _password;
@synthesize client = _client;

+ (WordPressApi *)apiWithXMLRPCEndpoint:(NSURL *)xmlrpc username:(NSString *)username password:(NSString *)password {
    return [[[self alloc] initWithXMLRPCEndpoint:xmlrpc username:username password:password] autorelease];
}


- (id)initWithXMLRPCEndpoint:(NSURL *)xmlrpc username:(NSString *)username password:(NSString *)password
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.xmlrpc = xmlrpc;
    self.username = username;
    self.password = password;
    
    self.client = [AFXMLRPCClient clientWithXMLRPCEndpoint:xmlrpc];
    
    return self;
}

- (void)dealloc {
    [_xmlrpc release];
    [_username release];
    [_password release];
    [_client release];
    [super dealloc];
}

#pragma mark - Publishing a post

- (void)publishPostWithText:(NSString *)content title:(NSString *)title success:(void (^)(NSUInteger, NSURL *))success failure:(void (^)(NSError *))failure {
    NSDictionary *postParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    title, @"title",
                                    content, @"description",
                                    @"publish", @"post_status",
                                    nil];
    NSArray *parameters = [self buildParametersWithExtra:postParameters];
    [self.client callMethod:@"metaWeblog.newPost"
                 parameters:parameters
                    success:^(AFHTTPRequestOperation *operation, id responseObject) {
                        if (success) {
                            success([responseObject intValue], nil);
                        }
                    }
                    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        if (failure) {
                            failure(error);
                        }
                    }];
}

- (void)publishPostWithImage:(UIImage *)image
                 description:(NSString *)content
                       title:(NSString *)title
                     success:(void (^)(NSUInteger postId, NSURL *permalink))success
                     failure:(void (^)(NSError *error))failure {
    [self publishPostWithText:content title:title success:success failure:failure];
}

- (void)publishPostWithGallery:(NSArray *)images
                   description:(NSString *)content
                         title:(NSString *)title
                       success:(void (^)(NSUInteger postId, NSURL *permalink))success
                       failure:(void (^)(NSError *error))failure {
    [self publishPostWithText:content title:title success:success failure:failure];
}

- (void)publishPostWithVideo:(NSString *)videoPath
                 description:(NSString *)content
                       title:(NSString *)title
                     success:(void (^)(NSUInteger postId, NSURL *permalink))success
                     failure:(void (^)(NSError *error))failure {
    [self publishPostWithText:content title:title success:success failure:failure];
}

#pragma mark - Managing posts

- (void)getPosts:(NSUInteger)count
         success:(void (^)(NSArray *posts))success
         failure:(void (^)(NSError *error))failure {
    NSArray *parameters = [self buildParametersWithExtra:nil];
    [self.client callMethod:@"metaWeblog.getRecentPosts"
                 parameters:parameters
                    success:^(AFHTTPRequestOperation *operation, id responseObject) {
                        if (success) {
                            success((NSArray *)responseObject);
                        }
                    }
                    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        if (failure) {
                            failure(error);
                        }
                    }];
}

#pragma mark - Helpers

+ (void)guessXMLRPCURLForSite:(NSURL *)siteURL
                      success:(void (^)(NSURL *siteURL, NSURL *xmlrpcURL))success
                      failure:(void (^)(NSURL *siteURL))failure {
    if (success) {
        NSURL *xmlrpc = [siteURL URLByAppendingPathComponent:@"/xmlrpc.php"];
        success(siteURL, xmlrpc);
    }
}

#pragma mark - Private Methods

- (NSArray *)buildParametersWithExtra:(id)extra {
    NSMutableArray *result = [NSMutableArray array];
    [result addObject:@"1"];
    [result addObject:@"q"];
    [result addObject:@"q"];
    if ([extra isKindOfClass:[NSArray class]]) {
        [result addObjectsFromArray:extra];
    } else if ([extra isKindOfClass:[NSDictionary class]]) {
        [result addObject:extra];
    }
    
    return [NSArray arrayWithArray:result];
}

@end
