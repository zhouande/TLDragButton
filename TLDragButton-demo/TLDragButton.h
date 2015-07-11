//
//  TLDragButton.h
//  按钮拖拽
//
//  Created by andezhou on 15/7/10.
//  Copyright (c) 2015年 andezhou. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TLDragButton;

@protocol TLDragButtonDelegate <NSObject>

/**
 *  @brief  通知父视图button的排列顺序发生了改变
 *
 *  @param dragButton  按钮位置已经改变button
 *  @param dragButtons 新排列的button数组
 */
- (void)dragButton:(TLDragButton *)dragButton dragButtons:(NSArray *)dragButtons;

@end

@interface TLDragButton : UIButton

/**
 *  代理方法
 */
@property (nonatomic, weak) id<TLDragButtonDelegate> delegate;

/**
 *  存放需要拖拽的按钮数组
 */
@property (nonatomic, strong) NSMutableArray *btnArray;

/**
 *  按钮正在被拖拽时的颜色
 */
@property (nonatomic, strong) UIColor *dragColor;


@end
