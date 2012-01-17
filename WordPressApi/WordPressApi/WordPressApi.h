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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 WordPress API for iOS 
*/
@interface WordPressApi : NSObject

///-----------------------------------------
/// @name Accessing WordPress API properties
///-----------------------------------------

@property (readonly, nonatomic, retain) NSURL *xmlrpc;

///-------------------------------------------------------
/// @name Creating and Initializing a WordPress API Client
///-------------------------------------------------------

/**
 Creates and initializes a `WordPressAPI` client using password authentication.
 
 @param xmlrpc The XML-RPC endpoint URL, e.g.: https://en.blog.wordpress.com/xmlrpc.php
 @param username The user name
 @param password The password
 */
+ (WordPressApi *)apiWithXMLRPCEndpoint:(NSURL *)xmlrpc username:(NSString *)username password:(NSString *)password;

/**
 Creates and initializes a `WordPressAPI` client using password authentication.
 
 Only supported for WordPress.com. See http://develop.wordpress.com/oauth2/
 
 @param xmlrpc The XML-RPC endpoint URL, e.g.: https://en.blog.wordpress.com/xmlrpc.php
 @param token The OAuth token
 */
+ (WordPressApi *)apiWithXMLRPCEndpoint:(NSURL *)xmlrpc token:(NSString *)token;


/**
 Initializes a `WordPressAPI` client using password authentication.
 
 @param xmlrpc The XML-RPC endpoint URL, e.g.: https://en.blog.wordpress.com/xmlrpc.php
 @param username The user name
 @param password The password
 */
- (id)initWithXMLRPCEndpoint:(NSURL *)xmlrpc username:(NSString *)username password:(NSString *)password;

/**
 Initializes a `WordPressAPI` client using OAuth.
 
 Only supported for WordPress.com. See http://develop.wordpress.com/oauth2/
 
 @param xmlrpc The XML-RPC endpoint URL, e.g.: https://en.blog.wordpress.com/xmlrpc.php
 @param token The OAuth token
 */
- (id)initWithXMLRPCEndpoint:(NSURL *)xmlrpc token:(NSString *)token;

///-------------------
/// @name Authenticate
///-------------------

/**
 Checks if Single Sign-On using the WordPress app is available 
 */
+ (BOOL)ssoAvailable;

/**
 Launches the WordPress app to authenticate with WordPress.com
 
 If you don't have the necessary parameters, get them at http://develop.wordpress.com/contact/
 
 @param clientId Your Client ID
 @param redirectUri The redirect URL, it needs to match the one you provided on registration
 @param secret Your secret code
 @param callback A custom URL scheme that your app is registered to handle.
 @see [Implementing Custom URL Schemes](http://developer.apple.com/library/ios/documentation/iPhone/Conceptual/iPhoneOSProgrammingGuide/AdvancedAppTricks/AdvancedAppTricks.html#//apple_ref/doc/uid/TP40007072-CH7-SW50)
 */
+ (void)authenticateWithClientId:(NSString *)clientId redirectUri:(NSString *)redirectUri secret:(NSString *)secret callback:(NSString *)callback;

/**
 Helper function for [UIApplicationDelegate application:handleOpenURL:] to process the authentication callback from the WordPress app
 
 In your application delegate:
 
     // Pre 4.2 support
     - (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
     return [facebook handleOpenURL:url]; 
     }
     
     // For 4.2+ support
     - (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
     sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
     return [facebook handleOpenURL:url]; 
     }
 
 @param url The url passed to [UIApplicationDelegate application:handleOpenURL:]
 @param success A block called if the url could be processed. The block has no return value and takes two arguments: the XML-RPC endpoint for the blog and the OAuth token. We highly recommend you store these in a secure place like the keychain.
 @returns YES if the url passed was a valid callback from authentication and it could be processed. Otherwise it returns NO.
 */
+ (BOOL)handleOpenURL:(NSURL *)url success:(void (^)(NSString *xmlrpc, NSString *token))success;

/**
 Performs a XML-RPC test call just to verify that the credentials are correct.
 
 @param success A block object to execute when the credentials are valid. This block has no return value and one argument: if the credentials are valid or not.
 @param failure A block object to execute when the credentials can't be verified: it doesn't mean the credentials are invalid, just they can't be verified due to some network error. This block has no return value and takes one argument: a NSError object with details on the error.
 */
- (void)authenticateWithSuccess:(void (^)(BOOL valid))success
                        failure:(void (^)(NSError *error))failure;

///------------------------
/// @name Publishing a post
///------------------------

/**
 Publishes a post asynchronously with text/HTML only
 
 All the parameters are optional, and can be set to `nil`
 
 @param content The post content/body. It can be text only or HTML, but be aware that some HTML might be stripped in WordPress. [What's allowed in WordPress.com?](http://en.support.wordpress.com/code/)
 @param title The post title.
 @param success A block object to execute when the method successfully publishes the post. This block has no return value and takes two arguments: the resulting post ID, and the permalink (or [shortlink](http://en.support.wordpress.com/shortlinks/) if available).
 @param failure A block object to execute when the method can't publish the post. This block has no return value and takes one argument: a NSError object with details on the error.
 */
