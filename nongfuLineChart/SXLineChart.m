//
//  SXLineChart.m
//  课堂测评第三期封装的View
//
//  Created by wanglei on 17/3/9.
//  Copyright © 2017年 wanglei. All rights reserved.
//

#import "SXLineChart.h"
@interface SXLineChart()
{
    NSArray * _chartArray;
    NSMutableArray * _pointsCenterArray;
    
    UILabel *_dateLabel;
    UILabel *_changeLabel;
    UILabel *_indexLabel;
    
    NSMutableArray *_bottomLabels;
    
    NSArray *_leftLabelTextArray;
}
@end

@implementation SXLineChart
-(instancetype)initWithFrame:(CGRect)frame andChartArray:(NSArray *)chartArray{
    if ( self = [super init] ) {
        self.frame = frame;
        [self addBackGroundView];
        [self addLabelAndLine];
        _chartArray = @[@"109.00",@"108.00",@"107.00",@"110.00",@"107.00",@"110.00"];
        [self addPoint];
    }
    return self;
}

- (void)drawRect:(CGRect)rect{
    [self strokeLine];
    [self addCircle];
    
    NSMutableArray *maskBottomPoints = @[].mutableCopy;
    for (int i = 0; i<_pointsCenterArray.count; i++) {
        CGPoint point = [[_pointsCenterArray objectAtIndex:i] CGPointValue];
        CGPoint bottomPoint = CGPointMake(point.x, self.frame.size.height);
        [maskBottomPoints addObject:[NSValue valueWithCGPoint:bottomPoint]];
    }
    for (int i = 0; i < _pointsCenterArray.count - 1; i++) {
        CGPoint firstPoint = CGPointMake([[maskBottomPoints objectAtIndex:i] CGPointValue].x - 0.125, [[maskBottomPoints objectAtIndex:i] CGPointValue].y);
        CGPoint secondPoint = CGPointMake([[_pointsCenterArray objectAtIndex:i] CGPointValue].x - 0.125, [[_pointsCenterArray objectAtIndex:i] CGPointValue].y);
        NSArray *maskPoints = @[[NSValue valueWithCGPoint:firstPoint],[NSValue valueWithCGPoint:secondPoint],[_pointsCenterArray objectAtIndex:i + 1],[maskBottomPoints objectAtIndex:i + 1]];
        
        CGContextRef graphContext = UIGraphicsGetCurrentContext();
        CGContextBeginPath(graphContext);
        CGPoint beginPoint = [[maskPoints objectAtIndex:0] CGPointValue];
        CGContextMoveToPoint(graphContext, beginPoint.x, beginPoint.y);
        for (NSValue* pointValue in maskPoints){
            CGPoint point = [pointValue CGPointValue];
            CGContextAddLineToPoint(graphContext, point.x, point.y);
        }
        CGContextClosePath(graphContext);
        CGContextSetFillColorWithColor(graphContext, [UIColor colorWithWhite:1 alpha:0.16].CGColor);
        CGContextDrawPath(graphContext,kCGPathFill);
    }
    
    [self addAnimation];
}

- (void)addAnimation{
    UIView *mask = [[UIView alloc] initWithFrame:CGRectMake(31, 39 - 3, self.frame.size.width - 31, self.frame.size.height - 39 + 3)];
    mask.backgroundColor = Color_With_Rgb(43,124,86,1);
    for (int i = 0; i < _leftLabelTextArray.count; i++) {
        UIView *horizontalLine = [[UIView alloc] initWithFrame:CGRectMake(0, i * 18 + 3, self.frame.size.width - 31, 1)];
        horizontalLine.backgroundColor = [UIColor whiteColor];
        horizontalLine.alpha = 0.05;
        [mask addSubview:horizontalLine];
    }
    [self addSubview:mask];
    
    for (UILabel *label in _bottomLabels) {
        [self bringSubviewToFront:label];
    }
    
    [UIView animateWithDuration:3 delay:0 options:UIViewAnimationOptionTransitionNone animations:^{
        mask.frame = CGRectMake(self.frame.size.width, 39 - 2, self.frame.size.width - 31, self.frame.size.height - 39 + 2);
    } completion:^(BOOL finished) {
        [mask removeFromSuperview];
    }];
    
    [self setClipsToBounds:YES];
}

- (void)addCircle{
    for (int i = 0; i<_pointsCenterArray.count; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 4, 4)];
        imageView.image = [UIImage imageNamed:@"ellipse_7"];
        imageView.center = [[_pointsCenterArray objectAtIndex:i] CGPointValue];
        [self addSubview:imageView];
    }
}

