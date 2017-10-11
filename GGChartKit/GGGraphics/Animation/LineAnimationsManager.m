//
//  LineAnimationsManager.m
//  GGCharts
//
//  Created by _ | Durex on 2017/9/17.
//  Copyright © 2017年 I really is a farmer. All rights reserved.
//

#import "LineAnimationsManager.h"
#import <objc/runtime.h>
#import "NSObject+FireBlock.h"

@interface LineAnimationsManager ()

/**
 * 柱状图抽象类数组
 */
@property (nonatomic, strong) NSMutableArray * lineAbstractAry;

/**
 * 动画类
 */
@property (nonatomic, strong) Animator * animator;

@end

@implementation LineAnimationsManager

#pragma mark - Public Method

/**
 * 注册折线图动画类
 *
 * @param 折线抽象类
 */
- (void)registerLineDrawAbstract:(id <LineDrawAbstract>)lineDrawAbstract
{
    [self.lineAbstractAry addObject:lineDrawAbstract];
}

/**
 * 清空动画类
 */
- (void)resetAnimationManager
{
    [self.lineAbstractAry removeAllObjects];
}

/**
 * 开始动画
 *
 * @param 动画时长
 * @param 动画类型
 */
- (void)startAnimationWithDuration:(NSTimeInterval)duration animationType:(LineAnimationsType)type
{
    if (type == LineAnimationRiseType) {
        
        [self startLineRiseAnimationWithDuration:duration];
    }
    else if (type == LineAnimationChangeType) {
        
        [self startChangeAnimationWithDuration:duration];
    }
    else if (type == LineAnimationStrokeType) {
    
        [self startStrokeAnimationWithDuration:duration];
    }
}

#pragma mark - Private Method

/**
 * 开启柱状图变换
 *
 * @param 动画时长
 */
- (void)startChangeAnimationWithDuration:(NSTimeInterval)duration
{
    NSMutableArray * aryAllNumberRenderers = [NSMutableArray array];
    
    for (id <BarDrawAbstract> barAbstract in self.lineAbstractAry) {
        
        [GET_ASSOCIATED(barAbstract, lineFillLayer) pathChangeAnimation:duration];
        [GET_ASSOCIATED(barAbstract, lineLayer) pathChangeAnimation:duration];
        [GET_ASSOCIATED(barAbstract, lineShapeLayer) pathChangeAnimation:duration];
        
        [aryAllNumberRenderers addObjectsFromArray:GET_ASSOCIATED(barAbstract, lineNumberArray)];
    }
    
    [self.animator startAnimationWithDuration:duration animationArray:aryAllNumberRenderers updateBlock:^(CGFloat progress) {
        
        for (id <LineDrawAbstract> lineDrawAbstract in self.lineAbstractAry) {
            
            [GET_ASSOCIATED(lineDrawAbstract, lineStringLayer) setNeedsDisplay];
        }
    }];
}

/**
 * 滑动动画
 *
 * @param 动画时长
 */
- (void)startStrokeAnimationWithDuration:(NSTimeInterval)duration
{
    for (id <LineDrawAbstract> lineAbstract in self.lineAbstractAry) {
        
        CAShapeLayer * ggLineLayer = GET_ASSOCIATED(lineAbstract, lineLayer);
        
        CGRect fromRect = ggLineLayer.frame;
//        fromRect.size.width = ;
        fromRect.origin.x = ggLineLayer.frame.size.width;
        CGRect toRect = ggLineLayer.frame;
        
        CABasicAnimation *frameAnimation = [CABasicAnimation animationWithKeyPath:@"bounds"];
        frameAnimation.duration = duration;
        frameAnimation.fromValue = [NSValue valueWithCGRect:fromRect];
        frameAnimation.toValue = [NSValue valueWithCGRect:toRect];
        frameAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        
        [ggLineLayer addAnimation:frameAnimation forKey:@"frameAnimation"];
        [GET_ASSOCIATED(lineAbstract, lineShapeLayer) addAnimation:frameAnimation forKey:@"frameAnimation"];
        [GET_ASSOCIATED(lineAbstract, lineFillLayer) addAnimation:frameAnimation forKey:@"frameAnimation"];
        [GET_ASSOCIATED(lineAbstract, lineStringLayer) addAnimation:frameAnimation forKey:@"frameAnimation"];
        
//        CABasicAnimation * lineAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
//        lineAnimation.duration = duration;
//        lineAnimation.fromValue = @0;
//        lineAnimation.toValue = @1;
//        lineAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
//        [GET_ASSOCIATED(lineAbstract, lineLayer) addAnimation:lineAnimation forKey:@"lineStroke"];
//        
//        CAGradientLayer * shapeGradientLayer = GET_ASSOCIATED(lineAbstract, lineShapeGradientLayer);
//        CGRect fromRect = shapeGradientLayer.bounds;
//        fromRect.size.width = 0;
//        CGRect toRect = shapeGradientLayer.bounds;
//        
//        CABasicAnimation *shapeFrameAnimation = [CABasicAnimation animationWithKeyPath:@"bounds"];
//        shapeFrameAnimation.duration = duration;
//        shapeFrameAnimation.fromValue = [NSValue valueWithCGRect:fromRect];
//        shapeFrameAnimation.toValue = [NSValue valueWithCGRect:toRect];
//        shapeFrameAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
//        [shapeGradientLayer addAnimation:shapeFrameAnimation forKey:@"frameAnimations"];
//
//        CAGradientLayer * fillGradientLayer = GET_ASSOCIATED(lineAbstract, lineFillGradientLayer);
//        fromRect = fillGradientLayer.bounds;
//        fromRect.size.width = 0;
//        toRect = fillGradientLayer.bounds;
//        
//        CABasicAnimation *frameAnimation = [CABasicAnimation animationWithKeyPath:@"bounds"];
//        frameAnimation.duration = duration;
//        frameAnimation.fromValue = [NSValue valueWithCGRect:fromRect];
//        frameAnimation.toValue = [NSValue valueWithCGRect:toRect];
//        frameAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
//        [fillGradientLayer addAnimation:frameAnimation forKey:@"frameAnimations"];
//        
//        NSArray * numberRenderers = GET_ASSOCIATED(lineAbstract, lineNumberArray);
//        
//        for (NSInteger i = 0; i < numberRenderers.count; i++) {
//            
//            GGNumberRenderer * renderers = numberRenderers[i];
//            renderers.hidden = YES;
//            
//            [self performAfterDelay:i * duration / (numberRenderers.count - 1) block:^{
//                
//                renderers.hidden = NO;
//                
//                CALayer * layer = GET_ASSOCIATED(lineAbstract, lineStringLayer);
//                [layer setNeedsDisplay];
//            }];
//        }
    }
}

