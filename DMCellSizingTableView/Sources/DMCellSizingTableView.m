//
//  BACellSizingTableView.m
//
//
//  Created by Dmitry Mazurenko on 1/12/15.
//  Copyright (c) 2015 Provectus-It. All rights reserved.
//

#import "DMCellSizingTableView.h"

typedef NS_ENUM(NSInteger, ErrorLevel) {
    ErrorLevelInfo = 0,
    ErrorLevelWarning,
    ErrorLevelCritical
};

@interface DMCellSizingTableView ()

@property (nonatomic, strong) NSMutableDictionary *viewCache;
@property (nonatomic, strong) NSMutableDictionary *heightCache;

- (CGFloat)heightForViewWithIdentifier:(NSString *)identifier
                        configureBlock:(DMTableViewConfigureBlock)configureBlock
                         minimumHeight:(CGFloat)minimumHeight
                      additionalHeight:(CGFloat)additionalHeight
                            storageKey:(id<NSCopying>)storageKey;

- (CGFloat)heightForViewWithIdentifier:(NSString *)identifier
                        configureBlock:(DMTableViewConfigureBlock)configureBlock
                         minimumHeight:(CGFloat)minimumHeight
                      additionalHeight:(CGFloat)additionalHeight
                            storageKey:(id<NSCopying>)storageKey
                      parentStorageKey:(id<NSCopying>)parentStorageKey;

@end

@implementation DMCellSizingTableView

- (void)dealloc
{
    [self cleanCache];
    
    _viewCache      = nil;
    _heightCache    = nil;
    
    [self logInfoWithMessage:@"Dealloc %@", NSStringFromClass([self class])];
}

#pragma mark - Logging

- (NSString *)titleForErrorLevel:(ErrorLevel)errorLevel
{
    NSString *title = @"[ERORR]";
    
    switch (errorLevel) {
        case ErrorLevelInfo:
            title = @"[INFO]";
            break;
        case ErrorLevelCritical:
            title = @"[***ERROR***]";
            break;
        case ErrorLevelWarning:
            title = @"[WARNING]";
            break;
        default:
            break;
    }
    
    return title;
}

- (void)logWithErrorType:(ErrorLevel)level format:(NSString *)format arguments:(va_list)argList
{
    NSString *formattedMessage = format;
    
    if ( argList )
    {
        formattedMessage = [[NSString alloc] initWithFormat:format arguments:argList];
    }
    
    switch (level)
    {
        case ErrorLevelInfo:
        case ErrorLevelCritical:
        case ErrorLevelWarning:
        default:
        {
            NSString *title         = [self titleForErrorLevel:level];
            NSString *fullMessage   = [title stringByAppendingFormat:@" %@", formattedMessage];
            
            NSLog(@"%@", fullMessage);
            break;
        }
    }
}

- (void)logWithErrorType:(ErrorLevel)level message:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    
    [self logWithErrorType:level format:format arguments:args];
    
    va_end(args);
}

- (void)logErrorWithMesage:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    
    [self logWithErrorType:ErrorLevelCritical format:format arguments:args];
    
    va_end(args);
}

- (void)logInfoWithMessage:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    
    [self logWithErrorType:ErrorLevelInfo format:format arguments:args];
    
    va_end(args);
}

- (void)logWarningWithMessage:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    
    [self logWithErrorType:ErrorLevelWarning format:format arguments:args];
    
    va_end(args);
}


#pragma mark - Caching

- (NSMutableDictionary *)viewCache
{
    if ( !_viewCache )
    {
        _viewCache = [NSMutableDictionary dictionary];
    }
    
    return _viewCache;
}

- (NSMutableDictionary *)heightCache
{
    if ( !_heightCache )
    {
        _heightCache = [NSMutableDictionary dictionary];
    }
    
    return _heightCache;
}

- (void)cleanCache
{
    [_viewCache removeAllObjects];
    [_heightCache removeAllObjects];
    
    [self logInfoWithMessage:@"Height and View Cache Cleaned"];
}

- (void)storeView:(UIView *)view identifier:(NSString *)identifier
{
    if ( !view && identifier )
    {
        [_viewCache removeObjectForKey:identifier];
        [self logInfoWithMessage:@"Unregistering view for identifier %@", identifier];
        return;
    }
    
    if ( !view || !identifier )
    {
        [self logErrorWithMesage:@"Not enough information to register view %@ for identifier %@.", view, identifier];
        return;
    }
    
    [self.viewCache setObject:view forKey:identifier];
    
    [self logInfoWithMessage:@"Registering view %@ for identifier %@", view, identifier];
}

