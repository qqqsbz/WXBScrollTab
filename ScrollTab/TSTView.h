//
//  TSTView.h
//  iPenYou
//
//  Created by fanly frank on 5/22/15.
//  Copyright (c) 2015 vbuy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class TSTView;

@protocol TSTViewDataSource <NSObject>

@required
- (NSInteger)numberOfTabsInTSTView:(TSTView *)tstview;
- (NSString *)tstview:(TSTView *)tstview titleForTabAtIndex:(NSInteger)tabIndex;
- (UIView *)tstview:(TSTView *)tstview viewForSelectedTabIndex:(NSInteger)tabIndex;

@end

@protocol TSTViewDelegate <NSObject>

@optional

- (UIColor *)tabViewBackgroundColorForTSTView:(TSTView *)tstview;
- (UIColor *)highlightColorForTSTView:(TSTView *)tstview;
- (UIColor *)normalColorForTSTView:(TSTView *)tstview;
- (UIColor *)normalColorForSeparatorInTSTView:(TSTView *)tstview;
- (UIColor *)normalColorForShadowViewInTSTView:(TSTView *)tstview;

- (CGFloat)heightForTabInTSTView:(TSTView *)tstview;
- (CGFloat)heightForTabSeparatorInTSTView:(TSTView *)tstview;
- (CGFloat)heightForSelectedIndicatorInTSTView:(TSTView *)tstview;

- (UIFont *)fontForNormalTabTitleInTSTView:(TSTView *)tstview;
- (UIFont *)fontForSelectedTabTitleInTSTView:(TSTView *)tstview;

- (void)tstview:(TSTView *)tstview didSelectedTabAtIndex:(NSInteger)tabIndex;

@end


@interface TSTView : UIView <UIScrollViewDelegate>

@property (assign, nonatomic) id <TSTViewDataSource> dataSource;
@property (assign, nonatomic) id <TSTViewDelegate>   delegate;
@property (assign, nonatomic, getter=isAutoAverageSort) BOOL autoAverageSort;
@property (assign, nonatomic, getter=isShadowTitleEqualWidth) BOOL shadowTitleEqualWidth;

- (void)registerReusableContentViewClass:(Class)contentViewClass;

- (NSString *)titleForSelectedTab;

- (NSInteger)indexForSelectedTab;

- (UIScrollView *)topTabViewInTSTView;

- (void)reloadData;

- (void)showFraternalViewAtIndex:(NSInteger)page;

- (NSArray *)tabContentSubViews;

@end

