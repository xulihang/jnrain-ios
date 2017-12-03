Type=StaticCode
Version=1.8
ModulesStructureVersion=1
B4i=true
@EndOfDesignText@
'Code module

Sub Process_Globals
	Private pg As Page
	Private ImageView1 As ImageView
	Private cam As Camera
	Private btnChoosePicture As Button
	Private ActionSheet1 As ActionSheet
	'Private vv As VideoView
	Private hd As HUD
	Public  returnedresult As String
	Private Timer1 As Timer
	Private btnScaleImage As Button
	Private btnUpload As Button
End Sub

Public Sub Show
    If pg.IsInitialized = False Then
	    pg.Initialize("pg")
	    pg.Title = "pg"
	    pg.RootPanel.Color = Colors.White
	    pg.RootPanel.LoadLayout("1")
	End If
	cam.Initialize("cam", pg)
	ActionSheet1.Initialize("actionsheet1","选择质量", "Cancel", "", Array As String("优","中","差"))

	Timer1.Initialize("timerevent",500)
	returnedresult=""
	btnScaleImage.Enabled=False
	btnUpload.Enabled=False
	
	'vv.Initialize("vv")
	'pg.RootPanel.AddView(vv.View, ImageView1.Left, ImageView1.Top, _
	'	ImageView1.Width, ImageView1.Height)
	'vv.View.Visible = False
	'btnTakePicture.Text="sss"
    Main.NavControl.ShowPage(pg)
End Sub

Private Sub Page1_Resize(Width As Int, Height As Int)
	'resize the VideoView to the same size as the ImageView.
	'vv.View.SetLayoutAnimated(0, 1, ImageView1.Left, ImageView1.Top, _
	'	ImageView1.Width, ImageView1.Height)
End Sub

Private Sub actionsheet1_Click(Item As String)
	Select Item
	Case "优"
        Dim NativeMe As NativeObject = Me
        NativeMe.RunMethod("scaleImage",Null)
		ImageView1.Bitmap=LoadBitmap(File.DirDocuments,"scaled.jpg")
		btnUpload.Enabled=True
	Case "中"
        Dim NativeMe As NativeObject = Me
        NativeMe.RunMethod("midImage",Null)
		ImageView1.Bitmap=LoadBitmap(File.DirDocuments,"scaled.jpg")
		btnUpload.Enabled=True
	Case "差"
        Dim NativeMe As NativeObject = Me
        NativeMe.RunMethod("smallImage",Null)
		ImageView1.Bitmap=LoadBitmap(File.DirDocuments,"scaled.jpg")
		btnUpload.Enabled=True
	End Select
End Sub

Sub btnScaleImage_Click
	'cam.TakeVideo
	ActionSheet1.Show(pg.RootPanel)
End Sub

Sub btnUpload_Click
    Dim NativeMe As NativeObject = Me
    NativeMe.RunMethod("uploadImage",Null)
	hd.ProgressDialogShow("上传中")
	Timer1.Enabled=True
	Log(returnedresult)
	'File.WriteString(File.DirDocuments,"value",returnedresult)
	'cam.TakePicture
End Sub

Private Sub Timerevent_Tick
    If returnedresult.Contains("[pic") Then
	    hd.ProgressDialogHide
		Dim ubound As Int
		Dim lbound As Int
		ubound=returnedresult.IndexOf("[pic")
		lbound=returnedresult.IndexOf("</script>")-3
		Log(ubound)
		Log(lbound)
		returnedresult=returnedresult.SubString2(ubound,lbound)
		Log(returnedresult)
		Main.ContentTV.Text=Main.ContentTV.Text&returnedresult
		hd.ToastMessageShow("上传成功",False)
		Main.NavControl.RemoveCurrentPage
        Timer1.Enabled=False
	End If
End Sub

Sub btnChoosePicture_Click
	cam.SelectFromSavedPhotos(Sender, cam.TYPE_ALL)
End Sub

