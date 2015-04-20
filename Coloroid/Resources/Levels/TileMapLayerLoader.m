//
//  TileMapLayerLoader.m
//  Coloroid
//
//  Created by Ayan Yenbekbay on 4/18/14.
//  Copyright (c) 2014 Ayan Yenbekbay. All rights reserved.
//

#import "TileMapLayerLoader.h"

@implementation TileMapLayerLoader

+ (TileMapLayer *)tileMapLayerFromFileNamed:(NSString *)fileName
                                     isGoal:(BOOL)goal {
  // file must be in bundle
  NSString *path = [[NSBundle mainBundle] pathForResource:fileName
                                                   ofType:nil];
  NSError *error;
  NSString *fileContents = [NSString stringWithContentsOfFile:path
                                                     encoding:NSUTF8StringEncoding
                                                        error:&error];
  // if there was an error, there is nothing to be done
  if (fileContents == nil && error) {
    NSLog(@"Error reading file: %@", error.localizedDescription);
    return nil;
  }

  // get the contents of the file, separated into lines
  NSArray *lines = [fileContents componentsSeparatedByString:@"\n"];

  // remaining lines are the grid. It's assumed that all rows are same length
  NSArray *grid = [lines subarrayWithRange:NSMakeRange(0, lines.count)];

  return [[TileMapLayer alloc] initWithGrid:grid
                                     isGoal:goal];
}

@end
