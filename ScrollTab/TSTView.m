//
//  TSTView.m
//  iPenYou
//
//  Created by fanly frank on 5/22/15.
//  Copyright (c) 2015 vbuy. All rights reserved.
//

#import "TSTView.h"
#import "NSLayoutConstraint+Util.h"
@interface TSTView ()

//subviews
@property (strong, nonatomic) UIScrollView *topTabView;
@property (strong, nonatomic) UIScrollView *contentView;
@property (strong, nonatomic) UIView *tabShadowView;
@property (strong, nonatomic) UIView *tabSeparator;

//appearance
@property (assign, nonatomic) CGFloat tabSpace;
@property (assign, nonatomic) CGFloat tabShadowHeight;
@property (assign, nonatomic) CGFloat leading;
@property (assign, nonatomic) CGFloat trailing;
@property (assign, nonatomic) CGFloat tabHeight;
@property (assign, nonatomic) CGFloat tabSeparatorHeight;

@property (strong, nonatomic) UIColor *tabHighlightColor;
@property (strong, nonatomic) UIColor *tabNormalColor;
@property (strong, nonatomic) UIColor *tabBackgroundColor;
@property (strong, nonatomic) UIColor *tabSeparatorColor;
@property (strong, nonatomic) UIColor *tabShadowViewColor;

@property (strong, nonatomic) UIFont *tabTitleNormalFont;
@property (strong, nonatomic) UIFont *tabTitleSelectedFont;

@property (strong, nonatomic) NSLayoutConstraint *tabShadowLeftConstraint;
@property (strong, nonatomic) NSLayoutConstraint *tabShadowHeightConstraint;
@property (strong, nonatomic) NSLayoutConstraint *tabShadowWidthConstraint;

@property (strong, nonatomic) NSMutableArray *reuseableContentViews;
@property (strong, nonatomic) NSMutableArray *tabButtons;

@property (assign, nonatomic) Class reuswableContentViewClass;
@property (strong, nonatomic) UIButton *currentSelectedBtn;

@property (assign, nonatomic) NSInteger tabsCount;
@property (assign, nonatomic) NSInteger currentSelectedIndex;
@property (assign, nonatomic) NSInteger currentLoadIndex;
@property (assign, nonatomic) NSInteger previousSelectedIndex;

@property (assign, nonatomic) BOOL isForwardSwip;


@end

@implementation TSTView

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        //init appearance
        self.tabSpace = 25.f;
        self.leading = 5.f;
        self.trailing = 5.f;
        self.tabShadowHeight = 3.f;
        self.tabHeight = 40.f;
        self.tabSeparatorHeight = .5f;
        self.autoAverageSort = NO;
        
        self.tabHighlightColor  = [UIColor greenColor];
        self.tabNormalColor     = [UIColor redColor];
        self.tabBackgroundColor = [UIColor clearColor];
        self.tabShadowViewColor = [UIColor grayColor];
        
        //init view
        self.topTabView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, self.tabHeight)];
        self.topTabView.translatesAutoresizingMaskIntoConstraints = NO;
        self.topTabView.showsHorizontalScrollIndicator = NO;
        self.topTabView.showsVerticalScrollIndicator = NO;
        self.topTabView.autoresizingMask = UIViewAutoresizingNone;
        
        self.tabSeparator = [[UIView alloc] initWithFrame:
                         CGRectMake(0, self.tabHeight - self.tabSeparatorHeight,frame.size.width, self.tabSeparatorHeight)];
        self.tabSeparator.translatesAutoresizingMaskIntoConstraints = NO;
        self.tabSeparator.backgroundColor = self.tabNormalColor;
        
        
        self.contentView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.tabHeight, frame.size.width, frame.size.height - self.tabHeight)];
        self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
        self.contentView.scrollEnabled = YES;
        self.contentView.autoresizingMask = UIViewAutoresizingNone;
        self.contentView.autoresizesSubviews = NO;
        self.contentView.showsHorizontalScrollIndicator = NO;
        self.contentView.showsVerticalScrollIndicator = NO;
        self.contentView.pagingEnabled = YES;
        self.contentView.delegate = self;
        
        [self addSubview:self.topTabView];
        [self addSubview:self.tabSeparator];
        [self addSubview:self.contentView];
        
        //init data
        self.tabButtons = [[NSMutableArray alloc] initWithCapacity:5];
        self.reuseableContentViews = [[NSMutableArray alloc] initWithCapacity:3];
        self.previousSelectedIndex = -1;
        self.currentSelectedIndex = -1;
        self.currentLoadIndex = 0;
        self.isForwardSwip = YES;
        
    }
    
    return self;
}

