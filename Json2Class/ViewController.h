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
@property (weak) IBOutlet NSTextField *nameTF;
-(IBAction)generate:(id)sender;
-(IBAction)OpenFileDialog:(id)sender;
@end

