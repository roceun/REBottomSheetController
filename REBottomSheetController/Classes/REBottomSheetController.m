//
//  REBottomSheetController.m
//  REBottomSheetController
//
//  Created by ROCEUN on 2020/03/22.
//

#import "REBottomSheetController.h"

@interface REBottomSheetController ()

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *topContentView;
@property (nonatomic, strong) UIScrollView *bottomScrollView;
@property (nonatomic, strong) UIButton *dimmedView;

@property (nonatomic, assign) CGFloat screenHeight;
@property (nonatomic, assign) CGFloat safeAreaBottom;

@property (nonatomic, assign) BOOL shouldDragView;
@property (nonatomic, assign) BOOL showsVerticalScrollIndicator;

@property (nonatomic, strong) NSLayoutConstraint *topConstraint;
@property (nonatomic, strong) NSLayoutConstraint *heightConstraint;

@property (nonatomic, strong) NSLayoutConstraint *bottomScrollViewConstraint;

@property (nonatomic, assign) CGFloat topContentViewHeight;

@end


// MARK: -

@implementation REBottomSheetController

- (instancetype)init {
	if (self = [super init]) {
		[self initialize];
	}
	return self;
}

- (void)initialize
{
	self.screenHeight = [UIScreen mainScreen].bounds.size.height;
	self.safeAreaBottom = 0;
	if (@available(iOS 11.0, *)) {
		UIWindow *window = UIApplication.sharedApplication.keyWindow;
		self.safeAreaBottom = window.safeAreaInsets.bottom;
	}
	
	self.topCornerRadius = 12;
	
	self.topCornerShadowColor = nil;
	self.topCornerShadowOpacity = 0;
	
	self.minHeight = 0;
	self.maxHeight = [UIScreen mainScreen].bounds.size.height / 2;
	
	self.bounceAnimationHeight = 10;
	self.animationDuration = 0.3f;
	
	self.dimmedColor = nil;
	self.dimmedAlphaForMinHeight = 0;
	self.dimmedAlphaForMaxHeight = 1;
	
	self.shouldPanGesture = YES;
	self.shouldAutoMoveAfterGestureEnded = YES;
}

- (void)dealloc
{
	for (UIView *view in _contentView.subviews) {
		[view removeFromSuperview];
	}
	
	[_contentView removeFromSuperview];
	[_dimmedView removeFromSuperview];
	
	self.contentView = nil;
	self.topContentView = nil;
	self.bottomScrollView = nil;
	self.dimmedView = nil;
	
	self.topCornerShadowColor = nil;
	self.dimmedColor = nil;
	
	self.topConstraint = nil;
	self.heightConstraint = nil;
	
	self.bottomScrollViewConstraint = nil;
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
		[self animateViewWithHeight:_minHeight];
	}
	else {
		[self animateViewWithHeight:_maxHeight];
	}
	
	UIGestureRecognizer * const recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizer:)];
	[self.view addGestureRecognizer:recognizer];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
	[super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
	
	self.screenHeight = size.height;
	[self setContentViewFrameWithOffsetY:_screenHeight - size.width + _topConstraint.constant];
	[coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
		[self.view setNeedsLayout];
	} completion:^(id<UIViewControllerTransitionCoordinatorContext> _Nonnull context){
	}];
}

- (void)viewWillLayoutSubviews
{
	[self roundRectWithView:_contentView];
	[self shadowRectWithView:self.view];
}

- (void)initConstraints
{
	self.view.translatesAutoresizingMaskIntoConstraints = NO;
	
	self.topConstraint = [self.view.topAnchor constraintEqualToAnchor:self.view.superview.topAnchor constant:_screenHeight];
	self.heightConstraint = [self.view.heightAnchor constraintEqualToConstant:_maxHeight + _bounceAnimationHeight];
	
	[NSLayoutConstraint activateConstraints:@[
		_topConstraint,
		_heightConstraint,
		[self.view.leftAnchor constraintEqualToAnchor:self.view.superview.leftAnchor],
		[self.view.rightAnchor constraintEqualToAnchor:self.view.superview.rightAnchor]
	]];
}