- (void)storeObjectOfClass:(Class)class withIdentifier:(NSString *)identifier
{
    NSParameterAssert(identifier);
    NSParameterAssert(class || [class isSubclassOfClass:[UIView class]]);
    
    UIView *reusableView = nil;
    
    if ( class )
    {
        reusableView = [[class alloc] init];
    }
    
    [self storeView:reusableView identifier:identifier];
}

- (void)storeObjectWithNib:(UINib *)nib withIdentifier:(NSString *)identifier
{
    NSParameterAssert(identifier);
    NSParameterAssert(nib);
    
    UIView *view = [[nib instantiateWithOwner:nil options:0] firstObject];
    
    [self storeView:view identifier:identifier];
}

#pragma mark - Resistration Overrides

- (void)registerClass:(Class)cellClass forCellReuseIdentifier:(NSString *)identifier
{
    [self storeObjectOfClass:cellClass withIdentifier:identifier];
    
    [super registerClass:cellClass forCellReuseIdentifier:identifier];
}

- (void)registerClass:(Class)aClass forHeaderFooterViewReuseIdentifier:(NSString *)identifier
{
    [self storeObjectOfClass:aClass withIdentifier:identifier];
    
    [super registerClass:aClass forHeaderFooterViewReuseIdentifier:identifier];
}

- (void)registerNib:(UINib *)nib forCellReuseIdentifier:(NSString *)identifier
{
    [self storeObjectWithNib:nib withIdentifier:identifier];
    
    [super registerNib:nib forCellReuseIdentifier:identifier];
}

- (void)registerNib:(UINib *)nib forHeaderFooterViewReuseIdentifier:(NSString *)identifier
{
    [self storeObjectWithNib:nib withIdentifier:identifier];
    
    [super registerNib:nib forHeaderFooterViewReuseIdentifier:identifier];
}

#pragma mark - Reloading Overrides

- (void)reloadData
{
    [_heightCache removeAllObjects];
    
    [super reloadData];
}

#pragma mark Rows

- (void)deleteCacheForRowsAtIndexPaths:(NSArray *)indexPaths
{
    [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *obj, NSUInteger idx, BOOL *stop) {
        
        NSMutableDictionary *sectionCahce = _heightCache[@(obj.section)];
        
        [sectionCahce removeObjectForKey:@(obj.row)];
    }];
}

