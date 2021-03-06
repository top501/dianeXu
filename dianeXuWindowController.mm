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
//  Copyright (c) 2012-2013 Dipl.Ing.(FH) Björn Schwarz <beegz@dianeXu.com>. All rights reserved.
//

#import "dianeXuWindowController.h"
#import "dianeXuITK3dRegionGrowing.h"
#import "dianeXuITKPointSetRegistration.h"

#import <OsiriXAPI/PreferencesWindowController.h>

@interface dianeXuWindowController ()

@end

@implementation dianeXuWindowController
@synthesize labelEAMNumCoords;
@synthesize labelLesionNumCoords;
@synthesize boxSegAlgorithm;
@synthesize labelXmm;
@synthesize labelYmm;
@synthesize labelZmm;
@synthesize labelXpx;
@synthesize labelYpx;
@synthesize labelZpx;
@synthesize labelValue;
@synthesize textLowerThreshold;
@synthesize textUpperThreshold;
@synthesize checkPreview;
@synthesize labelLowerThresholdProposal;
@synthesize labelUpperThresholdProposal;
@synthesize segDifRoi;
@synthesize segSteponeRoi;
@synthesize segDifToggle;
@synthesize segSteponeToggle;
@synthesize segEamToggle;
@synthesize segLesionToggle;
@synthesize segAllToggle;
@synthesize segRegistratedRoi;
@synthesize buttonShowToggledRois;
@synthesize buttonRegisterModels;
@synthesize labelVisDifCount;
@synthesize labelVisAngioCount;
@synthesize labelVisEamCount;
@synthesize labelVisLesionCount;
@synthesize mainViewer,scndViewer;
@synthesize currentStep;
@synthesize buttonNext,buttonPrev,buttonInfo;
@synthesize tabStep;
@synthesize pathEAM;
@synthesize labelEAMSource,labelMRINumCoords;

#pragma mark Init and delegate methods
/*
 * Custom window initialization
 */
- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        //set member variables
        statusWindow = [[dianeXuStatusWindowController alloc]initWithWindowNibName:@"dianeXuStatusWindow"];
        workingSet = [[dianeXuDataSet alloc] init];
        currentStep = 0;
        defaultSettings = [NSUserDefaults standardUserDefaults];
        
        //register for important notifications
        NSNotificationCenter *nc;
        nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(mouseViewerDown:) name:@"mouseDown" object:nil];
    }
    return self;
}

/*
 * Initializes the plugin window with two viewers
 */
- (id) initWithViewer: (ViewerController*)mViewer andViewer: (ViewerController*)sViewer {
    
    self = [super initWithWindowNibName:@"dianeXuWindow"];
    
    defaultSettings = [NSUserDefaults standardUserDefaults];
    workingSet = [[dianeXuDataSet alloc] init];
    currentStep = 0;
    
    if (self != nil) {
        mainViewer = mViewer;
        scndViewer = sViewer;
    }
    return self;
}

/*
 * run when the window is finished loading to pdate some parts of the gui
 */
- (void)windowDidLoad
{
    [super windowDidLoad];
    //update the GUI according to step
    [self updateStepGUI:currentStep];
}

/*
 * TabView method to do stuff when an item in the TabView is selected
 */
- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
    [self updateStepGUI:currentStep];
}

/*
 * Make the controller react to mousedowns in the viewer
 */
