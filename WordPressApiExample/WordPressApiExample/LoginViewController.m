//
//  LoginViewController.m
//  WordPressApiExample
//
//  Created by Jorge Bernal on 1/17/12.
//  Copyright (c) 2012 Automattic. All rights reserved.
//

#import "LoginViewController.h"
#import "WordPressApi.h"

@implementation LoginViewController
@synthesize urlField, usernameField, passwordField;

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        // Sign in
        NSString *xmlrpc = urlField.text;
        if (![xmlrpc hasPrefix:@"http"]) {
            xmlrpc = [NSString stringWithFormat:@"http://%@", xmlrpc];
        }
        if (![xmlrpc hasSuffix:@"xmlrpc.php"]) {
            xmlrpc = [NSString stringWithFormat:@"%@/xmlrpc.php", xmlrpc];
        }
        WordPressApi *api = [WordPressApi apiWithXMLRPCEndpoint:[NSURL URLWithString:xmlrpc] username:usernameField.text password:passwordField.text];
        [api authenticateWithSuccess:^(BOOL valid) {
            if (valid) {
                NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
                [def setObject:xmlrpc forKey:@"wp_xmlrpc"];
                [def setObject:usernameField.text forKey:@"wp_username"];
                [def setObject:passwordField.text forKey:@"wp_password"];
                [def synchronize];
                [self dismissModalViewControllerAnimated:YES];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid login" message:@"Invalid URL, username, or password" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                [alert release];
            }
        } failure:^(NSError *error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
            
        }];
    } else if (indexPath.section == 2) {
        // Sign in with WordPress.com
        [WordPressApi authenticateWithClientId:OAUTH_CLIENT_ID redirectUri:OAUTH_REDIRECT_URI secret:OAUTH_SECRET callback:OAUTH_CALLBACK];
        [self dismissModalViewControllerAnimated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

@end
