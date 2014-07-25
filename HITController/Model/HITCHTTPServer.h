//
//  HITCHTTPServer.h
//  HITController
//
//  Created by Masakazu Suetomo on 2012/12/14.
//  Copyright (c) 2012 Kyoto University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSFSingletonSynthesizer.h"


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
/// Class of HTTP server
@interface HITCHTTPServer : NSObject

MSF_SYSNTHESIZE_SINGLETON_FOR_CLASS_INTERFACE(HTTPServer, HITC);

/// Start HTTP server
- (void)start;

/// Stop HTTP server
- (void)stop;

@end

