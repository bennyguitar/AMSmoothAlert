//
//  AMSmoothAlertView.m
//  AMSmoothAlertViewDemo
//
//  Created by AMarliac on 2014-04-24.
//  Contributor: Everest Liu
//  Copyright (c) 2014 AMarliac. All rights reserved.
//

#import "AMSmoothAlertView.h"



@implementation AMSmoothAlertView
{
    UIView *alertView;
    AMBouncingView *circleView;
    UIImageView * bg;
    GPUImageiOSBlurFilter *_blurFilter;
}

- (id) initDropAlertWithTitle:(NSString*) title andText:(NSString*) text andCancelButton:(BOOL)hasCancelButton forAlertType:(AlertType) type size:(CGSize)size buttons:(NSArray *)btns
{
    return [self initDropAlertWithTitle:title andText:text andCancelButton:hasCancelButton forAlertType:type andColor:nil size:size buttons:btns];
}

- (id) initDropAlertWithTitle:(NSString*) title andText:(NSString*) text andCancelButton:(BOOL)hasCancelButton forAlertType:(AlertType) type andColor:(UIColor*) color size:(CGSize)size buttons:(NSArray *)btns
{
    self = [super init];
    if (self) {
        // Initialization code
        _animationType = DropAnimation;
        [self _initViewWithTitle:title andText:text andCancelButton:hasCancelButton forAlertType:type andColor:color size:size buttons:btns];
    }
    return self;
}


- (id) initFadeAlertWithTitle:(NSString*) title andText:(NSString*) text andCancelButton:(BOOL)hasCancelButton forAlertType:(AlertType) type size:(CGSize)size buttons:(NSArray *)btns
{
    return [self initFadeAlertWithTitle:title andText:text andCancelButton:hasCancelButton forAlertType:type andColor:nil size:size buttons:btns];
}

- (id) initFadeAlertWithTitle:(NSString*) title andText:(NSString*) text andCancelButton:(BOOL)hasCancelButton forAlertType:(AlertType) type andColor:(UIColor*) color size:(CGSize)size buttons:(NSArray *)btns
{
    self = [super init];
    if (self) {
        // Initialization code
        _animationType = FadeInAnimation;
        [self _initViewWithTitle:title andText:text andCancelButton:hasCancelButton forAlertType:type andColor:color size:size buttons:btns];
    }
    return self;
}

// init with completion blocks

- (id) initDropAlertWithTitle:(NSString*) title andText:(NSString*) text andCancelButton:(BOOL)hasCancelButton forAlertType:(AlertType) type size:(CGSize)size buttons:(NSArray *)btns withCompletionHandler:(dismissAlertWithButton) completionHandler
{
    self.completionBlock = completionHandler;
    return [self initDropAlertWithTitle:title andText:text andCancelButton:hasCancelButton forAlertType:type andColor:nil size:size buttons:btns];
}

- (id) initDropAlertWithTitle:(NSString*) title andText:(NSString*) text andCancelButton:(BOOL)hasCancelButton forAlertType:(AlertType) type andColor:(UIColor*) color size:(CGSize)size buttons:(NSArray *)btns withCompletionHandler:(dismissAlertWithButton) completionHandler
{
    self = [super init];
    if (self) {
        // Initialization code
        self.completionBlock = completionHandler;
        _animationType = DropAnimation;
        [self _initViewWithTitle:title andText:text andCancelButton:hasCancelButton forAlertType:type andColor:color size:size buttons:btns];
    }
    return self;
}


- (id) initFadeAlertWithTitle:(NSString*) title andText:(NSString*) text andCancelButton:(BOOL)hasCancelButton forAlertType:(AlertType) type size:(CGSize)size buttons:(NSArray *)btns withCompletionHandler:(dismissAlertWithButton) completionHandler
{
    self.completionBlock = completionHandler;
    return [self initFadeAlertWithTitle:title andText:text andCancelButton:hasCancelButton forAlertType:type andColor:nil size:size buttons:btns];
}

- (id) initFadeAlertWithTitle:(NSString*) title andText:(NSString*) text andCancelButton:(BOOL)hasCancelButton forAlertType:(AlertType) type andColor:(UIColor*) color size:(CGSize)size buttons:(NSArray *)btns withCompletionHandler:(dismissAlertWithButton) completionHandler
{
    self = [super init];
    if (self) {
        // Initialization code
        self.completionBlock = completionHandler;
        _animationType = FadeInAnimation;
        [self _initViewWithTitle:title andText:text andCancelButton:hasCancelButton forAlertType:type andColor:color size:size buttons:btns];
    }
    return self;
}


