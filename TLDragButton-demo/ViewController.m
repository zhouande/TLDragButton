//
//  ViewController.m
//  按钮拖拽
//
//  Created by andezhou on 15/7/9.
//  Copyright (c) 2015年 andezhou. All rights reserved.
//

#import "ViewController.h"
#import "TLDragButton.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"拖拽";
    
    NSMutableArray *array = [NSMutableArray array];
    CGFloat width = [UIScreen mainScreen].bounds.size.width/4.0;
    CGFloat height = 120;
    
    for (NSInteger index = 0; index < 12; index ++) {
        TLDragButton *btn = [TLDragButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(index%4 * width, index / 4 * height, width, 120);
        btn.backgroundColor = [UIColor whiteColor];
        btn.layer.borderWidth = 1;
        btn.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        
        [btn setTitle:[NSString stringWithFormat:@"%zi", index] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
        [self.view addSubview:btn];
        [array addObject:btn];
        btn.btnArray = array;
    }
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
