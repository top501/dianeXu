//
//  dianeXuITKImageWrapper.h
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

#import "OsiriXAPI/DCMPix.h"
#import "OsiriXAPI/ViewerController.h"

#include "itkImage.h"
#include "itkImportImageFilter.h"

typedef float itkPixelType;
typedef opITK::Image< itkPixelType, 3 > ImageType;
typedef opITK::ImportImageFilter< itkPixelType, 3 > ImportFilterType;

@interface dianeXuITKImageWrapper : NSObject {
    ImageType::Pointer image;
    ViewerController* activeViewer;
    double activeOrigin[3];
    double voxelSpacing[3];
    int sliceIndex;
    float* volumeData;
}

/*
 * Create a new imagewrapper from the given ViewerController's content
 */
- (id)initWithViewer:(ViewerController*)sourceViewer andSlice:(int)slice;

/*
 * Get a pointer to the ITK image
 */
- (ImageType::Pointer)image;

/*
 * Update the imagewrapper to reflect changes in the viewer
 */
- (void)updateWrapper;

@end