- (void)reloadRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation
{
    [self deleteCacheForRowsAtIndexPaths:indexPaths];
    
    [super reloadRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}

- (void)deleteRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation
{
    [self deleteCacheForRowsAtIndexPaths:indexPaths];
    
    [super deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}

- (void)moveRowAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath
{
    [self deleteCacheForSections:[NSIndexSet indexSetWithIndex:indexPath.section]];
    [self deleteCacheForSections:[NSIndexSet indexSetWithIndex:newIndexPath.section]];
    
    [super moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
}

#pragma mark Sections

- (void)deleteCacheForSections:(NSIndexSet *)sections
{
    if ( sections.count == [self numberOfSections] )
    {
        [self.heightCache removeAllObjects];
        return;
    }
    
    __weak typeof(self) wSelf = self;
    [sections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
       
        NSString *headerKey = [wSelf keyForHeaderInSection:idx];
        NSString *footerKey = [wSelf keyForFooterInSection:idx];
        
        [wSelf.heightCache removeObjectsForKeys:@[headerKey, footerKey, @(idx)]];
    }];
}

- (void)reloadSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation
{
    [self deleteCacheForSections:sections];
    
    [self reloadSections:sections withRowAnimation:animation];
}

- (void)deleteSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation
{
    [self deleteCacheForSections:sections];
    
    [super deleteSections:sections withRowAnimation:animation];
}

- (void)moveSection:(NSInteger)section toSection:(NSInteger)newSection
{
    if ( section == newSection )
    {
        return;
    }
 
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    [indexSet addIndex:section];
    [indexSet addIndex:newSection];
    
    [self deleteCacheForSections:indexSet];
    
    [super moveSection:section toSection:newSection];
}

#pragma mark - Size Calculations

- (NSNumber *)getCachedHeightForStorageKey:(id<NSCopying>)storageKey parentStorageKey:(id<NSCopying>)parentStorageKey
{
    NSParameterAssert(storageKey);
    
    if ( parentStorageKey )
    {
        NSDictionary *storedHeights = [_heightCache objectForKey:parentStorageKey];
        
        return [storedHeights objectForKey:storageKey];
    }
    
    return [_heightCache objectForKey:storageKey];
}

- (void)storeHeight:(CGFloat)height forKey:(id<NSCopying>)storageKey parentStorageKey:(id<NSCopying>)parentStorageKey
{
    NSParameterAssert(storageKey);
    
    if ( parentStorageKey )
    {
        NSMutableDictionary *storedObject = [_heightCache objectForKey:parentStorageKey];
        
        if ( !storedObject )
        {
            storedObject = [NSMutableDictionary dictionary];
        }
        
        [storedObject setObject:@(height) forKey:storageKey];
        
        [self.heightCache setObject:storedObject forKey:parentStorageKey];
    }
    else
    {
        [self.heightCache setObject:@(height) forKey:storageKey];
    }
    
    [self logInfoWithMessage:@"Heights updated %@", self.heightCache];
}

- (id)sizingViewWithIdentifier:(NSString *)identifier
{
    NSParameterAssert(identifier);
    
    UIView *reusableView = [_viewCache objectForKey:identifier];
    
    if ( !reusableView )
    {
        [self logWarningWithMessage:@"No sizing view with identifier %@", identifier];
    }
    
    return reusableView;
}

- (CGFloat)heightForView:(UIView *)view withMinimumHeight:(CGFloat)minimumHeight
{
    UIView *sizingView = nil;
    
    if ( [view isKindOfClass:[UITableViewCell class]] )
    {
        sizingView = [(UITableViewCell *)view contentView];
    }
    else
    {
        sizingView = view;
    }
    
    [view updateConstraintsIfNeeded];
    [view layoutIfNeeded];
    
    CGSize size = [sizingView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    
    size.height = MAX(ceil(size.height + 1.f), minimumHeight);
    
    return size.height;
}

- (CGFloat)heightForViewWithIdentifier:(NSString *)cellIdentifier
                        configureBlock:(DMTableViewConfigureBlock)configureBlock
                         minimumHeight:(CGFloat)minimumHeight
                      additionalHeight:(CGFloat)additionalHeight
{
    UIView *reuseView = [self sizingViewWithIdentifier:cellIdentifier];
    
    if ( configureBlock )
    {
        configureBlock(reuseView);
    }
    else
    {
        [self logWarningWithMessage:@"You have not specified configure block. Cell may not be populated with content."];
    }
    
    CGFloat height = [self heightForView:reuseView withMinimumHeight:minimumHeight];
    
    height += additionalHeight;
    
    return height;
}

- (CGFloat)heightForViewWithIdentifier:(NSString *)cellIdentifier
                        configureBlock:(DMTableViewConfigureBlock)configureBlock
                         minimumHeight:(CGFloat)minimumHeight
{
    return [self heightForViewWithIdentifier:cellIdentifier configureBlock:configureBlock minimumHeight:minimumHeight additionalHeight:0.f];
}

- (CGFloat)heightForViewWithIdentifier:(NSString *)identifier
                        configureBlock:(DMTableViewConfigureBlock)configureBlock
                         minimumHeight:(CGFloat)minimumHeight
                      additionalHeight:(CGFloat)additionalHeight
                            storageKey:(id<NSCopying>)storageKey
                      parentStorageKey:(id<NSCopying>)parentStorageKey
{
    NSParameterAssert(identifier);
    NSParameterAssert(storageKey);
    
    NSNumber *storedHeight = [self getCachedHeightForStorageKey:storageKey parentStorageKey:parentStorageKey];
    
    if ( storedHeight )
    {
        return [storedHeight floatValue];
    }
    
    CGFloat height = [self heightForViewWithIdentifier:identifier configureBlock:configureBlock minimumHeight:minimumHeight additionalHeight:additionalHeight];
    
    if ( height <= 0.f )
    {
        [self logErrorWithMesage:@"Unable to compute height for view with identifier %@ with key %@. Please make sure you specify minimum view height.", identifier, storageKey];
    }
    else
    {
        [self storeHeight:height forKey:storageKey parentStorageKey:parentStorageKey];
        [self logInfoWithMessage:@"%@ Height for row %@ is %f", storageKey, height];
    }
    
    return height;
}

- (CGFloat)heightForViewWithIdentifier:(NSString *)identifier
                        configureBlock:(DMTableViewConfigureBlock)configureBlock
                         minimumHeight:(CGFloat)minimumHeight
                      additionalHeight:(CGFloat)additionalHeight
                            storageKey:(id<NSCopying>)storageKey
{
    return [self heightForViewWithIdentifier:identifier configureBlock:configureBlock minimumHeight:minimumHeight additionalHeight:additionalHeight storageKey:storageKey parentStorageKey:nil];
}

#pragma mark - Cell

- (CGFloat)heightForCellAtIndexPath:(NSIndexPath *)indexPath
                         identifier:(NSString *)identifier
                     configureBlock:(DMTableViewConfigureBlock)configureBlock
                      minimumHeight:(CGFloat)minimumHeight
{
    return [self heightForCellAtIndexPath:indexPath identifier:identifier configureBlock:configureBlock minimumHeight:minimumHeight additionalHeight:0.f];
}

- (CGFloat)heightForCellAtIndexPath:(NSIndexPath *)indexPath
                         identifier:(NSString *)identifier
                     configureBlock:(DMTableViewConfigureBlock)configureBlock
                      minimumHeight:(CGFloat)minimumHeight
                   additionalHeight:(CGFloat)additionalHeight
{
    NSNumber *storageKey = @(indexPath.row);
    
    return [self heightForViewWithIdentifier:identifier configureBlock:configureBlock minimumHeight:minimumHeight additionalHeight:additionalHeight storageKey:storageKey parentStorageKey:@(indexPath.section)];
}


#pragma mark - Header

- (NSString *)keyForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"header_%ld", (long)section];
}

- (CGFloat)heightForHeaderInSection:(NSInteger)section
                         identifier:(NSString *)identifier
                     configureBlock:(DMTableViewConfigureBlock)configureBlock
                      minimumHeight:(CGFloat)minimumHeight
{
    
    return [self heightForHeaderInSection:section identifier:identifier configureBlock:configureBlock minimumHeight:minimumHeight additionalHeight:0.f];
}

- (CGFloat)heightForHeaderInSection:(NSInteger)section
                         identifier:(NSString *)identifier
                     configureBlock:(DMTableViewConfigureBlock)configureBlock
                      minimumHeight:(CGFloat)minimumHeight
                   additionalHeight:(CGFloat)additionalHeight
{
    NSString *key = [self keyForHeaderInSection:section];
    
    return [self heightForViewWithIdentifier:identifier configureBlock:configureBlock minimumHeight:minimumHeight additionalHeight:additionalHeight storageKey:key];
}


#pragma mark - Footer

- (NSString *)keyForFooterInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"footer_%ld", (long)section];
}

