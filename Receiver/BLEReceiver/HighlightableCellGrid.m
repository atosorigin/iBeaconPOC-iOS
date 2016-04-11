//
//  HighlightableCellGrid.m
//  BLEReceiver
//
//  Created by Peter Brock on 06/04/2016.
//  Copyright © 2016 Atos. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "HighlightableCellGrid.h"
#import "CircleCellView.h"

#define CURRENT_CELL_COLOUR [UIColor colorWithRed:0.0f green:0.3984f blue:0.6289f alpha:1.0f]
#define MEETING_CELL_COLOUR [UIColor colorWithRed:0.9609f green:0.3711f blue:0.0156f alpha:1.0f]
#define CELL_ALPHA 0.7f
#define CELL_BORDER 4.0f;

@interface HighlightableCellGrid()

@property (strong, nonatomic) NSArray *cellReferences;

@property (nonatomic) int currentCellX;
@property (nonatomic) int currentCellY;

@property (nonatomic) int meetingCellX;
@property (nonatomic) int meetingCellY;

@property (nonatomic) int numRows;
@property (nonatomic) int numColumns;

@end

@implementation HighlightableCellGrid

- (id)initWithCoder:(NSCoder*)coder
{
    if ((self = [super initWithCoder:coder])) {
        [self initialise];
    }
    return self;
}

#pragma mark Initialization

- (void)initialise {
    
    //set the default selection to be blank
    _currentCellX = -1;
    _currentCellY = -1;
    
    //set the default meeting location to be blank
    _meetingCellX = -1;
    _meetingCellY = -1;
    
    //set the grid dimensions - in the future this should probably be configurable
    _numRows = 5;
    _numColumns = 5;
    
    [self createGridAndReferences];
}

- (void)createGridAndReferences {
    
    NSMutableArray *cellToViewArray = [NSMutableArray arrayWithCapacity:_numRows];
    
    NSMutableArray *horizontalStackViews = [NSMutableArray array];
    
    //create the horizontal rows represented by stack views
    for (int i = 0; i < _numRows; i++) {
        
        NSMutableArray *rowViews = [NSMutableArray arrayWithCapacity:_numColumns];
        
        //create a cell for each column to be placed in this row
        for (int j = 0; j < _numColumns; j++) {
            CircleCellView *cell = [CircleCellView new];
            cell.backgroundColor = CURRENT_CELL_COLOUR;
            cell.layer.borderColor = [CURRENT_CELL_COLOUR CGColor];
            cell.layer.borderWidth = CELL_BORDER;
            
            //by default hide the view - we cant use the Hidden property as this removes it from the StackView
            cell.alpha = 0.0f;
            
            [rowViews addObject:cell];
        }
        
        //put a copy of the view references into the cell lookup array
        [cellToViewArray addObject:[NSArray arrayWithArray:rowViews]];
        
        //now create the stack view that flows horizontal with all cells for this row
        UIStackView *stackViewHorizontal = [[UIStackView alloc] initWithArrangedSubviews:[NSArray arrayWithArray:rowViews]];
        stackViewHorizontal.axis = UILayoutConstraintAxisHorizontal;
        stackViewHorizontal.distribution = UIStackViewDistributionFillEqually;
        stackViewHorizontal.alignment = UIStackViewAlignmentFill;
        stackViewHorizontal.spacing = 0.0f;
        
        [horizontalStackViews addObject:stackViewHorizontal];
    }
    
    //create a vertical stack view with will contain all the row stack views
    UIStackView *stackViewVertical = [[UIStackView alloc] initWithArrangedSubviews:[NSArray arrayWithArray:horizontalStackViews]];
    stackViewVertical.axis = UILayoutConstraintAxisVertical;
    stackViewVertical.distribution = UIStackViewDistributionFillEqually;
    stackViewVertical.alignment = UIStackViewAlignmentFill;
    stackViewVertical.spacing = 0.0f;
    stackViewVertical.translatesAutoresizingMaskIntoConstraints = NO;
    
    //add it as a subview and set it to glue to the edges of (self)
    [self addSubview:stackViewVertical];
    [self addConstraints:[NSLayoutConstraint
                                        constraintsWithVisualFormat:@"V:|[stackViewVertical]|"
                                        options:NSLayoutFormatDirectionLeadingToTrailing
                                        metrics:nil
                                        views:NSDictionaryOfVariableBindings(stackViewVertical)]];
    [self addConstraints:[NSLayoutConstraint
                                        constraintsWithVisualFormat:@"H:|[stackViewVertical]|"
                                        options:NSLayoutFormatDirectionLeadingToTrailing
                                        metrics:nil
                                        views:NSDictionaryOfVariableBindings(stackViewVertical)]];
    
    _cellReferences = [NSArray arrayWithArray:cellToViewArray];
}

