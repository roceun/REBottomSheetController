# REBottomSheetController

[![CI Status](https://img.shields.io/travis/roceun/REBottomSheetController.svg?style=flat)](https://travis-ci.org/roceun/REBottomSheetController)
[![Version](https://img.shields.io/cocoapods/v/REBottomSheetController.svg?style=flat)](https://cocoapods.org/pods/REBottomSheetController)
[![License](https://img.shields.io/cocoapods/l/REBottomSheetController.svg?style=flat)](https://cocoapods.org/pods/REBottomSheetController)
[![Platform](https://img.shields.io/cocoapods/p/REBottomSheetController.svg?style=flat)](https://cocoapods.org/pods/REBottomSheetController)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

하단에서 올라오는 bottom sheet 기능을 구현한 컨트롤러 입니다.

### 주요 특징

* 상단에는 UIView를 필수로 표시해야 하고, 하단에는 UIScrollView를 선택적으로 표시할 수 있습니다. 
	* REBottomSheetDelegate의 @required 항목을 참고해주세요.
* 하단의 UIScrollView의 contentOffset에 따라 Sheet컨트롤러의 view와 scrollView의 pan 제스처를 적절히 처리해줍니다. 
	* shoudPanGesture = NO로 설정하면 pan 제스처를 사용하지 않도록 설정이 가능합니다. 
* bounceAnimationHeight 값으로 드래그 후 bounce 효과의 높이를 변경할 수 있습니다. 
* topCornerRadius 값으로 좌우상단을 round 처리 할 수 있습니다. 
* 부모 컨트롤러의 view 전체를 투명한 view로 가리고 Sheet컨트롤러의 view 높이에 따라 투명도를 변경하거나 클릭 이벤트를 전달 받을 수 있습니다.
	* dimmedColor, dimmedAlphaForMinHeight, dimmedAlphaForMaxHeight

### 기본 사용법

뷰 생성하기

~~~
REBottomSheetController * const controller = [[REBottomSheetController alloc] init];
controller.delegate = self;
	
[self addChildViewController:controller];
[self.view addSubview:controller.view];
[controller didMoveToParentViewController:self];
~~~

뷰 제거하기

~~~
[controller willMoveToParentViewController:nil];
[controller.view removeFromSuperview];
[controller removeFromParentViewController];
~~~


## Requirements

iOS 9.0 이상

## Installation

REBottomSheetController is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'REBottomSheetController'
```

## Author

roceun, roceun@gmail.com

## License

REBottomSheetController is available under the MIT license. See the LICENSE file for more info.
