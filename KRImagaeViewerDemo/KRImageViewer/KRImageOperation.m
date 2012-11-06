//
//  KRImageOperation.m
//  MC
//
//  Created by Kalvar on 12/10/15.
//  Copyright (c) 2012年 Flashaim Inc. All rights reserved.
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
@property (nonatomic, assign) long long _dataTotalLength;

@end

@interface KRImageOperation (fixPrivate)

-(NSInteger)_findCacheMode;

@end

@implementation KRImageOperation (fixPrivate)

-(NSInteger)_findCacheMode{
    NSInteger _mode = 0;
    switch (self.cacheMode) {
        case KRImageOperationAllowCache:
            _mode = NSURLRequestUseProtocolCachePolicy;
            break;
        case KRImageOperationIgnoreCache:
            _mode = NSURLRequestReloadIgnoringCacheData;
            break;
        default:
            _mode = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
            break;
    }
    return _mode;
}

@end

@implementation KRImageOperation

@synthesize doneImage;
@synthesize progress;
@synthesize _connection;
@synthesize _photoURL;
@synthesize _receivedData;
@synthesize _isExecuting, _isFinished, _isCancelled;
@synthesize _dataTotalLength;


-(id)initWithImageURL:(NSString *)_imageURL{
    self = [super init];
    if (self) {
        self._isExecuting = NO;
        self._isCancelled = NO;
        self._isFinished  = NO;
        self._photoURL    = [NSURL URLWithString:_imageURL];
        self.progress     = 0.0f;
        self.cacheMode    = NSURLRequestReloadIgnoringCacheData;
    }
    return self;
}

-(void)dealloc{
    [_connection release];
    [_photoURL release];
    
    self.doneImage = nil;
    [doneImage release];
    
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
    self._isFinished  = YES;
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
    /*
     * NSURLRequest 的 cachePolicy 參數是 NSURL 是否要「緩存」於本機端的機制。
     *
     *   一般預設為 : NSURLRequestUseProtocolCachePolicy 代表允許直接緩存至本機端，並在下次啟動 NSURLRequest 時 (即使該 NSURL 已經被 release)，
     *   不允許快取 : NSURLRequestReloadIgnoringCacheData 代表不允許緩存，每一次的 NSURLRequest 都是一次新的連線。
     */
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:self._photoURL
                                                 cachePolicy:[self _findCacheMode]
                                             timeoutInterval:30.0f];
    _connection = [[NSURLConnection alloc] initWithRequest:request
                                                  delegate:self
                                          startImmediately:NO];
    if ( self._connection ) {
        _receivedData = [[NSMutableData alloc] init];
        [self._connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
    [self._connection start];
    [self willChangeValueForKey:krImageOperationIsExecuting];
    self._isExecuting = YES;
    [self didChangeValueForKey:krImageOperationIsExecuting];
    [request release];
}

-(void)cancel {
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
    self._dataTotalLength = [response expectedContentLength];
}

- (void)connection:(NSURLConnection *)con didReceiveData:(NSData *)data{
    [self._receivedData appendData:data];
    self.progress = ( (float)[self._receivedData length] / (float)self._dataTotalLength );
    //NSLog(@"_progress : %.2f", self.progress);
}

- (void)connection:(NSURLConnection *)con didFailWithError:(NSError *)error{
    [self removeConnections];
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
}

- (void)connectionDidFinishLoading:(NSURLConnection *)con{
    self.doneImage = [UIImage imageWithData:self._receivedData];
    [self removeConnections];
}


@end
