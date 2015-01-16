//
//  BACellSizingTableView.h
//
//
//  Created by Dmitry Mazurenko on 1/12/15.
//  Copyright (c) 2015 Provectus-It. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^DMTableViewConfigureBlock)(id viewToConfigure);

@interface DMCellSizingTableView : UITableView

/**
 *  Set this property to YES in order to return tableview's contentSize in intrinsicContentSize.
 */
@property (nonatomic, assign) BOOL autosizesToFitContent;

/* Cells */
- (CGFloat)heightForCellAtIndexPath:(NSIndexPath *)indexPath
                         identifier:(NSString *)identifier
                     configureBlock:(DMTableViewConfigureBlock)configureBlock
                      minimumHeight:(CGFloat)minimumHeight
                   additionalHeight:(CGFloat)additionalHeight;

- (CGFloat)heightForCellAtIndexPath:(NSIndexPath *)indexPath
                         identifier:(NSString *)identifier
                     configureBlock:(DMTableViewConfigureBlock)configureBlock
                      minimumHeight:(CGFloat)minimumHeight;

/* Headers */
- (CGFloat)heightForHeaderInSection:(NSInteger)section
                         identifier:(NSString *)identifier
                     configureBlock:(DMTableViewConfigureBlock)configureBlock
                      minimumHeight:(CGFloat)minimumHeight;

- (CGFloat)heightForHeaderInSection:(NSInteger)section
                         identifier:(NSString *)identifier
                     configureBlock:(DMTableViewConfigureBlock)configureBlock
                      minimumHeight:(CGFloat)minimumHeight
                   additionalHeight:(CGFloat)additionalHeight;

/* Footers */
- (CGFloat)heightForFooterInSection:(NSInteger)section
                         identifier:(NSString *)identifier
                     configureBlock:(DMTableViewConfigureBlock)configureBlock
                      minimumHeight:(CGFloat)minimumHeight;

- (CGFloat)heightForFooterInSection:(NSInteger)section
                         identifier:(NSString *)identifier
                     configureBlock:(DMTableViewConfigureBlock)configureBlock
                      minimumHeight:(CGFloat)minimumHeight
                   additionalHeight:(CGFloat)additionalHeight;

@end
