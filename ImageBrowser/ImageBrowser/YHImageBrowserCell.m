//
//  YHImageBrowserCell.m
//  HiFanSmooth
//
//  Created by apple on 2019/5/14.
//  Copyright © 2019 yinhe. All rights reserved.
//

#import "YHImageBrowserCell.h"

#import "YHImageBrowserCellProtocol.h"

#import "YHImageBrowserCellData.h"
#import "YHImageBrowserCellData+Private.h"

#import "YHImageBrowserLayoutDirectionManager.h"


#import <FLAnimatedImage/FLAnimatedImage.h>

@interface YHImageBrowserCell() <YHImageBrowserCellProtocol, UIScrollViewDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIScrollView *mainScrollView;
@property (nonatomic, strong) FLAnimatedImageView *mainImageView;

@property (nonatomic, strong) YHImageBrowserCellData *cellData;


@property (nonatomic, assign) YHImageBrowserLayoutDirection layoutDirection;
@property (nonatomic, assign) CGSize containerSize;

@end


@implementation YHImageBrowserCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.mainScrollView];
        [self.mainScrollView addSubview:self.mainImageView];
        
        [self addGesture];
    }
    return self;
}

- (void)prepareForReuse{
    // 复原
    self.mainScrollView.zoomScale = 1;
    self.mainImageView.image = nil;
    
    [self removeObserverForDataState];
    
    [super prepareForReuse];
}


- (void)addGesture {
    UITapGestureRecognizer *tapSingle = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondsToTapSingle:)];
    tapSingle.numberOfTapsRequired = 1;
    UITapGestureRecognizer *tapDouble = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondsToTapDouble:)];
    tapDouble.numberOfTapsRequired = 2;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(respondsToPan:)];
    pan.maximumNumberOfTouches = 1;
    pan.delegate = self;
    
    [tapSingle requireGestureRecognizerToFail:tapDouble];
    [tapSingle requireGestureRecognizerToFail:pan];
    [tapDouble requireGestureRecognizerToFail:pan];
    
    [self.mainScrollView addGestureRecognizer:tapSingle];
    [self.mainScrollView addGestureRecognizer:tapDouble];
    [self.mainScrollView addGestureRecognizer:pan];
}



// 更新ScrollView的Frame
- (void)updateContentScrollViewLayout{
    self.mainScrollView.frame = CGRectMake(0, 0, self.containerSize.width, self.containerSize.height);
}

// 更新mainImageView的Frame
- (void)updateContentViewLayout{
    CGSize imageSize;
    if (self.cellData.image) {
        if (self.cellData.image.image) {
            imageSize = self.cellData.image.image.size;
        }
    } else if (self.cellData.thumbImage) {
        imageSize = self.cellData.thumbImage.size;
    } else {
        return;
    }
    
    CGFloat width = 0;
    CGFloat height = 0;
    CGFloat x = 0;
    CGFloat y = 0;
    
    width = self.containerSize.width; // 宽度抵满屏幕
    height = width * (imageSize.height / imageSize.width); // 得到高度
    CGPoint offset = CGPointZero; // scrollView偏移量
    
    if (imageSize.width / imageSize.height >= self.containerSize.width / self.containerSize.height) {
        // 图片太宽
        y = (self.containerSize.height - height) / 2.0;
        offset = CGPointZero;
    } else if (imageSize.height / imageSize.width >= self.containerSize.height / self.containerSize.width) {
        // 图片太高
        y = 0;
        offset = CGPointMake(0, (height - self.containerSize.height) / 2.0);
    }
    
    self.mainImageView.frame = CGRectMake(x, y, width, height);
    [self.mainScrollView setContentOffset:offset animated:NO];
    
    self.mainScrollView.zoomScale = 1;
    self.mainScrollView.contentSize = CGSizeMake(width, height);
    self.mainScrollView.minimumZoomScale = 1;
    self.mainScrollView.maximumZoomScale = 2.5;
}

- (void)cellDataStateChanged{
    YHImageBrowserCellData *data = self.cellData;
    YHImageBrowserCellDataState dataState = data.dataState;
    
    switch (dataState) {
        case YHImageBrowserCellDataState_Invalid:
        {
            // 图片非法
        }
            break;
        case YHImageBrowserCellDataState_ImageReady:
        {
            // YHImage准备好    😆😆😆😆😆😆😆😆😆😆😆😆😆😆
            if (data.image.animatedImage) {
                self.mainImageView.animatedImage = data.image.animatedImage;
            } else if (data.image.image) {
                self.mainImageView.image = data.image.image;
            }
            [self updateContentViewLayout];
        }
            break;
        case YHImageBrowserCellDataState_ThumbImageReady:
        {
            // 本地缩略图准备好，此时可以显示缩略图    😆😆😆😆😆😆😆😆😆😆😆😆😆😆
            self.mainImageView.image = data.thumbImage;
            [self updateContentViewLayout];
        }
            break;
        case YHImageBrowserCellDataState_CompressImageReady:
        {
            // 压缩图片准备好了，此时可以显示压缩图  😆😆😆😆😆😆😆😆😆😆😆😆😆😆
            self.mainImageView.image = data.compressImage;
            [self updateContentViewLayout];
        }
            break;
        case YHImageBrowserCellDataState_IsCompressingImage:
        {
            // 正在压缩图片
        }
            break;
        case YHImageBrowserCellDataState_CompressImageComplete:
        {
            // 压缩图片完成
        }
            break;
        case YHImageBrowserCellDataState_IsDecoding:
        {
            // 正在Decode本地图片
        }
            break;
        case YHImageBrowserCellDataState_DecodeComplete:
        {
            // 本地图片Decod完成
        }
            break;
        case YHImageBrowserCellDataState_IsQueryingCache:
        {
            // 正在查询缓存图片
        }
            break;
        case YHImageBrowserCellDataState_QueryCacheComplete:
        {
            // 缓存图片查询完成
        }
            break;
        case YHImageBrowserCellDataState_DownloadReady:
        {
            // 准备下载图片
        }
            break;
        case YHImageBrowserCellDataState_IsDownloading:
        {
            // 图片下载中(此时有下载进度)
            NSLog(@"😋:下载进度:%.2f", data.downloadProgress);
        }
            break;
        case YHImageBrowserCellDataState_DownloadSuccess:
        {
            // 图片下载成功
        }
            break;
        case YHImageBrowserCellDataState_DownloadFailed:
        {
            // 图片下载失败
        }
            break;
        default:
            break;
    }
}