#pragma mark -- public methods

- (void)reloadData {
    
    [self updateBasicSubviewsConstraint];
    [self buildTabViews];
    [self layoutIfNeeded];
    [self buildContentViews];
    
    self.currentSelectedBtn = [self.tabButtons firstObject];
    [self autoScrollTopTabBySwipDirctionToPage:0];
}

- (void)registerReusableContentViewClass:(Class)contentViewClass {
    self.reuswableContentViewClass = contentViewClass;
}

- (NSString *)titleForSelectedTab {
    return self.currentSelectedBtn.titleLabel.text;
}

- (NSInteger)indexForSelectedTab {
    return self.currentSelectedIndex;
}


#pragma mark --  scroll view delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    NSInteger currentIndex = round(scrollView.contentOffset.x / scrollView.frame.size.width);
    [self autoScrollTopTabBySwipDirctionToPage:currentIndex];
    if (currentIndex == self.previousSelectedIndex)return;
    
    [self loadContentViewByIndex:currentIndex];
    if ([self.delegate respondsToSelector:@selector(tstview:didSelectedTabAtIndex:)]) {
        [self.delegate tstview:self didSelectedTabAtIndex:currentIndex];
    }
    
}

#pragma mark -- build methods

- (void)buildTabViews {
    
    if (self.dataSource) {
        
        if ([self.delegate respondsToSelector:@selector(highlightColorForTSTView:)]) {
            self.tabHighlightColor = [self.delegate highlightColorForTSTView:self];
        }
        
        if ([self.delegate respondsToSelector:@selector(normalColorForTSTView:)]) {
            self.tabNormalColor = [self.delegate normalColorForTSTView:self];
        }
        
        if ([self.delegate respondsToSelector:@selector(normalColorForSeparatorInTSTView:)]) {
            self.tabSeparatorColor = [self.delegate normalColorForSeparatorInTSTView:self];
        }
        
        if ([self.delegate respondsToSelector:@selector(heightForSelectedIndicatorInTSTView:)]) {
            self.tabShadowHeight = [self.delegate heightForSelectedIndicatorInTSTView:self];
        }
        
        if ([self.delegate respondsToSelector:@selector(normalColorForShadowViewInTSTView:)]) {
            self.tabShadowViewColor = [self.delegate normalColorForShadowViewInTSTView:self];
        }
        
        [self buildTabButtons];
        [self addConstraintToTabButtons];
        
        [self buildTabShadowView];
        [self addConstraintToTabShadowWihtAnchor:[self.tabButtons lastObject]];
        
        self.tabSeparator.backgroundColor = self.tabSeparatorColor;
        
    }
}

- (void)buildContentViews {
    
    self.contentView.contentSize = CGSizeMake(self.contentView.frame.size.width * self.tabsCount, self.contentView.frame.size.height);
    if (self.dataSource && self.tabsCount > 0) {
        if ([self.dataSource respondsToSelector:@selector(tstview:viewForSelectedTabIndex:)]) {
            UIView *contentAtIndex0 = [self.dataSource tstview:self viewForSelectedTabIndex:0];
            contentAtIndex0.frame = CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height);
            [self.contentView addSubview:contentAtIndex0];
            [self.reuseableContentViews addObject:contentAtIndex0];
        }
    }
}