- (void) _initViewWithTitle:(NSString *)title andText:(NSString *)text andCancelButton:(BOOL)hasCancelButton forAlertType:(AlertType)type andColor:(UIColor*) color size:(CGSize)size buttons:(NSArray *)btns
{
    self.frame = [self screenFrame];
    self.opaque = YES;
    self.alpha = 1;
    
    self.alertSize = size;
  
    _blurFilter = [[GPUImageiOSBlurFilter alloc] init];
    _blurFilter.blurRadiusInPixels = 2.0;
  
    bg = [[UIImageView alloc]initWithFrame:[self screenFrame]];
  
    alertView = [self alertPopupView];
  
    [self labelSetupWithTitle:title andText:text];
    [self buttonSetupForType:type withCancelButton: hasCancelButton andColor:color buttons:btns];
    alertView.center = self.center;
    [self addSubview:alertView];
    [self circleSetupForAlertType:type andColor:color];
}


- (UIView*) alertPopupView
{
    UIView * alertSquare = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.alertSize.width, self.alertSize.height)];
    
    alertSquare.backgroundColor = [UIColor colorWithRed:0.937 green:0.937 blue:0.937 alpha:1];
    alertSquare.center = CGPointMake([self screenFrame].size.width/2, -[self screenFrame].size.height/2);
    
    [alertSquare.layer setShadowColor:[UIColor blackColor].CGColor];
    [alertSquare.layer setShadowOpacity:0.4];
    [alertSquare.layer setShadowRadius:20.0f];
    [alertSquare.layer setShadowOffset:CGSizeMake(0.0, 0.0)];
    
    [self performScreenshotAndBlur];
    
    return alertSquare;
}


- (void) show
{
	id<AMSmoothAlertViewDelegate> delegate = self.delegate;
	if ([delegate respondsToSelector:@selector(alertViewWillShow:)]) [delegate alertViewWillShow:self];

    switch (_animationType) {
        case DropAnimation:
            [self triggerDropAnimations];
            break;
        case FadeInAnimation:
            [self triggerFadeAnimations];
            break;
            
        default:
            break;
    }
    [[[[UIApplication sharedApplication] delegate] window] addSubview:self];
}

#pragma mark - Blur

-(void) performScreenshotAndBlur
{
    UIImage * image = [self convertViewToImage];
    UIImage *blurredSnapshotImage = [_blurFilter imageByFilteringImage:image];
    
    [bg setImage:blurredSnapshotImage];
    bg.alpha = 0.0;
    
    [self addSubview:bg];
}


#pragma mark - Items Setup

- (void) circleSetupForAlertType:(AlertType) type andColor:(UIColor*) color
{
    UIView * circleMask = [[UIView alloc]initWithFrame:CGRectMake([self screenFrame].size.width/2, (([self screenFrame].size.height/2)-alertView.frame.size.height/2) , 60, 60)];
    circleView = [[AMBouncingView alloc]initSuccessCircleWithFrame:CGRectMake(0, 0, 0, 0) andImageSize:60 forAlertType:type andColor:color];
    
    _logoView = [[UIImageView alloc]initWithFrame:CGRectMake(circleMask.frame.size.width/2-30, circleMask.frame.size.height/2-30 , 0, 0)];
    
    switch (type) {
        case AlertSuccess:
            [_logoView setImage:[UIImage imageNamed:@"checkMark.png"]];
            break;
        case AlertFailure:
            [_logoView setImage:[UIImage imageNamed:@"crossMark.png"]];
            break;
        case AlertInfo:
            [_logoView setImage:[UIImage imageNamed:@"info.png"]];
            break;

        default:
            break;
    }
    _logoView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [self addSubview:circleMask];
    [circleMask addSubview:circleView];
    [circleMask addSubview:_logoView];
}

- (void) labelSetupWithTitle:(NSString*) title andText:(NSString*) text
{
    _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, self.alertSize.width - 20, 30)];
    _titleLabel.text = title;
    _titleLabel.font = [UIFont fontWithName:@"AvenirNext-Italic" size:24.0f];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    CGSize titleSize = [self sizeOfText:title withFont:_titleLabel.font];
    _titleLabel.frame = CGRectMake(0, 40, self.alertSize.width, titleSize.height);
    [alertView addSubview:_titleLabel];
    
    
    _textLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.alertSize.width - 20, 50)];
    _textLabel.text = text;
    _textLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:16.0f];
    CGSize textSize = [self sizeOfText:text withFont:_textLabel.font];
    _textLabel.frame = CGRectMake(10, _titleLabel.frame.origin.y + _titleLabel.frame.size.height + 10, self.alertSize.width - 20, textSize.height);
    _textLabel.textAlignment = NSTextAlignmentCenter;
    _textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _textLabel.numberOfLines = 0;
    [alertView addSubview:_textLabel];
    
}