#pragma mark Highlighting

- (void)exclusiveHighlightCellX:(int)cellX andCellY:(int)cellY {
    
    //first de-highlight the last one
    if (_currentCellX != -1 && _currentCellY != -1) {
        NSArray *row = [_cellReferences objectAtIndex:_currentCellY];
        UIView *cell = [row objectAtIndex:_currentCellX];
        
        //if the last cell is also the current meeting cell, keep it highlighted
        if (_meetingCellX == _currentCellX && _meetingCellY == _currentCellY) {
            cell.alpha = CELL_ALPHA;
            cell.layer.borderColor = [MEETING_CELL_COLOUR CGColor];
        } else {
            cell.alpha = 0.0f;
            cell.layer.borderColor = [CURRENT_CELL_COLOUR CGColor];
        }
    }
    
    //now highlight the new one
    if (cellX != -1 && cellY != -1) {
        NSArray *newRow = [_cellReferences objectAtIndex:cellY];
        UIView *newCell = [newRow objectAtIndex:cellX];
        
        newCell.alpha = CELL_ALPHA;
        
        //if the new cell is the current meeting cell, change the highlighting to suit
        if (cellX == _meetingCellX || cellY == _meetingCellY) {
            newCell.backgroundColor = MEETING_CELL_COLOUR;
            newCell.layer.borderColor = [CURRENT_CELL_COLOUR CGColor];
        } else {
            //else highlight the cell as normal
            newCell.backgroundColor = CURRENT_CELL_COLOUR;
            newCell.layer.borderColor = [CURRENT_CELL_COLOUR CGColor];
        }

    }
    
    _currentCellX = cellX;
    _currentCellY = cellY;
}

- (void)exclusiveMeetingHighlightCellX:(int)cellX andCellY:(int)cellY {
    
    //first de-highlight the last one
    if (_meetingCellX != -1 && _meetingCellY != -1) {
        NSArray *row = [_cellReferences objectAtIndex:_meetingCellX];
        UIView *cell = [row objectAtIndex:_meetingCellY];
        
        //change the background colour back to normal
        cell.backgroundColor = CURRENT_CELL_COLOUR;
        cell.layer.borderColor = [CURRENT_CELL_COLOUR CGColor];
        
        //if the last meeting cell is also the current normal cell, highlight it
        if (_meetingCellX == _currentCellX && _meetingCellY == _currentCellY) {
            cell.alpha = CELL_ALPHA;
        } else {
            //else last meeting cell is no longer visible
            cell.alpha = 0.0f;
        }
    }
    
    //now highlight the new one
    if (cellX != -1 && cellY != -1) {
        NSArray *newRow = [_cellReferences objectAtIndex:cellY];
        UIView *newCell = [newRow objectAtIndex:cellX];
        
        newCell.alpha = CELL_ALPHA;
        newCell.backgroundColor = MEETING_CELL_COLOUR;
        
        //if the new meeting cell is also the current location, highlight the border with the current colour
        if (cellX == _currentCellX && cellY == _currentCellY) {
            newCell.layer.borderColor = [CURRENT_CELL_COLOUR CGColor];
        } else {
            //highlight it the meeting colour instead
            newCell.layer.borderColor = [MEETING_CELL_COLOUR CGColor];
        }

    }
    
    _meetingCellX = cellX;
    _meetingCellY = cellY;
}

@end