- (void)buildTabShadowView {
    
    self.tabShadowView = [[UIView alloc] init];
    self.tabShadowView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tabShadowView.backgroundColor = self.tabShadowViewColor;
    [self.topTabView  addSubview:self.tabShadowView];
}

- (void)buildTabButtons {
    
    self.tabsCount = [self.dataSource numberOfTabsInTSTView:self];
    
    if ([self.delegate respondsToSelector:@selector(fontForNormalTabTitleInTSTView:)]) {
        self.tabTitleNormalFont = [self.delegate fontForNormalTabTitleInTSTView:self];
    }
    if ([self.delegate respondsToSelector:@selector(fontForSelectedTabTitleInTSTView:)]) {
        self.tabTitleSelectedFont = [self.delegate fontForSelectedTabTitleInTSTView:self];
    }
    
    for (NSInteger i = 0; i < self.tabsCount; i ++) {
        
        NSString *currentTabTitle = [self.dataSource tstview:self titleForTabAtIndex:i];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        
        if (self.tabTitleNormalFont) {
            btn.titleLabel.font = self.tabTitleNormalFont;
        }
        
        btn.tag = i;
        btn.translatesAutoresizingMaskIntoConstraints = NO;
        [btn setTitle:currentTabTitle forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor greenColor] forState:UIControlStateDisabled];
        
        [btn addTarget:self action:@selector(selectTab:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.tabButtons addObject:btn];
        [self.topTabView addSubview:btn];
    }
}

#pragma mark -- logic methods

- (void)loadContentViewByIndex:(NSInteger)index {
    
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(tstview:viewForSelectedTabIndex:)]) {
        NSInteger count = self.reuseableContentViews.count;
        NSArray *subViews = self.contentView.subviews;
        if (index >= count) {
            UIView *contentView = [self getContentViewAtIndex:index];
            [self.reuseableContentViews addObject:contentView];
            [self.contentView addSubview:contentView];
        } else {
            NSInteger tag = ((UIView *)subViews[index]).tag;
            if (tag != index) {
                UIView *contentView = [self getContentViewAtIndex:index];
                [self.reuseableContentViews addObject:contentView];
                [self.contentView insertSubview:contentView atIndex:index];
            }
        }
    }
}

- (UIView *)getContentViewAtIndex:(NSInteger)index
{
    UIView *contentView = [self.dataSource tstview:self viewForSelectedTabIndex:index];
    contentView.frame = CGRectMake(index * self.contentView.frame.size.width, 0, self.contentView.frame.size.width, self.contentView.frame.size.height);
    return contentView;
}


