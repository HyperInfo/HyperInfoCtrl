//
//  HITCControlMessage.m
//  HITController
//
//  Created by Masakazu Suetomo on 2012/12/12.
//  Copyright (c) 2012 Kyoto University. All rights reserved.
//

#import "HITCControlMessage.h"
#import "DDXML.h"


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
/// Date format for ControlMessage
static NSString *const HITCControlMessageDateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSSSSSZZZZZ";


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
@implementation HITCControlMessage

//-----------------------------------------------------------------------------------
- (id)initWithXMLData:(NSData *)XMLData
//-----------------------------------------------------------------------------------
{
    self = [super init];
    if (self) {
        [self HITCParseXMLData:XMLData];
    }
    
    return self;
}


#pragma mark -
#pragma mark Override

//-----------------------------------------------------------------------------------
- (NSString *)description
//-----------------------------------------------------------------------------------
{
    NSString *type = @"";
    switch (self.type) {
        case HITCControlMessageTypeSystem:
            type = @"System";
            break;
            
        case HITCControlMessageTypeWidget:
            type = @"Widget";
            break;
            
        case HITCControlMessageTypePlugin:
            type = @"plugin";
            break;
            
        case HITCControlMessageTypeImage:
            type = @"image";
            break;
            
        case HITCControlMessageTypeText:
            type = @"text";
            break;
            
        case HITCControlMessageTypeWeb:
            type = @"Web";
            break;
            
        case HITCControlMessageTypePDF:
            type = @"pdf";
            break;
            
        case HITCControlMessageTypeMovie:
            type = @"movie";
            break;
    }
    
    NSString *command = @"";
    switch (self.command) {
        case HITCControlMessageCommandAccept:
            command = @"accept";
            break;
            
        case HITCControlMessageCommandCreate:
            command = @"create";
            break;
            
        case HITCControlMessageCommandDelete:
            command = @"delete";
            break;
            
        case HITCControlMessageCommandMove:
            command = @"move";
            break;
            
        case HITCControlMessageCommandSize:
            command = @"size";
            break;
            
        case HITCControlMessageCommandNewComer:
            command = @"newcomer";
            break;
            
        case HITCControlMessageCommandTopmost:
            command = @"topmost";
            break;
            
        case HITCControlMessageCommandGesture:
            command = @"gesture";
            break;
    }
    
    NSString *displayState = @"";
    switch (self.displayState) {
        case HITCControlMessageDisplayStateNormal:
            displayState = @"Normal";
            break;
            
        case HITCControlMessageDisplayStateMinimized:
            displayState = @"Minimized";
            break;
            
        case HITCControlMessageDisplayStateMaximized:
            displayState = @"Maximized";
            break;
    }
    
    
    return [NSString stringWithFormat:
            @"%@\n"
            @"type = %@\n"
            @"command = %@\n"
            @"name = %@\n"
            @"file = %@\n"
            @"owner=%@\n"
            @"x,y,w,h = (%@)\n"
            @"focus = %@\n"
            @"date = %@\n"
            @"signature = %@\n"
            @"componentID = %@\n"
            @"contentSource = %@\n"
            @"displayState = %@\n"
            @"normal rect = (%@)\n"
            @"selected = %@\n",
            [super description],
            type,
            command,
            self.name,
            self.file,
            self.owner,
            NSStringFromCGRect(CGRectMake(self.position.x, self.position.y, self.size.width, self.size.height)),
            self.focus ? @"true" : @"false",
            [self.date descriptionWithLocale:[NSLocale currentLocale]],
            self.signature,
            self.componentID,
            self.contentSource,
            displayState,
            NSStringFromCGRect(CGRectMake(self.normalPosition.x, self.normalPosition.y, self.normalSize.width, self.normalSize.height)),
            self.isSelected ? @"true" : @"false"];
}


#pragma mark -
#pragma mark Public

//-----------------------------------------------------------------------------------
- (NSData *)XMLData
//-----------------------------------------------------------------------------------
{
    NSString *XMLString = [self XMLString];
    
    DDXMLDocument *xmlDocument = [[DDXMLDocument alloc] initWithXMLString:XMLString options:0 error:NULL];
    
    NSData *xmlData = [xmlDocument XMLData];
    
    NSMutableData *mutableXMLData = [xmlData mutableCopy];
    [mutableXMLData appendBytes:"\r\n" length:2];
    
    return mutableXMLData;
}

