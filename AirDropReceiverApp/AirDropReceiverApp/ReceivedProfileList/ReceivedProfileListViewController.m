//
//  ReceivedProfileListViewController.m
//  AirDropReceiverApp
//
//  Created by Pranay on 3/26/14.
//  Copyright (c) 2014 DMI. All rights reserved.
//

#import "ReceivedProfileListViewController.h"
#import "Constant.h"
#import "APLUtilities.h"
#import "APLProfile.h"

@interface ReceivedProfileListViewController ()
@property (strong, nonatomic) NSMutableArray *tableContents;
@end

@implementation ReceivedProfileListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Received File List";
    
    self.tableContents = [[NSMutableArray alloc] init];
    [self.tableContents addObjectsFromArray:[APLUtilities loadProfiles]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tableContents count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ReceivedProfileListCellIdenifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSInteger row = [indexPath row];
    cell.imageView.image = [(APLProfile *)self.tableContents[row] thumbnailImage];
    cell.textLabel.text = [(APLProfile *)self.tableContents[row] name];
    
    return cell;
}

@end
