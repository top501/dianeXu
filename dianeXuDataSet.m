//
//  dianeXuDataSet.m
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

#import "dianeXuDataSet.h"

@implementation dianeXuDataSet

- (id)init {
    self = [super init];
    if (status == nil) {
        status = [[dianeXuStatusWindowController alloc] initWithWindowNibName:@"dianeXuStatusWindow"];
    }
    primarySpacing = [[dianeXuCoord alloc] init];
    primaryOrigin = [[dianeXuCoord alloc] init];
    secondarySpacing = [[dianeXuCoord alloc] init];
    secondaryOrigin = [[dianeXuCoord alloc] init];
    eamPoints = [[NSMutableArray alloc] init];
    return self;
}

- (void)eamROItoController: (ViewerController*)targetController {
    //prepare needed data
    dianeXuCoord* pixelGeometry = [[dianeXuCoord alloc] init];
    DCMPix* slice = [[targetController pixList] objectAtIndex:0];
    NSMutableArray* pointsROI = [[NSMutableArray alloc] init];
    
    [pixelGeometry setX:[NSNumber numberWithDouble:[slice pixelSpacingX]]];
    [pixelGeometry setY:[NSNumber numberWithDouble:[slice pixelSpacingY]]];
    [pixelGeometry setZ:[NSNumber numberWithDouble:[slice sliceThickness]]];
    
    NSLog(@"%u",[eamPoints count]);
    for (dianeXuCoord* currentCoord in eamPoints) {
        dianeXuCoord* tmpCoord = [[dianeXuCoord alloc] init];
         NSLog(@"%@",tmpCoord);
        [tmpCoord setX:[NSNumber numberWithDouble:[[currentCoord x] doubleValue]/[[pixelGeometry x] doubleValue]]];
        [tmpCoord setY:[NSNumber numberWithDouble:[[currentCoord y] doubleValue]/[[pixelGeometry y] doubleValue]]];
        [tmpCoord setZ:[NSNumber numberWithDouble:[[currentCoord z] doubleValue]/[[pixelGeometry z] doubleValue]]];
        [pointsROI addObject:[tmpCoord copy]];
        tmpCoord = nil;
    }
    
    NSLog(@"%@",[pointsROI objectAtIndex:0]);
    
}

- (void)makePointsFromNavxString:(NSString *)inputString:(int)pointCount {
    //+status
    [status showWindow:self];
    [[status window] orderFrontRegardless];
    [status setStatusText:@"Reading NavX coordinates to dianeXu..."];
    int statusDone = 0;
    //-status
    
    NSMutableArray *lineCoords = [[inputString componentsSeparatedByString:@"\n"] mutableCopy];
    //trim lines
    [lineCoords removeObjectAtIndex:0];
    [lineCoords removeLastObject];
    
    
    for (NSString *singleCoord in lineCoords) {
        dianeXuCoord *currentCoord = [[dianeXuCoord alloc] init];
        
        //trim junk from the single lines
        NSString *trimmedSingleCoord = [singleCoord stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        //seperate the coords
        NSArray *justCoords = [trimmedSingleCoord componentsSeparatedByString:@"  "];
        
        //set coordinate values and add to eamPoints array.
        [currentCoord setX:[NSNumber numberWithDouble:[[justCoords objectAtIndex:0]  doubleValue]]];
        [currentCoord setY:[NSNumber numberWithDouble:[[justCoords objectAtIndex:1]  doubleValue]]];
        [currentCoord setZ:[NSNumber numberWithDouble:[[justCoords objectAtIndex:2]  doubleValue]]];
         
        [eamPoints addObject:currentCoord];
        
        currentCoord = nil;
        
        //+status
        statusDone++;
        [status setStatusPercent:(int)statusDone/pointCount];
        //-status
    }
    
    //+status
    [[status window] orderOut:self];
    [status setStatusPercent:0];
    NSLog(@"%u",[eamPoints count]);
    //-status
}


- (void)updateGeometryInfoFrom:(ViewerController *)primeViewer andFrom:(ViewerController *)secondViewer {
    //get the first images of each viewer
    DCMPix* primeSlice = [[primeViewer pixList] objectAtIndex:0];
    DCMPix* secondSlice = [[secondViewer pixList] objectAtIndex:0];
    
    [primarySpacing setX:[NSNumber numberWithDouble:[primeSlice pixelSpacingX]]];
    [primarySpacing setY:[NSNumber numberWithDouble:[primeSlice pixelSpacingY]]];
    [primarySpacing setZ:[NSNumber numberWithDouble:[primeSlice sliceThickness]]];
    
    [secondarySpacing setX:[[NSNumber alloc] initWithDouble:[secondSlice pixelSpacingX]]];
    [secondarySpacing setY:[[NSNumber alloc] initWithDouble:[secondSlice pixelSpacingY]]];
    [secondarySpacing setZ:[[NSNumber alloc] initWithDouble:[secondSlice sliceThickness]]];
    
    NSLog(@"Updated prime geometry info to psX:%@, psY:%@, psZ:%@",[primarySpacing x],[primarySpacing y],[primarySpacing z]);
    NSLog(@"Updated scnd geometry info to psX:%@, psY:%@, psZ:%@",[secondarySpacing x],[secondarySpacing y],[secondarySpacing z]);
}


@end
