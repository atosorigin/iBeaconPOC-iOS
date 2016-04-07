//
//  HighlightableCellGrid.m
//  BLEReceiver
//
//  Created by Peter Brock on 06/04/2016.
//  Copyright © 2016 Atos. All rights reserved.
//

#import "HighlightableCellGrid.h"
#import "CircleCellView.h"

@interface HighlightableCellGrid()

@property (strong, nonatomic) NSArray *cellReferences;

@property (nonatomic) int currentCellX;
@property (nonatomic) int currentCellY;

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
            cell.backgroundColor = [UIColor colorWithRed:0.0f green:0.3984f blue:0.6289f alpha:1.0f];
            
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
        
        cell.alpha = 0.0f;
    }
    
    //now highlight the new one
    if (cellX != -1 && cellY != -1) {
        NSArray *newRow = [_cellReferences objectAtIndex:cellY];
        UIView *newCell = [newRow objectAtIndex:cellX];
        
        newCell.alpha = 0.7f;
    }
    
    _currentCellX = cellX;
    _currentCellY = cellY;
}

@end
