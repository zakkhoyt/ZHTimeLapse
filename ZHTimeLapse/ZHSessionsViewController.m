//
//  ZHSessionsViewController.m
//  ZHTimeLapse
//
//  Created by Zakk Hoyt on 12/23/15.
//  Copyright © 2015 Zakk Hoyt. All rights reserved.
//

#import "ZHSessionsViewController.h"
#import "ZHSessionTableViewController.h"
#import "ZHFileManager.h"
#import "ZHSession.h"

#import "ZHSessionTableViewCell.h"


static NSString *SegueSessionsToOptions = @"SegueSessionsToOptions";

@interface ZHSessionsViewController (UITableViewDataSource) <UITableViewDataSource>
@end

@interface ZHSessionsViewController (UITableViewDelegate) <UITableViewDelegate>
@end


@interface ZHSessionsViewController ()
@property (nonatomic, strong) NSMutableArray *sessions;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation ZHSessionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _sessions = [[ZHFileManager sessions] mutableCopy];
    [_tableView reloadData];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:SegueSessionsToOptions]) {
        UINavigationController *nc = segue.destinationViewController;
        ZHSessionTableViewController *vc = [nc.viewControllers firstObject];
        vc.session = sender;
    }
}

#pragma mark IBActions

- (IBAction)addBarButtonAction:(id)sender {
    [self performSegueWithIdentifier:SegueSessionsToOptions sender:nil];
}

@end

@implementation ZHSessionsViewController (UITableViewDataSource)

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _sessions.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZHSessionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ZHSessionTableViewCell"];
    ZHSession *session = _sessions[indexPath.row];
    cell.session = session;
    return cell;
}
@end

@implementation ZHSessionsViewController (UITableViewDelegate)

#pragma mark UITableViewDelegate (editing)
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    // Empty implementation required
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        [_tableView setEditing:NO animated:YES];
        ZHSession *session = _sessions[indexPath.row];
        [ZHFileManager deleteSession:session];
        
        [_sessions removeObject:session];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
    }];
    
    return @[deleteAction];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ZHSession *session = _sessions[indexPath.row];
    [self performSegueWithIdentifier:SegueSessionsToOptions sender:session];
}
@end
