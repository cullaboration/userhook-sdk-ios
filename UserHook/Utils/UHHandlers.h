/*
 * Copyright (c) 2015 - present, Cullaboration Media, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#ifndef UHHandlers_h
#define UHHandlers_h

typedef void(^UHDictionaryHandler)(NSDictionary * response);
typedef void(^UHArrayHandler)(NSArray * items);
typedef void(^UHPushHandler)(NSDictionary * payload);
typedef void(^UHPayloadHandler)(NSDictionary * payload);
typedef void(^UHResponseHandler)(BOOL success);

#endif /* UHHandlers_h */
