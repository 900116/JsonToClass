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
@property(nonatomic,strong) NSMutableString *methodStr;
@end

@implementation ClassStringInfo

+(instancetype)objWithType:(BOOL)HorM name:(NSString *)name coding:(BOOL)coding
{
    ClassStringInfo *info = [[ClassStringInfo alloc]init];
    info.name = name;
    if (HorM) {
        info.fileName = [name stringByAppendingString:@".h"];
        info.importStr = [NSMutableString stringWithFormat:@"\n#import <Foundation/Foundation.h>\n#import <UIKit/UIKit.h>"];
        info.define = [NSMutableString stringWithFormat:@"\n@interface %@:NSObject%@\n",name,coding?@"<NSCoding>":@""];
        info.methodStr = [NSMutableString string];
    }
    else
    {
        info.fileName = [name stringByAppendingString:@".m"];
        info.importStr = [NSMutableString stringWithFormat:@"\n#import \"%@.h\"",name];
        info.define = [NSMutableString stringWithFormat:@"\n@implementation %@\n",name];
        info.methodStr = [NSMutableString stringWithFormat:@"\n-(instancetype)init{\n"];
        [info.methodStr appendString:@"\tself = [super init];\n\tif(self){\n\n\t}\n\treturn self;\n}\n"];
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
    NSString *string = [NSString stringWithFormat:@"%@%@%@%@%@\n@end",_headStr,_importStr,_define,_methodStr,_propertyStr];
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    return data;
}

-(void)saveWithPath:(NSString *)path
{
    NSData *data = [self dataContent];
    if (!path) {
        NSString*bundel=[[NSBundle mainBundle] resourcePath];
        NSString*deskTopLocation=[[bundel substringToIndex:[bundel rangeOfString:@"Library"].location] stringByAppendingFormat:@"Desktop"];
        path = deskTopLocation;
    }
    NSString *finalPath = [path stringByAppendingPathComponent:self.fileName];
    [data writeToFile:finalPath atomically:YES];
}
@end

typedef NS_ENUM(int, PropertyType)
{
    PropertyTypeInteger,
    PropertyTypeFloat,
    PropertyTypeDouble,
    PropertyTypeString,
    PropertyTypeArray,
    PropertyTypeDictionary
};

@interface PropertyInfo : NSObject
@property(nonatomic,copy) NSString *propertyStr;

@property(nonatomic,copy) NSString *descriptionHead;
@property(nonatomic,copy) NSString *descriptionTail;

@property(nonatomic,copy) NSString *decodeStr;
@property(nonatomic,copy) NSString *encodeStr;

-(void)setType:(PropertyType)type key:(NSString *)key;
@end

@implementation PropertyInfo
-(void)setPropertyWithClassName:(NSString *)className key:(NSString *)key
{
    NSString * propertyStr = [NSString stringWithFormat:@"@property (nonatomic,strong) %@ *%@;\n",className,key];
    NSString * formatKey = @"%@";
    NSString * decodeMethod = @"decodeObjectForKey:";
    NSString * encodeMethod = @"encodeObject:";
    
    NSString *desHead = [NSString stringWithFormat:@"%@:%@",key,formatKey];
    NSString *desTail = [NSString stringWithFormat:@"_%@",key];
    NSString *decodeStr = [NSString stringWithFormat:@"\n\t\tself.%@ = [aDecoder %@@\"%@\"];",key,decodeMethod,key];
    NSString *encodeStr = [NSString stringWithFormat:@"\n\t[aCoder %@_%@ forKey:@\"%@\"];",encodeMethod,key,key];
    
    self.descriptionHead = desHead;
    self.descriptionTail = desTail;
    self.decodeStr = decodeStr;
    self.encodeStr = encodeStr;
    self.propertyStr = propertyStr;
}

-(void)setType:(PropertyType)type key:(NSString *)key
{
    NSString *propertyStr = nil;
    NSString *formatKey = nil;
    NSString *encodeMethod = nil;
    NSString *decodeMethod = nil;
    switch (type) {
        case PropertyTypeInteger: {
            propertyStr = [NSString stringWithFormat:@"@property (nonatomic,assign) NSInteger %@;\n",key];
            formatKey = @"%ld";
            decodeMethod = @"decodeIntegerForKey:";
            encodeMethod = @"encodeInteger:";
            break;
        }
        case PropertyTypeFloat: {
            propertyStr = [NSString stringWithFormat:@"@property (nonatomic,assign) CGFloat %@;\n",key];
            formatKey = @"%lf";
            decodeMethod = @"decodeFloatForKey:";
            encodeMethod = @"encodeFloat:";
            break;
        }
        case PropertyTypeDouble: {
            propertyStr = [NSString stringWithFormat:@"@property (nonatomic,assign) CGFloat %@;\n",key];
            formatKey = @"%lf";
            decodeMethod = @"decodeDoubleForKey:";
            encodeMethod = @"encodeDouble:";
            break;
        }
        case PropertyTypeString: {
            propertyStr = [NSString stringWithFormat:@"@property (nonatomic,copy) NSString *%@;\n",key];
            formatKey = @"%@";
            decodeMethod = @"decodeObjectForKey:";
            encodeMethod = @"encodeObject:";
            break;
        }
        case PropertyTypeArray: {
            propertyStr = [NSString stringWithFormat:@"@property (nonatomic,copy) NSArray *%@;\n",key];
            formatKey = @"%@";
            decodeMethod = @"decodeObjectForKey:";
            encodeMethod = @"encodeObject:";
            break;
        }
        case PropertyTypeDictionary: {
            break;
        }
        default: {
            break;
        }
    }
    NSString *desHead = [NSString stringWithFormat:@"%@:%@",key,formatKey];
    NSString *desTail = [NSString stringWithFormat:@"_%@",key];
    NSString *decodeStr = [NSString stringWithFormat:@"\n\t\tself.%@ = [aDecoder %@@\"%@\"];",key,decodeMethod,key];
    NSString *encodeStr = [NSString stringWithFormat:@"\n\t[aCoder %@_%@ forKey:@\"%@\"];",encodeMethod,key,key];
    
    self.descriptionHead = desHead;
    self.descriptionTail = desTail;
    self.decodeStr = decodeStr;
    self.encodeStr = encodeStr;
    self.propertyStr = propertyStr;
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

-(NSString *)lagerKeyWithKey:(NSString *)key className:(NSString *)className
{
    char p = [key characterAtIndex:0];
    char P = p;
    if (p >= 97) {
        P = p - 32;
    }
    NSString *largeKey = [key stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%c",p] withString:[NSString stringWithFormat:@"%c",P] options:0 range:NSMakeRange(0, 1)];
    largeKey =  [NSString stringWithFormat:@"%@%@",className,largeKey];
    return largeKey;
}

-(void)createModelWithDictionary:(NSDictionary *)dict name:(NSString *)className
{
    ClassStringInfo *hClassInfo = [ClassStringInfo objWithType:YES name:className coding:_codingSeg.selectedSegment == 0];
    ClassStringInfo *mClassInfo = [ClassStringInfo objWithType:NO name:className coding:_codingSeg.selectedSegment == 0];
    
    NSMutableString *decodeStr = [NSMutableString stringWithFormat:@"\n-(instancetype)initWithCoder:(NSCoder *)aDecoder\n{\n"];
    [decodeStr appendString:@"\tself = [super init];\n\tif(self){"];
    NSMutableString *encodeStr = [NSMutableString stringWithFormat:@"\n-(void)encodeWithCoder:(NSCoder *)aCoder\n{"];
    
    NSMutableString *descrptionHead = [NSMutableString stringWithFormat:@"\n-(NSString *)description{\n\treturn [NSString stringWithFormat:@\"{"];
    NSMutableString *descrptionTail = [NSMutableString stringWithFormat:@""];
    
    NSMutableString *mjArrayStr = nil;
    
    NSArray *allKeys = [dict allKeys];
    for (NSString *key in allKeys) {
        id  value = [dict objectForKey:key];
        PropertyInfo *inf = [[PropertyInfo alloc]init];
        if ([value isKindOfClass:[NSNull class]]) {
            [inf setType:PropertyTypeString key:key];
        }
        else if ([value isKindOfClass:[NSNumber class]]) {
            NSNumber *nValue = value;
            if (strcmp([nValue objCType], @encode(int)) == 0||strcmp([nValue objCType], @encode(long)) == 0) {
                //整形
                [inf setType:PropertyTypeInteger key:key];
            }
            else if (strcmp([nValue objCType], @encode(float)) == 0)
            {
                [inf setType:PropertyTypeFloat key:key];
            }
            else if (strcmp([nValue objCType], @encode(double)) == 0 )
            {
                [inf setType:PropertyTypeDouble key:key];
            }
        }
        else if([value isKindOfClass:[NSString class]])
        {
            [inf setType:PropertyTypeString key:key];
        }
        else if([value isKindOfClass:[NSArray class]])
        {
            NSArray *array = value;
            if (array.count > 0) {
                if ([array[0] isKindOfClass:[NSDictionary class]]) {
                    NSString *largeKey = [self lagerKeyWithKey:key className:className];
                    [self createModelWithDictionary:array[0] name:largeKey];
                    if (!mjArrayStr) {
                        mjArrayStr = [NSMutableString stringWithFormat:@"\n+(NSDictionary *)objectClassInArray\n{\n\treturn @{"];
                    }
                    if ([mjArrayStr rangeOfString:key].location == NSNotFound) {
                        [mjArrayStr appendFormat:@"@\"%@\":@\"%@\",",key,largeKey];
                    }
                }
            }
            [inf setType:PropertyTypeArray key:key];
        }
        else if([value isKindOfClass:[NSDictionary class]])
        {
            NSString *largeKey = [self lagerKeyWithKey:key className:className];
            [hClassInfo.importStr appendFormat:@"\n#import \"%@.h\"",largeKey];
            [self createModelWithDictionary:value name:largeKey];
            [inf setPropertyWithClassName:largeKey key:key];
        }
        [hClassInfo.propertyStr  appendString:inf.propertyStr];
        
        [descrptionHead appendString:inf.descriptionHead];
        [descrptionTail appendString:inf.descriptionTail];
        
        [decodeStr appendString:inf.decodeStr];
        [encodeStr appendString:inf.encodeStr];
        if ([allKeys indexOfObject:key]!=allKeys.count-1) {
            [descrptionHead appendFormat:@","];
            [descrptionTail appendFormat:@","];
        }
    }
    
    [encodeStr appendFormat:@"\n}\n"];
    [decodeStr appendFormat:@"\n\t}\n\treturn self;\n}\n"];
    
    [descrptionHead appendFormat:@"}\","];
    [descrptionTail appendFormat:@"];\n}\n"];
    
    [mjArrayStr deleteCharactersInRange:NSMakeRange(mjArrayStr.length-1, 1)];
    [mjArrayStr appendString:@"};\n}\n"];
    
    //coding
    if (_codingSeg.selectedSegment == 0) {
        [mClassInfo.methodStr appendString:decodeStr];
        [mClassInfo.methodStr appendString:encodeStr];
    }
    
    //descprtoins
    if ([_descrptionSeg selectedSegment] == 0) {
        [mClassInfo.methodStr appendFormat:@"%@%@",descrptionHead,descrptionTail];
    }
    
    //mjArray
    if (_mjArraySeg.selectedSegment == 0) {
        if (mjArrayStr) {
            [mClassInfo.methodStr appendString:mjArrayStr];
        }
    }
    
    [hClassInfo saveWithPath:_path];
    [mClassInfo saveWithPath:_path];
}

-(IBAction)generate:(NSButton *)sender
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
        [alert beginSheetModalForWindow:self.view.window completionHandler:nil];
    }
    else
    {
        NSString *className = _nameTF.stringValue;
        if (!className || [className isEqualToString:@""]) {
            className = @"Default";
        }
        [self createModelWithDictionary:dict name:className];
        NSAlert *alert = [[NSAlert alloc]init];
        alert.messageText = @"成功";
        [alert setAlertStyle:NSInformationalAlertStyle];
        [alert beginSheetModalForWindow:self.view.window completionHandler:nil];
    }
}

@end
