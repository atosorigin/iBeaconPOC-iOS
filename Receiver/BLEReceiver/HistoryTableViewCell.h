//
//  HistoryTableViewCell.h
//  BLEReceiver
//
//  Created by Peter Brock on 17/03/2016.
//  Copyright © 2016 Atos. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *labelLocation;
@property (weak, nonatomic) IBOutlet UILabel *labelDate;

@end
