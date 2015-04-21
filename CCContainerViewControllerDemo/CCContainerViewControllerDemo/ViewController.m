//
//  ViewController.m
//  CCContainerViewControllerDemo
//
//  Created by Charles-Adrien Fournier on 10/04/15.
//  Copyright (c) 2015 Charles-Adrien Fournier. All rights reserved.
//

#import "ViewController.h"
#import "CCContainerViewController.h"
#import "TestCollectionViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor colorWithRed:0.16 green:0.16 blue:0.16 alpha:1]];
}

- (IBAction)viewControllerWithNotifications:(id)sender {
    UIViewController *vc1 = [UIViewController new];
    [vc1.view setBackgroundColor:[UIColor colorWithRed:0.88 green:0.18 blue:0.08 alpha:1]];
    UIViewController *vc2 = [UIViewController new];
    [vc2.view setBackgroundColor:[UIColor colorWithRed:0.00 green:0.50 blue:0.88 alpha:1]];
    UIViewController *vc3 = [UIViewController new];
    [vc3.view setBackgroundColor:[UIColor colorWithRed:0.93 green:0.65 blue:0.18 alpha:1]];
    
    CCBarItem *barItem1 = [[CCBarItem alloc] initWithTitle:@"User" image:[UIImage imageNamed:@"user"]];
    CCBarItem *barItem2 = [[CCBarItem alloc] initWithTitle:@"Mail" image:[UIImage imageNamed:@"mail"]];
    CCBarItem *barItem3 = [[CCBarItem alloc] initWithTitle:@"Camera" image:[UIImage imageNamed:@"camera"]];

    [barItem2 setEnabled:NO];
    
    [vc1 setBarItem:barItem1];
    [vc2 setBarItem:barItem2];
    [vc3 setBarItem:barItem3];
    
    NSArray *controllers = [[NSArray alloc] initWithObjects:vc1, vc2, vc3, nil];
    
    CCContainerViewController *container = [CCContainerViewController new];
    
    [container setViewControllers:controllers animated:YES];
    [container.view addSubview:[self closeButton]];
    [self presentViewController:container animated:YES completion:^{
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            [NSThread sleepForTimeInterval:2.0];
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [barItem1 setBadgeValue:@"700"];
            });
        });
    }];
}

- (IBAction)splitViewController:(id)sender {
    UISplitViewController *splitViewController = [UISplitViewController new];
    
    CCBarItem *barItem1 = [[CCBarItem alloc] initWithTitle:@"User" image:[UIImage imageNamed:@"user"]];
    [splitViewController setBarItem:barItem1];
    
    UIViewController *vc1 = [UIViewController new];
    [vc1.view setBackgroundColor:[UIColor colorWithRed:0.88 green:0.18 blue:0.08 alpha:1]];
    UIViewController *vc2 = [UIViewController new];
    [vc2.view setBackgroundColor:[UIColor colorWithRed:0.00 green:0.50 blue:0.88 alpha:1]];
    
    splitViewController.viewControllers = [NSArray arrayWithObjects:vc1, vc2, nil];
    NSArray *controllers = [[NSArray alloc] initWithObjects:splitViewController, nil];
    
    CCContainerViewController *container = [CCContainerViewController new];
    
    [container setViewControllers:controllers animated:YES];
    [container.view addSubview:[self closeButton]];
    [self presentViewController:container animated:YES completion:nil];
}

- (IBAction)navigationViewController:(id)sender {
    UINavigationController *navCon = [UINavigationController new];
 
    UIViewController *vc1 = [UIViewController new];
    [vc1.view setBackgroundColor:[UIColor colorWithRed:0.88 green:0.18 blue:0.08 alpha:1]];
    UIViewController *vc2 = [UIViewController new];
    [vc2.view setBackgroundColor:[UIColor colorWithRed:0.00 green:0.50 blue:0.88 alpha:1]];

    [navCon pushViewController:vc1 animated:NO];
    [navCon pushViewController:vc2 animated:NO];
    
    CCBarItem *barItem1 = [[CCBarItem alloc] initWithTitle:@"User" image:[UIImage imageNamed:@"user"]];
    [navCon setBarItem:barItem1];

    NSArray *controllers = [[NSArray alloc] initWithObjects:navCon, nil];

    CCContainerViewController *container = [CCContainerViewController new];

    [container setViewControllers:controllers animated:YES];
    [container.view addSubview:[self closeButton]];
    [self presentViewController:container animated:YES completion:nil];
}

- (IBAction)collectionView:(id)sender
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing = 4.0;
    flowLayout.minimumInteritemSpacing = 0.0;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    TestCollectionViewController *collection = [[TestCollectionViewController alloc] initWithCollectionViewLayout:flowLayout];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:collection];
    
    CCBarItem *barItem1 = [[CCBarItem alloc] initWithTitle:@"User" image:[UIImage imageNamed:@"user"]];
    [nav setBarItem:barItem1];
    
    CCContainerViewController *container = [CCContainerViewController new];
    container.enabledStatusBarBackground = YES;
    
    [container setViewControllers:@[nav] animated:YES];
    [container.view addSubview:[self closeButton]];
    [self presentViewController:container animated:YES completion:nil];
}

- (UIButton *)closeButton {
 
    UIButton *button = [UIButton new];
    [button setTitle:@"Close" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(closeController) forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(7.5, self.view.bounds.size.height - 60, 50, 50)];
    return button;
}

- (void)closeController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