- (void)strokeLine{
    //划线
    CAShapeLayer *_chartLine = [CAShapeLayer layer];
    _chartLine.lineCap = kCALineCapRound;
    _chartLine.lineJoin = kCALineJoinBevel;
    _chartLine.fillColor   = [[UIColor clearColor] CGColor];
    _chartLine.lineWidth   = 1;
    _chartLine.strokeEnd   = 0.0;
    [self.layer addSublayer:_chartLine];
    
    UIBezierPath *progressline = [UIBezierPath bezierPath];
    CGPoint firstPointCenter = [[_pointsCenterArray objectAtIndex:0] CGPointValue];
    [progressline moveToPoint:firstPointCenter];
    [progressline setLineWidth:2.0];
    [progressline setLineCapStyle:kCGLineCapRound];
    [progressline setLineJoinStyle:kCGLineJoinRound];
    for (int j = 1; j < _pointsCenterArray.count; j++ ) {
        [progressline addLineToPoint:[[_pointsCenterArray objectAtIndex:j] CGPointValue]];
    }
    
    _chartLine.path = progressline.CGPath;
    _chartLine.strokeColor = [UIColor colorWithWhite:1 alpha:0.2].CGColor;
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = _pointsCenterArray.count*0.4;
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    pathAnimation.autoreverses = NO;
//    [_chartLine addAnimation:pathAnimation forKey:@"strokeEndAnimation"];
    _chartLine.strokeEnd = 1.0;
}



- (void)addPoint{
    float bottomLabelSpace = (self.frame.size.width - 35 - 30) / (_chartArray.count -1);
    float maxSub = 110.00 - 107.00;
    _pointsCenterArray = @[].mutableCopy;
    for (int i = 0; i<_chartArray.count; i++) {
        float num = [_chartArray[i] doubleValue] - 107.0;
        float y = 93 - ((num / maxSub) * (18 * 3));
        NSValue *centerValue = [NSValue valueWithCGPoint:CGPointMake(35 + 15 + bottomLabelSpace * i, y)];
        [_pointsCenterArray addObject:centerValue];
    }
}

- (void)addBackGroundView{
    self.backgroundColor = Color_With_Rgb(43,124,86,1);
    
    UIImageView *farm_products_index = [[UIImageView alloc] initWithFrame:CGRectMake(6, 15, 109, 14)];
    farm_products_index.image = [UIImage imageNamed:@"farm_products_index"];
    [self addSubview:farm_products_index];
    
    _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - 9 - 38, 9, 38, 9)];
    _dateLabel.text = @"10月12日";
    _dateLabel.font = [UIFont systemFontOfSize:8.7];
    _dateLabel.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
    _dateLabel.alpha = 0.64;
    _dateLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_dateLabel];
    
    _changeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - 9 - 36, 21, 36, 9)];
    _changeLabel.text = @"+0.21";
    _changeLabel.font = [UIFont systemFontOfSize:9.8];
    _changeLabel.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
    _changeLabel.backgroundColor = Color_With_Rgb(253, 149, 38, 1);
    _changeLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_changeLabel];
    
    _indexLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - 9 - 38 - 3 - 87, 9, 87, 21)];
    _indexLabel.text = @"107.50";
    _indexLabel.font = [UIFont systemFontOfSize:27.5];
    _indexLabel.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
    _indexLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_indexLabel];
}

- (void)addLabelAndLine{
    //横坐标
    _leftLabelTextArray = @[@"110.00",@"109.00",@"108.00",@"107.00"];
    for (int i = 0; i < _leftLabelTextArray.count; i++) {
        UILabel *leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 36 + i * 18, 28, 7)];
        leftLabel.textAlignment = NSTextAlignmentRight;
        leftLabel.font =  [UIFont fontWithName:@"PingFang-SC-Medium" size:6.7];
        leftLabel.text = _leftLabelTextArray[i];
        leftLabel.alpha = 0.43;
        leftLabel.textColor = [UIColor whiteColor];
        [self addSubview:leftLabel];
        
        UIView *horizontalLine = [[UIView alloc] initWithFrame:CGRectMake(31, 36 + i * 18 + 3, self.frame.size.width - 31, 1)];
        horizontalLine.backgroundColor = [UIColor whiteColor];
        horizontalLine.alpha = 0.05;
        [self addSubview:horizontalLine];
    }
    
    //纵坐标
    NSArray *bottomLabelTextArray = @[@"9.25",@"9.26",@"9.27",@"9.28",@"9.29",@"9.30"];
    _bottomLabels = @[].mutableCopy;
    float bottomLabelSpace = (self.frame.size.width - 35 - 30) / (bottomLabelTextArray.count -1);
    for (int i = 0; i < bottomLabelTextArray.count; i++) {
        UILabel *bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 7)];
        bottomLabel.center = CGPointMake(35 + 15 + bottomLabelSpace * i, 102);
        bottomLabel.textAlignment = NSTextAlignmentCenter;
        bottomLabel.font =  [UIFont fontWithName:@"PingFang-SC-Medium" size:6.7];
        bottomLabel.text = bottomLabelTextArray[i];
        bottomLabel.alpha = 0.43;
        bottomLabel.textColor = [UIColor whiteColor];
        [self addSubview:bottomLabel];
        [_bottomLabels addObject:bottomLabel];
    }
}

@end
