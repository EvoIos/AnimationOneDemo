//
//  ViewController.m
//  AnimationOneDemo
//
//  Created by zhenglanchun on 16/3/11.
//  Copyright © 2016年 dothisday. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) CADisplayLink *displayLink;
//背景图层
@property (nonatomic, strong) CALayer *canvasLayer;
//遮罩图层
@property (nonatomic, strong) CAShapeLayer *waveLayer;
//背景图层frame
@property (nonatomic) CGRect frame;
//遮罩图层frame
@property (nonatomic) CGRect shapeFrame;

@property (nonatomic, strong) CALayer *coverLayer;

@end

@implementation ViewController
//初始相位
static float phase = 0;
//相位偏移量
static float phaseShift = 0.25;

- (void)viewDidLoad {
    [super viewDidLoad];
    //带波浪的注水动画
    {
        //shapePointY=92，设定mask起始位置（0，92）
        CGFloat shapePointY = 95;
        CGRect frame = CGRectMake(0, 0, 53, 95);
        CGRect shapeFrame = CGRectMake(0, shapePointY, 53, 95);
        self.frame = frame;
        self.shapeFrame = shapeFrame;
        
        //黑色边框
        CAShapeLayer *bglayer = [CAShapeLayer layer];
        bglayer.frame = CGRectMake(20, 80, 52, 94);
        bglayer.path = [[self createBezierPath] CGPath];
        bglayer.fillColor = [[UIColor clearColor] CGColor];
        bglayer.strokeColor = [[UIColor blackColor] CGColor];
        [self.view.layer addSublayer:bglayer];
        
        CAShapeLayer *mask = [CAShapeLayer layer];
        mask.path = [[self createBezierPath] CGPath];
        bglayer.mask = mask;
        
        //创建背景图层
        self.canvasLayer = [CALayer layer];
        self.canvasLayer.frame = frame;
        self.canvasLayer.backgroundColor = [UIColor orangeColor].CGColor;
        [bglayer addSublayer:self.canvasLayer];
        //创建遮罩图层
        self.waveLayer = [CAShapeLayer layer];
        self.waveLayer.frame = shapeFrame;
        //设定mask为waveLayer
        self.canvasLayer.mask = self.waveLayer;
        
        //开始动画
        [self startAnimating];
    }
    
    //不带波浪的注水动画
    {
    CALayer *canvasLayer = [CALayer layer];
    canvasLayer.frame = CGRectMake(200, 80, 53, 95);
    canvasLayer.backgroundColor = [[UIColor orangeColor] CGColor];
    [self.view.layer addSublayer:canvasLayer];
    
    CAShapeLayer *ovalShapeLayer = [CAShapeLayer layer];
    ovalShapeLayer.path = [[self createBezierPath] CGPath];
    canvasLayer.mask = ovalShapeLayer;
    
    CALayer *coverLayer = [CALayer layer];
    coverLayer.frame = CGRectMake(0, 0 , 53, 95 );
    coverLayer.anchorPoint = CGPointMake(0, 0);
    coverLayer.position = CGPointMake(0, 0);
    coverLayer.backgroundColor = [[UIColor whiteColor] CGColor];
    [canvasLayer addSublayer:coverLayer];
    
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath = @"bounds.size.height";
    animation.fromValue = @(94);
    animation.toValue = @(0);
    animation.duration = 5;
    animation.repeatCount = HUGE;
    animation.removedOnCompletion = YES;
    
    [coverLayer addAnimation:animation forKey:nil];
    }
}

- (void)startAnimating {
    [self.displayLink invalidate];
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
    CGPoint position = self.waveLayer.position;
    position.y = position.y - self.shapeFrame.size.height;
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.fromValue = [NSValue valueWithCGPoint:self.waveLayer.position];
    animation.toValue = [NSValue valueWithCGPoint:position];
    animation.duration = 5.0;
    animation.repeatCount = HUGE_VALF;
    animation.removedOnCompletion = NO;
    [self.waveLayer addAnimation:animation forKey:nil];

}
//波浪滚动 phase相位每桢变化值：phaseShift
- (void)update {
    CGRect frame = self.frame;
    phase += phaseShift;
    UIGraphicsBeginImageContext(frame.size);
    UIBezierPath *wavePath = [UIBezierPath bezierPath];
    CGFloat endX = 0;
    for(CGFloat x = 0; x < frame.size.width ; x += 1) {
        endX=x;
        //正弦函数，求y值
        CGFloat y = 3 * sinf(2 * M_PI *(x / frame.size.width)  + phase) ;
        if (x==0) {
            [wavePath moveToPoint:CGPointMake(x, y)];
        }else {
            [wavePath addLineToPoint:CGPointMake(x, y)];
        }
    }
    CGFloat endY = CGRectGetHeight(frame);
    [wavePath addLineToPoint:CGPointMake(endX, endY)];
    [wavePath addLineToPoint:CGPointMake(0, endY)];
    //修改每桢的wavelayer.path
    self.waveLayer.path = [wavePath CGPath];
    UIGraphicsEndImageContext();
}

- (UIBezierPath *)createBezierPath {
    // W:H = 70:120
    // oval frame {1,1,52,94}
    UIBezierPath* ovalPath = [UIBezierPath bezierPath];
    [ovalPath moveToPoint: CGPointMake(53, 30.53)];
    [ovalPath addCurveToPoint: CGPointMake(27, 95) controlPoint1: CGPointMake(53, 46.83) controlPoint2: CGPointMake(41.36, 95)];
    [ovalPath addCurveToPoint: CGPointMake(1, 30.53) controlPoint1: CGPointMake(12.64, 95) controlPoint2: CGPointMake(1, 46.83)];
    [ovalPath addCurveToPoint: CGPointMake(27, 1) controlPoint1: CGPointMake(1, 14.22) controlPoint2: CGPointMake(12.64, 1)];
    [ovalPath addCurveToPoint: CGPointMake(53, 30.53) controlPoint1: CGPointMake(41.36, 1) controlPoint2: CGPointMake(53, 14.22)];
    [ovalPath closePath];

    return ovalPath;
}

@end



