//
//  ViewController.h
//  Json2Class
//
//  Created by YongCheHui on 15/5/7.
//  Copyright (c) 2015年 FengHuang. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController
@property(nonatomic,strong) IBOutlet NSTextView *jsonTF;
@property (nonatomic,weak) IBOutlet NSTextField *nameTF;
@property (weak) IBOutlet NSSegmentedControl *descrptionSeg;
@property (weak) IBOutlet NSSegmentedControl *codingSeg;
@property (weak) IBOutlet NSSegmentedControl *mjArraySeg;

-(IBAction)generate:(id)sender;
-(IBAction)OpenFileDialog:(id)sender;
@end

