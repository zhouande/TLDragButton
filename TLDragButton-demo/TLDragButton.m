//
//  TLDragButton.m
//  按钮拖拽
//
//  Created by andezhou on 15/7/10.
//  Copyright (c) 2015年 andezhou. All rights reserved.
//

#import "TLDragButton.h"

static CGFloat kDuration = .2f;
static CGFloat kBaseDuration = .4f;

#define screenHeight self.superview.frame.size.height //[UIScreen mainScreen].bounds.size.height

@interface TLDragButton ()

@property (nonatomic, assign) NSInteger dragIndex;
@property (nonatomic, assign) CGPoint dragCenter;
@property (nonatomic, strong) UIColor *bgColor;

@property (nonatomic, assign) NSMutableArray *dragButtons;
@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, assign) NSUInteger startIndex;

@property (nonatomic, strong) UIView *displayView;
@property (nonatomic, strong) UIButton *topView, *bottomView;

@property (nonatomic, copy) DisplayOpenBlock openBlock;
@property (nonatomic, copy) DisplayCloseBlock closeBlock;
@property (nonatomic, copy) DisplayCompletionBlock completionBlock;

@end

@implementation TLDragButton

#pragma mark -
#pragma mark lifecycle
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(buttonLongPressed:)];
        [self addGestureRecognizer:longGesture];
    }
    return self;
}

- (void)setBtnArray:(NSMutableArray *)btnArray
{
    _btnArray = btnArray;

    for (TLDragButton *btn in btnArray) {
        btn.dragButtons = btnArray;
    }
}

#pragma mark -
#pragma mark init methods

#pragma mark -
#pragma mark GestureRecognizer
// 手势响应，并判断状态
- (void)buttonLongPressed:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        [self touchesBegan:gestureRecognizer];
        
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        
        [self touchesMoved:gestureRecognizer];
        
    } else {
        [self touchesEnded:gestureRecognizer];
    }
}

// 拖拽开始
- (void)touchesBegan:(UILongPressGestureRecognizer *)gestureRecognizer {
    [[self superview] bringSubviewToFront:self];

    self.startPoint = [gestureRecognizer locationInView:self];
    self.bgColor = self.backgroundColor;
    self.dragCenter = self.center;
    self.dragIndex = [self.dragButtons indexOfObject:self];
    self.startIndex = [self.dragButtons indexOfObject:self];
    
    [UIView animateWithDuration:kDuration animations:^{
        self.backgroundColor = self.dragColor ? self.dragColor : self.bgColor;
        self.transform = CGAffineTransformMakeScale(1.2, 1.2);
    }];
}

// 拖拽移动
- (void)touchesMoved:(UILongPressGestureRecognizer *)gestureRecognizer {
    // 调整被拖拽按钮的center， 保证它根手指一起滑动
    CGPoint newPoint = [gestureRecognizer locationInView:self];
    CGFloat deltaX = newPoint.x - self.startPoint.x;
    CGFloat deltaY = newPoint.y - self.startPoint.y;
    self.center = CGPointMake(self.center.x + deltaX, self.center.y + deltaY);

    for (NSInteger index = 0; index < self.dragButtons.count; index ++) {
        UIButton *button = self.dragButtons[index];
        
        if (self.dragIndex != index) {
            if (CGRectContainsPoint(button.frame, self.center)) {
                [self adjustButtons:self index:index];
            }
        }
    }
}

// 拖拽结束
- (void)touchesEnded:(UILongPressGestureRecognizer *)gestureRecognizer {
    [UIView animateWithDuration:kDuration animations:^{
        self.backgroundColor = self.bgColor;
        self.transform = CGAffineTransformIdentity;
        self.center = self.dragCenter;
    }];
    
    // 判断按钮位置是否已经改变，如果发生改变通过代理通知父视图
    if (self.startIndex != self.dragIndex) {
        if ([self.delegate respondsToSelector:@selector(dragButton:dragButtons:)]) {
            [self.delegate dragButton:self dragButtons:self.dragButtons];
        }
    }    
}

