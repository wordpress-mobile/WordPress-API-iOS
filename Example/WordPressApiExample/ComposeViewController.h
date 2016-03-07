#import <UIKit/UIKit.h>

@interface ComposeViewController : UIViewController
@property (nonatomic, retain) IBOutlet UITextField *titleField;
@property (nonatomic, retain) IBOutlet UITextView *content;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) UIImage *image;
- (IBAction)save:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)addPicture:(id)sender;
@end