- (void)publishPostWithText:(NSString *)content
                      title:(NSString *)title
                    success:(void (^)(NSUInteger postId, NSURL *permalink))success
                    failure:(void (^)(NSError *error))failure;

/**
 Publishes a post asynchronously with an image
 
 All the parameters are optional, and can be set to `nil`
 
 @param image An image to add to the post. The image will be embedded **before** the content.
 @param content The post content/body. It can be text only or HTML, but be aware that some HTML might be stripped in WordPress. [What's allowed in WordPress.com?](http://en.support.wordpress.com/code/)
 @param title The post title.
 @param success A block object to execute when the method successfully publishes the post. This block has no return value and takes two arguments: the resulting post ID, and the permalink (or [shortlink](http://en.support.wordpress.com/shortlinks/) if available).
 @param failure A block object to execute when the method can't publish the post. This block has no return value and takes one argument: a NSError object with details on the error.
 */
- (void)publishPostWithImage:(UIImage *)image
                 description:(NSString *)content
                       title:(NSString *)title
                     success:(void (^)(NSUInteger postId, NSURL *permalink))success
                     failure:(void (^)(NSError *error))failure;

/**
 Publishes a post asynchronously with an image gallery
 
 All the parameters are optional, and can be set to `nil`
 
 @param images An array containing images (as UIImage) to add to the post. The gallery will be embedded **before** the content using the [[gallery]](http://en.support.wordpress.com/images/gallery/) shortcode.
 @param content The post content/body. It can be text only or HTML, but be aware that some HTML might be stripped in WordPress. [What's allowed in WordPress.com?](http://en.support.wordpress.com/code/)
 @param title The post title.
 @param success A block object to execute when the method successfully publishes the post. This block has no return value and takes two arguments: the resulting post ID, and the permalink (or [shortlink](http://en.support.wordpress.com/shortlinks/) if available).
 @param failure A block object to execute when the method can't publish the post. This block has no return value and takes one argument: a NSError object with details on the error.
 */
- (void)publishPostWithGallery:(NSArray *)images
                   description:(NSString *)content
                         title:(NSString *)title
                       success:(void (^)(NSUInteger postId, NSURL *permalink))success
                       failure:(void (^)(NSError *error))failure;

/**
 Publishes a post asynchronously with a video
 
 All the parameters are optional, and can be set to `nil`

 For WordPress.com, if VideoPress is not available for the blog, there will be an error.
 
 For self hosted blogs, if VideoPress is available it will be used, otherwise the video will be embedded using the HTML5 `<video>` tag.

 @param videoPath A string containing the path to the video file to add to the post. The video will be embedded **before** the content.
 @param content The post content/body. It can be text only or HTML, but be aware that some HTML might be stripped in WordPress. [What's allowed in WordPress.com?](http://en.support.wordpress.com/code/)
 @param title The post title.
 @param success A block object to execute when the method successfully publishes the post. This block has no return value and takes two arguments: the resulting post ID, and the permalink (or [shortlink](http://en.support.wordpress.com/shortlinks/) if available).
 @param failure A block object to execute when the method can't publish the post. This block has no return value and takes one argument: a NSError object with details on the error.
 
 */
- (void)publishPostWithVideo:(NSString *)videoPath
                 description:(NSString *)content
                       title:(NSString *)title
                     success:(void (^)(NSUInteger postId, NSURL *permalink))success
                     failure:(void (^)(NSError *error))failure;

///---------------------
/// @name Managing posts
///---------------------

/**
 Get a list of the recent posts
 
 @param count Number of recent posts to get
 @param success A block object to execute when the method successfully publishes the post. This block has no return value and takes one argument: an array with the latest posts.
 @param failure A block object to execute when the method can't publish the post. This block has no return value and takes one argument: a NSError object with details on the error.
 */
- (void)getPosts:(NSUInteger)count
         success:(void (^)(NSArray *posts))success
         failure:(void (^)(NSError *error))failure;

///--------------
/// @name Helpers
///--------------

/**
 Given a site URL, tries to guess the URL for the XML-RPC endpoint
 
 When asked for a site URL, sometimes users type the XML-RPC url, or the xmlrpc.php has been moved/renamed. This method would try a few methods to find the proper XML-RPC endpoint:
 
 * Try to load the given URL adding `/xmlrpc.php` at the end. This is the most common use case for proper site URLs
 * If that fails, try a test XML-RPC request given URL, maybe it was the XML-RPC URL already
 * If that fails, fetch the given URL and search for an `EditURI` link pointing to the XML-RPC endpoint
 
 For additional URL typo fixing, see [NSURL-Guess](https://github.com/koke/NSURL-Guess)
 
 @param siteURL The site's main url, e.g.: http://en.blog.wordpress.com/
 @param success A block object to execute when the method finds a suitable XML-RPC endpoint on the site provided. This block has no return value and takes two arguments: the original site URL, and the found XML-RPC endpoint URL.
 @param failure A block object to execute when the method doesn't find a suitable XML-RPC endpoint on the site. This block has no return value and takes one argument: the original site URL.
 */
+ (void)guessXMLRPCURLForSite:(NSURL *)siteURL
                      success:(void (^)(NSURL *siteURL, NSURL *xmlrpcURL))success
                      failure:(void (^)(NSURL *siteURL))failure;


@end