- (CGSize)sizeOfText:(NSString *)text withFont:(UIFont *)font {
    NSDictionary *attributes = @{NSFontAttributeName:font,
                                 NSParagraphStyleAttributeName:[NSParagraphStyle defaultParagraphStyle]};
    CGRect boundingRect = [text boundingRectWithSize:CGSizeMake(self.alertSize.width - 20, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    return CGSizeMake(ceilf(boundingRect.size.width), ceilf(boundingRect.size.height));
}

- (void) buttonSetupForType:(AlertType)type withCancelButton:(BOOL) hasCancelButton andColor:(UIColor*) color buttons:(NSArray *)btns
{
    float runningY = _textLabel.frame.origin.y + _textLabel.frame.size.height + 20;
    UIFont *btnFont = [UIFont fontWithName:@"AvenirNext-Regular" size:21.0f];
    
    for (NSInteger xx = 0; xx < btns.count; xx++) {
        NSString *title = btns[xx];
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(20, runningY, self.alertSize.width - 40, 40)];
        [self setColorForButton:color onButton:btn withType:type];
        [btn.layer setCornerRadius:8];
        btn.titleLabel.textColor = [UIColor whiteColor];
        btn.titleLabel.font = btnFont;
        btn.tag = xx;
        [btn setTitle:title forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(handleButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        [alertView addSubview:btn];
        runningY += btn.frame.size.height + 10;
    }
    
    if (hasCancelButton || !btns) {
        //cancel button
        _cancelButton = [[UIButton alloc]initWithFrame:CGRectMake(20, runningY, self.alertSize.width - 40, 40)];
        _cancelButton.backgroundColor = [UIColor colorWithRed:0.792 green:0.792 blue:0.792 alpha:1];
        
        [_cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        _cancelButton.titleLabel.textColor = [UIColor whiteColor];
        _cancelButton.titleLabel.font = btnFont;
		[_cancelButton addTarget:self action:@selector(handleButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        [_cancelButton.layer setCornerRadius:8.0f];
        [alertView addSubview:_cancelButton];
        runningY += 60;
    }
    
    alertView.frame = CGRectMake(0, 0, _alertSize.width, runningY);
}


- (void) setColorForButton:(UIColor*) color onButton:(UIButton*) btn withType:(AlertType)type
{
    if (color)
    {
        btn.backgroundColor = color;
    }
    else
    {
        switch (type) {
            case AlertSuccess:
                btn.backgroundColor = GREENCOLOR;
                break;
            case AlertFailure:
                btn.backgroundColor = REDCOLOR;
                break;
            case AlertInfo:
                btn.backgroundColor = BLUECOLOR;
                break;
                
            default:
                break;
        }
    }
    
}

- (void) setTitleFont:(UIFont *)titleFont
{
    [_titleLabel setFont:titleFont];
}

- (void) setTextFont:(UIFont *)textFont
{
    [_textLabel setFont:textFont];
}

-(void) setTitleText:(NSString*) string
{
    _titleLabel.text = string;
}

-(void) setMessageText:(NSString*) string
{
    _textLabel.text = string;
}

#pragma mark - Animations

-(void) triggerDropAnimations
{
 
    NSMutableArray* animationBlocks = [NSMutableArray new];
    
    typedef void(^animationBlock)(BOOL);
    
    // getNextAnimation
    // removes the first block in the queue and returns it
    animationBlock (^getNextAnimation)() = ^{
        animationBlock block = animationBlocks.count ? (animationBlock)[animationBlocks objectAtIndex:0] : nil;
        if (block){
            [animationBlocks removeObjectAtIndex:0];
            return block;
        }else{
            return ^(BOOL finished){};
        }
    };
    
    //block 1
    [animationBlocks addObject:^(BOOL finished){;
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            bg.alpha = 1.0;
        } completion: getNextAnimation()];
    }];
    
    //block 2
    [animationBlocks addObject:^(BOOL finished){;
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            alertView.center = CGPointMake([self screenFrame].size.width/2, ([self screenFrame].size.height/2)+alertView.frame.size.height*0.1);
        } completion: getNextAnimation()];
    }];
    
    //block 3
    [animationBlocks addObject:^(BOOL finished){;
        [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            alertView.center = CGPointMake([self screenFrame].size.width/2, ([self screenFrame].size.height/2));
        } completion: getNextAnimation()];
    }];
    
    //add a block to our queue
    [animationBlocks addObject:^(BOOL finished){;
        [self circleAnimation];
    }];
    
    // execute the first block in the queue
    getNextAnimation()(YES);
}



-(void) triggerFadeAnimations
{
 
    alertView.alpha = 0;
    alertView.center = CGPointMake([self screenFrame].size.width/2, ([self screenFrame].size.height/2));

    NSMutableArray* animationBlocks = [NSMutableArray new];
    
    typedef void(^animationBlock)(BOOL);
    
    // getNextAnimation
    // removes the first block in the queue and returns it
    animationBlock (^getNextAnimation)() = ^{
        animationBlock block = animationBlocks.count ? (animationBlock)[animationBlocks objectAtIndex:0] : nil;
        if (block){
            [animationBlocks removeObjectAtIndex:0];
            return block;
        }else{
            return ^(BOOL finished){};
        }
    };
    
    //block 1
    [animationBlocks addObject:^(BOOL finished){;
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            bg.alpha = 1.0;
        } completion: getNextAnimation()];
    }];
    
    //block 2
    [animationBlocks addObject:^(BOOL finished){;
        [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            alertView.alpha = 1;
        } completion: getNextAnimation()];
    }];
    
    //add a block to our queue
    [animationBlocks addObject:^(BOOL finished){;
        [self circleAnimation];
    }];
    
    // execute the first block in the queue
    getNextAnimation()(YES);
    
}

