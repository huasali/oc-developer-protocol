//
//  ViewController.m
//  oc-developer-protocol
//
//  Created by Huasali on 2021/11/22.
//

#import "ViewController.h"
#import "ProtocolViewController.h"
#import "CryptHelper.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>{
    NSArray *_dataArray;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"List";
    _dataArray = [CryptHelper classesInfo];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.text = _dataArray[indexPath.row];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [self pushViewControllerWithIdentifier:_dataArray[indexPath.row]];
}
- (void)pushViewControllerWithIdentifier:(NSString *)identifier{
    ProtocolViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ProtocolViewController"];
    vc.className = identifier;
    [self.navigationController pushViewController:vc animated:true];
}

@end
