//
//  REBottomSheetController.h
//  REBottomSheetController
//
//  Created by ROCEUN on 2020/03/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol REBottomSheetDelegate;

@interface REBottomSheetController : UIViewController

@property (nonatomic, weak, nullable) id<REBottomSheetDelegate> delegate;

@property (nonatomic, assign) CGFloat topCornerRadius;

@property (nonatomic, assign) CGFloat minHeight;
@property (nonatomic, assign) CGFloat maxHeight;

@property (nonatomic, assign) CGFloat bounceAnimationHeight;
@property (nonatomic, assign) CGFloat animationDuration;

@property (nonatomic, strong, nullable) UIColor *dimmedColor;
@property (nonatomic, assign) CGFloat dimmedAlphaForMinHeight;
@property (nonatomic, assign) CGFloat dimmedAlphaForMaxHeight;

@property (nonatomic, assign) BOOL shoudPanGesture;

- (void)moveToMinHeight;
- (void)moveToMaxHeight;

@end


// MARK: -

@protocol REBottomSheetDelegate <NSObject>

@required

- (UIView *)REBottomSheetControllerGetTopContentView:(REBottomSheetController *)viewController;
- (CGFloat)REBottonSheetViewControllerGetTopContentViewHeight:(REBottomSheetController *)viewController;

@optional

- (UIScrollView *)REBottomSheetControllerGetBottomScrollView:(REBottomSheetController *)viewController;

- (void)REBottomSheetController:(REBottomSheetController *)viewController didChangedMinHeightOffsetY:(CGFloat)height;
- (void)REBottomSheetController:(REBottomSheetController *)viewController didChangedMaxHeightOffsetY:(CGFloat)height;

- (void)REBottomSheetControllerDidTouchDimmedView:(REBottomSheetController *)viewController;

@end

NS_ASSUME_NONNULL_END