-(void) mouseViewerDown:(NSNotification*)note {
    if ([note object] == mainViewer && currentStep == 0) {
        int pxX, pxY, pxZ;
        float mmX, mmY, mmZ;
        
        pxX = [[[note userInfo] objectForKey:@"X"] intValue];
        pxY = [[[note userInfo] objectForKey:@"Y"] intValue];
        pxZ = [[mainViewer imageView] curImage];
        
        float loc[3];
        [[[mainViewer imageView] curDCM] convertPixX:(float)pxX pixY:(float)pxY toDICOMCoords:(float*)loc pixelCenter:YES];
        mmX = loc[0];
        mmY = loc[1];
        mmZ = loc[2];
        
        [labelXpx setStringValue:[NSString stringWithFormat:@"%d",pxX]];
        [labelYpx setStringValue:[NSString stringWithFormat:@"%d",pxY]];
        [labelZpx setStringValue:[NSString stringWithFormat:@"slice %d",pxZ]];
        
        [labelXmm setStringValue:[NSString stringWithFormat:@"%2.2f",mmX]];
        [labelYmm setStringValue:[NSString stringWithFormat:@"%2.2f",mmY]]; //switch y and z to account for MRI coordinates
        [labelZmm setStringValue:[NSString stringWithFormat:@"%2.2f",mmZ]];
        
        float value = [[[mainViewer imageView] curDCM] getPixelValueX:pxX Y:pxY];
        [labelValue setStringValue:[NSString stringWithFormat:@"%2.0f",value]];
        
        [textLowerThreshold setStringValue:[NSString stringWithFormat:@"%2.0f",value-50]];
        [textUpperThreshold setStringValue:[NSString stringWithFormat:@"%2.0f",value+50]];
        [labelLowerThresholdProposal setStringValue:[NSString stringWithFormat:@"(%2.0f proposed)",value-50]];
        [labelUpperThresholdProposal setStringValue:[NSString stringWithFormat:@"(%2.0f proposed)",value+50]];
        
        if ([checkPreview state] == NSOnState) {
            NSLog(@"dianeXu: Previewing segmentation.");
            NSString* roiName = [NSString stringWithFormat:@"dianeXu segmentation preview"];
            NSColor* roiColor = [NSColor colorWithCalibratedRed:1.0f green:.1f blue:0.1f alpha:1.0f];
            [mainViewer roiIntDeleteAllROIsWithSameName:roiName];
            dianeXuITK3dRegionGrowing* previewSegmentation = [[dianeXuITK3dRegionGrowing alloc] initWithViewer:mainViewer];
            [previewSegmentation start3dRegionGrowingAt:pxZ withSeedPoint:NSMakePoint(pxX, pxY) usingRoiName:roiName andRoiColor:roiColor withAlgorithm:0 lowerThreshold:[[textLowerThreshold stringValue] floatValue]  upperThreshold:[[textUpperThreshold stringValue] floatValue] outputResolution:8];
            [previewSegmentation release];
        }
        [[note userInfo] setValue:[NSNumber numberWithBool:YES] forKey:@"stopMouseDown"];
    }
}

#pragma mark Utility Methods
/*
 * Method to update the gui according to selected step in TabView
 */
- (void)updateStepGUI: (int)toStep
{
    switch (toStep) {
        case 0:
            [buttonPrev setEnabled:FALSE];
            [buttonNext setEnabled:TRUE];
            [mainViewer roiIntDeleteAllROIsWithSameName:@"dianeXu difGeometry"];
            [mainViewer roiIntDeleteAllROIsWithSameName:@"dianeXu eamGeometry"];
            [mainViewer roiIntDeleteAllROIsWithSameName:@"dianeXu lesionGeometry point"];
            [tabStep selectTabViewItemAtIndex:toStep];
            break;
            
        case 1:
            [buttonPrev setEnabled:TRUE];
            [buttonNext setEnabled:TRUE];
            [mainViewer roiIntDeleteAllROIsWithSameName:@"dianeXu angioGeometry"];
            [mainViewer roiIntDeleteAllROIsWithSameName:@"dianeXu segmentation preview"];
            [tabStep selectTabViewItemAtIndex:toStep];
            [labelEAMSource setStringValue:[[NSUserDefaults standardUserDefaults] valueForKey:dianeXuEAMSourceKey]];
            break;
            
        case 2:
            [buttonPrev setEnabled:TRUE];
            [buttonNext setEnabled:TRUE];
            [mainViewer roiIntDeleteAllROIsWithSameName:@"dianeXu difGeometry"];
            [mainViewer roiIntDeleteAllROIsWithSameName:@"dianeXu angioGeometry"];
            [mainViewer roiIntDeleteAllROIsWithSameName:@"dianeXu segmentation preview"];
            [mainViewer roiIntDeleteAllROIsWithSameName:@"dianeXu eamGeometry"];
            [mainViewer roiIntDeleteAllROIsWithSameName:@"dianeXu lesionGeometry point"];
            [tabStep selectTabViewItemAtIndex:toStep];
            break;
            
        case 3:
            [buttonPrev setEnabled:TRUE];
            [buttonNext setEnabled:TRUE];
            [mainViewer roiIntDeleteAllROIsWithSameName:@"dianeXu difGeometry"];
            [mainViewer roiIntDeleteAllROIsWithSameName:@"dianeXu angioGeometry"];
            [mainViewer roiIntDeleteAllROIsWithSameName:@"dianeXu segmentation preview"];
            [mainViewer roiIntDeleteAllROIsWithSameName:@"dianeXu eamGeometry"];
            [mainViewer roiIntDeleteAllROIsWithSameName:@"dianeXu lesionGeometry point"];
            [self updateLabelsGUI]; // make sure the labels are up to date
            [tabStep selectTabViewItemAtIndex:toStep];
            [buttonShowToggledRois setEnabled:YES];
            break;
            
        case 4:
            [buttonPrev setEnabled:TRUE];
            [buttonNext setEnabled:FALSE];
            [mainViewer roiIntDeleteAllROIsWithSameName:@"dianeXu difGeometry"];
            [mainViewer roiIntDeleteAllROIsWithSameName:@"dianeXu angioGeometry"];
            [mainViewer roiIntDeleteAllROIsWithSameName:@"dianeXu segmentation preview"];
            [mainViewer roiIntDeleteAllROIsWithSameName:@"dianeXu eamGeometry"];
            [mainViewer roiIntDeleteAllROIsWithSameName:@"dianeXu lesionGeometry point"];
            [tabStep selectTabViewItemAtIndex:toStep];
            break;
            
        default:
            NSLog(@"Huh? I have no idea what that step is supposed to be. Sorry.");
            break;
    }
}