//-----------------------------------------------------------------------------------
- (NSString *)XMLString
//-----------------------------------------------------------------------------------
{
    NSString *type = @"";
    
    switch (self.type) {
        case HITCControlMessageTypeSystem:
            type = @"System";
            break;
            
        case HITCControlMessageTypeWidget:
            type = @"Widget";
            break;
            
        case HITCControlMessageTypePlugin:
            type = @"plugin";
            break;
            
        case HITCControlMessageTypeImage:
            type = @"image";
            break;
            
        case HITCControlMessageTypeText:
            type = @"text";
            break;
            
        case HITCControlMessageTypeWeb:
            type = @"Web";
            break;
            
        case HITCControlMessageTypePDF:
            type = @"pdf";
            break;
            
        case HITCControlMessageTypeMovie:
            type = @"movie";
            break;
    }
    
    NSString *command = @"";
    
    switch (self.command) {
        case HITCControlMessageCommandAccept:
            command = @"accept";
            break;
            
        case HITCControlMessageCommandCreate:
            command = @"create";
            break;
            
        case HITCControlMessageCommandDelete:
            command = @"delete";
            break;
            
        case HITCControlMessageCommandMove:
            command = @"move";
            break;
            
        case HITCControlMessageCommandSize:
            command = @"size";
            break;
            
        case HITCControlMessageCommandNewComer:
            command = @"newcomer";
            break;
            
        case HITCControlMessageCommandTopmost:
            command = @"topmost";
            break;
            
        case HITCControlMessageCommandGesture:
            command = @"gesture";
            break;
    }
    
    NSString *displayState = @"";
    
    switch (self.displayState) {
        case HITCControlMessageDisplayStateNormal:
            displayState = @"Normal";
            break;
            
        case HITCControlMessageDisplayStateMinimized:
            displayState = @"Minimized";
            break;
            
        case HITCControlMessageDisplayStateMaximized:
            displayState = @"Maximized";
            break;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:HITCControlMessageDateFormat];
    NSString *dateString = [dateFormatter stringFromDate:self.date];
    
    NSString *formatString = nil;
    NSString *xmlString = nil;
    if (self.file) {
        formatString =
        @"<?xml version=\"1.0\"?>"
        @"<ControlMessage type=\"%@\">"
        @"<command>%@</command>"
        @"<name>%@</name>"
        @"<file>%@</file>"
        @"<owner>%@</owner>"
        @"<position><X>%d</X><Y>%d</Y></position>"
        @"<size><Width>%d</Width><Height>%d</Height></size>"
        @"<focus>%@</focus>"
        @"<date>%@</date>"
        @"<signature>%@</signature>"
        @"<ComponentId>%@</ComponentId>"
        @"<ContentSource>%@</ContentSource>"
        @"<DisplayState>%@</DisplayState>"
        @"<NormalPosition><X>%d</X><Y>%d</Y></NormalPosition>"
        @"<NormalSize><Width>%d</Width><Height>%d</Height></NormalSize>"
        @"<IsSelected>%@</IsSelected>"
        @"</ControlMessage>"
        @"\r\n";
        xmlString = [NSString stringWithFormat:formatString,
                     type,
                     command,
                     self.name,
                     self.file,
                     self.owner,
                     (NSInteger)self.position.x,
                     (NSInteger)self.position.y,
                     (NSInteger)self.size.width,
                     (NSInteger)self.size.height,
                     self.focus ? @"true" : @"false",
                     dateString,
                     self.signature,
                     self.componentID,
                     self.contentSource,
                     displayState,
                     (NSInteger)self.normalPosition.x,
                     (NSInteger)self.normalPosition.y,
                     (NSInteger)self.normalSize.width,
                     (NSInteger)self.normalSize.height,
                     self.isSelected ? @"true" : @"false"];
    }
    else {
        formatString =
        @"<?xml version=\"1.0\"?>"
        @"<ControlMessage type=\"%@\">"
        @"<command>%@</command>"
        @"<name>%@</name>"
        @"<owner>%@</owner>"
        @"<position><X>%d</X><Y>%d</Y></position>"
        @"<size><Width>%d</Width><Height>%d</Height></size>"
        @"<focus>%@</focus>"
        @"<date>%@</date>"
        @"<signature>%@</signature>"
        @"<ComponentId>%@</ComponentId>"
        @"<ContentSource>%@</ContentSource>"
        @"<DisplayState>%@</DisplayState>"
        @"<NormalPosition><X>%d</X><Y>%d</Y></NormalPosition>"
        @"<NormalSize><Width>%d</Width><Height>%d</Height></NormalSize>"
        @"<IsSelected>%@</IsSelected>"
        @"</ControlMessage>"
        @"\r\n";
        xmlString = [NSString stringWithFormat:formatString,
                     type,
                     command,
                     self.name,
                     self.owner,
                     (NSInteger)self.position.x,
                     (NSInteger)self.position.y,
                     (NSInteger)self.size.width,
                     (NSInteger)self.size.height,
                     self.focus ? @"true" : @"false",
                     dateString,
                     self.signature,
                     self.componentID,
                     self.contentSource,
                     displayState,
                     (NSInteger)self.normalPosition.x,
                     (NSInteger)self.normalPosition.y,
                     (NSInteger)self.normalSize.width,
                     (NSInteger)self.normalSize.height,
                     self.isSelected ? @"true" : @"false"];
    }
    
    return xmlString;
}