Sub Cam_Complete (Success As Boolean, image As Bitmap, VideoPath As String)
	If Success Then
		If image.IsInitialized Then
		    Dim out As OutputStream
		    out=File.OpenOutput(File.DirDocuments,"chosen.jpg",False)
			Dim data() As Byte = GetByteFromBitmap(image, 100)
		    out.WriteBytes(data, 0, data.Length)
	        out.Close
			Log(File.GetAttributes(File.DirDocuments,"chosen.jpg"))
			'vv.View.Visible = False
			ImageView1.Bitmap = image
			btnScaleImage.Enabled=True
		'Else
		'	vv.View.Visible = True
		'	vv.LoadVideo(VideoPath, "")
		End If
	End If
End Sub

Sub GetByteFromBitmap(img As Bitmap, Quality As Int) As Byte()
      Dim out As OutputStream
      Dim data() As Byte
      out.InitializeToBytesArray(1)
      img.WriteToStream(out,Quality,"JPEG")
      data = out.ToBytesArray
      out.Close
      Return data 
End Sub



#If OBJC
#import "AFHTTPRequestOperationManager.h"

- (int)getwidth {
    UIImage *image2 = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[@[@"File:///",[[self.__c File] DirDocuments],@"/me.jpg"] componentsJoinedByString:@""]]]];
    NSLog(@"image height: %f",image2.size.width);
    return image2.size.width;
}

- (void)scaleImage {
    
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[@[@"File:///",[[self.__c File] DirDocuments],@"/chosen.jpg"] componentsJoinedByString:@""]]]];
    float scaleSize=0.9;
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width*scaleSize,image.size.height*scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height *scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
    NSData *dataForJPEGFile = UIImageJPEGRepresentation(scaledImage, 0.6);
	
	 // 获取程序Documents目录路径
    //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    //NSString *documentsDirectory = [paths objectAtIndex:0];

    NSString *path =[@[[[self.__c File] DirDocuments],@"/scaled.jpg"] componentsJoinedByString:@""];
    
    [dataForJPEGFile writeToFile:path atomically:YES];
    //return scaledImage;
}

- (void)midImage {
    
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[@[@"File:///",[[self.__c File] DirDocuments],@"/chosen.jpg"] componentsJoinedByString:@""]]]];
    float scaleSize=0.5;
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width*scaleSize,image.size.height*scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height *scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
    NSData *dataForJPEGFile = UIImageJPEGRepresentation(scaledImage, 0.6);
	
	 // 获取程序Documents目录路径
    //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    //NSString *documentsDirectory = [paths objectAtIndex:0];

    NSString *path =[@[[[self.__c File] DirDocuments],@"/scaled.jpg"] componentsJoinedByString:@""];
    
    [dataForJPEGFile writeToFile:path atomically:YES];
    //return scaledImage;
}

- (void)smallImage {
    
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[@[@"File:///",[[self.__c File] DirDocuments],@"/chosen.jpg"] componentsJoinedByString:@""]]]];
    float scaleSize=0.3;
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width*scaleSize,image.size.height*scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height *scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
    NSData *dataForJPEGFile = UIImageJPEGRepresentation(scaledImage, 0.6);
	
	 // 获取程序Documents目录路径
    //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    //NSString *documentsDirectory = [paths objectAtIndex:0];

    NSString *path =[@[[[self.__c File] DirDocuments],@"/scaled.jpg"] componentsJoinedByString:@""];
    
    [dataForJPEGFile writeToFile:path atomically:YES];
    //return scaledImage;
}

- (NSString*)uploadImage {
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[@[@"File:///",[[self.__c File] DirDocuments],@"/scaled.jpg"] componentsJoinedByString:@""]]]];
    //NSString *path =[@[[[self.__c File] DirDocuments],@"/scaled.jpg"] componentsJoinedByString:@""];
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager POST:@"http://bbs.jiangnan.edu.cn/attachments/upload.php" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData
                                    name:@"file"
                                fileName:@"scaled.jpg" mimeType:@"image/jpeg"];
        
        //[formData appendPartWithFormData:[key1 dataUsingEncoding:NSUTF8StringEncoding]name:@"key1"];
        
        //[formData appendPartWithFormData:[key2 dataUsingEncoding:NSUTF8StringEncoding]name:@"key2"];
        
        // etc.
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //[self._btntakepicture setText: [NSString stringWithFormat:@"%@",operation.responseString]];
        self._returnedresult =[NSString stringWithFormat:@"%@",operation.responseString];
        NSLog(@"Response: %@", operation.responseString);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    return self._returnedresult;

}
#End If

