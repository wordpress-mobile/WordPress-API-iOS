#import "LoginViewController.h"
#import "WordPressApi.h"

@implementation LoginViewController

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        // Sign in
        [WordPressApi signInWithURL:self.urlField.text
                           username:self.usernameField.text
                           password:self.passwordField.text
                            success:^(NSURL *xmlrpcURL) {
                                NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
                                [def setObject:[xmlrpcURL absoluteString] forKey:@"wp_xmlrpc"];
                                [def setObject:self.usernameField.text forKey:@"wp_username"];
                                [def setObject:self.passwordField.text forKey:@"wp_password"];
                                [def synchronize];
                                [self dismissViewControllerAnimated:YES completion:nil];
                            } failure:^(NSError *error) {
                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                [alert show];
                            }];
    } else if (indexPath.section == 2) {
        // Sign in with WordPress.com
        [WordPressApi signInWithOauthWithSuccess:^(NSString *authToken, NSString *siteId) {
            NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
            [def setObject:siteId forKey:@"wp_site_id"];
            [def setObject:authToken forKey:@"wp_token"];
            [def synchronize];
            [self dismissViewControllerAnimated:YES completion:nil];
        } failure:^(NSError *error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

@end
