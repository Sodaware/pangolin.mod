' ------------------------------------------------------------------------------
' -- src/tile.bmx
' --
' -- Contains information about a single tile. All tiles have collision data,
' -- but there's an optional `meta` table for storing free-form data.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.map

Type Tile
	
	Field id:Int				' Prob remove this
	
	' Collision (can store all this in a single byte)?
	Field collideLeft:Byte
	Field collideUp:Byte
	Field collideDown:Byte
	Field collideRight:Byte
	
	Field alpha:Float
	
	Field _meta:TMap
	
	
	' ------------------------------------------------------------
	' -- Meta Values
	' ------------------------------------------------------------
	
	Method getMeta:Object(name:String)
		If Self._meta = Null Then Return Null
		Return Self._meta.ValueForKey(name)
	End Method
	
	Method setMeta:Object(name:String, value:Object)
		If Self._meta = Null Then Self._meta = New TMap
		Self._meta.Insert(name, value)
	End Method
	
	' SLOW!
	Method countMeta:Short()
		If Self._meta = Null Then Return 0
		Local count:Short = 0
		For Local k:Object = EachIn Self._meta.Keys()
			count:+ 1
		Next
		Return count
	End Method
	
	
	' ------------------------------------------------------------
	' -- Creation / Destruction
	' ------------------------------------------------------------
	
	Function Create:Tile(cUp:Byte = 0, cRight:Byte = 0, cDown:Byte = 0, cLeft:Byte = 0, alpha:Float = 1)
		Local this:Tile = New Tile
		
		this.CollideUp    = cUp
		this.CollideRight = cRight
		this.CollideDown  = cDown
		this.CollideLeft  = cLeft
		
		this.Alpha        = Alpha
		
		Return this
	End Function
	
End Type
