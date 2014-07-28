//
//  MSFCommon.h
//  MSFCommonThings
//
//  Created by mxs on 2012/04/01.
//  Modified by mxs on 2012/06/29.

//
//  Copyright (c) 2012, moonxseed (http://www.moonxseed.com)
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification,
//  are permitted provided that the following conditions are met:
//
//     * Redistributions of source code must retain the above copyright notice, this
//       list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above copyright notice,
//       this list of conditions and the following disclaimer in the documentation
//       and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
//  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
//  OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
//  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
//  IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import <Foundation/Foundation.h>


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
#if !__has_feature(objc_arc)
    /// Release object safely
    #define MSFReleaseSafely(object) {[(object) release], (object) = nil;}
    
    /// Release object
    #define MSFRelease(object) [(object) release]
    
    /// Retain object
    #define MSFRetain(object) [(object) retain]

    /// Autorelease object
    #define MSFAutorelease(object) [(object) autorelease]
#endif

/// Invalidate timer safely
#define MSFInvalidateTimerSafely(timer) {[(timer) invalidate], (timer) = nil;}


//= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
/// Release Core Foundation object safely
#define MSFCFReleaseSafely(object) {if (object) {CFRelease(object), (object) = NULL;}}

/// Release Core Foundation object
#define MSFCFRelease(object) {if (object) {CFRelease(object);}}

/// Retain Core Foundation object
#define MSFCFRetain(object) {if (object) {CFRetain(object);}}


//= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
/// Log
#ifdef MSFDEBUG
    #define MSFLog(...) NSLog(__VA_ARGS__)
#else
    #define MSFLog(...)
#endif

/// Log method
#define MSFLogMethod() MSFLog(@"%s", __PRETTY_FUNCTION__)

/// Log step
#define MSFLogStep(format, ...) MSFLog((@"%s #%d " format), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

/// Log object
#define MSFLogObject(value) MSFLog(@"'%s' is %@", #value, value)

/// Log BOOL
#define MSFLogBOOL(value) MSFLog(@"'%s' is %@", #value, (value) ? @"YES" : @"NO")

/// Log NSDate
#define MSFLogDate(value) MSFLog(@"'%s' is %@", #value, [value descriptionWithLocale:[NSLocale currentLocale]])

/// Log NSDateComponents
#define MSFLogDateComponents(components) MSFLog(@"'%s' is %04d-%02d-%02d (%d) %02d:%02d:%02d w:%d", \
#components, [components year], [components month], [components day], [components weekday], [components hour], [components minute], [components second], [components week])

/// Log call stack symbols
#define MSFLogCallStackSymbols() MSFLog(@"%@", [NSThread callStackSymbols])

/// Log view hierarchy
#define MSFLogViewHierarchy(view) MSFLog(@"%@", [view performSelector:@selector(recursiveDescription)])


//= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
/// Prepare uncaught exception handler
#ifdef MSFDEBUG
    extern void MSFUncaughtExceptionHandler(NSException *exception);
    #define PrepareUncaughtExceptionHandler() NSSetUncaughtExceptionHandler(&MSFUncaughtExceptionHandler)
#else
    #define PrepareUncaughtExceptionHandler()
#endif


//= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
/// Assign to CGRect.origin.x
#define MSFCGRectAssignX(rect, px) \
{CGRect theRect = (rect); theRect.origin.x = (px); (rect) = theRect;}

/// Assign to CGRect.origin.y
#define MSFCGRectAssignY(rect, py) \
{CGRect theRect = (rect); theRect.origin.y = (py); (rect) = theRect;}

/// Assign to CGRect.origin
#define MSFCGRectAssignOrigin(rect, rectOrigin) \
{CGRect theRect = (rect); theRect.origin = (rectOrigin); (rect) = theRect;}

/// Assign to CGRect.size.width
#define MSFCGRectAssignWidth(rect, rectWidth) \
{CGRect theRect = (rect); theRect.size.width = (rectWidth); (rect) = theRect;}

/// Assign to CGRect.size.height
#define MSFCGRectAssignHeight(rect, rectHeight) \
{CGRect theRect = (rect); theRect.size.height = (rectHeight); (rect) = theRect;}

/// Assign to CGRect.size
#define MSFCGRectAssignSize(rect, rectSize) \
{CGRect theRect = (rect); theRect.size = (rectSize); (rect) = theRect;}


/// Add to CGRect.origin.x
#define MSFCGRectAddX(rect, dx) \
{CGRect theRect = (rect); theRect.origin.x += (dx); (rect) = theRect;}

/// Add to CGRect.origin.y
#define MSFCGRectAddY(rect, dy) \
{CGRect theRect = (rect); theRect.origin.y += (dy); (rect) = theRect;}

/// Add to CGRect.origin
#define MSFCGRectAddXY(rect, dx, dy) \
{CGRect theRect = (rect); theRect.origin.x += (dx); theRect.origin.y += (dy); (rect) = theRect;}

/// Add to CGRect.size.width
#define MSFCGRectAddWidth(rect, dwidth) \
{CGRect theRect = (rect); theRect.size.width += (dwidth); (rect) = theRect;}

/// Add to CGRect.size.height
#define MSFCGRectAddHeight(rect, dheight) \
{CGRect theRect = (rect); theRect.size.height += (dheight); (rect) = theRect;}

/// Add to CGRect.size
#define MSFCGRectAddWidthHeight(rect, dwidth, dheight) \
{CGRect theRect = (rect); theRect.size.width += (dwidth); theRect.size.height += (dheight); (rect) = theRect;}


//= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
/// Assign to CGPoint.x
#define MSFCGPointAssignX(point, px) \
{CGPoint thePoint = (point); thePoint.x = (px); (point) = thePoint;}

/// Assign to CGPoint.y
#define MSFCGPointAssignY(point, py) \
{CGPoint thePoint = (point); thePoint.y = (py); (point) = thePoint;}


/// Add to CGPoint.x
#define MSFCGPointAddX(point, dx) \
{CGPoint thePoint = (point); thePoint.x += (dx); (point) = thePoint;}

/// Add to CGPoint.y
#define MSFCGPointAddY(point, dy) \
{CGPoint thePoint = (point); thePoint.y += (dy); (point) = thePoint;}


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
#ifdef MSFDEBUG
    #define MSFNotImplementedYet() \
    { \
        NSString *reason = [NSString stringWithFormat:@"%s Not Implemented Yet", __FUNCTION__]; \
        NSException *exception = [NSException exceptionWithName:MSFGenericException reason:reason userInfo:nil]; \
        @throw exception; \
    }
#else
    #define MSFNotImplementedYet()
#endif


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
/// Exceptions
extern NSString *const MSFGenericException;                 ///< Generic Exception
extern NSString *const MSFInvalidArgumentException;         ///< Invalid Argument Exception
extern NSString *const MSFInternalInconsistencyException;   ///< Internal Inconsistency Exception
