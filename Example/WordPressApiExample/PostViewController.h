#import <UIKit/UIKit.h>

@interface PostViewController : UIViewController

@property (strong, nonatomic) NSDictionary *post;

@property (strong, nonatomic) IBOutlet UIWebView *postContentView;

@end
