#import <UIKit/UIKit.h>
#import "WordPressBaseApi.h"

@interface PostsViewController : UITableViewController
@property (readonly, nonatomic, retain) id<WordPressBaseApi> api;

- (IBAction)refreshPosts:(id)sender;
- (void)publishPostWithTitle:(NSString *)title content:(NSString *)content image:(UIImage *)image;
@end
