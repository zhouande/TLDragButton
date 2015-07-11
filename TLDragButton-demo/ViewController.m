//
//  ViewController.m
//  按钮拖拽
//
//  Created by andezhou on 15/7/9.
//  Copyright (c) 2015年 andezhou. All rights reserved.
//

#import "ViewController.h"
#import "TLDragButton.h"

static NSUInteger kCount = 4;
#define RGB(r,g,b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]

@interface ViewController () <TLDragButtonDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"拖拽";
    
    NSMutableArray *array = [NSMutableArray array];
    CGFloat kMargin = 1;
    CGFloat width = ([UIScreen mainScreen].bounds.size.width - kMargin*(kCount + 1))/kCount;
    CGFloat height = 120;
    
    for (NSInteger index = 0; index < 12; index ++) {
        NSUInteger X = index % kCount;
        NSUInteger Y = index / kCount;
        
        TLDragButton *btn = [TLDragButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(X * (width + kMargin) + kMargin, Y * (height + kMargin), width, height);
        btn.backgroundColor = [self getColor];
        btn.dragColor = [UIColor blueColor];
        btn.delegate = self;
        [btn setTitle:[NSString stringWithFormat:@"%zi", index] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];

        [array addObject:btn];
        btn.btnArray = array;
    }
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)clickAction:(UIButton *)sender {
    NSString *currentTitle = sender.currentTitle;
    NSLog(@"你点中了：%@", currentTitle);
}

- (void)dragButton:(TLDragButton *)dragButton dragButtons:(NSArray *)dragButtons {
    NSString *currentTitle = dragButton.currentTitle;
    NSLog(@"%@位置发生了改变", currentTitle);
}

- (UIColor *)getColor {
    return RGB(arc4random() % 255, arc4random() % 255, arc4random() % 255);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
