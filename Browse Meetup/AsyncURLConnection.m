//
//  AsyncURLConnection.m
//
//  Created by Denis on 30.04.14.
//  Copyright (c) 2014 cityleeks. All rights reserved.
//

#import "AsyncURLConnection.h"

@implementation AsyncURLConnection

+ (id)requestWithMutable:(NSMutableURLRequest *)request completeBlock:(completeBlock_t)completeBlock errorBlock:(errorBlock_t)errorBlock
{
    return [[self alloc] initWithMutableRequest:request completeBlock:completeBlock errorBlock:errorBlock];
}

+ (id)request:(NSString*)requestUrl completeBlock:(completeBlock_t)completeBlock errorBlock:(errorBlock_t)errorBlock
{
    return [[self alloc] initWithRequest:requestUrl
                           completeBlock:completeBlock errorBlock:errorBlock];
}

- (id)initWithRequest:(NSString *)requestUrl completeBlock:(completeBlock_t)completeBlock errorBlock:(errorBlock_t)errorBlock
{
    if ((self=[super init])) {
        data_ = [[NSMutableData alloc] init];
        completeBlock_ = [completeBlock copy];
        errorBlock_ = [errorBlock copy];
        NSURL *url = [NSURL URLWithString:requestUrl];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [NSURLConnection connectionWithRequest:request delegate:self];
    }
    return self;
}

- (id)initWithMutableRequest:(NSMutableURLRequest *)request completeBlock:(completeBlock_t)completeBlock errorBlock:(errorBlock_t)errorBlock
{
    if ((self=[super init])) {
        data_ = [[NSMutableData alloc] init];
        completeBlock_ = [completeBlock copy];
        errorBlock_ = [errorBlock copy];
        [NSURLConnection connectionWithRequest:request delegate:self];
    }
    return self;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [data_ setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [data_ appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    completeBlock_(data_);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    errorBlock_(error);
}


- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if ([challenge previousFailureCount] == 0)
    {
        NSURLCredential *newCredential;
        newCredential=[NSURLCredential credentialWithUser:@"someUser"
                                                 password:@"someUser"
                                              persistence:NSURLCredentialPersistenceForSession];
        [[challenge sender] useCredential:newCredential forAuthenticationChallenge:challenge];
        NSLog(@"responded to authentication challenge");
        
    }else{
        NSLog(@"previous authentication failure");
    }
}

@end