/*
 * Method to update all general labels to their respective Values
 */
- (void) updateLabelsGUI {
    [labelMRINumCoords setStringValue:[NSString stringWithFormat:@"%d",[[workingSet difGeometry] count]]];
    [labelEAMNumCoords setStringValue:[NSString stringWithFormat:@"%d",[[workingSet eamGeometry] count]]];
    [labelLesionNumCoords setStringValue:[NSString stringWithFormat:@"%d",[[workingSet lesionGeometry] count]]];
    [labelVisAngioCount setStringValue:[NSString stringWithFormat:@"%d",[[workingSet angioGeometry] count]]];
    [labelVisDifCount setStringValue:[NSString stringWithFormat:@"%d",[[workingSet difGeometry] count]]];
    [labelVisEamCount setStringValue:[NSString stringWithFormat:@"%d",[[workingSet eamGeometry] count]]];
    [labelVisLesionCount setStringValue:[NSString stringWithFormat:@"%d",[[workingSet lesionGeometry] count]]];
}

#pragma mark IBAction implementations
/*
 * IBAction implementations start here
 */
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
    //TODO: Clean up everything (especially observers) before deallocating!
    //[self dealloc];
}

- (IBAction)pushInfo:(id)sender {
    //TODO: Insert info popup about the working set and used viewers
}

- (IBAction)pushGetNavxData:(id)sender {
    [statusWindow setStatusText:@"Importing NavX data..."];
    [statusWindow showStatusText];
    NavxImport *retrieve = [[NavxImport alloc] init];
    NSError *error = nil;

    [retrieve retrieveNavxDataFrom:[pathEAM URL] withError:&error];
    [workingSet setDifGeometry:[[retrieve difGeometry] copy]];
    [workingSet setEamGeometry:[[retrieve eamGeometry] copy]];
    [workingSet setLesionGeometry:[[retrieve lesionGeometry] copy]];
    
    [retrieve dealloc];
    
    // update interface
    [self updateLabelsGUI];
    
    // Enable show ROI button now that we have the data
    [segDifRoi setEnabled:YES];
    [buttonRegisterModels setEnabled:YES];
    [[statusWindow window] orderOut:nil];
}

- (IBAction)pushDifRoi:(id)sender {
//  NSLog(@"%@",[workingSet difGeometry]);
    if ([segDifRoi selectedSegment] == 0) {
        [mainViewer roiIntDeleteAllROIsWithSameName:@"dianeXu difGeometry"];
        [workingSet modelROItoController:mainViewer forGeometry:@"difGeometry"];
    } else {
        [mainViewer roiIntDeleteAllROIsWithSameName:@"dianeXu difGeometry"];
    }

}

- (IBAction)pushSegCompute:(id)sender {
    if ([[labelXpx stringValue] floatValue] == 0 && [[labelYpx stringValue] floatValue] == 0) {
        NSRunInformationalAlertPanel(@"WARNING", @"First select a seedpoint by clicking into the image!", @"OK", nil, nil,nil);
        return;
    }
    NSString* roiName = [NSString stringWithFormat:@"dianeXu angioGeometry"];
    NSColor* roiColor = [NSColor colorWithCalibratedRed:1.0f green:0.1f blue:0.1f alpha:1.0f];
    // clear old ROIs
    [mainViewer roiIntDeleteAllROIsWithSameName:@"dianeXu segmentation preview"];
    [mainViewer roiIntDeleteAllROIsWithSameName:roiName];
    // perform segmentation
    dianeXuITK3dRegionGrowing* computeSegmentation = [[dianeXuITK3dRegionGrowing alloc] initWithViewer:mainViewer];
    NSMutableArray* segmentedModel = [computeSegmentation start3dRegionGrowingAt:-1 withSeedPoint:NSMakePoint((float)[[labelXpx stringValue] floatValue], (float)[[labelYpx stringValue] floatValue]) usingRoiName:roiName andRoiColor:roiColor withAlgorithm:0 lowerThreshold:[[textLowerThreshold stringValue] floatValue]  upperThreshold:[[textUpperThreshold stringValue] floatValue] outputResolution:4];
    [computeSegmentation release];
    [workingSet setAngioGeometry:segmentedModel];
    // enable related gui components
    [segSteponeRoi setEnabled:YES];
}

