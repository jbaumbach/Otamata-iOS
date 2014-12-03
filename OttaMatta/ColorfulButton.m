#import "ColorfulButton.h"

@implementation ColorfulButton

@synthesize highColor = _highColor;
@synthesize lowColor = _lowColor;
@synthesize gradientLayer;
@synthesize cornerRadius = _cornerRadius;

-(void)buttonDown
{
    DLog(@"Button down!");
    
    [self setNeedsDisplay];
}

-(void)buttonUp
{
    DLog(@"Button up!");
    
    
    [self setHighlighted:NO];
    [self setNeedsDisplay];
}

- (void)awakeFromNib;
{
    gradientLayer = [[CAGradientLayer alloc] init];
    [gradientLayer setBounds:[self bounds]];
    [gradientLayer setPosition:CGPointMake([self bounds].size.width/2, [self bounds].size.height/2)];
    
    [[self layer] insertSublayer:gradientLayer atIndex:0];

    _cornerRadius = 6.0f;
    
    [[self layer] setCornerRadius:_cornerRadius];
    [[self layer] setMasksToBounds:YES];
    [[self layer] setBorderWidth:1.0f];
    
    UIColor *backgroundColor = [self backgroundColor];
    int pct = 45;
    
    self.highColor = [backgroundColor colorAdjustedByPercent:pct];
    self.lowColor = [backgroundColor colorAdjustedByPercent:pct * -1];
    
    [self addTarget:self action:@selector(buttonDown) forControlEvents:UIControlEventTouchDown];
    [self addTarget:self action:@selector(buttonUp) forControlEvents:UIControlEventTouchUpInside];
}

- (void)drawRect:(CGRect)rect;
{
    if ([self isHighlighted])
    {
        //
        // We're kind of hijacking the highlighted event here. We want
        // to show that the button has been pressed.
        //
        // Probably the best way to do this would be to create the 
        // graphics on startup and store them in the button.  Then
        // let the OS do all this work.  It'll be cleaner.
        //
        int pct = 25;
        
        UIColor *selectedHighColor = [_highColor colorAdjustedByPercent:pct * -1];
        UIColor *selectedLowColor = [_lowColor colorAdjustedByPercent:pct * -1];
        
        [gradientLayer setColors:[NSArray arrayWithObjects:(id)[selectedHighColor CGColor], (id)[selectedLowColor CGColor], nil]];
    }
    else 
    if ([self isEnabled])
    {
        if (_highColor && _lowColor)
        {
            [gradientLayer setColors:[NSArray arrayWithObjects:(id)[_highColor CGColor], (id)[_lowColor CGColor], nil]];
        }
    }
    else 
    {
        UIColor *disabledColor = [UIColor colorWithHexString:@"cccccc"];
        int pct = 45;
        
        UIColor *disabledHighColor = [disabledColor colorAdjustedByPercent:pct];
        UIColor *disabledLowColor = [disabledColor colorAdjustedByPercent:pct * -1];

        [gradientLayer setColors:[NSArray arrayWithObjects:(id)[disabledHighColor CGColor], (id)[disabledLowColor CGColor], nil]];
    }
    [super drawRect:rect];
}

- (void)setHighColor:(UIColor*)color;
{
    [_highColor release];
    _highColor = [color retain];
    [[self layer] setNeedsDisplay];
}

- (void)setLowColor:(UIColor*)color;
{
    [_lowColor release];
    _lowColor = [color retain];
    [[self layer] setNeedsDisplay];
}

-(void)setCornerRadius:(float)cornerRadius
{
    _cornerRadius = cornerRadius;
    [[self layer] setCornerRadius:_cornerRadius];
    [[self layer] setNeedsDisplay];
}


- (void)dealloc {
    [_highColor release];
    [_lowColor release];
    [gradientLayer release];
    [super dealloc];
}

@end

