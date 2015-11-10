#import <UIKit/UIKit.h>

@interface WPHTTPAuthenticationAlertView : UIAlertView
- (id)initWithChallenge:(NSURLAuthenticationChallenge *)challenge;
@end