- (CGFloat)heightForFooterInSection:(NSInteger)section
                         identifier:(NSString *)identifier
                     configureBlock:(DMTableViewConfigureBlock)configureBlock
                      minimumHeight:(CGFloat)minimumHeight
{
    
    return [self heightForFooterInSection:section identifier:identifier configureBlock:configureBlock minimumHeight:minimumHeight additionalHeight:0.f];
}

- (CGFloat)heightForFooterInSection:(NSInteger)section
                         identifier:(NSString *)identifier
                     configureBlock:(DMTableViewConfigureBlock)configureBlock
                      minimumHeight:(CGFloat)minimumHeight
                   additionalHeight:(CGFloat)additionalHeight
{
    NSString *key = [self keyForFooterInSection:section];
    
    return [self heightForViewWithIdentifier:identifier configureBlock:configureBlock minimumHeight:minimumHeight additionalHeight:additionalHeight storageKey:key];
}

#pragma mark - Sizing to content

- (void)setAutosizesToFitContent:(BOOL)autosizesToFitContent
{
    if ( _autosizesToFitContent == autosizesToFitContent )
    {
        return;
    }
    
    _autosizesToFitContent = autosizesToFitContent;
    
    [self invalidateIntrinsicContentSize];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.autosizesToFitContent && !CGSizeEqualToSize(self.bounds.size, [self intrinsicContentSize]))
    {
        [self invalidateIntrinsicContentSize];
    }
}

- (CGSize)intrinsicContentSize
{
#if TARGET_INTERFACE_BUILDER
    return [super intrinsicContentSize];
#else
    
    CGSize size = [super intrinsicContentSize];
    
    if ( self.autosizesToFitContent )
    {
        size.height = self.contentSize.height;
    }
    
    return size;
#endif
}



@end
