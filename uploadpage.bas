Type=StaticCode
Version=1.8
ModulesStructureVersion=1
B4i=true
@EndOfDesignText@
'Code module

Sub Process_Globals
	Private Page1 As Page
	Private ImageView1 As ImageView
	Private cam As Camera
	Private btnChoosePicture As Button
	Private btnTakePicture As Button
	Private btnTakeVideo As Button
	Private vv As VideoView
	Private hd As HUD
	Public returnedresult As String
End Sub

Private Sub Application_Start (Nav As NavigationController)
	Page1.Initialize("Page1")
	Page1.Title = "Page 1"
	Page1.RootPanel.Color = Colors.White
	Page1.RootPanel.LoadLayout("1")
	cam.Initialize("cam", Page1)
	
	'disable unsupported features
	btnTakePicture.Enabled = cam.IsSupported
	btnTakeVideo.Enabled = cam.IsVideoSupported
	vv.Initialize("vv")
	Page1.RootPanel.AddView(vv.View, ImageView1.Left, ImageView1.Top, _
		ImageView1.Width, ImageView1.Height)
	vv.View.Visible = False
	'btnTakePicture.Text="sss"

End Sub

Private Sub Page1_Resize(Width As Int, Height As Int)
	'resize the VideoView to the same size as the ImageView.
	vv.View.SetLayoutAnimated(0, 1, ImageView1.Left, ImageView1.Top, _
		ImageView1.Width, ImageView1.Height)
End Sub

Sub btnTakeVideo_Click
	'cam.TakeVideo
	Dim NativeMe As NativeObject = Me
    NativeMe.RunMethod("smallImage",Null)
End Sub

Sub btnTakePicture_Click
    Dim NativeMe As NativeObject = Me
    NativeMe.RunMethod("uploadImage",Null)
	Log(returnedresult)
	File.WriteString(File.DirDocuments,"value",returnedresult)
	'cam.TakePicture
	'Dim upload As HttpJob
	'upload.Initialize("upload",Me)
	'upload.PostFile("http://bbs.jiangnan.edu.cn/attachments/upload.php",File.DirDocuments,"scaled.jpg")
End Sub

Sub btnChoosePicture_Click
	cam.SelectFromSavedPhotos(Sender, cam.TYPE_ALL)
	
End Sub

Sub JobDone (job As HttpJob)
	Log("JobName = " & job.JobName & ", Success = " & job.Success)
	If job.Success = True Then
		Select job.JobName
			Case "upload"
				loaddone(job.GetString2("GBK"))
		End Select
	Else
		Log("Error: " & job.ErrorMessage)
		hd.ToastMessageShow("Error: " & job.ErrorMessage, True)
	End If
	hd.ProgressDialogHide
	job.Release
End Sub

Sub loaddone(result As String)
    Log(result)
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
			vv.View.Visible = False
			ImageView1.Bitmap = image
		Else
			vv.View.Visible = True
			vv.LoadVideo(VideoPath, "")
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


Sub getimageheight As Int
 Dim NativeMe As NativeObject = Me
 Return NativeMe.RunMethod("getheight", Null).AsNumber
End Sub

Sub getimagewidth As Int
  Dim NativeMe As NativeObject = Me
  Return NativeMe.RunMethod("getwidth", Null).AsNumber
End Sub

#If OBJC

- (int)getheight {
//NSString *ImageURL = @"http://gigaom2.files.wordpress.com/2013/01/teacher-classroom.jpg";
//ImageURL =[ImageURL stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    //NSLog([@[@"File:///",[[self.__c File] DirAssets],@"/"] componentsJoinedByString:@""]);
    
	UIImage *image2 = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[@[@"File:///",[[self.__c File] DirDocuments],@"/me.jpg"] componentsJoinedByString:@""]]]];
    
//NSLog(@"img url ==%@",ImageURL);
//NSURL *imageUrl =[NSURL URLWithString:ImageURL];
//NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
//UIImage *image = [UIImage imageWithData:imageData];
//[inView setImage:image];
    NSLog(@"image height: %f",image2.size.height);
//    [self._btntakepicture setText: [NSString stringWithFormat:@"%f",image2.size.height]];
//NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
//UIImage *image = [UIImage imageWithData:imageData];
//NSLog(@'image height: %f',image.size.height);
//NSLog(@'image width: %f',image.size.width); 
    return image2.size.height;
}

- (int)getwidth {
    UIImage *image2 = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[@[@"File:///",[[self.__c File] DirDocuments],@"/me.jpg"] componentsJoinedByString:@""]]]];
    NSLog(@"image height: %f",image2.size.width);
    return image2.size.width;
}

- (void)scaleImage {
    
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[@[@"File:///",[[self.__c File] DirDocuments],@"/chosen.jpg"] componentsJoinedByString:@""]]]];
    float scaleSize=0.8;
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