- (void) circleAnimation
{
    NSMutableArray* animationBlocks = [NSMutableArray new];
    
    typedef void(^animationBlock)(BOOL);
    
    // getNextAnimation
    // removes the first block in the queue and returns it
    animationBlock (^getNextAnimation)() = ^{
        animationBlock block = animationBlocks.count ? (animationBlock)[animationBlocks objectAtIndex:0] : nil;
        if (block){
            [animationBlocks removeObjectAtIndex:0];
            return block;
        }else{
            return ^(BOOL finished){};
        }
    };
    
    //block 1
    [animationBlocks addObject:^(BOOL finished){;
        [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            circleView.frame = [circleView newFrameWithWidth:85 andHeight:85];
            _logoView.frame = [self newFrameForView:_logoView withWidth:40 andHeight:40];
        } completion: getNextAnimation()];
    }];
    
    //block 2
    [animationBlocks addObject:^(BOOL finished){;
        [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            circleView.frame = [circleView newFrameWithWidth:50 andHeight:50];
            _logoView.frame = [self newFrameForView:_logoView withWidth:15 andHeight:15];
        } completion: getNextAnimation()];
    }];
    
    //block 3
    [animationBlocks addObject:^(BOOL finished){;
        [UIView animateWithDuration:0.05 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            circleView.frame = [circleView newFrameWithWidth:60 andHeight:60];
            _logoView.frame = [self newFrameForView:_logoView withWidth:20 andHeight:20];
        } completion: getNextAnimation()];
    }];
    
    //add a block to our queue
    [animationBlocks addObject:^(BOOL finished){;
        self.isDisplayed = true;
		id<AMSmoothAlertViewDelegate> delegate = self.delegate;
		if ([delegate respondsToSelector:@selector(alertViewDidShow:)]) [delegate alertViewDidShow:self];
    }];
    
    // execute the first block in the queue
    getNextAnimation()(YES);
}


- (void) dismissAlertView
{
	id<AMSmoothAlertViewDelegate> delegate = self.delegate;
	if ([delegate respondsToSelector:@selector(alertViewWillDismiss:)]) [delegate alertViewWillDismiss:self];
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         [self removeFromSuperview];
                         self.isDisplayed = false;
						 if ([delegate respondsToSelector:@selector(alertViewDidDismiss:)]) [delegate alertViewDidDismiss:self];
                     }];
}


#pragma mark - Miscellaneous

- (void) setCornerRadius:(float)cornerRadius
{
    [alertView.layer setCornerRadius:cornerRadius];
}


- (CGRect) screenFrame
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    return screenRect;
}


-(UIImage *)convertViewToImage
{
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    CGRect rect = [keyWindow bounds];
    UIGraphicsBeginImageContextWithOptions(rect.size,YES,0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [keyWindow.layer renderInContext:context];
    UIImage *capturedScreen = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return capturedScreen;
}

- (CGRect) newFrameForView:(UIView*) uiview withWidth:(float) width andHeight:(float) height
{
    return CGRectMake(uiview.frame.origin.x + ((uiview.frame.size.width - width)/2),
                      uiview.frame.origin.y + ((uiview.frame.size.height - height)/2),
                      width,
                      height);
}

#pragma mark - Delegate Methods
- (void)handleButtonTouched:(id)sender {
	[self dismissAlertView];

	id<AMSmoothAlertViewDelegate> delegate = self.delegate;
	UIButton *button = (UIButton *) sender;
    if (sender != _cancelButton) {
        if ([delegate respondsToSelector:@selector(alertView:didDismissWithButton:)]) {
            // Since there isn't a button index for the alertView, pass the button
            [delegate alertView:self didDismissWithButton:button];
        }
    }
    
    if(self.completionBlock) {
        self.completionBlock(self, button);
    }
}

@end
