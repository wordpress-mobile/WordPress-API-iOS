#import <UIKit/UIKit.h>
#import "AFHTTPRequestOperation.h"

@interface WPHTTPAuthenticationAlertView : UIAlertView
- (id)initWithChallenge:(NSURLAuthenticationChallenge *)challenge;
@end
