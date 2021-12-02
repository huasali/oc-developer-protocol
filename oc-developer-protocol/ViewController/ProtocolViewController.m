//
//  ProtocolViewController.m
//  oc-developer-protocol
//
//  Created by Huasali on 2021/11/25.
//

#import "ProtocolViewController.h"

@interface ProtocolViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation ProtocolViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.className;
    self.textView.layer.borderColor = [[UIColor grayColor] CGColor];
    self.textView.layer.borderWidth = 0.5;
    self.textView.layoutManager.allowsNonContiguousLayout = NO;
    self.textView.text = @"print log";
    NSLog(@"viewDidLoad %@",self.title);
}

- (IBAction)buttonAction:(id)sender {
    [self startTest:^(NSString *log) {
        NSLog(@"%@", log);
        [self printLog:log];
    }];
}
- (void)printLog:(NSString *)log{
    self.textView.text = [NSString stringWithFormat:@"%@\n%@",self.textView.text,log];
    [self.textView scrollRangeToVisible:NSMakeRange(self.textView.text.length,1)];
}
- (void)startTest:(void(^)(NSString *log))callback{
    [self performSelectorWithCLass:self.className sel:@"cryptTest:" withObject:callback];
}
- (void)performSelectorWithCLass:(NSString *)className sel:(NSString *)selName withObject:(id)object{
    Class class = NSClassFromString(className);
    SEL sel = NSSelectorFromString(selName);
    if ([class respondsToSelector:sel]) {
        [class performSelector:sel withObject:object];
    }
}
- (void)dealloc{
    NSLog(@"dealloc %@",self.title);
}
@end
