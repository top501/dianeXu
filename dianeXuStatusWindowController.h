//
//  dianeXuStatusWindowController.h
//  This file is part of dianeXu <http://www.dianeXu.com>.
//
//  dianeXu is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  dianeXu is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with dianeXu.  If not, see <http://www.gnu.org/licenses/>.
//
//  Copyright (c) 2012-2013 Dipl.Ing.(FH) Björn Schwarz <beegz@dianeXu.com>. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface dianeXuStatusWindowController : NSWindowController {
    NSTextField *labelStatusText;
    NSProgressIndicator *_progressBar;
    NSString* statusText;
}

@property (weak) IBOutlet NSTextField *labelStatusText;
@property (weak) IBOutlet NSProgressIndicator *_progressBar;
@property (retain) NSString* statusText;

- (void)showStatusText;

@end
