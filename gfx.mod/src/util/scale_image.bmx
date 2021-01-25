' ------------------------------------------------------------------------------
' -- src/util/scale_image.bmx
' --
' -- Utility functions for scaling images.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.max2d
Import brl.pixmap

Function scaleImage:TPixmap(inputImage:TPixmap, xScale:Float, yScale:Float)
		
	Local xPos:Float
	Local yPos:Float
	Local scaledImage:TPixmap
	
	Local newWidth:Float  = inputImage.width * xScale
	Local newHeight:Float = inputImage.height * yScale
	
	scaledImage = CreatePixmap(Int(newWidth), Int(newHeight), PF_RGBA8888)

	' TODO: Optimize this a little bit	
	For Local x:Int = 0 To inputImage.width - 1
		
		yPos = 0
		For Local y:Int = 0 To inputImage.height - 1		
		
			For Local x1:Int = 0 To xScale - 1
				For Local y1:Int = 0 To yScale - 1
					WritePixel(scaledImage, Int(xPos + x1), Int(yPos + y1), ReadPixel(inputImage, x, y))
				Next
			Next
			
			yPos :+ yScale
			
		Next			
		
		xPos :+ xScale
		
	Next
	
	Return scaledImage
	
End Function


Function ImageToPixmap:TPixmap(inputImage:TImage)
	
	Local outputPixmap:TPixmap     = CreatePixmap(inputImage.height,inputImage.width, PF_RGBA8888)
	Local inputImagePixmap:TPixmap = LockImage(inputImage)
	
	For Local x:Int = 0 To inputImage.width - 1
		For Local y:Int = 0 To inputImage.height - 1
			outputPixmap.WritePixel(x, y, inputImagePixmap.ReadPixel(x, y))
		Next			
	Next
	
	UnlockImage(inputImage)
	inputImagePixmap = Null
	
	Return outputPixmap 
	
End Function 

Function ResizeImage:TImage(inputImage:TImage, xScale:Float, yScale:Float)
	Local resizedImage:TPixmap = scaleImage( ImageToPixmap( inputImage ), xscale, yScale )
	Return LoadImage(resizedImage)
End Function
