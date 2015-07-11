//
//  TLDragButton.m
//  按钮拖拽
//
//  Created by andezhou on 15/7/10.
//  Copyright (c) 2015年 andezhou. All rights reserved.
//

#import "TLDragButton.h"

static CGFloat kDuration = 0.2;

@interface TLDragButton ()

@property (nonatomic, assign) NSInteger dragIndex;
@property (nonatomic, assign) CGPoint dragCenter;
@property (nonatomic, strong) UIColor *bgColor;

@property (nonatomic, assign) NSMutableArray *dragButtons;
@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, assign) NSUInteger startIndex;

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

@end
