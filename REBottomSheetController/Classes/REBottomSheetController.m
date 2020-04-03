//
//  REBottomSheetController.m
//  REBottomSheetController
//
//  Created by ROCEUN on 2020/03/22.
//

#import "REBottomSheetController.h"

@interface REBottomSheetController ()

@property (nonatomic, strong) UIView *topContentView;
@property (nonatomic, strong) UIScrollView *bottomScrollView;
@property (nonatomic, strong) UIButton *dimmedView;

@property (nonatomic, assign) CGFloat screenHeight;
@property (nonatomic, assign) CGFloat safeAreaBottom;

@property (nonatomic, assign) BOOL shouldDragView;

@property (nonatomic, strong) NSLayoutConstraint *topConstraint;
@property (nonatomic, strong) NSLayoutConstraint *heightConstraint;

@property (nonatomic, assign) CGFloat topContentViewHeight;

@end

@implementation REBottomSheetController

- (instancetype)init {
    if (self = [super init]) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    self.topCornerRadius = 12;
    
    self.minHeight = 0;
    self.maxHeight = [UIScreen mainScreen].bounds.size.height;
    
    self.bounceAnimationHeight = 20;
    self.animationDuration = 0.2f;
    
    self.dimmedColor = nil;
    self.dimmedAlphaForMinHeight = 0;
    self.dimmedAlphaForMaxHeight = 1;
    
    self.shoudPanGesture = YES;
    
    self.screenHeight = [UIScreen mainScreen].bounds.size.height;
    self.safeAreaBottom = 0;
    if (@available(iOS 11.0, *)) {
        UIWindow *window = UIApplication.sharedApplication.keyWindow;
        self.safeAreaBottom = window.safeAreaInsets.bottom;
    }
}

- (void)dealloc
{
    for (UIView *view in self.view.subviews) {
        [view removeFromSuperview];
    }
    
    [_dimmedView removeFromSuperview];
    
    self.topContentView = nil;
    self.bottomScrollView = nil;
    self.dimmedView = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self initDimmedView];
    
	[self initConstraints];
	[self initSubviews];
	
	[self setContentViewFrameWithOffsetY:_screenHeight];
    if (_minHeight > 0) {
        [self animateView:_screenHeight - _minHeight];
    }
    else {
        [self animateView:_screenHeight - _maxHeight];
    }
	
	UIGestureRecognizer * const recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizer:)];
    [self.view addGestureRecognizer:recognizer];
}

- (void)viewWillLayoutSubviews
{
    [self roundRectWithView:_topContentView];
}

- (void)initConstraints
{
	self.view.translatesAutoresizingMaskIntoConstraints = NO;
	
	self.topConstraint = [self.view.topAnchor constraintEqualToAnchor:self.view.superview.topAnchor];
	_topConstraint.active = YES;
	
	self.heightConstraint = [self.view.heightAnchor constraintEqualToConstant:(_minHeight > 0 ? _minHeight : _maxHeight)];
	_heightConstraint.active = YES;
	
	[NSLayoutConstraint activateConstraints:@[
		[self.view.leftAnchor constraintEqualToAnchor:self.view.superview.leftAnchor],
		[self.view.rightAnchor constraintEqualToAnchor:self.view.superview.rightAnchor]
	]];
}

- (void)initSubviews
{
    NSMutableArray * const constraints = [NSMutableArray new];
    
    self.topContentViewHeight = 0;
    UIView *topContentView = nil;
    if ([_delegate respondsToSelector:@selector(REBottomSheetControllerGetTopContentView:)] &&
        [_delegate respondsToSelector:@selector(REBottonSheetViewControllerGetTopContentViewHeight:)]) {
        topContentView = [_delegate REBottomSheetControllerGetTopContentView:self];
        self.topContentViewHeight = MAX(0, [_delegate REBottonSheetViewControllerGetTopContentViewHeight:self]);
    }
    [self.view addSubview:topContentView];
    self.topContentView = topContentView;
    
    topContentView.translatesAutoresizingMaskIntoConstraints = NO;
    [constraints addObjectsFromArray:@[
        [topContentView.topAnchor constraintEqualToAnchor:topContentView.superview.topAnchor],
        [topContentView.leftAnchor constraintEqualToAnchor:topContentView.superview.leftAnchor],
        [topContentView.rightAnchor constraintEqualToAnchor:topContentView.superview.rightAnchor],
        [topContentView.heightAnchor constraintEqualToConstant:_topContentViewHeight]
    ]];
    
    UIScrollView *bottomScrollView = nil;
    if ([_delegate respondsToSelector:@selector(REBottomSheetControllerGetBottomScrollView:)]) {
        bottomScrollView = [_delegate REBottomSheetControllerGetBottomScrollView:self];
    }
    
    if (bottomScrollView) {
        bottomScrollView.scrollEnabled = NO;
        bottomScrollView.contentInset = UIEdgeInsetsMake(0, 0, _bounceAnimationHeight + _safeAreaBottom, 0);
        [self.view addSubview:bottomScrollView];
        self.bottomScrollView = bottomScrollView;
        
        bottomScrollView.translatesAutoresizingMaskIntoConstraints = NO;
        [constraints addObjectsFromArray:@[
            [bottomScrollView.topAnchor constraintEqualToAnchor:topContentView.bottomAnchor],
            [bottomScrollView.leftAnchor constraintEqualToAnchor:bottomScrollView.superview.leftAnchor],
            [bottomScrollView.rightAnchor constraintEqualToAnchor:bottomScrollView.superview.rightAnchor],
            [bottomScrollView.bottomAnchor constraintEqualToAnchor:bottomScrollView.superview.bottomAnchor]
        ]];
        
        [bottomScrollView.panGestureRecognizer addTarget:self action:@selector(panGestureRecognizerForScrollView:)];
    }
    
    [NSLayoutConstraint activateConstraints:constraints];
	
	[self.view layoutIfNeeded];
}

