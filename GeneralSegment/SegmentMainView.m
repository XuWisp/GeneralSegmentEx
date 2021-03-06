//
//  SegmentMainView.m
//  GeneralSegmentEx
//
//  Created by 徐沙洪 on 2018/7/22.
//  Copyright © 2018年 徐沙洪. All rights reserved.
//

#import "SegmentMainView.h"

#define kScreenW [UIScreen mainScreen].bounds.size.width

@interface SegmentMainView ()

@property (nonatomic, strong) UIScrollView *scrollV;

@end

@implementation SegmentMainView

#pragma mark - Life Cycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.scrollV];
    }
    return self;
}

#pragma mark - Lazy load

- (NSArray *)btnDataArr {
    if (!_btnDataArr) {
        _btnDataArr = [NSArray new];
    }
    return _btnDataArr;
}

- (void)setBtnDataArr:(NSArray *)btnDataArr {
    if (_btnDataArr == btnDataArr) {
        return;
    }
    _btnDataArr = btnDataArr;
    [self viewInitByArr];
}

- (UIButton *)demoBtn {
    if (!_demoBtn) {
        _demoBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [_demoBtn setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
        [_demoBtn setTitleColor:[UIColor blackColor] forState:(UIControlStateSelected)];
    }
    return _demoBtn;
}

- (UIScrollView *)scrollV {
    if (!_scrollV) {
        _scrollV = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollV.scrollEnabled = NO;
        _scrollV.showsVerticalScrollIndicator = FALSE;
        _scrollV.showsHorizontalScrollIndicator = FALSE;
        [_scrollV addSubview:self.lineV];
    }
    return _scrollV;
}

- (UIView *)lineV {
    if (!_lineV) {
        _lineV = [[UIView alloc] initWithFrame:(CGRectMake(0, self.frame.size.height-4, kScreenW, 4))];
        _lineV.backgroundColor = [UIColor blackColor];
    }
    return _lineV;
}

- (UIView *)segLineV {
    if (!_segLineV) {
        _segLineV = [[UIView alloc] initWithFrame:(CGRectMake(0,
                                                              (self.frame.size.height-30)/2,
                                                              1,
                                                              30))];
        _segLineV.backgroundColor = [UIColor grayColor];
    }
    return _segLineV;
}

#pragma mark - view init

- (void)viewInitByArr {
    for (int i = 0; i < self.btnDataArr.count; i++) {
        NSData * archiveData = [NSKeyedArchiver archivedDataWithRootObject:self.demoBtn];
        UIButton *btn = [NSKeyedUnarchiver unarchiveObjectWithData:archiveData];
        btn.frame = (CGRectMake(kScreenW/self.btnDataArr.count * i,
                                0,
                                kScreenW/self.btnDataArr.count,
                                self.frame.size.height));
        [btn setTitle:self.btnDataArr[i] forState:(UIControlStateNormal)];
        if (self.demoBtn.frame.size.width) {
            UIButton *previousBtn = (UIButton *)[self viewWithTag:1000+i-1];
            btn.frame = CGRectMake(previousBtn.frame.origin.x + previousBtn.frame.size.width,
                                   0,
                                   [self calculateRowWidth:self.btnDataArr[i]]+30,
                                   self.frame.size.height);
            self.scrollV.scrollEnabled = YES;
        }else {
            self.scrollV.scrollEnabled = NO;
        }
        if (self.Font) {
            btn.titleLabel.font = self.Font;
        }
        btn.tag = 1000+i;
        [btn addTarget:self action:@selector(segBtnClick:) forControlEvents:(UIControlEventTouchUpInside)];
        [self.scrollV addSubview:btn];
        // When the last button is set, set the size of the sliding view canvas
        if (i == self.btnDataArr.count-1) {
            self.scrollV.contentSize = CGSizeMake(btn.frame.origin.x + btn.frame.size.width, 0);
        }
        // The default initialization selects the first
        if (!i) {
            [self lineMove:0];
            btn.selected = YES;
            if (self.sFont) {
                btn.titleLabel.font = self.sFont;
            }
        }else { // Set the secant line
            NSData * archiveData = [NSKeyedArchiver archivedDataWithRootObject:self.segLineV];
            UIView *view = [NSKeyedUnarchiver unarchiveObjectWithData:archiveData];
            view.frame = CGRectMake(btn.frame.origin.x-view.frame.size.width/2, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
            [self.scrollV addSubview:view];
        }
    }
}

#pragma mark - active

- (void)reloadScrollView {
    [self.scrollV.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.scrollV addSubview:self.lineV];
    [self viewInitByArr];
}

- (void)lineMove:(NSUInteger)index {
    UIButton *btn = [self viewWithTag:1000+index];
    __weak __typeof(self)weakSelf = self;
    [UIView animateWithDuration:0.5 animations:^{
        CGRect rect = weakSelf.lineV.frame;
        if (!self.lineVWidth) {
            rect.size.width = [weakSelf calculateRowWidth:weakSelf.btnDataArr[index]];
        }
        rect.origin.x = btn.center.x-rect.size.width/2;
        weakSelf.lineV.frame = rect;
        if (weakSelf.demoBtn.frame.size.width) {
            if (weakSelf.scrollV.contentSize.width < btn.center.x+weakSelf.frame.size.width/2) {
                weakSelf.scrollV.contentOffset = CGPointMake(weakSelf.scrollV.contentSize.width-weakSelf.frame.size.width, 0);
            }else if (btn.center.x < weakSelf.frame.size.width/2) {
                weakSelf.scrollV.contentOffset = CGPointMake(0, 0);
            }else {
                weakSelf.scrollV.contentOffset = CGPointMake(btn.center.x-weakSelf.frame.size.width/2, 0);
            }
        }
    } completion:^(BOOL finished) {
        weakSelf.scrollV.contentSize = weakSelf.scrollV.contentSize;
    }];
}

- (void)segBtnClick:(UIButton *)btn {
    for (int i = 0; i < self.btnDataArr.count; i++) {
        UIButton *abtn = [self viewWithTag:1000+i];
        abtn.selected = NO;
        abtn.titleLabel.font = self.Font;
    }
    btn.selected = YES;
    if (self.sFont) {
        btn.titleLabel.font = self.sFont;
    }
    NSUInteger index = btn.tag-1000;
    [self lineMove:index];
    [self.delegate btnClickAtIndex:index];
}

- (void)subBtnUnActionClick:(UIButton *)btn {
    for (int i = 0; i < self.btnDataArr.count; i++) {
        UIButton *abtn = [self viewWithTag:1000+i];
        abtn.selected = NO;
        abtn.titleLabel.font = self.Font;
    }
    btn.selected = YES;
    if (self.sFont) {
        btn.titleLabel.font = self.sFont;
    }
    NSUInteger index = btn.tag-1000;
    [self lineMove:index];
}

- (CGFloat)calculateRowWidth:(NSString *)string {
    if (!self.sFont) {
        self.sFont = [UIFont systemFontOfSize:18];
    }
    NSDictionary *dic = @{NSFontAttributeName:self.sFont};
    CGRect rect = [string boundingRectWithSize:CGSizeMake(0, 30) options:NSStringDrawingUsesLineFragmentOrigin |
                   NSStringDrawingUsesFontLeading attributes:dic context:nil];
    return rect.size.width;
}

@end

