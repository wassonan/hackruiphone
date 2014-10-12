//
//  Soc.m
//  Surroundr
//
//  Created by Ben Kropf on 10/11/14.
//  Copyright (c) 2014 benkropf. All rights reserved.
//

#import <Foundation/Foundation.h>

#include <netinet/in.h>
#include <sys/socket.h>
#include <unistd.h>
#include <arpa/inet.h>

#include <CFNetwork/CFNetwork.h>

@interface Surroundr : NSObject <NSStreamDelegate>

@end

@implementation Surroundr {
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
    BOOL canWrite;
}

- (void)sendBroadcastPacket {
    
    // Open a socket
    int sd = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP);
    if (sd<=0) {
        NSLog(@"Error: Could not open socket");
        return;
    }
    
    // Set socket options
    // Enable broadcast
    int broadcastEnable=1;
    int ret=setsockopt(sd, SOL_SOCKET, SO_BROADCAST, &broadcastEnable, sizeof(broadcastEnable));
    if (ret) {
        NSLog(@"Error: Could not open set socket to broadcast mode");
        close(sd);
        return;
    }
    
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)@"HOSTNAME", 48317, &readStream, &writeStream);
    
    inputStream = (__bridge  NSInputStream*)readStream;
    outputStream = (__bridge  NSOutputStream*)writeStream;
    
    
    inputStream.delegate = self;
    outputStream.delegate = self;
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    // Since we don't call bind() here, the system decides on the port for us, which is what we want.
    
    // Configure the port and ip we want to send to
    struct sockaddr_in broadcastAddr; // Make an endpoint
    memset(&broadcastAddr, 0, sizeof broadcastAddr);
    broadcastAddr.sin_family = AF_INET;
    inet_pton(AF_INET, "239.255.255.250", &broadcastAddr.sin_addr); // Set the broadcast IP address
    broadcastAddr.sin_port = htons(1900); // Set port 1900
    
    // Send the broadcast request, ie "Any upnp devices out there?"
    char *request = "M-SEARCH * HTTP/1.1\r\nHOST:239.255.255.250:1900\r\nMAN:\"ssdp:discover\"\r\nST:ssdp:all\r\nMX:1\r\n\r\n";
    ret = (int)sendto(sd, request, strlen(request), 0, (struct sockaddr*)&broadcastAddr, sizeof broadcastAddr);
    if (ret<0) {
        NSLog(@"Error: Could not open send broadcast");
        close(sd);
        return;
    }
    
    // Get responses here using recvfrom if you want...
    close(sd);
}

-(void) writeToStream {
    if (canWrite) {
        // Write data
        canWrite = NO;
    } else {
        // Store data to be written
    }
}

// 224.0.0.2

-(void) stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    if (eventCode == NSStreamEventHasBytesAvailable) {
        // You have data to be read
    } else if (eventCode == NSStreamEventHasSpaceAvailable) {
        // You can write to this
        
        // If have bytes to write
        // - write them
        // - canWrite = NO;
        
        // else
        canWrite = YES;
    } else if (eventCode == NSStreamEventErrorOccurred) {
        // Error
    } else if (eventCode == NSStreamEventEndEncountered) {
        
    } else if (eventCode == NSStreamEventOpenCompleted) {
        // Stream exists
    }
    
    
}

@end
