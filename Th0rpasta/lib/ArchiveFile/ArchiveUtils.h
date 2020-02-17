//
//  ArchiveUtils.h


#ifndef ArchiveUtils_h
#define ArchiveUtils_h

#include <stdio.h>
#include <Foundation/Foundation.h>

void extractFile(NSString *fileToExtract, NSString *pathToExtractTo);
void extractSliceFile(NSString *fileToExtract);
void extractFileWithoutInjection(NSString *fileToExtract, NSString *pathToExtractTo);

#endif /* ArchiveUtils_h */