- (IBAction)pushRegisterModels:(id)sender {
    [statusWindow setStatusText:@"Performing registration... grab a coffee, this may take a while"];
    [statusWindow showStatusText];
    dianeXuITKPointSetRegistration* reg = [[dianeXuITKPointSetRegistration alloc] initWithFixedSet:[workingSet angioGeometry] andMovingSet:[workingSet eamGeometry]];
    [reg performRegistration:0];
    [workingSet setEamGeometry:[reg transformPoints:[workingSet eamGeometry]]];
    [workingSet setLesionGeometry:[reg transformPoints:[workingSet lesionGeometry]]];
//  NSLog(@"%@ %@",[workingSet angioGeometry],[workingSet eamGeometry]);
    [[statusWindow window] orderOut:nil];
    // enable related gui components
    [segRegistratedRoi setEnabled:YES];
    [reg release];
}

- (IBAction)pushRegistratedROI:(id)sender {
    if ([segRegistratedRoi selectedSegment] == 0) {
        [mainViewer roiIntDeleteAllROIsWithSameName:@"dianeXu eamGeometry"];
        [mainViewer roiIntDeleteAllROIsWithSameName:@"dianeXu lesionGeometry point"];
        [workingSet modelROItoController:mainViewer forGeometry:@"eamGeometry"];
        [workingSet modelPointsToController:mainViewer forGeometry:@"lesionGeometry"];
    } else {
        [mainViewer roiIntDeleteAllROIsWithSameName:@"dianeXu eamGeometry"];
        [mainViewer roiIntDeleteAllROIsWithSameName:@"dianeXu lesionGeometry point"];
    }
}

- (IBAction)pushSteponeRoi:(id)sender {
    if ([segSteponeRoi selectedSegment] == 0) {
        [mainViewer roiIntDeleteAllROIsWithSameName:@"dianeXu angioGeometry"];
        [workingSet modelROItoController:mainViewer forGeometry:@"angioGeometry"];
    } else {
        [mainViewer roiIntDeleteAllROIsWithSameName:@"dianeXu angioGeometry"];
    }
}

- (IBAction)pushShowToggledRois:(id)sender {
    // remove old rois
    [scndViewer roiIntDeleteAllROIsWithSameName:@"dianeXu difGeometry"];
    [scndViewer roiIntDeleteAllROIsWithSameName:@"dianeXu eamGeometry"];
    [scndViewer roiIntDeleteAllROIsWithSameName:@"dianeXu lesionGeometry"];
    [scndViewer roiIntDeleteAllROIsWithSameName:@"dianeXu angioGeometry"];
    
    // show new rois if selected
    if ([segDifToggle selectedSegment] == 0) {
        [workingSet modelROItoController:scndViewer forGeometry:@"difGeometry"];
    }
    if ([segEamToggle selectedSegment] == 0) {
        [workingSet modelROItoController:scndViewer forGeometry:@"eamGeometry"];
    }
    if ([segLesionToggle selectedSegment] == 0) {
        [workingSet modelPointsToController:scndViewer forGeometry:@"lesionGeometry"];
    }
    if ([segSteponeToggle selectedSegment] == 0) {
        [workingSet modelROItoController:scndViewer forGeometry:@"angioGeometry"];
    }
}

- (IBAction)pushToggleAllRois:(id)sender {
    if ([segAllToggle selectedSegment] == 0) {
        [segDifToggle setSelectedSegment:0];
        [segEamToggle setSelectedSegment:0];
        [segLesionToggle setSelectedSegment:0];
        [segSteponeToggle setSelectedSegment:0];
    } else {
        [segDifToggle setSelectedSegment:1];
        [segEamToggle setSelectedSegment:1];
        [segLesionToggle setSelectedSegment:1];
        [segSteponeToggle setSelectedSegment:1];
    }
}
@end