//  调整按钮位置
- (void)adjustButtons:(UIButton *)dragBtn index:(NSInteger)index {
    UIButton *moveBtn = self.dragButtons[index];
    CGPoint moveCenter = moveBtn.center;
    
    __block CGPoint oldCenter = self.dragCenter;
    __block CGPoint nextCenter = CGPointZero;
    
    if (index < self.dragIndex) {  // 将靠前的按钮移动到靠后的位置
        
        for (NSInteger num = self.dragIndex - 1; num >= index; num--) {
            // 将上一个按钮的位置赋值给当前按钮
            [UIView animateWithDuration:kDuration animations:^{
                UIButton *nextBtn = [self.dragButtons objectAtIndex:num];
                nextCenter = nextBtn.center;
                nextBtn.center = oldCenter;
                oldCenter = nextCenter;
            }];
        }
        
        // 调整顺序
        [self.dragButtons insertObject:dragBtn atIndex:index];
        [self.dragButtons removeObjectAtIndex:self.dragIndex + 1];
        
    } else {  // 将靠后的按钮移动到前边
        
        for (NSInteger num = self.dragIndex + 1; num <= index; num ++) {
            // 将上一个按钮的位置赋值给当前按钮
            [UIView animateWithDuration:kDuration animations:^{
                UIButton *nextBtn = [self.dragButtons objectAtIndex:num];
                nextCenter = nextBtn.center;
                nextBtn.center = oldCenter;
                oldCenter = nextCenter;
            }];
        }
        
        // 调整顺序
        [self.dragButtons insertObject:dragBtn atIndex:index + 1];
        [self.dragButtons removeObjectAtIndex:self.dragIndex];
    }
    
    self.dragIndex = index;
    self.dragCenter = moveCenter;
}

#pragma mack - public methods
- (void)openDisplayView:(UIView *)displayView
              openBlock:(DisplayOpenBlock)openBlock
             closeBlock:(DisplayCloseBlock)closeBlock
        completionBlock:(DisplayCompletionBlock)completionBlock {
    
    if (!self.lineCount) {
#warning 如使用此方法，lineCount不能为空
        return;
    }
    // 回调block
    self.openBlock = openBlock;
    self.completionBlock = completionBlock;
    self.closeBlock = closeBlock;

    self.displayView = displayView;
    self.dragIndex = [self.dragButtons indexOfObject:self];

    // 设置displayView的frame
    CGFloat height = CGRectGetHeight(self.displayView.frame);
    CGFloat width = CGRectGetWidth(self.displayView.frame);
    CGFloat position = CGRectGetMaxY(self.frame);
    
    CGFloat offsetY = 0.0f;
    // 检查父视图是否为UIScrollView
    if ([self.superview isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)self.superview;
        offsetY = scrollView.contentOffset.y;
        position -= offsetY;
    }
    
    // 检查点击的按钮是否全部在屏幕之中
    CGFloat btnOffset = 0.0f;
    if (position - screenHeight > 0) {
        btnOffset = position - screenHeight;
        // 此时position就是屏幕的高度
        position -= btnOffset;
    }
    
    // 屏幕不够显示displayView时,按钮向上偏移值
    CGFloat deltaY = 0.0f;
    if (position + height > screenHeight) {
        deltaY = height - (screenHeight - position);
    }
    
    // 初始化上下阴影
    CGRect upperRect = CGRectMake(0, offsetY, width, position);
    CGRect lowerRect = CGRectMake(0, position + offsetY, width, screenHeight - position);
    self.topView = [self buttonForRect:upperRect position:position];
    self.bottomView = [self buttonForRect:lowerRect position:position];
    
    // 设置展示视图
    CGRect showFrame = self.displayView.frame;
    showFrame.origin = CGPointMake(0, position + offsetY - deltaY);
    self.displayView.frame = showFrame;
    
    // 加载视图
    [self.superview addSubview:self.topView];
    [self.superview addSubview:self.bottomView];
    [self.superview insertSubview:self.displayView atIndex:0];
    
    // 展开动画
    [self openAnimationWithDeltaY:deltaY btnOffset:btnOffset height:height];
    
    // 透明变半透明
    [UIView animateWithDuration:kBaseDuration animations:^{
        self.topView.alpha = 0.4f;
        self.bottomView.alpha = 0.4f;
    }];
    
    // openBlock
    if (self.openBlock) {
        self.openBlock(self.displayView, kBaseDuration);
    }
}

#pragma mark - private methods
// 关闭动画
- (void)performClose:(UIButton *)sender {
    CGFloat height = CGRectGetHeight(self.displayView.frame);
    CGFloat position = CGRectGetMaxY(self.frame);
    
    CGFloat offsetY = 0.0f;
    // 检查父视图是否为UIScrollView
    if ([self.superview isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)self.superview;
        offsetY = scrollView.contentOffset.y;
        position = position - offsetY;
    }
    
    // 检查点击的按钮是否全部在屏幕之中
    CGFloat btnOffset = 0.0f;
    if (position - screenHeight > 0) {
        btnOffset = position - screenHeight;
        // 此时position就是屏幕的高度
        position -= btnOffset;
    }
    
    // 屏幕不够显示displayView时,按钮向上偏移值
    CGFloat deltaY = 0.0f;
    if (position + height > screenHeight) {
        deltaY = height - (screenHeight - position);
    }
    
    // 关闭动画
    [self closeAnimationWithDeltaY:deltaY btnOffset:btnOffset height:height];
    
    // 半透明变透明
    [UIView animateWithDuration:kBaseDuration animations:^{
        self.topView.alpha = 0.0f;
        self.bottomView.alpha = 0.0f;
        self.displayView.alpha = 0.0f;
    }];
    
    // closeBlock
    if (self.closeBlock) {
        self.closeBlock(self.displayView, kBaseDuration);
    }
}