- (void)initSubviews
{
	NSMutableArray * const constraints = [NSMutableArray new];
	
	UIView * const contentView = [UIView new];
	[self.view addSubview:contentView];
	self.contentView = contentView;
	
	contentView.translatesAutoresizingMaskIntoConstraints = NO;
	[constraints addObjectsFromArray:@[
		[contentView.topAnchor constraintEqualToAnchor:contentView.superview.topAnchor],
		[contentView.leftAnchor constraintEqualToAnchor:contentView.superview.leftAnchor],
		[contentView.bottomAnchor constraintEqualToAnchor:contentView.superview.bottomAnchor],
		[contentView.rightAnchor constraintEqualToAnchor:contentView.superview.rightAnchor],
	]];
	
	UIView * const backColorView = [UIView new];
	[contentView addSubview:backColorView];
	
	self.topContentViewHeight = 0;
	UIView *topContentView = nil;
	if ([_delegate respondsToSelector:@selector(REBottomSheetControllerGetTopContentView:)] &&
		[_delegate respondsToSelector:@selector(REBottomSheetViewControllerGetTopContentViewHeight:)]) {
		topContentView = [_delegate REBottomSheetControllerGetTopContentView:self];
		self.topContentViewHeight = MAX(0, [_delegate REBottomSheetViewControllerGetTopContentViewHeight:self]);
	}
	else {
		NSLog(@"Required methods! REBottomSheetControllerGetTopContentView, REBottomSheetViewControllerGetTopContentViewHeight");
		return;
	}
	[contentView addSubview:topContentView];
	self.topContentView = topContentView;
	
	topContentView.translatesAutoresizingMaskIntoConstraints = NO;
	[constraints addObjectsFromArray:@[
		[topContentView.topAnchor constraintEqualToAnchor:topContentView.superview.topAnchor],
		[topContentView.leftAnchor constraintEqualToAnchor:topContentView.superview.leftAnchor],
		[topContentView.rightAnchor constraintEqualToAnchor:topContentView.superview.rightAnchor],
		[topContentView.heightAnchor constraintEqualToConstant:_topContentViewHeight]
	]];
	
	
	// bottomScrollView
	UIScrollView *bottomScrollView = nil;
	if ([_delegate respondsToSelector:@selector(REBottomSheetControllerGetBottomScrollView:)]) {
		bottomScrollView = [_delegate REBottomSheetControllerGetBottomScrollView:self];
	}
	
	if (bottomScrollView) {
		bottomScrollView.contentInset = UIEdgeInsetsMake(0, 0, _safeAreaBottom, 0);
		[contentView addSubview:bottomScrollView];
		self.bottomScrollView = bottomScrollView;
		
		bottomScrollView.translatesAutoresizingMaskIntoConstraints = NO;
		
		self.bottomScrollViewConstraint = [bottomScrollView.heightAnchor constraintEqualToConstant:(_minHeight > 0 ? _minHeight : _maxHeight) - _topContentViewHeight];
		[constraints addObjectsFromArray:@[
			[bottomScrollView.topAnchor constraintEqualToAnchor:topContentView.bottomAnchor],
			[bottomScrollView.leftAnchor constraintEqualToAnchor:bottomScrollView.superview.leftAnchor],
			[bottomScrollView.rightAnchor constraintEqualToAnchor:bottomScrollView.superview.rightAnchor],
			_bottomScrollViewConstraint
		]];
		
		self.showsVerticalScrollIndicator = bottomScrollView.showsVerticalScrollIndicator;
		[bottomScrollView.panGestureRecognizer addTarget:self action:@selector(panGestureRecognizerForScrollView:)];
	}
	
	backColorView.backgroundColor = (bottomScrollView ?: topContentView).backgroundColor;
	backColorView.translatesAutoresizingMaskIntoConstraints = NO;
	[constraints addObjectsFromArray:@[
		[backColorView.topAnchor constraintEqualToAnchor:(bottomScrollView ?: topContentView).bottomAnchor constant:-1],
		[backColorView.leftAnchor constraintEqualToAnchor:backColorView.superview.leftAnchor],
		[backColorView.rightAnchor constraintEqualToAnchor:backColorView.superview.rightAnchor],
		[backColorView.bottomAnchor constraintEqualToAnchor:backColorView.superview.bottomAnchor]
	]];
	
	[NSLayoutConstraint activateConstraints:constraints];
	
	[topContentView layoutIfNeeded];
	[contentView layoutIfNeeded];
}

