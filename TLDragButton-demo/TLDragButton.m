//
//  TLDragButton.m
//  按钮拖拽
//
//  Created by andezhou on 15/7/10.
//  Copyright (c) 2015年 andezhou. All rights reserved.
//

#import "TLDragButton.h"

static CGFloat kDuration = 0.25;

@interface TLDragButton ()

@property (assign, nonatomic) CGPoint startPoint;
@property (assign, nonatomic) NSInteger moveIndex;
@property (assign, nonatomic) CGPoint moveCenter;
@property (assign, nonatomic) CGPoint startCenter;

@property (assign, nonatomic) NSMutableArray *btnList;

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
        btn.btnList = btnArray;
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

- (void)touchesBegan:(UILongPressGestureRecognizer *)gestureRecognizer {
    //    AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
    
    UIButton *moveBtn = (UIButton *)gestureRecognizer.view;
    [[self superview] bringSubviewToFront:moveBtn];
    
    self.startPoint = [gestureRecognizer locationInView:moveBtn];
    self.moveCenter = moveBtn.center;
    self.startCenter = moveBtn.center;
    self.moveIndex = [self.btnList indexOfObject:moveBtn];
    
    [UIView animateWithDuration:kDuration animations:^{
        moveBtn.backgroundColor = [UIColor lightGrayColor];
        moveBtn.transform = CGAffineTransformMakeScale(1.2, 1.2);
    }];
}

- (void)touchesMoved:(UILongPressGestureRecognizer *)gestureRecognizer {
    UIButton *moveBtn = (UIButton *)gestureRecognizer.view;
    // 调整被拖拽按钮的center， 保证它根手指一起滑动
    CGPoint newPoint = [gestureRecognizer locationInView:moveBtn];
    CGFloat deltaX = newPoint.x - self.startPoint.x;
    CGFloat deltaY = newPoint.y - self.startPoint.y;
    moveBtn.center = CGPointMake(moveBtn.center.x + deltaX, moveBtn.center.y + deltaY);
    
    for (NSInteger index = 0; index < self.btnList.count; index ++) {
        UIButton *button = self.btnList[index];
        
        if (self.moveIndex != index) {
            if (CGRectContainsPoint(button.frame, moveBtn.center)) {
                [self adjustButtons:moveBtn index:index];
            }
        }
    }
}

- (void)touchesEnded:(UILongPressGestureRecognizer *)gestureRecognizer {
    UIButton *moveBtn = (UIButton *)gestureRecognizer.view;
    [UIView animateWithDuration:kDuration animations:^{
        moveBtn.backgroundColor = [UIColor whiteColor];
        moveBtn.transform = CGAffineTransformIdentity;
        moveBtn.center = self.moveCenter;
    }];
}

//  调整按钮位置
- (void)adjustButtons:(UIButton *)moveBtn index:(NSInteger)index {
    UIButton *currentBtn = self.btnList[index];
    CGPoint currentCenter = currentBtn.center;
    
    __block CGPoint oldCenter = self.moveCenter;
    __block CGPoint nextCenter = CGPointZero;
    
    if (index < self.moveIndex) {  // 将靠前的按钮移动到靠后的位置
        
        for (NSInteger num = self.moveIndex - 1; num >= index; num--) {
            
            // 将上一个按钮的位置赋值给当前按钮
            [UIView animateWithDuration:kDuration animations:^{
                UIButton *nextBtn = [self.btnList objectAtIndex:num];
                nextCenter = nextBtn.center;
                nextBtn.center = oldCenter;
                oldCenter = nextCenter;
            }];
        }
        
        // 调整顺序
        [self.btnList insertObject:moveBtn atIndex:index];
        [self.btnList removeObjectAtIndex:self.moveIndex + 1];
        
    } else {  // 将靠后的按钮移动到前边
        
        for (NSInteger num = self.moveIndex + 1; num <= index; num ++) {
            // 将上一个按钮的位置赋值给当前按钮
            [UIView animateWithDuration:kDuration animations:^{
                UIButton *nextBtn = [self.btnList objectAtIndex:num];
                nextCenter = nextBtn.center;
                nextBtn.center = oldCenter;
                oldCenter = nextCenter;
            }];
        }
        
        // 调整顺序
        [self.btnList insertObject:moveBtn atIndex:index + 1];
        [self.btnList removeObjectAtIndex:self.moveIndex];
    }
    
    self.moveIndex = index;
    self.moveCenter = currentCenter;
}

@end
