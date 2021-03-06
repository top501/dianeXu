//
//  dianeXuPreferencesController.m
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

#import "dianeXuPreferencesController.h"
#import "dianeXuPreferencesKeys.h"

@implementation dianeXuPreferencesController

#pragma mark Overrides
@synthesize preferenceFilterBox;
@synthesize preferenceDEStudyBox;
@synthesize preferenceT2StudyBox;
@synthesize preferenceEAMSourceBox;
+ (void)initialize
{
    //The following defines the default settings!
    //create dictionary
    NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
    
    //archive objects
        //none as of yet
    
    //throw defaults in the dictionary
    [defaultValues setObject:[NSNumber numberWithBool:YES] forKey:dianeXuFilterKey];
    
    //register the dictionary
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
}

#pragma mark Actions
//URL reference opening via click
- (IBAction)openBugtrackerURL:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/dianeXu/dianeXu/issues"]];
}
- (IBAction)openProjectURL:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.dianeXu.com"]];
}

@end