- (UIBezierPath *)besizerPathWithView:(UIView *)view
{
	return [UIBezierPath bezierPathWithRoundedRect:view.bounds
								 byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight)
									   cornerRadii:CGSizeMake(_topCornerRadius, _topCornerRadius)];;
}

- (void)roundRectWithView:(UIView *)view
{
	CAShapeLayer * const mask = [CAShapeLayer new];
	mask.path = [self besizerPathWithView:view].CGPath;
	view.layer.mask = mask;
}

- (void)shadowRectWithView:(UIView *)view
{
	view.layer.masksToBounds = NO;
	view.layer.shadowPath = [self besizerPathWithView:view].CGPath;
	view.layer.shadowColor = _topCornerShadowColor.CGColor;
	view.layer.shadowOpacity = _topCornerShadowOpacity;
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
	_heightConstraint.constant = _maxHeight + _bounceAnimationHeight;
	
	_bottomScrollViewConstraint.constant = MAX(_screenHeight - offsetY, (_minHeight > 0 ? _minHeight : _maxHeight)) - _topContentViewHeight;
	
	[self.view updateConstraintsIfNeeded];
	[self.view setNeedsLayout];
}

- (void)notifyDragViewBegin
{
	if ([_delegate respondsToSelector:@selector(REBottomSheetController:dragViewBeginOffsetY:)]) {
		[_delegate REBottomSheetController:self dragViewBeginOffsetY:_topConstraint.constant];
	}
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

- (void)animateViewWithHeight:(CGFloat)height
{
	const CGFloat offsetY = _screenHeight - height;
	if (_topConstraint.constant == offsetY) {
		return;
	}
	
	if (height == _minHeight) {
		_bottomScrollView.contentOffset = CGPointZero;
	}
	
	const BOOL shouldAnimation = _animationDuration > 0;
	
	CGFloat bounceOffsetY = offsetY;
	if (shouldAnimation && _bounceAnimationHeight > 0 &&
		_topConstraint.constant >= _screenHeight - _maxHeight &&
		_topConstraint.constant <= _screenHeight - _minHeight) {
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
		[strongSelf.view.superview layoutIfNeeded];
	};
	
	void (^completion)(BOOL) = ^(BOOL finished) {
		__strong __typeof(self) strongSelf = weakSelf;
		if (!strongSelf) {
			return;
		}
		
		if (shouldAnimation && bounceOffsetY != offsetY) {
			[strongSelf animateViewWithHeight:strongSelf.screenHeight - offsetY];
		}
		else {
			if (bounceOffsetY == strongSelf.screenHeight - strongSelf.minHeight) {
				[strongSelf didChangedMinHeight];
			}
			else if (bounceOffsetY == strongSelf.screenHeight - strongSelf.maxHeight) {
				[strongSelf didChangedMaxHeight];
			}
		}
	};
	
	[self.view.superview layoutIfNeeded];
	if (shouldAnimation) {
		[UIView animateWithDuration:_animationDuration
						 animations:animations
						 completion:completion];
	}
	else {
		animations();
		completion(YES);
	}
}

- (void)gestureRecognizerStateEnded:(BOOL)isScrollDown withOffsetY:(CGFloat)offsetY
{
	if (_shouldAutoMoveAfterGestureEnded) {
		[self animateViewWithHeight:(isScrollDown ? _minHeight : _maxHeight)];
	}
	else {
		if (isScrollDown) {
			if (offsetY > _screenHeight - _minHeight) {
				[self animateViewWithHeight:_minHeight];
			}
		} else {
			if (offsetY < _screenHeight - _maxHeight) {
				[self animateViewWithHeight:_maxHeight];
			}
		}
	}
}

// MARK: - panGesture

- (void)panGestureRecognizer:(UIPanGestureRecognizer *)recognizer
{
	if (!_shouldPanGesture) {
		return;
	}
	
	CGFloat offsetY = _topConstraint.constant + [recognizer translationInView:self.view].y;
	offsetY = MAX(offsetY, _screenHeight - _maxHeight - _bounceAnimationHeight);
	
	const BOOL isScrollDown = [recognizer velocityInView:self.view].y > 0;
	switch (recognizer.state) {
		case UIGestureRecognizerStateBegan:
			[self notifyDragViewBegin];
			break;
			
		case UIGestureRecognizerStateChanged:
			[self setContentViewFrameWithOffsetY:offsetY];
			[recognizer setTranslation:CGPointZero inView:self.view];
			break;
			
		case UIGestureRecognizerStateEnded:
			[self gestureRecognizerStateEnded:isScrollDown withOffsetY:offsetY];
			break;
			
		default:
			break;
	}
}

- (void)panGestureRecognizerForScrollView:(UIPanGestureRecognizer *)recognizer
{
	if (!_shouldPanGesture) {
		return;
	}
	
	const BOOL isMaxHeight = _topConstraint.constant <= _screenHeight - _maxHeight;
	const BOOL isScrollDown = [recognizer velocityInView:self.view].y > 0;
	
	const BOOL shouldDragViewDown = isScrollDown && _bottomScrollView.contentOffset.y <= 0;
	const BOOL shouldDragViewUp = !isScrollDown && !isMaxHeight;
	
	CGFloat offsetY = _topConstraint.constant + [recognizer translationInView:self.view].y;
	offsetY = MAX(offsetY, _screenHeight - _maxHeight - _bounceAnimationHeight);
	
	switch (recognizer.state) {
		case UIGestureRecognizerStateBegan:
			self.shouldDragView = NO;
			_bottomScrollView.showsVerticalScrollIndicator = _showsVerticalScrollIndicator;
			break;
			
		case UIGestureRecognizerStateChanged:
		{
			if (!_shouldDragView && (shouldDragViewDown || shouldDragViewUp)) {
				[self notifyDragViewBegin];
				self.shouldDragView = YES;
				
				self.showsVerticalScrollIndicator = _bottomScrollView.showsVerticalScrollIndicator;
				_bottomScrollView.showsVerticalScrollIndicator = NO;
			}
			if (_shouldDragView) {
				[self setContentViewFrameWithOffsetY:offsetY];
				[recognizer setTranslation:CGPointZero inView:self.view];
			}
			break;
		}
		case UIGestureRecognizerStateEnded:
			if (_shouldDragView) {
				[self gestureRecognizerStateEnded:isScrollDown withOffsetY:offsetY];
			}
			break;
			
		default:
			break;
	}
}

// MARK: - Properties

- (void)setMinHeight:(CGFloat)minHeight
{
	if (0 <= minHeight) {
		_minHeight = minHeight;
		
		if (_maxHeight < _minHeight) {
			self.maxHeight = _minHeight;
		}
	}
}

- (void)setMaxHeight:(CGFloat)maxHeight
{
	if (_minHeight <= maxHeight) {
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
	[self animateViewWithHeight:_minHeight];
}

- (void)moveToMaxHeight
{
	[self animateViewWithHeight:_maxHeight];
}

// MARK: - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if (![_bottomScrollView isEqual:scrollView]) {
		return;
	}
	
	if (_shouldDragView ||
		_topConstraint.constant == _screenHeight - _minHeight) {
		scrollView.contentOffset = CGPointZero;
	}
}

@end
