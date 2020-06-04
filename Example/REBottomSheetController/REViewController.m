//
//  REViewController.m
//  REBottomSheetController
//
//  Created by roceun on 04/03/2020.
//  Copyright (c) 2020 roceun. All rights reserved.
//

#import "REViewController.h"

#import <REBottomSheetController.h>

@interface REViewController () <REBottomSheetDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) REBottomSheetController *sheetController;

@end

@implementation REViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	self.view.backgroundColor = UIColor.yellowColor;
	
	REBottomSheetController * const controller = [[REBottomSheetController alloc] init];
	controller.maxHeight = self.view.frame.size.height * 0.6f;
	controller.minHeight = 150;
	controller.delegate = self;
	
	[self addChildViewController:controller];
    [self.view addSubview:controller.view];
    [controller didMoveToParentViewController:self];
	
	self.sheetController = controller;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView *)REBottomSheetControllerGetTopContentView:(REBottomSheetController *)viewController
{
	UIView * const handleView = [UIView new];
    handleView.backgroundColor = UIColor.blueColor;

    UIView * const handle = [UIView new];
    [handleView addSubview:handle];
    handle.backgroundColor = [UIColor colorWithRed:209/255 green:209/255 blue:209/255 alpha:1];
    handle.layer.cornerRadius = 2;
    handle.translatesAutoresizingMaskIntoConstraints = NO;

    [NSLayoutConstraint activateConstraints:@[
        [handle.topAnchor constraintEqualToAnchor:handleView.topAnchor constant:6],
        [handle.widthAnchor constraintEqualToConstant:48],
        [handle.heightAnchor constraintEqualToConstant:4],
        [handle.centerXAnchor constraintEqualToAnchor:handleView.centerXAnchor]
    ]];

    return handleView;
}

- (CGFloat)REBottomSheetViewControllerGetTopContentViewHeight:(REBottomSheetController *)viewController
{
	return 16;
}

- (UIScrollView *)REBottomSheetControllerGetBottomScrollView:(REBottomSheetController *)viewController
{
	UITableView *tableView = [UITableView new];
    tableView.delegate = self;
    tableView.dataSource = self;
    return tableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * const cellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSLog(@"## index %d", (int)indexPath.row);

    cell.backgroundColor = UIColor.blueColor;
    cell.textLabel.text = [NSString stringWithFormat:@"%d", (int)indexPath.row];
    
    return cell;
}

// MARK: - UITableViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[_sheetController scrollViewDidScroll:scrollView];
}

@end
