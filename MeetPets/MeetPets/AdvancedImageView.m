//
//  AdvancedImageView.m
//  HelloMyAdvancedImageView
//
//  Created by 張峻綸 on 2016/5/20.
//  Copyright © 2016年 張峻綸. All rights reserved.
//

#import "AdvancedImageView.h"
@interface AdvancedImageView(){
    UIActivityIndicatorView * loadingIndicatorView;
    NSOperationQueue *downloadQueue;
}
@end
@implementation AdvancedImageView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)preparing{
    //Remove previous loadingIndicatorView
    if(loadingIndicatorView != nil){
        [loadingIndicatorView removeFromSuperview];
        loadingIndicatorView=nil;
    }
    //Creat a new loadingIndicatorView
    //frame 有x,y,w,h
    //CGRectGetWidth(self.frame)=self.frame.size.width
    CGRect indicatorViewFrame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    loadingIndicatorView=[[UIActivityIndicatorView alloc]
                          initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    loadingIndicatorView.frame=indicatorViewFrame;
    loadingIndicatorView.color = [UIColor blueColor];
    loadingIndicatorView.hidesWhenStopped= true;
    
    [self addSubview:loadingIndicatorView];
}

-(void)loadImageWithURL:(NSURL*)url{
    [self preparing];
    
    //Cancel previous download process
    //防止圖片下載到一半，使用者取消下載現有圖片，下載新的圖片會有問題
    if (downloadQueue !=nil) {
        [downloadQueue cancelAllOperations];
        downloadQueue = nil;
    }
    
    //Check if there is any cache exist
    //Cache目錄名稱:NSCachesDirectory NSUserDomainMask:使用者能用的東西
    //會拿到矩陣,我們要第0個
    NSString *cachePath=NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, true)[0];
    //為防止檔名相同使用hash  雜湊函數取名
    NSString *hashFileName = [NSString stringWithFormat:@"Cache_%ld",(unsigned long)[url hash]];
    //stringByAppendingPathComponent 字串相加,但PathComponent會自動增加"/"區隔
    NSString * fullFilePathname = [cachePath stringByAppendingPathComponent:hashFileName];
    UIImage * cachedImage = [UIImage imageWithContentsOfFile:fullFilePathname];
    if (cachedImage != nil) {
        self.image=cachedImage;
        return;
    }
    
    
    
    //Download image file
    
    self.image = nil; //clear up! don't show exist image.
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                //每次都真的把東西抓回來忽略Cache,60秒沒回應就算失敗
                cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0];
    downloadQueue=[NSOperationQueue new];
    
    [loadingIndicatorView startAnimating];
    
    //使用非同步式的request,並使用downloadQueue
    // 下載完成後completionHandler處理
    //sendAsynchronousRequest非同步,不會等待繼續下載
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable connectionError) {
        // connectionError -> error
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [loadingIndicatorView stopAnimating];
        });
        
        if (connectionError) {
            NSLog(@"connectionError:%@",connectionError);
            
            return ;        }
        
        
        NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
        if (statusCode != 200) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadDataFailed" object:nil];
            return;
        }
        
        
 
        
        //show the response
//        NSLog(@"response:%@",response.description);
        
        //Use the data
        UIImage *originalImage = [UIImage imageWithData:data];
        UIImage *resizedImage = [self resizeWithImage:originalImage];
        
        NSData *imageData=UIImageJPEGRepresentation(resizedImage, 0.3);
        
        UIImage *resultImage = [UIImage imageWithData:imageData];
        //因在背景downloadQueue不能控制UI,需要在main queue才能
        //(dispatch_get_main_queue()表示
        //使用GCD指定self.image=image給main_queue執行
        //dispatch_async表示downloadQueue把指定丟給main_queue不必等待完成
        //假如使用dispatch_sync則須等待main_queue執行完才能繼續執行下面的程式碼
        dispatch_async(dispatch_get_main_queue(), ^{
            self.image=resultImage;
        });
        
        //使用完成設定成nil將記憶體回收
        downloadQueue=nil;
        
        //Save data as a cache file
        //atomically:true 會先用臨時檔名先去存檔,假如空間不足,這樣真正檔名就不存檔成功
        //Cache沒有每次都去下載
        [data writeToFile:fullFilePathname atomically:true];
        //NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
        //NSLog(@"catch path:%@",path);
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadDataSuccess" object:data];
    }];
    [task resume];

}


-(UIImage*)resizeWithImage:(UIImage*) srcImage{
    
    CGFloat maxLength = 768.0;
    CGSize targetSize;
    //No need to resiz. Use original image.
    if (srcImage.size.width <= maxLength &&srcImage.size.height <= maxLength ) {
        
        targetSize=srcImage.size;
        
    }else{
        //Adjust the size
        if (srcImage.size.width >= srcImage.size.height) {
            
            CGFloat ratio = srcImage.size.width / maxLength;
            targetSize = CGSizeMake(maxLength, srcImage.size.height / ratio);
        }else{
            CGFloat ratio = srcImage.size.height / maxLength;
            targetSize = CGSizeMake(srcImage.size.width/ratio, maxLength);
        }
    }
    
    
    
    
    
    
    // Resize the srcimage as targetSize
    //C語言底層API
    //BeginImageContext 在記憶體建立一塊虛擬畫布
   UIGraphicsBeginImageContext(targetSize);
    
    //虛擬畫布上的(0,0)開始用srcImage照片畫寬為targetSize.width,長為targetSize.height照片
    //drawInRect為縮放的方法
     [srcImage drawInRect:CGRectMake(0, 0, targetSize.width, targetSize.height)];
    
    //Draw Frame
//    UIImage *frameImage = [UIImage imageNamed:@"frame_01.png"];
//    [frameImage drawInRect:CGRectMake(0,0,targetSize.width, targetSize.height)];
    
    //把畫好的虛擬畫布指定給resultImage
//    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //重要! 使用完ImageContext須關閉,不然會留在記憶體內佔用
    UIGraphicsEndImageContext();
    
    return srcImage;
    
}

@end
