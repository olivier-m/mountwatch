/* ------------------------------------------------------------------
DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
                   Version 2, December 2004

Copyright (C) 2010 Olivier Meunier

Everyone is permitted to copy and distribute verbatim or modified
copies of this license document, and changing it is allowed as long
as the name is changed.

           DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
  TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION

 0. You just DO WHAT THE FUCK YOU WANT TO.
------------------------------------------------------------------ */
#import <Cocoa/Cocoa.h>

@interface Listener : NSObject {
	NSString *handleScript;
}
- (void)volumeDidMount:(NSNotification *) aNotification;
- (void)volumeDidUnmount:(NSNotification *) aNotification;
@end

@implementation Listener
- (id)init:(NSString *) handleScript_ {
	[super init];
	handleScript = handleScript_;
	return self;
}
- (void)volumeDidMount:(NSNotification *) aNotification {
	@try {
		NSString* devicePath;
		devicePath = [NSString stringWithFormat: @"%@", [[aNotification userInfo] valueForKey:@"NSWorkspaceVolumeURLKey"]];
		NSLog(@"Volume mounted: %@", devicePath);

		NSTask *task = [[[NSTask alloc]init]autorelease];
		[task setLaunchPath: handleScript];
		[task setArguments: [NSArray arrayWithObjects: devicePath, nil]];
		[task launch];
		[task waitUntilExit];
	}
	@catch (NSException *exception) {
		NSLog(@"Error: %@", exception);
	}
}
- (void)volumeDidUnmount:(NSNotification *) aNotification {
	NSLog(@"Volume unmounted: %@", [[aNotification userInfo]
		valueForKey:@"NSDevicePath"]
	);
}
@end

int main(int argc, char *argv[]) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSArray *args = [[NSProcessInfo processInfo] arguments];
	if ([args count] < 2) {
		NSLog(@"Error: You should specify a handler script");
		exit(1);
	}
	
	NSString *handleScript = [args objectAtIndex:1];
	if (![[NSFileManager defaultManager] fileExistsAtPath:handleScript]) {
		NSLog(@"Error: Handler script %@ does not exist.", handleScript);
		exit(1);
	}
	
	Listener *listener = [[Listener alloc] init:handleScript];
	
	NSWorkspace *sharedWorkspace = [NSWorkspace sharedWorkspace];
	
	// Mount event listener
	[[sharedWorkspace notificationCenter] addObserver:listener
		selector:@selector(volumeDidMount:)
		name:NSWorkspaceDidMountNotification
		object:nil
	];
	
	//[[sharedWorkspace notificationCenter] addObserver:listener
	//	selector:@selector(volumeDidUnmount:)
	//	name:NSWorkspaceDidUnmountNotification object:nil
	//];
	
	[[NSRunLoop currentRunLoop] run];
	[listener release];
	[pool release];
	exit(0);
}
