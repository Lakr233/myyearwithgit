//
//  AskBeforeCloseMyWindow.swift
//
//
//  Created by Lakr Aream on 2021/11/30.
//

#import <AppKit/AppKit.h>
#import <objc/runtime.h>

static void HookMessage(Class cls, SEL selName, IMP replaced, IMP *orig) {
    Method origMethod = class_getInstanceMethod(cls, selName);
    if (!origMethod) {
        printf("nullprt origMethod, check class and selector name\n");
        return;
    }
    *orig = method_setImplementation(origMethod, replaced);
#ifdef DEBUG
    printf("HookMessage %p -> %p <%s>\n", orig, replaced, [NSStringFromClass(cls) UTF8String]);
#endif
}

static void (*original_NSWindow_close)(NSWindow *self, SEL _cmd);
static void replaced_NSWindow_close(NSWindow *self, SEL _cmd)
{
    NSString *className = NSStringFromClass([self class]);
    if (![className isEqualToString:@"SwiftUI.SwiftUIWindow"]) {
        original_NSWindow_close(self, _cmd);
        return;
    }
    
    // check if we need to perform this action
    NSString *userDefaultKey = @"wiki.qaq.window.confirm.close";
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:userDefaultKey] boolValue] != YES) {
        original_NSWindow_close(self, _cmd);
        exit(0);
        return;
    }
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setAlertStyle:NSAlertStyleCritical];
    [alert setMessageText:@"关闭窗口将不会保存你的分析记录。"];
    [alert addButtonWithTitle:@"确定"];
    [alert addButtonWithTitle:@"取消"];
    NSWindow *window = [NSApp keyWindow];
    if (window) {
        [alert beginSheetModalForWindow:window completionHandler:^(NSModalResponse returnCode) {
            if (returnCode == NSAlertFirstButtonReturn) {
                exit(0);
            }
        }];
    } else {
        if ([alert runModal] == NSAlertFirstButtonReturn) {
            exit(0);
        }
    }
    return;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

__attribute__((constructor))
static void makeMyMagicWork(void) {
    // do our magic
    HookMessage(
        objc_getClass("NSWindow"),
        NSSelectorFromString(@"close"),
        (IMP)&replaced_NSWindow_close,
        (IMP *)&original_NSWindow_close
    );
}

#pragma clang diagnostic pop
