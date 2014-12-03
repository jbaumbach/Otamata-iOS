//
//  SoundInfoControl.h
//  Otamata
//
//  Created by John Baumbach on 6/3/12.
//  Copyright (c) 2012 Ergocentric Software, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SoundIconView.h"
#import "Sound.h"

/************************************************************************

 How to use this control
 
 1. In your nib, drag a view into the place where you want this control.
    Get the dimensions about right: 320 x 100.
 2. Control-drag an outlet to your view controller's .h and name it 
    something interesting like "soundInfoHolder".  
 3. Manually create a property in your .h and .m of type SoundInfoControl and call it something interesting like "soundInfoControl".
 4. Add this code to your view controller's ViewDidLoad method:
 
     //
     // Create a sound info control and set it into our placeholder view
     //
     self.soundInfoControl = [GlobalFunctions initClassFromNib:[SoundInfoControl class]];
     self.soundInfoControl.sound = self.sound;  // <=-- sound to use
     [soundInfoHolder addSubview:self.soundInfoControl];

 5. Boom.
 
************************************************************************/


@interface SoundInfoControl : UIView
    <SoundIconViewProtocol>

//
// Instance properties
//
@property (nonatomic, retain) Sound *sound;

//
// UI elements
//
@property (retain, nonatomic) IBOutlet SoundIconView *icon;
@property (retain, nonatomic) IBOutlet UILabel *nameLabel;
@property (retain, nonatomic) IBOutlet UILabel *descriptionLabel;
@end