/**
 * 升起动画
 *
 * @param 动画时长
 */

- (void)startLineRiseAnimationWithDuration:(NSTimeInterval)duration
{
    NSMutableArray * aryAllNumberRenderers = [NSMutableArray array];
    
    for (id <LineDrawAbstract> lineAbstract in self.lineAbstractAry) {
        
        CGPoint * linePoints = [lineAbstract points];
        NSInteger size = [lineAbstract dataAry].count;
        CGFloat bottomPix = [lineAbstract bottomYPix];
        NSArray * numberRenderers = GET_ASSOCIATED(lineAbstract, lineNumberArray);
        
        if (numberRenderers) {
            
            for (NSInteger i = 0; i < [lineAbstract dataAry].count; i++) {
                
                GGNumberRenderer * renderer = numberRenderers[i];
                renderer.fromPoint = CGPointMake(renderer.toPoint.x, bottomPix);
                renderer.fromNumber = 0;
                [aryAllNumberRenderers addObject:renderer];
            }
        }
        
        GGShapeCanvas * anifillLayer = GET_ASSOCIATED(lineAbstract, lineFillLayer);
        
        if (anifillLayer) {
            
            CAKeyframeAnimation * fillAnimation = [CAKeyframeAnimation animationWithKeyPath:@"path"];
            fillAnimation.duration = duration;
            fillAnimation.values = GGPathFillLinesUpspringAnimation(linePoints, size, bottomPix);
            [anifillLayer addAnimation:fillAnimation forKey:@"fillAnimation"];
        }
        
        GGShapeCanvas * aniLineLayer = GET_ASSOCIATED(lineAbstract, lineLayer);
        
        if (aniLineLayer) {
            
            CAKeyframeAnimation * lineAnimation = [CAKeyframeAnimation animationWithKeyPath:@"path"];
            lineAnimation.duration = duration;
            lineAnimation.values = GGPathLinesUpspringAnimation(linePoints, size, bottomPix);
            [aniLineLayer addAnimation:lineAnimation forKey:@"lineAnimation"];
        }
        
        GGShapeCanvas * aniShapeLayer = GET_ASSOCIATED(lineAbstract, lineShapeLayer);
        
        if (aniShapeLayer) {
            
            CAKeyframeAnimation * pointAnimation = [CAKeyframeAnimation animationWithKeyPath:@"path"];
            pointAnimation.duration = duration;
            pointAnimation.values = GGPathCirclesUpspringAnimation(linePoints, [lineAbstract shapeRadius], size, bottomPix, [lineAbstract showShapeIndexSet]);
            [aniShapeLayer addAnimation:pointAnimation forKey:@"pointAnimation"];
        }
    }
    
    [self.animator startAnimationWithDuration:duration animationArray:aryAllNumberRenderers updateBlock:^(CGFloat progress) {
        
        for (id <LineDrawAbstract> lineDrawAbstract in self.lineAbstractAry) {
            
            [GET_ASSOCIATED(lineDrawAbstract, lineStringLayer) setNeedsDisplay];
        }
    }];
}

#pragma mark - Lazy

GGLazyGetMethod(NSMutableArray, lineAbstractAry);

/**
 * 动画类
 */
- (Animator *)animator
{
    if (_animator == nil) {
        
        _animator = [[Animator alloc] init];
        _animator.animationType = AnimationLinear;
    }
    
    return _animator;
}

@end
