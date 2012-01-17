//
//  ComposeViewController.m
//  WordPressApiExample
//
//  Created by Jorge Bernal on 1/17/12.
//  Copyright (c) 2012 Automattic. All rights reserved.
//

#import "ComposeViewController.h"
#import "PostsViewController.h"

@implementation ComposeViewController
@synthesize title, content;

- (IBAction)cancel:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)save:(id)sender {
    PostsViewController *postsVC = (PostsViewController *)[(UINavigationController *)[self presentingViewController] topViewController];
    [postsVC publishPostWithTitle:title.text content:content.text];
    [self dismissModalViewControllerAnimated:YES];
}

@end
