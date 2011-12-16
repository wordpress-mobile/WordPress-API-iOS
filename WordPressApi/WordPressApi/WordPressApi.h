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

///-------------------------------------------------------
/// @name Creating and Initializing a WordPress API Client
///-------------------------------------------------------

/**
 Initializes a `WordPressAPI` client trying to guess the proper XML-RPC endpoint from the site URL.
 
 @param xmlrpc The XML-RPC endpoint URL, e.g.: https://en.blog.wordpress.com/xmlrpc.php
 @param username The user name
 @param password The password
 */
- (id)initWithXMLRPCEndpoint:(NSURL *)xmlrpc username:(NSString *)username password:(NSString *)password;

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