// 开启动画
- (void)openAnimationWithDeltaY:(CGFloat)deltaY btnOffset:(CGFloat)btnOffset height:(CGFloat)height {
    // 获取当前点击所在的行
    NSUInteger line = self.dragIndex / self.lineCount + 1;
    NSUInteger count = self.lineCount * line;
    
    // 设置上下阴影的动画
    CABasicAnimation *topAnimation = [self positionMoveBasicAnimationFromValue:btnOffset toValue:-deltaY];
    [self.topView.layer addAnimation:topAnimation forKey:@"top1"];
    
    CABasicAnimation *bottomAnimation = [self positionMoveBasicAnimationFromValue:0 toValue:height - deltaY];
    [self.bottomView.layer addAnimation:bottomAnimation forKey:@"bottom1"];
    
    // 设置上下按钮动画
    CABasicAnimation *topDragAnimation = [self positionMoveBasicAnimationFromValue:0 toValue:-deltaY - btnOffset];
    NSUInteger maxCount = count < self.dragButtons.count ? count : self.dragButtons.count;
    for (NSUInteger index = 0; index < maxCount; index ++) {
        TLDragButton *dragBtn = self.dragButtons[index];
        [dragBtn.layer addAnimation:topDragAnimation forKey:@"topDrag1"];
    }
    
    CABasicAnimation *bottomDragAnimation = [self positionMoveBasicAnimationFromValue:0 toValue:height - deltaY - btnOffset];
    for (NSUInteger index = self.dragButtons.count - 1; index >= count; index --) {
        TLDragButton *dragBtn = self.dragButtons[index];
        [dragBtn.layer addAnimation:bottomDragAnimation forKey:@"bottomDrag1"];
    }
}

// 关闭动画
- (void)closeAnimationWithDeltaY:(CGFloat)deltaY btnOffset:(CGFloat)btnOffset height:(CGFloat)height {
    NSUInteger line = self.dragIndex / self.lineCount + 1;
    NSUInteger count = self.lineCount * line;
    NSUInteger maxCount = count < self.dragButtons.count ? count : self.dragButtons.count;
    
    CGFloat fromvalue = height - deltaY;
    // 关闭上下button动画
    CABasicAnimation *topDragAnimation = [self positionMoveBasicAnimationFromValue:-deltaY - btnOffset toValue:0];
    for (NSUInteger index = 0; index < maxCount; index ++) {
        TLDragButton *dragBtn = self.dragButtons[index];
        [dragBtn.layer addAnimation:topDragAnimation forKey:@"topDrag2"];
    }
    
    CABasicAnimation *bottomDragAnimation = [self positionMoveBasicAnimationFromValue:fromvalue - btnOffset toValue:0];
    for (NSUInteger index = self.dragButtons.count - 1; index >= count; index --) {
        TLDragButton *dragBtn = self.dragButtons[index];
        [dragBtn.layer addAnimation:bottomDragAnimation forKey:@"bottomDrag2"];
    }
    
    // 关闭阴影动画
    CABasicAnimation *topAnimation = [self positionMoveBasicAnimationFromValue:-deltaY toValue:btnOffset];
    [self.topView.layer addAnimation:topAnimation forKey:@"top2"];
    
    CABasicAnimation *bottomAnimation = [self positionMoveBasicAnimationFromValue:fromvalue toValue:0];
    [bottomAnimation setValue:@"close" forKey:@"animationType"];
    bottomAnimation.delegate = self;
    [self.bottomView.layer addAnimation:bottomAnimation forKey:@"base"];
}

// 初始化阴影按钮
- (UIButton *)buttonForRect:(CGRect)rect position:(CGFloat)position {
    UIButton *btn = [[UIButton alloc] initWithFrame:rect];
    btn.backgroundColor = [UIColor whiteColor];
    btn.alpha = 0;
    [btn addTarget:self action:@selector(performClose:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

// 基本动画
- (CABasicAnimation *)positionMoveBasicAnimationFromValue:(CGFloat)fromValue toValue:(CGFloat)toValue {
    CABasicAnimation *position = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    position.duration = kBaseDuration;
    position.speed = 1.1;
    position.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    position.fromValue = @(fromValue);
    position.toValue = @(toValue);
    position.removedOnCompletion = NO;
    position.fillMode = kCAFillModeForwards;
    return position;
}

// CABasicAnimation的代理方法
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if ([[anim valueForKey:@"animationType"] isEqualToString:@"close"]) {
        [self.displayView removeFromSuperview];
        [self.topView removeFromSuperview];
        [self.bottomView removeFromSuperview];
        
        self.displayView = nil;
        self.topView = nil;
        self.bottomView = nil;
        
        // completionBlock
        if (self.completionBlock) {
            self.completionBlock();
        }
    }
}

@end