- (void)roundRectWithView:(UIView *)view
{
    UIBezierPath * const path = [UIBezierPath bezierPathWithRoundedRect:view.bounds
                                                      byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight)
                                                            cornerRadii:CGSizeMake(_topCornerRadius, _topCornerRadius)];
    CAShapeLayer * const mask = [CAShapeLayer new];
    mask.path = path.CGPath;
    view.layer.mask = mask;
}

- (void)initDimmedView
{
    if (_dimmedView || !_dimmedColor) {
        return;
    }
    
    UIButton * const dimmedView = [UIButton buttonWithType:UIButtonTypeCustom];
    dimmedView.backgroundColor = [_dimmedColor colorWithAlphaComponent:_dimmedAlphaForMinHeight];
    [dimmedView addTarget:self action:@selector(touchedDimmedView:) forControlEvents:UIControlEventTouchUpInside];
    [self.view.superview insertSubview:dimmedView belowSubview:self.view];
    self.dimmedView = dimmedView;
    
    dimmedView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [dimmedView.topAnchor constraintEqualToAnchor:dimmedView.superview.topAnchor],
        [dimmedView.leftAnchor constraintEqualToAnchor:dimmedView.superview.leftAnchor],
        [dimmedView.bottomAnchor constraintEqualToAnchor:dimmedView.superview.bottomAnchor],
        [dimmedView.rightAnchor constraintEqualToAnchor:dimmedView.superview.rightAnchor]
    ]];
}

- (void)setDimmedViewColorWithOffsetY:(CGFloat)offsetY
{
    if (!_dimmedView || !_dimmedColor) {
        return;
    }
    
    CGFloat currentHeight = _screenHeight - offsetY;
    currentHeight = MAX(currentHeight, _minHeight);
    currentHeight = MIN(currentHeight, _maxHeight);
    
    const CGFloat percent = (currentHeight - _minHeight) / (_maxHeight - _minHeight);
    CGFloat currentAlpha = _dimmedAlphaForMaxHeight - _dimmedAlphaForMinHeight;
    currentAlpha *= percent;
    currentAlpha += _dimmedAlphaForMinHeight;
    
    _dimmedView.backgroundColor = [_dimmedColor colorWithAlphaComponent:currentAlpha];
}

- (void)setContentViewFrameWithOffsetY:(CGFloat)offsetY
{
    [self setDimmedViewColorWithOffsetY:offsetY];
    
	_topConstraint.constant = offsetY;
	_heightConstraint.constant = MAX(MAX(_screenHeight - offsetY, _minHeight), _topContentViewHeight);
}

- (void)didChangedMinHeight
{
    if ([_delegate respondsToSelector:@selector(REBottomSheetController:didChangedMinHeightOffsetY:)]) {
        [_delegate REBottomSheetController:self didChangedMinHeightOffsetY:_topConstraint.constant];
    }
}

- (void)didChangedMaxHeight
{
    if ([_delegate respondsToSelector:@selector(REBottomSheetController:didChangedMaxHeightOffsetY:)]) {
        [_delegate REBottomSheetController:self didChangedMaxHeightOffsetY:_topConstraint.constant];
    }
}

- (void)animateView:(CGFloat)offsetY
{
    if (_topConstraint.constant == offsetY) {
        return;
    }
    
    _bottomScrollView.scrollEnabled = (offsetY == _screenHeight - _maxHeight);
    const BOOL shouldAnimation = _animationDuration > 0;
    
    CGFloat bounceOffsetY = offsetY;
    if (shouldAnimation &&
        _topConstraint.constant > _screenHeight - _maxHeight &&
        _topConstraint.constant < _screenHeight - _minHeight) {
        if (_topConstraint.constant < offsetY) { // scroll down
            bounceOffsetY += _bounceAnimationHeight;
        }
        else {
            bounceOffsetY -= _bounceAnimationHeight;
        }
    }
    
    __weak __typeof(self) weakSelf = self;
    void (^animations)(void) = ^{
        __strong __typeof(self) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        
        [strongSelf setContentViewFrameWithOffsetY:bounceOffsetY];
    };
    
    void (^completion)(BOOL) = ^(BOOL finished) {
        __strong __typeof(self) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        
        if (bounceOffsetY == strongSelf.screenHeight - strongSelf.minHeight) {
            [strongSelf didChangedMinHeight];
        }
        else if (bounceOffsetY == strongSelf.screenHeight - strongSelf.maxHeight) {
            [strongSelf didChangedMaxHeight];
        }
        
        if (shouldAnimation && bounceOffsetY != offsetY) {
            [strongSelf animateView:offsetY];
		}
		
		if (!strongSelf.bottomScrollView.scrollEnabled) {
			strongSelf.bottomScrollView.contentOffset = CGPointZero;
		}
	};
    
    if (shouldAnimation) {
        [UIView animateWithDuration:_animationDuration
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:animations
                         completion:completion];
    }
    else {
        animations();
        completion(YES);
    }
}

