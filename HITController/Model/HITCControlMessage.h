//
//  HITCControlMessage.h
//  HITController
//
//  Created by Masakazu Suetomo on 2012/12/12.
//  Copyright (c) 2012 Kyoto University. All rights reserved.
//

#import <Foundation/Foundation.h>


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
/// ControlMessage types
typedef enum {
    HITCControlMessageTypeSystem        = 0,    ///< System
    HITCControlMessageTypeWidget        = 1,    ///< Widget
    HITCControlMessageTypePlugin        = 2,    ///< Plugin
    HITCControlMessageTypeImage         = 3,    ///< Image
    HITCControlMessageTypeText          = 4,    ///< Text
    HITCControlMessageTypeWeb           = 5,    ///< Web
    HITCControlMessageTypePDF           = 6,    ///< PDF
    HITCControlMessageTypeMovie         = 7,    ///< Movie
} HITCControlMessageType;

/// ControlMessage commands
typedef enum {
    HITCControlMessageCommandAccept     = 0,    ///< Accept
    HITCControlMessageCommandCreate     = 1,    ///< Create
    HITCControlMessageCommandDelete     = 2,    ///< Delete
    HITCControlMessageCommandMove       = 3,    ///< Move
    HITCControlMessageCommandSize       = 4,    ///< Size
    HITCControlMessageCommandNewComer   = 5,    ///< New comer
    HITCControlMessageCommandTopmost    = 6,    ///< Topmost
    HITCControlMessageCommandGesture    = 7,    ///< Gesture
} HITCControlMessageCommand;

/// ControlMessage display states
typedef enum {
    HITCControlMessageDisplayStateNormal    = 0,    ///< Normal
    HITCControlMessageDisplayStateMinimized = 1,    ///< Minimized
    HITCControlMessageDisplayStateMaximized = 2,    ///< Maximized
} HITCControlMessageDisplayState;


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
/// Class of control message
@interface HITCControlMessage : NSObject

/// Control message type
@property (nonatomic, assign) HITCControlMessageType type;
/// Command
@property (nonatomic, assign) HITCControlMessageCommand command;
/// Name --- Widget name, plugin name or filename except extension
@property (nonatomic, copy) NSString *name;
/// File --- Filename
@property (nonatomic, copy) NSString *file;
/// Owner --- Registrant IP Address e.g. 10.0.1.1
@property (nonatomic, copy) NSString *owner;
/// Position --- Integer value but keeps as float value
@property (nonatomic, assign) CGPoint position;
/// Size --- Integer value but keeps as float value
@property (nonatomic, assign) CGSize size;
/// Focus
@property (nonatomic, assign) BOOL focus;
/// Date --- Current date when created message
@property (nonatomic, copy) NSDate *date;
/// Signature --- Registrant IP Address e.g. 10.0.1.1
@property (nonatomic, copy) NSString *signature;
/// ComponentID --- UUID
@property (nonatomic, copy) NSString *componentID;
/// Component source --- URL
@property (nonatomic, copy) NSString *contentSource;
/// Display state
@property (nonatomic, assign) HITCControlMessageDisplayState displayState;
/// Normal position --- Integer value but keeps as float value
@property (nonatomic, assign) CGPoint normalPosition;
/// Normal size --- Integer value but keeps as float value
@property (nonatomic, assign) CGSize normalSize;
/// Selected
@property (nonatomic, assign, getter = isSelected) BOOL selected;

/// Initializer
- (id)initWithXMLData:(NSData *)XMLData;

/// Returns XML data
- (NSData *)XMLData;

/// Returns XML string
- (NSString *)XMLString;

/// Returns formatted XML string
- (NSString *)prettyXMLString;

@end
