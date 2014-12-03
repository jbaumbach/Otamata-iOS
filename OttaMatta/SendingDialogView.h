//
//  SendingDialogView.h
//  OttaMatta
//
//  Created by John Baumbach on 1/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SendingDialogViewItems.h"
#import "GlobalFunctions.h"
#import "Config.h"

typedef enum
{
    dtSpinner,
    dtProgressBar
} DialogType;


@protocol SendDialogViewComplete <NSObject>

-(void) sendCompleteWithStatus:(SendDialogStatusCode)status;

@optional
-(void) sendCompleteWithStatus:(SendDialogStatusCode)status forKey:(NSString *)key;
-(void) sendCompleteWithStatus:(SendDialogStatusCode)status forKey:(NSString *)key andObject:(id)object;

@end


//
// This object can be used to show a progress overlay.  Add these lines to your
// controller:
//
// SendingDialogView *view = [[SendingDialogView alloc] initWithFrame:parentController.view.frame];
// [parentController.view addSubview:view];
//
// Then, to dismiss:
//
// [parentController.view removeFromSuperview];
//

@interface SendingDialogView : UIView
{
    SendingDialogViewItems *_itemView;
}

@property (nonatomic) DialogType type;
@property (nonatomic, retain) NSMutableData *activeDownload;
@property (nonatomic, retain) NSURLConnection *imageConnection;
@property (nonatomic, retain) id<SendDialogViewComplete> delegate;
@property (nonatomic, retain) NSString *key;    // In case you have multiple dialogs on a single form, set this
@property (nonatomic) float progress;

-(void) dismissDialogWithStatus:(SendDialogStatusCode)status;
-(void) dismissDialogWithStatus:(SendDialogStatusCode)status andObject:(id)object;

+(SendDialogStatusCode) resultFromServerResponse:(NSDictionary *)jsonData;


@end
