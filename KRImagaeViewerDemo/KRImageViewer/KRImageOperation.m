//
//  KRImageOperation.m
//  Kuo-Ming Lin
//
//  Created by Kuo-Ming Lin ( Kalvar, ilovekalvar@gmail.com ) on 12/10/2.
//  Copyright (c) 2012年 Kuo-Ming Lin All rights reserved.
//

#import "KRImageOperation.h"

static NSString *krImageOperationIsFinished  = @"isFinished";
static NSString *krImageOperationIsCancelled = @"isCancelled";
static NSString *krImageOperationIsExecuting = @"isExecuting";

@interface KRImageOperation ()

@property (nonatomic, retain) NSURLConnection *_connection;
@property (nonatomic, retain) NSURL *_photoURL;
@property (nonatomic, assign) NSMutableData *_receivedData;
@property (nonatomic, assign) BOOL _isExecuting;
@property (nonatomic, assign) BOOL _isFinished;
@property (nonatomic, assign) BOOL _isCancelled;

@end

@implementation KRImageOperation

@synthesize doneImage;
@synthesize _connection;
@synthesize _photoURL;
@synthesize _receivedData;
@synthesize _isExecuting, _isFinished, _isCancelled;

-(id)initWithImageURL:(NSString *)_imageURL{
    self = [super init];
    if (self) {
        self._isExecuting = NO;
        self._isCancelled = NO;
        self._isFinished  = NO;
        self._photoURL    = [NSURL URLWithString:_imageURL];
    }
    return self;
}

-(void)dealloc{
    [_connection release];
    [_photoURL release];
    
    [super dealloc];
}

#pragma My Methods
//移除連線
-(void)removeConnections
{
    if ( self._connection ) {
        [self._connection unscheduleFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        self._connection   = nil;
        self._receivedData = nil;
    }
    [self willChangeValueForKey:krImageOperationIsFinished];
    [self willChangeValueForKey:krImageOperationIsExecuting];
    self._isExecuting = NO;
    self._isFinished = YES;
    [self didChangeValueForKey:krImageOperationIsExecuting];
    [self didChangeValueForKey:krImageOperationIsFinished];
}

#pragma Override NSOperation Functions 覆寫父函式
/*
 * 以下函式都是自動執行的
 */
- (void)start{
    if ( [self isCancelled] ) {
        [self willChangeValueForKey:krImageOperationIsFinished];
        self._isFinished = YES;
        [self didChangeValueForKey:krImageOperationIsFinished];
        return;
    }
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:self._photoURL
                                                 cachePolicy:NSURLRequestUseProtocolCachePolicy
                                             timeoutInterval:30.0f];
    _connection = [[NSURLConnection alloc] initWithRequest:request
                                                  delegate:self
                                          startImmediately:NO];
    if ( self._connection ) {
        _receivedData = [[NSMutableData alloc]init];
        [self._connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        [self._connection start];
    }
    [self._connection start];
    [self willChangeValueForKey:krImageOperationIsExecuting];
    self._isExecuting = YES;
    [self didChangeValueForKey:krImageOperationIsExecuting];
    [request release];
}

-( void)cancel {
    [self removeConnections];
    [self._connection cancel];
    [self willChangeValueForKey:krImageOperationIsCancelled];
    self._isCancelled = YES;
    [self didChangeValueForKey:krImageOperationIsCancelled];
}

- (BOOL)isCancelled{
    return self._isCancelled;
}

- (BOOL)isConcurrent {
    return YES;
}

- (BOOL)isExecuting {
    return self._isExecuting;
}

- (BOOL)isFinished {
    return self._isFinished;
}

#pragma  mark - NSURLConnection Delegate methods
- (void)connection:(NSURLConnection *)con didReceiveResponse:(NSURLResponse *)response {
    [self._receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)con didReceiveData:(NSData *)data{
    [self._receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)con didFailWithError:(NSError *)error{
    [self removeConnections];
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    // ...
}

- (void)connectionDidFinishLoading:(NSURLConnection *)con{
    self.doneImage = [UIImage imageWithData:self._receivedData];
    [self removeConnections];
}

@end
