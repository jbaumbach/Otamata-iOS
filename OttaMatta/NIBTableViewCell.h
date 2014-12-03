//
//  NIBTableViewCell.h
//  Otamata
//
//  Created by John Baumbach on 2/12/12.
//  Copyright (c) 2012 Ergocentric Software, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 
 Use this class to set the reuseIdentifier outside of the
 init function.  Apple has made the property read-only by default, but
 you can set this "reuseIdentifierSpecial" property and the class
 will return this value when the table view cell wants to dequeue.
 
 Also, when initing these cells in your cellforrow function, do NOT
 autorelease the cell.  It will then soon be zombie time.
 
 */
@interface NIBTableViewCell : UITableViewCell
@property (nonatomic, copy) NSString *reuseIdentifierSpecial;

@end
