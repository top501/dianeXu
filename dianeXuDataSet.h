//
//  dianeXuDataSet.h
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

#import <Foundation/Foundation.h>
#import "dianeXuCoord.h"
#import "dianeXuStatusWindowController.h"
#import <OsiriXAPI/ROI.h>
#import <OsiriXAPI/ViewerController.h>
#import <OsiriXAPI/DCMView.h>
#import <OsiriXAPI/DCMPix.h>

@interface dianeXuDataSet : NSObject {
    NSMutableArray* eamGeometry;
    NSMutableArray* difGeometry;
    NSMutableArray* lesionGeometry;
    NSMutableArray* angioGeometry;
}

@property (retain,nonatomic) NSMutableArray* difGeometry;
@property (retain,nonatomic) NSMutableArray* eamGeometry;
@property (retain,nonatomic) NSMutableArray* lesionGeometry;
@property (retain,nonatomic) NSMutableArray* angioGeometry;

/*
 * output model data as roi to a viewer controller
 */
- (void)modelROItoController:(ViewerController*)targetController forGeometry:(NSString*)geometry;

/*
 * output model data as point rois to a viewer controller
 */
- (void)modelPointsToController:(ViewerController*)targetController forGeometry:(NSString*)geometry;

/*
 * reduce the number of points in a model to be lower than maxPoints.
 */
- (NSMutableArray*)reduceModelPointsOf:(NSMutableArray*)inArray to:(int)maxPoints;

/*
 * custom setters for all models using the number reduce
 */
- (void)setAngioGeometry:(NSMutableArray *)inGeometry;
- (void)setDifGeometry:(NSMutableArray *)inGeometry;
- (void)setEamGeometry:(NSMutableArray *)inGeometry;
- (void)setLesionGeometry:(NSMutableArray *)inGeometry;

/*
 * sort the points of a roi slice in circular fashion to approcimate the closed polygon order.
 */
+ (void)sortClockwise:(NSMutableArray*)sortArray;

@end
