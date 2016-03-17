//
//  HistoryTableViewController.m
//  BLEReceiver
//
//  Created by Peter Brock on 17/03/2016.
//  Copyright © 2016 Atos. All rights reserved.
//

#import "HistoryTableViewController.h"
#import "HistoryTableViewCell.h"
#import "BeaconLocationManager.h"

@interface HistoryTableViewController ()

@end

@implementation HistoryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //get location list here
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    //count of location list
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //int locationNumber = indexPath.row;
    //get locationData from locationNumber here
    
    HistoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HistoryCell" forIndexPath:indexPath];
    
    BeaconLocation location = [BeaconLocationManager getLocationForID:1];

    cell.labelLocation.text = [BeaconLocationManager getLocationDescriptionForLocation:location];
    cell.labelDate.text = @"";
    
    
    return cell;
}


@end
