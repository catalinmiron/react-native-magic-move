//
//  RCTMagicMoveClone.m
//  react-native-magic-move
//
//  Created by Hein Rutjes on 16/01/2019.
//

#import <Foundation/Foundation.h>
#import <React/UIView+React.h>
#import "RCTMagicMoveClone.h"
#import "RCTMagicMoveCloneDataManager.h"
#import "BlurEffectWithAmount.h"

#ifdef DEBUG
#define DebugLog(...) NSLog(__VA_ARGS__)
#else
#define DebugLog(...) (void)0
#endif


@implementation RCTMagicMoveClone
{
  RCTMagicMoveCloneDataManager* _dataManager;
  RCTMagicMoveCloneData* _data;
  UIVisualEffectView* _blurEffectView;
}

@synthesize id = _id;
@synthesize options = _options;
@synthesize contentType = _contentType;

- (instancetype)initWithDataManager:(RCTMagicMoveCloneDataManager*)dataManager
{
  if ((self = [super init])) {
    _dataManager = dataManager;
    _data = nil;
    _options = 0;
    _contentType = MMContentTypeChildren;
    // self.layer.masksToBounds = YES; // overflow = 'hidden'
  }
  
  return self;
}

- (void)dealloc
{
  if (_data != nil) {
    [_dataManager release:_data];
    _data = nil;
  }
}

- (void)displayLayer:(CALayer *)layer
{
  [super displayLayer:layer];
  
  if (_data == nil) return;
  
  if (_options & MMOptionVisible) {
    if (_contentType == MMContentTypeRawImage) {
      self.layer.contents =  _data.rawImage ? (id)_data.rawImage.CGImage : nil;
    }
    else if (_contentType == MMContentTypeSnapshotImage) {
      self.layer.contents =  _data.snapshotImage ? (id)_data.snapshotImage.CGImage : nil;
    }
  }
}

- (void) reactSetFrame:(CGRect)frame
{
  // This ensures that the initial clone is visible before it has
  // received any styles from the JS side
  if (frame.size.width * frame.size.height) {
    [super reactSetFrame:frame];
  }
}

- (void) setInitialData:(RCTMagicMoveCloneData*)data contentType:(MMContentType)contentType
{
  _data = data;
  _options = data.options;
  _contentType = contentType;
  [super reactSetFrame:_data.layout];
  [self.layer setNeedsDisplay];
}

- (void)setBlurRadius:(CGFloat)blurRadius
{
  blurRadius = (blurRadius <=__FLT_EPSILON__) ? 0 : blurRadius;
  if (blurRadius != _blurRadius) {
    _blurRadius = blurRadius;
    // DebugLog(@"[MagicMove] setBlurRadius: %f", blurRadius);
    //[self.layer setNeedsDisplay];
    
    if (blurRadius) {
      BlurEffectWithAmount* blurEffect = [BlurEffectWithAmount effectWithStyle:UIBlurEffectStyleLight andBlurAmount:@(blurRadius)];
      if (_blurEffectView == nil) {
        _blurEffectView = [[UIVisualEffectView alloc] init];
        _blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _blurEffectView.effect = blurEffect;
        _blurEffectView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        [self addSubview:_blurEffectView];
      }
      else {
        _blurEffectView.effect = blurEffect;
      }
    }
    else if (_blurEffectView) {
      [_blurEffectView removeFromSuperview];
      _blurEffectView = nil;
    }
  }
  
  // image = RCTBlurredImageWithRadius(image, 4.0f);
}

- (void)didSetProps:(NSArray<NSString *> *)changedProps
{
  if ((_data == nil) && (_id != nil)) {
    NSString* key = [RCTMagicMoveCloneData keyForSharedId:_id options:_options];
    _data = [_dataManager acquire:key];
  }
  [self.layer setNeedsDisplay];
}

@end
