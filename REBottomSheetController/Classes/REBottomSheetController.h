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

@property (nonatomic, assign) CGFloat topCornerRadius; // default value is 12
@property (nonatomic, strong, nullable) UIColor *topCornerShadowColor; // default value is nil
@property (nonatomic, assign) CGFloat topCornerShadowOpacity; // default value is 0

@property (nonatomic, assign) CGFloat minHeight; // default value is 0
@property (nonatomic, assign) CGFloat maxHeight; // default value is half of screen

@property (nonatomic, assign) CGFloat bounceAnimationHeight; // default value is 20
@property (nonatomic, assign) CGFloat animationDuration; // default value is 0.3

@property (nonatomic, strong, nullable) UIColor *dimmedColor; // default value is nil
@property (nonatomic, assign) CGFloat dimmedAlphaForMinHeight; // default value is 0
@property (nonatomic, assign) CGFloat dimmedAlphaForMaxHeight; // default value is 1

@property (nonatomic, assign) BOOL shoudPanGesture; // default value is YES

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

