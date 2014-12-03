//
//  IconViewContainer.m
//  JohnsNavBasedProject
//
//  Created by John Baumbach on 12/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "IconViewContainer.h"
#import "GlobalFunctions.h"

@implementation IconViewContainer
@synthesize itemList;
@synthesize delegate;
@synthesize padding;
@synthesize iconCornerRadius;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self commonIniter];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self commonIniter];
    }
    return self;
}

-(void)commonIniter
{
    [self drawView];
    self.padding = 3.0f;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void) dealloc
{
    self.delegate = nil;
    self.itemList = nil;
    
    [super dealloc];
}

-(void)setItemList:(NSMutableArray *)newItemList
{
    //DLog(@"In manual setter for iconlist!");
    
    [itemList release];
    itemList = [newItemList retain];
    [self drawView];
}

//
// find optimal (largest) tile size for which
// at least N tiles fit in WxH rectangle
// http://stackoverflow.com/questions/3859891/algorithm-for-maximizing-coverage-of-rectangular-area-with-scaling-tiles
//
double optimal_size (double W, double H, int N)
{
    int i_min, j_min ; // minimum values for which you get at least N tiles 
    for (int i=round(sqrt(N*W/H)) ; ; i++) {
        if (i*floor(H*i/W) >= N) {
            i_min = i ;
            break ;
        }
    }
    for (int j=round(sqrt(N*H/W)) ; ; j++) {
        if (floor(W*j/H)*j >= N) {
            j_min = j ;
            break ;
        }
    }
    //return std::max (W/i_min, H/j_min) ;
    return fmax(W/i_min, H/j_min);
    
}

-(void) drawView
{
    [[self subviews] makeObjectsPerformSelector: @selector(removeFromSuperview)];
    if (itemList != nil && [itemList count] > 0)
    {
        CGRect mainRect = self.frame;
        
        float squareSize = optimal_size(mainRect.size.width, mainRect.size.height, itemList.count);
        
        float currentX = 0.0f;
        float currentY = 0.0f;
        
        float itemSquareSize = squareSize - (2 * padding);
        
        //
        // Find required padding.  First get the # of rows and columms.
        //
        int columns = 0;
        int rows = 0;
        
        for (columns = 0; columns < itemList.count; columns++)
        {
            if ((currentX + squareSize) > mainRect.size.width)
            {
                break;
            }
            else
            {
                currentX += squareSize;
            }
        }
        
        //
        // Get all the leftover values, then divide to find the new spacing.
        //
        float leftoverWidth = mainRect.size.width - (squareSize * columns);
        float spaceBetweenColumns = columns > 1 ? leftoverWidth / (columns - 1) : 0;
        
        //
        // We're good on the div by zero error here - but should test to make the Analyzer happy.
        // 
        rows = itemList.count / columns;
        if (itemList.count % columns != 0)
        {
            rows++;
        }
        
        //
        // Put the items into the box at the right position and size
        //
        currentX = 0.0f;
        int row = 1;
        int column = 1;
        for (NSObject *item in itemList)
        {
            UIView *subView;
            
            CGRect targetFrame = CGRectMake(currentX + padding + (columns == 1 ? leftoverWidth / 2 : 0), 
                                            currentY + padding, 
                                            itemSquareSize, 
                                            itemSquareSize);
            
            if (delegate && [delegate respondsToSelector:@selector(iconViewForItem:withFrame:)])
            {
                
                subView = [delegate iconViewForItem:item withFrame:targetFrame];
            }
            else
            {
                subView = [[[UIView alloc] initWithFrame:targetFrame] autorelease];
                subView.backgroundColor = [UIColor redColor];
            }
            
            [self addSubview:subView];
            
            //
            // Look two ahead since we already wrote the current square out
            //
            if ((currentX + (squareSize * 2)) > mainRect.size.width)
            {
                currentX = 0.0f;
                currentY += squareSize;     //+ (paddingVertical * 2);
                column = 1;
                row++;
            }
            else
            {
                currentX += squareSize + spaceBetweenColumns;     //+ (paddingHorizontal * 2);
                column++;
            }
        }
    }
    else
    {
        DLog(@"No items in list!");
    }
}
@end