- (void)autoScrollTopTabBySwipDirctionToPage:(NSInteger)page {

    self.previousSelectedIndex = self.currentSelectedIndex;
    self.currentSelectedIndex = page;
    
    self.currentSelectedBtn = self.tabButtons[page];
    
    if (self.previousSelectedIndex < page) {
        self.isForwardSwip = YES;
    }
    else if (self.previousSelectedIndex > page) {
        self.isForwardSwip = NO;
    }
    
    //
    CGFloat tag;
    CGFloat btnX;
    CGFloat subtrace;
    CGFloat spare;
    CGFloat tabsOffsetX = self.topTabView.contentOffset.x;
    
    CGFloat tabsFrameWidth = self.topTabView.frame.size.width;
    CGFloat tabsContentWidth = self.topTabView.contentSize.width;
    
    CGFloat frameWidth = self.frame.size.width;
    
    tag = tabsOffsetX + frameWidth / 2 ;
    btnX = self.currentSelectedBtn.center.x;
    subtrace = self.isForwardSwip ? btnX - tag : tag - btnX;
    
    if (subtrace >= 0) {
        
        //calculate tab scorll content offset
        spare = self.isForwardSwip ? tabsContentWidth - (tabsOffsetX + tabsFrameWidth) : tabsOffsetX;
        
        spare = spare < 0 ? 0 : spare;
        
        CGFloat moveX = spare > subtrace ? subtrace : spare;
        
        moveX = self.isForwardSwip ? tabsOffsetX + moveX : tabsOffsetX - moveX;
        
        //animate change
        [UIView animateWithDuration:0.25f
                              delay:0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             
                             self.topTabView.contentOffset = CGPointMake(moveX, 0);
                             
                         } completion:nil];
        
    }
    
    //calculate tab title color and separtor width and color
    for (UIButton *btn in self.tabButtons) {
        
        if (btn.tag == self.currentSelectedBtn.tag) {
            btn.userInteractionEnabled = NO;
            [btn setTitleColor:self.tabHighlightColor forState:UIControlStateNormal];
            if (self.tabTitleNormalFont) {
                btn.titleLabel.font = self.tabTitleSelectedFont;
            }
        } else {
            btn.userInteractionEnabled = YES;
            [btn setTitleColor:self.tabNormalColor forState:UIControlStateNormal];
            if (self.tabTitleSelectedFont) {
                btn.titleLabel.font = self.tabTitleNormalFont;
            }
        }
        
    }
    
    if (self.isShadowTitleEqualWidth) {
        self.tabShadowLeftConstraint.constant = self.currentSelectedBtn.frame.origin.x;
        self.tabShadowWidthConstraint.constant = self.currentSelectedBtn.frame.size.width;
    } else {
        UIButton *currentSelectedBtn = self.tabButtons[page];
        CGFloat lead = CGRectGetMinX(currentSelectedBtn.frame) - CGRectGetWidth(currentSelectedBtn.frame) / 7;
        self.tabShadowLeftConstraint.constant  = lead;
        self.tabShadowWidthConstraint.constant = (CGRectGetWidth(currentSelectedBtn.frame) * 4) / 3;
    }
    
    [UIView animateWithDuration:.25 animations:^{
        [self layoutIfNeeded];
    }];
    
}