//-----------------------------------------------------------------------------------
- (NSString *)prettyXMLString
//-----------------------------------------------------------------------------------
{
    DDXMLDocument *xmlDocument = [[DDXMLDocument alloc] initWithXMLString:[self XMLString] options:0 error:NULL];
    
    return [xmlDocument XMLStringWithOptions:DDXMLNodePrettyPrint];
}


#pragma mark -
#pragma mark Private

/// Parse XML data
//-----------------------------------------------------------------------------------
- (void)HITCParseXMLData:(NSData *)data
//-----------------------------------------------------------------------------------
{
    DDXMLDocument *XMLDocument = [[DDXMLDocument alloc] initWithData:data options:0 error:NULL];
    
    DDXMLElement *rootElement = [XMLDocument rootElement];
    [[rootElement attributes] enumerateObjectsUsingBlock:^(DDXMLNode *attribute, NSUInteger idx, BOOL *stop) {
        if ([[attribute name] isEqualToString:@"type"]) {
            NSString *type = [attribute stringValue];
            if ([type isEqualToString:@"System"]) {
                self.type = HITCControlMessageTypeSystem;
            }
            else if ([type isEqualToString:@"Widget"]) {
                self.type = HITCControlMessageTypeWidget;
            }
            else if ([type isEqualToString:@"plugin"]) {
                self.type = HITCControlMessageTypePlugin;
            }
            else if ([type isEqualToString:@"image"]) {
                self.type = HITCControlMessageTypeImage;
            }
            else if ([type isEqualToString:@"text"]) {
                self.type = HITCControlMessageTypeText;
            }
            else if ([type isEqualToString:@"Web"]) {
                self.type = HITCControlMessageTypeWeb;
            }
            else if ([type isEqualToString:@"pdf"]) {
                self.type = HITCControlMessageTypePDF;
            }
            else if ([type isEqualToString:@"movie"]) {
                self.type = HITCControlMessageTypeMovie;
            }
        }
    }];
    
    NSArray *childrenNode = [rootElement children];
    [childrenNode enumerateObjectsUsingBlock:^(DDXMLNode *node, NSUInteger idx, BOOL *stop) {
        NSString *nodeName = node.name;
        if ([nodeName isEqualToString:@"command"]) {
            NSString *command = [node stringValue];
            if ([command isEqualToString:@"accept"]) {
                self.command = HITCControlMessageCommandAccept;
            }
            else if ([command isEqualToString:@"create"]) {
                self.command = HITCControlMessageCommandCreate;
            }
            else if ([command isEqualToString:@"delete"]) {
                self.command = HITCControlMessageCommandDelete;
            }
            else if ([command isEqualToString:@"move"]) {
                self.command = HITCControlMessageCommandMove;
            }
            else if ([command isEqualToString:@"size"]) {
                self.command = HITCControlMessageCommandSize;
            }
            else if ([command isEqualToString:@"newcomer"]) {
                self.command = HITCControlMessageCommandNewComer;
            }
            else if ([command isEqualToString:@"topmost"]) {
                self.command = HITCControlMessageCommandTopmost;
            }
            else if ([command isEqualToString:@"gesture"]) {
                self.command = HITCControlMessageCommandGesture;
            }
        }
        else if ([nodeName isEqualToString:@"name"]) {
            self.name = [node stringValue];
        }
        else if ([nodeName isEqualToString:@"file"]) {
            self.file = [node stringValue];
        }
        else if ([nodeName isEqualToString:@"owner"]) {
            self.owner = [node stringValue];
        }
        else if ([nodeName isEqualToString:@"position"]) {
            [[node children] enumerateObjectsUsingBlock:^(DDXMLNode *childNode, NSUInteger idx, BOOL *stop) {
                NSString *nodeName = childNode.name;
                if ([nodeName isEqualToString:@"X"]) {
                    self.position = CGPointMake([[childNode stringValue] floatValue], self.position.y);
                }
                else if ([nodeName isEqualToString:@"Y"]) {
                    self.position = CGPointMake(self.position.x, [[childNode stringValue] floatValue]);
                }
            }];
        }
        else if ([nodeName isEqualToString:@"size"]) {
            [[node children] enumerateObjectsUsingBlock:^(DDXMLNode *childNode, NSUInteger idx, BOOL *stop) {
                NSString *nodeName = childNode.name;
                if ([nodeName isEqualToString:@"Width"]) {
                    self.size = CGSizeMake([[childNode stringValue] floatValue], self.size.height);
                }
                else if ([nodeName isEqualToString:@"Height"]) {
                    self.size = CGSizeMake(self.size.width, [[childNode stringValue] floatValue]);
                }
            }];
        }
        else if ([nodeName isEqualToString:@"focus"]) {
            self.focus = [[node stringValue] isEqualToString:@"false"] ? NO : YES;
        }
        else if ([nodeName isEqualToString:@"date"]) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:HITCControlMessageDateFormat];
            self.date = [dateFormatter dateFromString:[node stringValue]];
        }
        else if ([nodeName isEqualToString:@"signature"]) {
            self.signature = [node stringValue];
        }
        else if ([nodeName isEqualToString:@"ComponentId"]) {
            self.componentID = [node stringValue];
        }
        else if ([nodeName isEqualToString:@"ContentSource"]) {
            self.contentSource = [node stringValue];
        }
        else if ([nodeName isEqualToString:@"DisplayState"]) {
            NSString *command = [node stringValue];
            if ([command isEqualToString:@"Normal"]) {
                self.displayState = HITCControlMessageDisplayStateNormal;
            }
            else if ([command isEqualToString:@"Minimized"]) {
                self.displayState = HITCControlMessageDisplayStateMinimized;
            }
            else if ([command isEqualToString:@"Maximized"]) {
                self.displayState = HITCControlMessageDisplayStateMaximized;
            }
        }
        else if ([nodeName isEqualToString:@"NormalPosition"]) {
            [[node children] enumerateObjectsUsingBlock:^(DDXMLNode *childNode, NSUInteger idx, BOOL *stop) {
                NSString *nodeName = childNode.name;
                if ([nodeName isEqualToString:@"X"]) {
                    self.normalPosition = CGPointMake([[childNode stringValue] floatValue], self.normalPosition.y);
                }
                else if ([nodeName isEqualToString:@"Y"]) {
                    self.normalPosition = CGPointMake(self.normalPosition.x, [[childNode stringValue] floatValue]);
                }
            }];
        }
        else if ([nodeName isEqualToString:@"NormalSize"]) {
            [[node children] enumerateObjectsUsingBlock:^(DDXMLNode *childNode, NSUInteger idx, BOOL *stop) {
                NSString *nodeName = childNode.name;
                if ([nodeName isEqualToString:@"Width"]) {
                    self.normalSize = CGSizeMake([[childNode stringValue] floatValue], self.normalSize.height);
                }
                else if ([nodeName isEqualToString:@"Height"]) {
                    self.normalSize = CGSizeMake(self.normalSize.width, [[childNode stringValue] floatValue]);
                }
            }];
        }
        else if ([nodeName isEqualToString:@"IsSelected"]) {
            self.selected = [[node stringValue] isEqualToString:@"false"] ? NO : YES;
        }
    }];
}

@end
