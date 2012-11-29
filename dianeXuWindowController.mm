//
//  dianeXuWindowController.mm
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
//  Copyright (c) 2012 Dipl.Ing.(FH) Björn Schwarz <beegz@dianeXu.com>. All rights reserved.
//

#import "dianeXuWindowController.h"
#import <OsiriXAPI/PreferencesWindowController.h>

@interface dianeXuWindowController ()


@end

@implementation dianeXuWindowController
@synthesize currentStep;
@synthesize buttonNext;
@synthesize buttonPrev;
@synthesize tabStep;
@synthesize pathEAM;
@synthesize labelEAMSource;
@synthesize labelEAMNumCoords;
@synthesize buttonInfo;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        //set properties
        workingSet = [[dianeXuDataSet alloc] init];
        currentStep = 0;
        defaultSettings = [NSUserDefaults standardUserDefaults];
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    //update the GUI according to step
    [self updateStepGUI:currentStep];
}

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
    [self updateStepGUI:currentStep];
}

- (IBAction)pushNext:(id)sender {
    currentStep++; //increment the Step
    [self updateStepGUI:currentStep];
}

- (IBAction)pushPrev:(id)sender {
    currentStep--; //decrement the Step
    [self updateStepGUI:currentStep];
}

- (IBAction)pushQuit:(id)sender {
    [[self window] orderOut:self];
}

- (IBAction)pushInfo:(id)sender {
    NSRunInformationalAlertPanel(@"DEBUG:", @"Infopopup", @"OK", nil, nil,nil);
}

- (IBAction)pushGetEAMData:(id)sender {
    XmlRetrieve *retrieve = [[XmlRetrieve alloc] init];
    NSError *error = nil;
    NSString * rawData;
    [labelEAMNumCoords setStringValue:[NSString stringWithFormat:@"%d",[retrieve retrieveNavxVertixCount:[pathEAM URL] :&error]]]; //get Number of vertices and Show!
    rawData = [retrieve retrieveNavxDataFrom:[pathEAM URL] :&error];
    NSRunInformationalAlertPanel(@"DEBUG:", rawData, @"OK", nil, nil,nil);
}

- (void)updateStepGUI: (int)toStep
{
    switch (toStep) {
        case 0:
            [buttonPrev setEnabled:FALSE];
            [buttonNext setEnabled:TRUE];
            [tabStep selectTabViewItemAtIndex:toStep];
            break;
            
        case 1:
            [buttonPrev setEnabled:TRUE];
            [buttonNext setEnabled:TRUE];
            [tabStep selectTabViewItemAtIndex:toStep];
            [labelEAMSource setStringValue:[[NSUserDefaults standardUserDefaults] valueForKey:dianeXuEAMSourceKey]];
            break;
            
        case 2:
            [buttonPrev setEnabled:TRUE];
            [buttonNext setEnabled:TRUE];
            [tabStep selectTabViewItemAtIndex:toStep];
            break;
            
        case 3:
            [buttonPrev setEnabled:TRUE];
            [buttonNext setEnabled:TRUE];
            [tabStep selectTabViewItemAtIndex:toStep];
            break;
            
        case 4:
            [buttonPrev setEnabled:TRUE];
            [buttonNext setEnabled:FALSE];
            [tabStep selectTabViewItemAtIndex:toStep];
            break;
            
        default:
            
            break;
    }
}

@end
