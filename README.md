## A simple Objective-C client to publish post on the WordPress platform.

### WordPress API for iOS is a library for iOS designed to make sharing on your WordPress blog easy.

It's not meant to provide access to the full feature set of the WordPress XML-RPC API.

## Installation

You can download the project from FIXME

### The quick way

* Drag `libWordPressApi.a` and `WordPressApi.h` to your Xcode project. Make sure to check "Copy items into destination group's folder"
* Add `#import "WordPressApi.h"` to your source file where you plan to use the API
* You're ready to go

### The long way

There can be a few reasons why you wouldn't want to just link the library and import the source instead, some of them:

* You want to modify the code
* You are already using `AFNetworking` or the `XMLRPC` library. In this case, adding the static library would throw "duplicate symbols" errors on compile

If that's the case, or you just like to have the source available in your project:

* Download [AFNetworking](https://github.com/AFNetworking/AFNetworking) and add the `AFNetworking` folder to your project
* Download [XMLRPC](https://github.com/eczarny/xmlrpc) and add it to your project. A way to do that is to create a `XMLRPC` group in your project and add all the .h/.m files in there
* Add the `WordPressApi` folder to your project (the one that has `WordPressApi.h`)
* Add `#import "WordPressApi.h"` to your source file where you plan to use the API

## Example project

[TODO] Example project will include examples for posting text, images or video

## Example usage

### Posting a picture

A hypothetical camera app called Cameramattic wants to add an option to share its pictures on WordPress

    NSURL *xmlrpcURL = [NSURL URLWithString:@"https://aphotoblog.wordpress.com"];
    NSString *username = "aUsername";
    NSString *password = "thePassword";
    NSString *title = "My cat";
    NSString *content = "She likes to sleep like that";
    UIImage *image = ... // The image to upload

    WordPressAPI *wp = [[WordPressAPI alloc] initWithXMLRPCEndpoint:xmlrpcURL username:username password:password];
    [wp publishPostWithImage:(UIImage *)image
                 description:(NSString *)content
                       title:(NSString *)title
                     success:^(NSUInteger postId, NSURL *permalink) {
                         NSLog(@"Image post successful with ID %d at %@", postId, permalink);
                     }
                     failure:^(NSError *error) {
                         NSLog(@"Post upload failed: %@", [error localizedDescription])
                     }];
