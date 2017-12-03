Type=StaticCode
Version=1.8
ModulesStructureVersion=1
B4i=true
@EndOfDesignText@
'Code module

Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'Public variables can be accessed from all modules.
    Private pg As Page
	Public WebView3 As WebView
	Private hd As HUD
End Sub

Public Sub Show(url As String)
    If pg.IsInitialized = False Then
	    pg.Initialize("pg")
	    pg.Title = "操作"
	    pg.RootPanel.Color = Colors.White
	    pg.RootPanel.LoadLayout("thread2")
	End If
    If url.Contains("getface") Then
		Dim content As String
		content="<html><body><a href="& Chr(34) &"http://127.0.0.1/"& Chr(34) &"><img src="& Chr(34) & url& Chr(34) &" width="& Chr(34) &"120"& Chr(34) &" height="& Chr(34) &"120"& Chr(34) &" align=absmiddle/></a></body></html>"
        WebView3.LoadHtml(content)	
	Else If url.Contains("mp3") Then
	    WebView3.LoadUrl(url)
	Else If url.Contains("bbspst") OR url.Contains("bbsedit") OR url.Contains("bbssnd") Then
	    WebView3.LoadUrl(url)
	End If
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


Sub WebView3_OverrideUrl (Url As String) As Boolean
	Return False
End Sub
Sub WebView3_Click
	
End Sub

Sub WebView1_PageFinished (Success As Boolean, Url As String)
	Dim no As NativeObject = WebView3
	Dim result As String
	result=no.RunMethod("stringByEvaluatingJavaScriptFromString:", Array("document.documentElement.innerHTML")).AsString
	If result.Contains("文章修改成功") Then
	    WebView3.LoadHtml("编辑成功")
	Else If result.Contains("发文成功") Then
	    WebView3.LoadHtml("发表成功")
	End If
End Sub
