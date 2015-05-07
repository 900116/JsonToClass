//
//  JCTextView.m
//  Json2Class
//
//  Created by YongCheHui on 15/5/7.
//  Copyright (c) 2015年 FengHuang. All rights reserved.
//

#import "JCTextView.h"

@implementation JCTextView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(void)mouseDown:(NSEvent *)theEvent
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self.string = @"";
        self.font = [NSFont systemFontOfSize:15];
    });
}
@end