// MARK: - panGesture

- (void)panGestureRecognizer:(UIPanGestureRecognizer *)recognizer
{
    if (!_shoudPanGesture) {
        return;
    }
    
    const BOOL isScrollDown = [recognizer velocityInView:self.view].y > 0;
    CGFloat offsetY = _topConstraint.constant + [recognizer translationInView:self.view].y;
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateChanged:
            offsetY = MAX(offsetY, _screenHeight - _maxHeight - _bounceAnimationHeight);
            
            [self setContentViewFrameWithOffsetY:offsetY];
            [recognizer setTranslation:CGPointZero inView:self.view];
            break;
            
        case UIGestureRecognizerStateEnded:
            if (isScrollDown) {
                offsetY = _screenHeight - _minHeight;
            } else {
                offsetY = _screenHeight - _maxHeight;
            }
            
            [self animateView:offsetY];
            break;
            
        default:
            break;
    }
}

- (void)panGestureRecognizerForScrollView:(UIPanGestureRecognizer *)recognizer
{
    if (!_shoudPanGesture) {
        return;
    }
    
    const BOOL isMaxHeight = _topConstraint.constant <= _screenHeight - _maxHeight;
    const BOOL isScrollDown = [recognizer velocityInView:self.view].y > 0;
    
    const BOOL shouldDragViewDown = isScrollDown && _bottomScrollView.contentOffset.y <= 0;
    const BOOL shouldDragViewUp = !isScrollDown && !isMaxHeight;
    
    CGFloat offsetY = _topConstraint.constant + [recognizer translationInView:self.view].y;
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            self.shouldDragView = shouldDragViewDown || shouldDragViewUp;
            
            if (_shouldDragView) {
                [_bottomScrollView setContentOffset:CGPointZero animated:NO];
            }
            _bottomScrollView.bounces = !_shouldDragView;
            
            break;
            
        case UIGestureRecognizerStateChanged:
            if (_shouldDragView) {
                offsetY = MAX(offsetY, _screenHeight - _maxHeight - _bounceAnimationHeight);
                
                [self setContentViewFrameWithOffsetY:offsetY];
                [recognizer setTranslation:CGPointZero inView:self.view];
            }
            break;
            
        case UIGestureRecognizerStateEnded:
            if (_shouldDragView) {
                if (isScrollDown) {
                    offsetY = _screenHeight - _minHeight;
                } else {
                    _bottomScrollView.bounces = YES;
                    offsetY = _screenHeight - _maxHeight;
                }
                
                [self animateView:offsetY];
            }
            break;
            
        default:
            break;
    }
}

// MARK: - Properties

- (void)setMinHeight:(CGFloat)minHeight
{
    if (0 < minHeight && minHeight < _maxHeight) {
        _minHeight = minHeight;
    }
}

- (void)setMaxHeight:(CGFloat)maxHeight
{
    if (_minHeight < maxHeight) {
        _maxHeight = maxHeight;
    }
}

- (void)setBounceAnimationHeight:(CGFloat)bounceAnimationHeight
{
    _bounceAnimationHeight = MAX(0, bounceAnimationHeight);
}

- (void)setAnimationDuration:(CGFloat)animationDuration
{
	_animationDuration = MAX(0, animationDuration);
}

- (void)setDimmedAlphaForMinHeight:(CGFloat)dimmedAlphaForMinHeight
{
    if (0 <= dimmedAlphaForMinHeight && dimmedAlphaForMinHeight <= _dimmedAlphaForMaxHeight) {
        _dimmedAlphaForMinHeight = dimmedAlphaForMinHeight;
    }
}

- (void)setDimmedAlphaForMaxHeight:(CGFloat)dimmedAlphaForMaxHeight
{
    if (_dimmedAlphaForMinHeight <= dimmedAlphaForMaxHeight && dimmedAlphaForMaxHeight <= 1) {
        _dimmedAlphaForMaxHeight = dimmedAlphaForMaxHeight;
    }
}

// MARK: - Actions

- (void)touchedDimmedView:(UIButton *)button
{
    if ([_delegate respondsToSelector:@selector(REBottomSheetControllerDidTouchDimmedView:)]) {
        [_delegate REBottomSheetControllerDidTouchDimmedView:self];
    }
}

// MARK: - Public Methods

- (void)moveToMinHeight
{
    [self animateView:_minHeight];
}

- (void)moveToMaxHeight
{
    [self animateView:_maxHeight];
}

@end