#pragma mark -- update constraint methods
- (void)updateBasicSubviewsConstraint {
    
    if ([self.delegate respondsToSelector:@selector(tabViewBackgroundColorForTSTView:)]) {
        self.topTabView.backgroundColor = [self.delegate tabViewBackgroundColorForTSTView:self];
    }
    
    if ([self.delegate respondsToSelector:@selector(heightForTabInTSTView:)]) {
        self.tabHeight = [self.delegate heightForTabInTSTView:self];
    }
    
    if ([self.delegate respondsToSelector:@selector(heightForTabSeparatorInTSTView:)]) {
        self.tabSeparatorHeight = [self.delegate heightForTabSeparatorInTSTView:self];
    }
    
    //top tab view to self
    [NSLayoutConstraint constraintWithItem:self.topTabView
                                 attribute:NSLayoutAttributeTop
                                 relatedBy:NSLayoutRelationEqual
                                 toItem:self
                                 attribute:NSLayoutAttributeTop
                                 multiplier:1
                                 constant:0
                                 toView:self];
    
    [NSLayoutConstraint constraintWithItem:self.topTabView
                                 attribute:NSLayoutAttributeLeading
                                 relatedBy:NSLayoutRelationEqual
                                 toItem:self
                                 attribute:NSLayoutAttributeLeading
                                 multiplier:1
                                 constant:0
                                 toView:self];
    
    [NSLayoutConstraint constraintWithItem:self.topTabView
                                 attribute:NSLayoutAttributeTrailing
                                 relatedBy:NSLayoutRelationEqual
                                 toItem:self
                                 attribute:NSLayoutAttributeTrailing
                                 multiplier:1
                                 constant:0
                                 toView:self];
    
    [NSLayoutConstraint constraintWithItem:self.topTabView
                                 attribute:NSLayoutAttributeHeight
                                 relatedBy:NSLayoutRelationEqual
                                 toItem:self.topTabView
                                 attribute:NSLayoutAttributeHeight
                                 multiplier:0
                                 constant:self.tabHeight
                                 toView:self.topTabView];
    
    //separator to top tab
    [NSLayoutConstraint constraintWithItem:self.tabSeparator
                                 attribute:NSLayoutAttributeTop
                                 relatedBy:NSLayoutRelationEqual
                                 toItem:self.topTabView
                                 attribute:NSLayoutAttributeBottom
                                 multiplier:1
                                 constant:0
                                 toView:self];
    
    [NSLayoutConstraint constraintWithItem:self.tabSeparator
                                 attribute:NSLayoutAttributeLeading
                                 relatedBy:NSLayoutRelationEqual
                                 toItem:self
                                 attribute:NSLayoutAttributeLeading
                                 multiplier:1
                                 constant:0
                                 toView:self];
    
    [NSLayoutConstraint constraintWithItem:self.tabSeparator
                                 attribute:NSLayoutAttributeTrailing
                                 relatedBy:NSLayoutRelationEqual
                                 toItem:self
                                 attribute:NSLayoutAttributeTrailing
                                 multiplier:1
                                 constant:0
                                 toView:self];
    
    [NSLayoutConstraint constraintWithItem:self.tabSeparator
                                 attribute:NSLayoutAttributeHeight
                                 relatedBy:NSLayoutRelationEqual
                                 toItem:self.tabSeparator
                                 attribute:NSLayoutAttributeHeight
                                 multiplier:0
                                 constant:self.tabSeparatorHeight
                                 toView:self.tabSeparator];
    
    
    //content view to top tab
    [NSLayoutConstraint constraintWithItem:self.contentView
                                 attribute:NSLayoutAttributeTop
                                 relatedBy:NSLayoutRelationEqual
                                 toItem:self.tabSeparator
                                 attribute:NSLayoutAttributeBottom
                                 multiplier:1
                                 constant:0
                                 toView:self];
    
    [NSLayoutConstraint constraintWithItem:self.contentView
                                 attribute:NSLayoutAttributeLeading
                                 relatedBy:NSLayoutRelationEqual
                                 toItem:self
                                 attribute:NSLayoutAttributeLeading
                                 multiplier:1
                                 constant:0
                                 toView:self];
    
    [NSLayoutConstraint constraintWithItem:self.contentView
                                 attribute:NSLayoutAttributeTrailing
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self
                                 attribute:NSLayoutAttributeTrailing
                                multiplier:1
                                  constant:0
                                    toView:self];
    
    [NSLayoutConstraint constraintWithItem:self.contentView
                                 attribute:NSLayoutAttributeBottom
                                 relatedBy:NSLayoutRelationEqual
                                 toItem:self
                                 attribute:NSLayoutAttributeBottom
                                 multiplier:1
                                 constant:0
                                 toView:self];
}