#pragma mark ------------------ Gesture ------------------
// 单击
- (void)respondsToTapSingle:(UITapGestureRecognizer *)tap{
    
}

// 双击
- (void)respondsToTapDouble:(UITapGestureRecognizer *)tap{
    UIScrollView *scrollView = self.mainScrollView;
    UIView *zoomView = [self viewForZoomingInScrollView:scrollView];
    CGPoint point = [tap locationInView:zoomView];
    if (!CGRectContainsPoint(zoomView.bounds, point)) return;
    if (scrollView.zoomScale == scrollView.maximumZoomScale) {
        [scrollView setZoomScale:1 animated:YES];
    } else {
        [scrollView zoomToRect:CGRectMake(point.x, point.y, 1, 1) animated:YES];
    }
}

// 拖动
- (void)respondsToPan:(UIPanGestureRecognizer *)pan{
    
}



#pragma mark ------------------ KVO ------------------
- (void)addObserverForDataState{
    [self.cellData addObserver:self forKeyPath:@"dataState" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

- (void)removeObserverForDataState {
    [self.cellData removeObserver:self forKeyPath:@"dataState"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"dataState"]) {
        [self cellDataStateChanged];
    }
}

#pragma mark ------------------ YHImageBrowserCellProtocol ------------------
- (void)yh_browserSetInitialCellData:(id<YHImageBrowserCellDataProtocol>)data layoutDirection:(YHImageBrowserLayoutDirection)layoutDirection containerSize:(CGSize)containerSize{
    self.containerSize = containerSize;
    self.layoutDirection = layoutDirection;
    
    self.cellData = data;
    
    [self addObserverForDataState];
    [self.cellData loadData];
    
    [self updateContentScrollViewLayout];
}

- (void)yh_browserLayoutDirectionChanged:(YHImageBrowserLayoutDirection)layoutDirection containerSize:(CGSize)containerSize{
    self.containerSize = containerSize;
    self.layoutDirection = layoutDirection;
    
    [self updateContentScrollViewLayout];
    [self updateContentViewLayout];
}



#pragma mark ------------------ UIScrollViewDelegate ------------------
- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    CGFloat zoomScale = scrollView.zoomScale;
    NSLog(@"😆:%.2f", zoomScale);
    
    CGRect imageViewFrame = self.mainImageView.frame;

    CGFloat width = imageViewFrame.size.width;
    CGFloat height = imageViewFrame.size.height;
    
    CGFloat sHeight = scrollView.bounds.size.height;
    CGFloat sWidth = scrollView.bounds.size.width;

    if (height > sHeight) {
        imageViewFrame.origin.y = 0;
    } else {
        imageViewFrame.origin.y = (sHeight - height) / 2.0;
    }
    if (width > sWidth) {
        imageViewFrame.origin.x = 0;
    } else {
        imageViewFrame.origin.x = (sWidth - width) / 2.0;
    }
    self.mainImageView.frame = imageViewFrame;
}


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.mainImageView;
}

#pragma mark ------------------ UIGestureRecognizerDelegate ------------------
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}




#pragma mark ------------------ Getter ------------------
- (UIScrollView *)mainScrollView{
    if (!_mainScrollView) {
        _mainScrollView = [[UIScrollView alloc] init];
        _mainScrollView.delegate = self;
        _mainScrollView.showsVerticalScrollIndicator = NO;
        _mainScrollView.showsHorizontalScrollIndicator = NO;
        _mainScrollView.maximumZoomScale = 1;
        _mainScrollView.minimumZoomScale = 1;
        _mainScrollView.alwaysBounceVertical = NO;
        _mainScrollView.alwaysBounceHorizontal = YES;
        if (@available(iOS 11.0, *)) {
            _mainScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _mainScrollView;
}

- (FLAnimatedImageView *)mainImageView{
    if (!_mainImageView) {
        _mainImageView = [[FLAnimatedImageView alloc] init];
    }
    return _mainImageView;
}

@end

