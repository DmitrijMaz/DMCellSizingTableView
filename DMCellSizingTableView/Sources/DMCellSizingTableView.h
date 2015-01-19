//
//  BACellSizingTableView.h
//
//
//  Created by Dmitry Mazurenko on 1/12/15.
//  Copyright (c) 2015 Provectus-It. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DMCellSizingTableViewDelegate <UITableViewDelegate>

@optional
- (CGFloat)tableView:(UITableView *)tableView minimumHeightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)tableView:(UITableView *)tableView additionalHeightForRowAtIndexPath:(NSIndexPath *)indexPath;

- (CGFloat)tableView:(UITableView *)tableView minimumHeightForHeaderInSection:(NSInteger)section;
- (CGFloat)tableView:(UITableView *)tableView additionalHeightForHeaderInSection:(NSInteger)section;

- (CGFloat)tableView:(UITableView *)tableView minimumHeightForFooterInSection:(NSInteger)section;
- (CGFloat)tableView:(UITableView *)tableView additionalHeightForFooterInSection:(NSInteger)section;

@end

typedef void (^DMTableViewConfigureBlock)(id viewToConfigure);

@interface DMCellSizingTableView : UITableView

/**
 *  Set this property to YES in order to return tableview's contentSize in intrinsicContentSize.
 */
@property (nonatomic, assign) BOOL autosizesToFitContent;

/* Cells */

/**
 *  Calculate and return height for row at specified index path. Minimum and additional height is returned by delegate if using this method.
 *
 *  @param indexPath      NSIndexPath of row to calculate height for. Must not be nil.
 *  @param identifier     Reuse identifier of cell. Must not be nil.
 *  @param configureBlock Block that will be called prior to calculating height. Used to populate cell with content.
 *
 *  @return Maximum from calculated height and minimum height + additional height.
 */
- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath
                        identifier:(NSString *)identifier
                    configureBlock:(DMTableViewConfigureBlock)configureBlock;

/**
 *  Calculate and return height for row at specified index path. Minimum height is returned by delegate if using this method.
 *
 *  @param indexPath        NSIndexPath of row to calculate height for. Must not be nil.
 *  @param identifier       Reuse identifier of cell. Must not be nil.
 *  @param configureBlock   Block that will be called prior to calculating height. Used to populate cell with content.
 *  @param additionalHeight Additional height that should be added to the final value.
 *
 *  @return Maximum from calculated height and minimum height + additional height.
 */
- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath
                        identifier:(NSString *)identifier
                    configureBlock:(DMTableViewConfigureBlock)configureBlock
                  additionalHeight:(CGFloat)additionalHeight;

/**
 *  Calculate and return height for row at specified index path. Additional height is returned by delegate if using this method.
 *
 *  @param indexPath        NSIndexPath of row to calculate height for. Must not be nil.
 *  @param identifier       Reuse identifier of cell. Must not be nil.
 *  @param configureBlock   Block that will be called prior to calculating height. Used to populate cell with content.
 *  @param minimumHeight    Minimum height that should be added to the final value.
 *
 *  @return Maximum from calculated height and minimum height + additional height.
 */
- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath
                        identifier:(NSString *)identifier
                    configureBlock:(DMTableViewConfigureBlock)configureBlock
                     minimumHeight:(CGFloat)minimumHeight;

/**
 *  Calculate and return height for row at specified index path. Delegate won't be asked for additional and minimum heights if using this method.
 *
 *  @param indexPath        NSIndexPath of row to calculate height for. Must not be nil.
 *  @param identifier       Reuse identifier of cell. Must not be nil.
 *  @param configureBlock   Block that will be called prior to calculating height. Used to populate cell with content.
 *  @param minimumHeight    Minimum height that should be added to the final value.
 *  @param additionalHeight Additional height that should be added to the final value.
 *
 *  @return Maximum from calculated height and minimum height + additional height.
 */
- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath
                        identifier:(NSString *)identifier
                    configureBlock:(DMTableViewConfigureBlock)configureBlock
                     minimumHeight:(CGFloat)minimumHeight
                  additionalHeight:(CGFloat)additionalHeight;

/* Headers */
- (CGFloat)heightForHeaderInSection:(NSInteger)section
                         identifier:(NSString *)identifier
                     configureBlock:(DMTableViewConfigureBlock)configureBlock;


- (CGFloat)heightForHeaderInSection:(NSInteger)section
                         identifier:(NSString *)identifier
                     configureBlock:(DMTableViewConfigureBlock)configureBlock
                      minimumHeight:(CGFloat)minimumHeight;

- (CGFloat)heightForHeaderInSection:(NSInteger)section
                         identifier:(NSString *)identifier
                     configureBlock:(DMTableViewConfigureBlock)configureBlock
                   additionalHeight:(CGFloat)additionalHeight;

- (CGFloat)heightForHeaderInSection:(NSInteger)section
                         identifier:(NSString *)identifier
                     configureBlock:(DMTableViewConfigureBlock)configureBlock
                      minimumHeight:(CGFloat)minimumHeight
                   additionalHeight:(CGFloat)additionalHeight;

/* Footers */

- (CGFloat)heightForFooterInSection:(NSInteger)section
                         identifier:(NSString *)identifier
                     configureBlock:(DMTableViewConfigureBlock)configureBlock;

- (CGFloat)heightForFooterInSection:(NSInteger)section
                         identifier:(NSString *)identifier
                     configureBlock:(DMTableViewConfigureBlock)configureBlock
                      minimumHeight:(CGFloat)minimumHeight;

- (CGFloat)heightForFooterInSection:(NSInteger)section
                         identifier:(NSString *)identifier
                     configureBlock:(DMTableViewConfigureBlock)configureBlock
                   additionalHeight:(CGFloat)additionalHeight;

- (CGFloat)heightForFooterInSection:(NSInteger)section
                         identifier:(NSString *)identifier
                     configureBlock:(DMTableViewConfigureBlock)configureBlock
                      minimumHeight:(CGFloat)minimumHeight
                   additionalHeight:(CGFloat)additionalHeight;

@end