- (void)addConstraintToTabButtons
{
    UIButton *firstButton = [self.tabButtons firstObject];
    UIButton *lastButton = [self.tabButtons lastObject];
    
    [NSLayoutConstraint constraintWithItem:self.topTabView
                                 attribute:NSLayoutAttributeTrailing
                                 relatedBy:NSLayoutRelationEqual
                                 toItem:lastButton
                                 attribute:NSLayoutAttributeTrailing
                                 multiplier:1.0f
                                 constant:self.isAutoAverageSort ? self.tabSpace : self.leading * 2
                                 toView:self.topTabView];
    
    [NSLayoutConstraint constraintWithItem:firstButton
                                 attribute:NSLayoutAttributeLeading
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.topTabView
                                 attribute:NSLayoutAttributeLeading
                                multiplier:1.0f
                                  constant:self.isAutoAverageSort ? self.tabSpace: self.leading * 2
                                    toView:self.topTabView];
    
    [NSLayoutConstraint constraintWithItem:lastButton
                                 attribute:NSLayoutAttributeHeight
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.topTabView
                                 attribute:NSLayoutAttributeHeight
                                multiplier:1.0f
                                  constant:0.f
                                    toView:self.topTabView];
    
    [NSLayoutConstraint constraintWithItem:lastButton
                                 attribute:NSLayoutAttributeCenterY
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.topTabView
                                 attribute:NSLayoutAttributeCenterY
                                multiplier:1.0f
                                  constant:0.f
                                    toView:self.topTabView];
    if (self.autoAverageSort) {
        [firstButton layoutIfNeeded];
        self.tabSpace = (CGRectGetWidth(self.frame) - CGRectGetWidth(firstButton.frame) * self.tabsCount) / self.tabsCount;
        [firstButton layoutIfNeeded];
    }
    
    for (NSInteger i = [self.tabButtons count] - 1; i > 0; --i) {
        
        [NSLayoutConstraint constraintWithItem:self.tabButtons[i]
                                     attribute:NSLayoutAttributeHeight
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.tabButtons[i - 1]
                                     attribute:NSLayoutAttributeHeight
                                    multiplier:1.0f
                                      constant:0.f
                                        toView:self.topTabView];
        
        [NSLayoutConstraint constraintWithItem:self.tabButtons[i]
                                     attribute:NSLayoutAttributeBaseline
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.tabButtons[i - 1]
                                     attribute:NSLayoutAttributeBaseline
                                    multiplier:1.0f
                                      constant:0.f
                                        toView:self.topTabView];
        
        [NSLayoutConstraint constraintWithItem:self.tabButtons[i]
                                     attribute:NSLayoutAttributeLeading
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.tabButtons[i - 1]
                                     attribute:NSLayoutAttributeTrailing
                                    multiplier:1.0f
                                      constant:self.tabSpace
                                        toView:self.topTabView];
    }
}

- (void)addConstraintToTabShadowWihtAnchor:(UIView *)anchor {
    
    self.tabShadowLeftConstraint =
    [NSLayoutConstraint constraintWithItem:self.tabShadowView
                                 attribute:NSLayoutAttributeLeading
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.topTabView
                                 attribute:NSLayoutAttributeLeading
                                multiplier:1.0f
                                  constant:self.leading
                                    toView:self.topTabView];
    
    [NSLayoutConstraint constraintWithItem:self.tabShadowView
                                 attribute:NSLayoutAttributeBottom
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:anchor
                                 attribute:NSLayoutAttributeBottom
                                multiplier:1.0f
                                  constant:0
                                    toView:self.topTabView];
    
    self.tabShadowHeightConstraint =
    [NSLayoutConstraint constraintWithItem:self.tabShadowView
                                 attribute:NSLayoutAttributeHeight
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:anchor
                                 attribute:NSLayoutAttributeHeight
                                multiplier:0.0f
                                  constant:self.tabShadowHeight
                                    toView:self.topTabView];
    
    self.tabShadowWidthConstraint =
    [NSLayoutConstraint constraintWithItem:self.tabShadowView
                                 attribute:NSLayoutAttributeWidth
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:anchor
                                 attribute:NSLayoutAttributeWidth
                                multiplier:0.f
                                  constant:0
                                    toView:self.topTabView];
}

#pragma mark -- button aciton
- (void)selectTab:(UIButton *)selectedBtn {
    
    if (!selectedBtn) {
        return;
    }
    
    NSInteger currentIndex = selectedBtn.tag;
    self.currentSelectedBtn = selectedBtn;
    
    [self autoScrollTopTabBySwipDirctionToPage:currentIndex];
    
    [self loadContentViewByIndex:currentIndex];
    
    self.contentView.contentOffset = CGPointMake(self.contentView.frame.size.width * currentIndex, 0);

}


- (UIScrollView *)topTabViewInTSTView
{
    return self.topTabView;
}

- (void)showFraternalViewAtIndex:(NSInteger)page
{
    [self loadContentViewByIndex:page];
}

- (NSArray *)tabContentSubViews
{
    return self.contentView.subviews;
}

@end
