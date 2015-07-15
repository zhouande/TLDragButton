//
//  ViewController.m
//  按钮拖拽
//
//  Created by andezhou on 15/7/9.
//  Copyright (c) 2015年 andezhou. All rights reserved.
//

#import "ViewController.h"
#import "TLDragButton.h"

static NSUInteger kLineCount = 4;

@interface ViewController () <TLDragButtonDelegate>

@property (nonatomic, strong) NSArray *tags;
@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"拖拽";
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSMutableArray *array = [NSMutableArray array];
    CGFloat kMargin = 1;
    CGFloat width = ([UIScreen mainScreen].bounds.size.width - kMargin*(kLineCount + 1))/kLineCount;
    CGFloat height = 130;
    
    self.tags = @[@1, @4, @5, @7, @8, @9, @11, @14, @18];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64)];
    self.scrollView.backgroundColor = [UIColor lightGrayColor];
    self.scrollView.contentSize = CGSizeMake(0, 5*131);
    [self.view addSubview:self.scrollView];
    
    for (NSInteger index = 0; index < 20; index ++) {
        NSUInteger X = index % kLineCount;
        NSUInteger Y = index / kLineCount;
        
        TLDragButton *btn = [TLDragButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(X * (width + kMargin) + kMargin, Y * (height + kMargin), width, height);
        btn.backgroundColor = [self getColor];
        btn.tag = index;
        btn.lineCount = kLineCount;
        btn.dragColor = [UIColor blueColor];
        btn.delegate = self;
        [btn setTitle:[NSString stringWithFormat:@"%zi", index] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:btn];

        [array addObject:btn];
        btn.btnArray = array;
    }
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)clickAction:(TLDragButton *)sender {
    NSLog(@"你点中了：%@", sender.currentTitle);
    
    if ([self.tags containsObject:@(sender.tag)]) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 200)];
        view.backgroundColor = [UIColor lightGrayColor];
        [sender openDisplayView:view openBlock:^(UIView *displayView, CFTimeInterval duration) {
//            NSLog(@"开始");
            self.scrollView.scrollEnabled = NO;
        } closeBlock:^(UIView *displayView, CFTimeInterval duration) {
//            NSLog(@"关闭");
        } completionBlock:^{
//            NSLog(@"完成");
            self.scrollView.scrollEnabled = YES;
        }];
    }
}

- (void)dragButton:(TLDragButton *)dragButton dragButtons:(NSArray *)dragButtons {
    NSString *currentTitle = dragButton.currentTitle;
    NSLog(@"%@位置发生了改变", currentTitle);
}

- (UIColor *)getColor {
    CGFloat red = arc4random() % 256;
    CGFloat green = arc4random() % 256;
    CGFloat blue = arc4random() % 256;
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
