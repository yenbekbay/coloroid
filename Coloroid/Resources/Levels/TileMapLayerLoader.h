//
//  TileMapLayerLoader.h
//  Coloroid
//
//  Created by Ayan Yenbekbay on 4/18/14.
//  Copyright (c) 2014 Ayan Yenbekbay. All rights reserved.
//

#import "TileMapLayer.h"

@interface TileMapLayerLoader : NSObject

+ (TileMapLayer *)tileMapLayerFromFileNamed:(NSString *)fileName
                                     isGoal:(BOOL)goal;
    
@end
