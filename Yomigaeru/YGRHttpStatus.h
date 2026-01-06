//
//  YGRHttpStatus.h
//  Yomigaeru
//
//  Created by John Connery on 2025/11/13.
//  Copyright (c) 2025年 Wumbo World. All rights reserved.
//

#ifndef Kaiko_HttpStatus_h
#define Kaiko_HttpStatus_h

typedef enum {
    // 2xx Success
    HttpStatusOK = 200,
    HttpStatusCreated = 201,
    HttpStatusAccepted = 202,
    HttpStatusNoContent = 204,
    
    // 3xx Redirection
    HttpStatusMovedPermanently = 301,
    HttpStatusFound = 302,
    HttpStatusSeeOther = 303,
    HttpStatusNotModified = 304,
    HttpStatusTemporaryRedirect = 307,
    HttpStatusPermanentRedirect = 308,
    
    // 4xx Client Errors
    HttpStatusBadRequest = 400,
    HttpStatusUnauthorized = 401,
    HttpStatusForbidden = 403,
    HttpStatusNotFound = 404,
    HttpStatusMethodNotAllowed = 405,
    HttpStatusConflict = 409,
    HttpStatusUnprocessableEntity = 422,
    
    // 5xx Server Errors
    HttpStatusInternalServerError = 500,
    HttpStatusNotImplemented = 501,
    HttpStatusBadGateway = 502,
    HttpStatusServiceUnavailable = 503,
    HttpStatusGatewayTimeout = 504
} HttpStatus_t;

#endif
