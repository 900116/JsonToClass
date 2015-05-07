//
//  ViewController.m
//  Json2Class
//
//  Created by YongCheHui on 15/5/7.
//  Copyright (c) 2015年 FengHuang. All rights reserved.
//

#import "ViewController.h"
#import <CoreGraphics/CoreGraphics.h>
#import <unistd.h>

@interface ClassStringInfo : NSObject
@property(nonatomic,strong) NSMutableString *headStr;
@property(nonatomic,strong) NSMutableString *importStr;
@property(nonatomic,strong) NSMutableString *define;
@property(nonatomic,copy) NSString *name;
@property(nonatomic,copy) NSString *fileName;
@property(nonatomic,strong) NSMutableString *propertyStr;
+(instancetype)objWithType:(BOOL)HorM name:(NSString *)name;
@end

@implementation ClassStringInfo
+(instancetype)objWithType:(BOOL)HorM name:(NSString *)name
{
    ClassStringInfo *info = [[ClassStringInfo alloc]init];
    info.name = name;
    if (HorM) {
        info.fileName = [name stringByAppendingString:@".h"];
        info.importStr = [NSMutableString stringWithFormat:@"\n#import <Foundation/Foundation.h>"];
        info.define = [NSMutableString stringWithFormat:@"\n@interface %@:NSObject\n",name];
    }
    else
    {
        info.fileName = [name stringByAppendingString:@".m"];
        info.importStr = [NSMutableString stringWithFormat:@"\n#import \"%@.h\"",name];
        info.define = [NSMutableString stringWithFormat:@"\n@implementation %@\n",name];
    }
    
    info.headStr = [NSMutableString stringWithFormat:@"//\n//%@ \n//\n//\n//Create by ",info.fileName];
    NSString *userName = [(__bridge NSDictionary *)CGSessionCopyCurrentDictionary() objectForKey:(NSString*)kCGSessionUserNameKey];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yy/M/d";
    NSString *dateStr = [formatter stringFromDate:[NSDate new]];
    
    NSString *cpy = [NSString stringWithFormat:@"%@ on %@ \n//Copyright (c)",userName,dateStr];
    [info.headStr appendString:cpy];
    formatter.dateFormat = @"yyyy年";
    [info.headStr appendString:[NSString stringWithFormat:@" %@ %@. All rights reserved.\n//\n//",[formatter stringFromDate:[NSDate new]],userName]];
    
    info.propertyStr = [NSMutableString new];
    return info;
}

-(NSData *)dataContent
{
    NSString *string = [NSString stringWithFormat:@"%@%@%@%@\n@end",_headStr,_importStr,_define,_propertyStr];
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    return data;
}
@end

@interface ViewController()
{
    NSString *_path;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}

-(IBAction)OpenFileDialog:(id)sender
{
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseFiles:NO];
    [openDlg setCanChooseDirectories:YES];
    if([openDlg runModal] == NSModalResponseOK)
    {
        NSArray* files = [openDlg URLs];
        _path = [files[0] path];
    }
}

-(void)createModelWithDictionary:(NSDictionary *)dict name:(NSString *)className
{
    ClassStringInfo *hClassInfo = [ClassStringInfo objWithType:YES name:className];
    ClassStringInfo *mClassInfo = [ClassStringInfo objWithType:NO name:className];
    NSArray *allKeys = [dict allKeys];
    for (NSString *key in allKeys) {
        id  value = [dict objectForKey:key];
        if ([value isKindOfClass:[NSNumber class]]) {
            NSNumber *nValue = value;
            CGFloat fValue = nValue.doubleValue;
            if (fValue == (int)fValue) {
                //整形
                [hClassInfo.propertyStr  appendFormat:@"@property (nonatomic,assign) NSInteger %@;\n",key];
            }
            else
            {
                [hClassInfo.propertyStr  appendFormat:@"@property (nonatomic,assign) CGFloat %@;\n",key];
            }
        }
        else if([value isKindOfClass:[NSString class]])
        {
            [hClassInfo.propertyStr appendFormat:@"@property (nonatomic,copy) NSString *%@;\n",key];
        }
        else if([value isKindOfClass:[NSArray class]])
        {
            [hClassInfo.propertyStr appendFormat:@"@property (nonatomic,copy) NSArray *%@;\n",key];
            NSArray *array = value;
            if (array.count > 0) {
                if ([array[0] isKindOfClass:[NSDictionary class]]) {
                    char p = [key characterAtIndex:0];
                    char P = p - 32;
                    NSString *largeKey = [key stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%c",p] withString:[NSString stringWithFormat:@"%c",P] options:0 range:NSMakeRange(0, 1)];
                    largeKey =  [NSString stringWithFormat:@"%@%@",className,largeKey];
                    [self createModelWithDictionary:array[0] name:largeKey];
                }
            }
        }
        else if([value isKindOfClass:[NSDictionary class]])
        {
            char p = [key characterAtIndex:0];
            char P = p - 32;

            NSString *largeKey = [key stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%c",p] withString:[NSString stringWithFormat:@"%c",P] options:0 range:NSMakeRange(0, 1)];
            largeKey =  [NSString stringWithFormat:@"%@%@",className,largeKey];
            [hClassInfo.propertyStr appendFormat:@"@property (nonatomic,strong) %@ *%@;\n",largeKey,key];
            [hClassInfo.importStr appendFormat:@"\n#import \"%@.h\"",largeKey];
            [self createModelWithDictionary:value name:largeKey];
        }
    }

    NSData *hData = [hClassInfo dataContent];
    NSData *mData = [mClassInfo dataContent];
    
    if (!_path) {
        NSString*bundel=[[NSBundle mainBundle] resourcePath];
        NSString*deskTopLocation=[[bundel substringToIndex:[bundel rangeOfString:@"Library"].location] stringByAppendingFormat:@"Desktop"];
        _path = deskTopLocation;
    }
    NSString *hPath = [_path stringByAppendingPathComponent:hClassInfo.fileName];
    NSString *mPath = [_path stringByAppendingPathComponent:mClassInfo.fileName];
    
    [hData writeToFile:hPath atomically:YES];
    [mData writeToFile:mPath atomically:YES];
}

-(IBAction)generate:(id)sender
{
    NSString *jsonStr = _jsonTF.string;
    NSData *jd = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jd options:NSJSONReadingAllowFragments error:&error];
    if (error) {
        NSAlert *alert = [[NSAlert alloc]init];
        alert.messageText = @"错误";
        alert.informativeText = @"不是json!!!";
        [alert setAlertStyle:NSInformationalAlertStyle];
        [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
            
        }];
    }
    else
    {
        NSString *className = _nameTF.stringValue;
        if (!className || [className isEqualToString:@""]) {
            className = @"Default";
        }
        [self createModelWithDictionary:dict name:className];
    }
}

@end
