//
//  MultiViewHelper.h
//  Otamata
//
//  Created by John Baumbach on 8/13/12.
//  Copyright (c) 2012 Ergocentric Software, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**********************************************************************

 To use:
 
 1. Add an instance of this class as a property.
 2. Create an enum to hold all the views you want to set up.
 3. In your NIB, the views can be outside the main view.  This 
    makes them easy to edit.  This class will stack them 
    and resize them to fit the parent view.
 4. Init it in your viewDidLoad, passing self.view and the
    enum of the page to display by default.
 5. Also in viewDidLoad pass all your views in via the "addPage" function.
 6. Show/hide your pages as you wish by calling the "setViewStatus"
    function and pass in your enum value.
 
**********************************************************************/

@interface MultiViewHelper : NSObject

//
// Instance properties
//
@property (nonatomic, retain) NSMutableDictionary *pages;
@property (nonatomic, retain) UIView *parentView;
@property int defaultKey;

//
// Instance methods
//
-(id)initWithParent:(UIView *)parent andInitialView:(int)key;
-(void) setViewStatus:(int)key;
-(void) addPage:(UIView *)view withKey:(int)key;

@end
