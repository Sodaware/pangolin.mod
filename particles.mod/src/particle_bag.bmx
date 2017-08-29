' ------------------------------------------------------------------------------
' -- src/particle_bag.bmx
' --
' -- A collection of BaseParticle objects. Makes rendering a lot of particles
' -- faster as it avoids casting.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "particles/base_particle.bmx"

''' <summary>
''' A collection of BaseParticle objects. Works exactly the same as an ObjectBag
''' except it is strongly typed. Much faster than a TList and more flexible
''' than a standard array. Supports iteration as well as sorting by priority.
''' </summary>
Type ParticleBag
	
	Const SORT_ASC:Int		= 1
	Const SORT_DESC:Int		= -1

	Field _size:Int					'''< Number of items in the bag
	Field _objects:BaseParticle[]	'''< Bag contents
	
	' Custom sorting
	Field _sortMethod:Int(obj1:BaseParticle, obj2:BaseParticle) = CompareParticleObjects


	' ------------------------------------------------------------
	' -- Custom sorting
	' ------------------------------------------------------------
	
	Method setSortMethod(sortMethod:Int(obj1:BaseParticle, obj2:BaseParticle))
		Self._sortMethod = sortMethod
	End Method
	
	
	' ------------------------------------------------------------
	' -- Retrieving bag information
	' ------------------------------------------------------------
	
	''' <summary>Get the number of items in the bag.</summary>
	''' <return>The number of items in the bag.</return>
	Method getSize:Int()
		Return Self._size
	End Method
	
	''' <summary>Get the capacity of the bag.</summary>
	''' <return>Bag capacity</return>
	Method getCapacity:Int()
		Return Self._objects.Length
	End Method
	
	''' <summary>Check if bag is empty.</summary>
	''' <return>True if empty, false if not.</return>
	Method isEmpty:Short()
		Return (Self._size = 0)
	End Method
	
	''' <summary>Check if a bag contains an object.</summary>
	''' <param name="obj">The object to search for.</param>
	''' <return>True if bag contains the object, false if not.</return>
	Method contains:Int(obj:BaseParticle)
		Return (Self.findObject(obj) <> -1)
	End Method
	
	''' <summary>Check if a bag contains an object, and returns its location if found.</summary>
	''' <param name="obj">The object to search for.</param>
	''' <return>Object offset if found, or -1 if not found.</return>
	Method findObject:Int(obj:BaseParticle)
	
		For Local pos:Int = 0 To Self._size - 1
			If Self._objects[pos] = obj Then Return pos
		Next
		
		Return -1
		
	End Method
	
	
	' ------------------------------------------------------------
	' -- Retrieving items
	' ------------------------------------------------------------
	
	''' <summary>Retrieve an object at a specific location.</summary>
	''' <param name="index">Offset to retrieve from.</param>
	''' <return>Object at this offset, or null if not found.</return>
	Method get:BaseParticle(index:Int)
		If index < 0 Or index >= Self._size Then Return Null
		Return Self._objects[index]
	End Method
	
	
	' ------------------------------------------------------------
	' -- Adding items
	' ------------------------------------------------------------
	
	''' <summary>
	''' Add a new object to the bag. Will expand the capacity of the
	''' bag if it is not big enough.
	''' </summary>
	''' <param name="obj">The object to add to the bag.</param>
	Method add(obj:BaseParticle, doSort:Byte = True)
		
		' Grow the bag if required
		If Self._size = Self._objects.Length Then Self._grow()
		
		' Add the data + move to the next position
		Self._objects[Self._size] = obj
		Self._size:+ 1
		
		If doSort Then Self.sort(ParticleBag.SORT_DESC)
		
	End Method
	
	''' <summary>Add the contents of another ObjectBag to this bag.</summary>
	''' <param name="bag">The bag to add.</param>
	Method addCollection(bag:ParticleBag)
		
		If bag = Null Then Return
		
		' Add all items
		For Local pos:Int = 0 To bag.getSize() - 1
			Self.add(bag.get(pos), False)
		Next
		
		Self.sort(ParticleBag.SORT_DESC)
		
	End Method
	
	''' <summary>Add the contents of an array to this bag.</summary>
	''' <param name="objects">The array to add.</param>
	Method addArray(objects:BaseParticle[])
		
		If objects = Null Then Return
		
		For Local obj:BaseParticle = EachIn objects
			Self.add(obj, False)
		Next
		
		Self.sort(ParticleBag.SORT_DESC)
		
	End Method
	
	''' <summary>
	''' Set an object at a specific index. Will expand the bag if
	''' the index is greater than the current bag size.
	''' </summary>
	''' <param name="index">The index to set at.</param>
	''' <param name="obj">The object value.</param>
	Method set(index:Int, obj:BaseParticle)
		
		' Check bounds
		If index < 0 Then Throw "Cannot set element at index < 0"
		
		' Resize bag if required
		If index >= Self._objects.Length Then
		
			Self._grow(1 + (index * 2))
			Self._size = index + 1
			
		ElseIf index >= Self._size
		
			Self._size = index + 1
			
		End If
		
		Self._objects[index] = obj
		
		Self.sort(ParticleBag.SORT_DESC)
		
	End Method
	
	
	' ------------------------------------------------------------
	' -- Removing items
	' ------------------------------------------------------------
	
	''' <summary>Remove an item from the bag and return it.</summary>
	''' <param name="index">The index to remove from.</param>
	''' <return>The object removed, or null if out of range.</return>
	Method remove:BaseParticle(index:Int, doSort:Byte = True)
		
		' TODO: Check some bounds here
	
		' Check bounds
		If index < 0 Or index >= Self._size Then Return Null
		
		' Get object
		Local obj:BaseParticle = Self._objects[index]
		
		' Replace object with end of list and then remove last item
		Self._objects[index] = Self._objects[Self._size - 1]
		Self._objects[Self._size - 1] = Null
		Self._size:- 1
		
		If doSort Then Self.sort(ParticleBag.SORT_DESC)
		
		' Done
		Return obj
		
	End Method
	
	''' <summary>Remove the last item from the bag and return it.</summary>
	''' <return>Last item in bag, or null if bag is empty.</return>
	Method removeLast:BaseParticle()
		
		' Check list is not empty.
		If Self._size = 0 Then Return Null
		
		' Get object at end
		Local obj:BaseParticle = Self._objects[Self._size - 1]
		
		' Remove final object + resize list
		Self._objects[Self._size] = Null
		Self._size:- 1
		
		Self.sort(ParticleBag.SORT_DESC)
		
		' Done
		Return obj
		
	End Method
	
	''' <summary>Remove the first occurance of an object instance.</summary>
	''' <param name="obj">The object instance to remove.</param>
	''' <return>True if removed, false if not.</return>
	Method removeObject:Short(obj:BaseParticle, doSort:Byte = True)
		Local result:Short = (Self.remove(Self.findObject(obj)) <> Null)
		If doSort Then Self.sort(ParticleBag.SORT_DESC)
		Return result
	End Method
	
	''' <summary>Remove all items from this bag that are present in another bag.</summary>
	''' <param name="bag">The bag containing items to remove.</param>
	''' <return>True if items removed, false if not.</return>
	Method removeCollection:Int(bag:ParticleBag)
		
		Local startSize:Int = Self._size
		
		For Local pos:Int = 0 To bag.getSize() - 1
			Self.removeObject(bag.get(pos), False)
		Next
	
		Self.sort(ParticleBag.SORT_DESC)
		
		Return startSize <> Self._size
	
	End Method
	
	''' <summary>Clear the contents of the bag.</summary>
	Method clear()
		
		For Local pos:Int = 0 To Self._size - 1
			Self._objects[pos] = Null
		Next
		Self._size = 0
		
	End Method

	
	' ------------------------------------------------------------
	' -- Sorting
	' ------------------------------------------------------------
	
	''' <summary>Sort the contents of the bag.</summary>
	''' <param name="sortOrder">The order to use (either SORT_ASC or SORT_DESC). Default is SORT_ASC.</param>
	''' <param name="compareFunction">The function used to compare the two objects.</param>
	Method sort(sortOrder:Byte = SORT_ASC, compareFunction:Int(obj1:BaseParticle, obj2:BaseParticle) = Null)
		
		' Get sort method
		If compareFunction = Null Then compareFunction = Self._sortMethod
		
		' Check if bag needs to be sorted
		If Self.getSize() <= 1 Then Return
	
		Local isSwapped:Byte	= False
		Local pos:Int 			= 0
		Local startPos:Int		= -1
		Local endPos:Int		= Self.getSize() - 2
		
		Repeat
			
			' Move start position + reset swap flag
			startPos:+ 1 
			isSwapped = False
			
			' Forward search
			For pos = startPos To endPos
				If compareFunction(Self.get(pos), Self.get(pos + 1)) = sortOrder Then
					Self._swap(pos, pos + 1)
					isSwapped = True
				EndIf
			Next
			
			' If no swaps, array is sorted
			If Not(isSwapped) Then Exit
			
			' Backward search
			isSwapped = False
			endPos:- 1
			For pos = endPos To startPos Step -1
				If compareFunction(Self.get(pos), Self.get(pos + 1)) = sortOrder Then
					Self._swap(pos, pos + 1)
					isSwapped = True
				EndIf
			Next
			
		Until isSwapped = False
		
	End Method
	
	''' <summary>Swaps two elements.</summary>
	''' <param name="targetPos">The element to move.</param>
	''' <param name="destinationPos">The element to move to.</param>
	Method _swap(targetPos:Int, destinationPos:Int)
		
		Local temp:BaseParticle = Self.get(destinationPos)
		Self.set(destinationPos, Self.get(targetPos))
		Self.set(targetPos, temp)
		
	End Method
	
	
	' ------------------------------------------------------------
	' -- Internal helpers
	' ------------------------------------------------------------
	
	''' <summary>Increase the capacity of the bag.</summary>
	''' <param name="newCapacity">Optional new capacity.</param>
	Method _grow(newCapacity:Int = -1)
		
		' Use default new size if none set
		If newCapacity < 0 Then newCapacity = ((Self._objects.Length * 3) / 2) + 1
		
		' Create copy of current objects
		Local oldObjects:BaseParticle[] = Self._objects
		
		' Recreate array with new size
		Self._objects = New BaseParticle[newCapacity]
		
		' Copy the old conents back
		For Local pos:Int = 0 To oldObjects.Length - 1
			Self._objects[pos] = oldObjects[pos]
		Next
	
	End Method
	
	
	' ------------------------------------------------------------
	' -- ForEach support
	' ------------------------------------------------------------
	
	Method ObjectEnumerator:ParticleBagEnum()
		Return ParticleBagEnum.Create(Self)
	End Method
	
	
	' ------------------------------------------------------------
	' -- Construction / Destruction
	' ------------------------------------------------------------
	
	''' <summary>Create a new ObjectBag with an initial capacity.</summary>
	''' <param name="capacity">Size of the bag to create.</param>
	''' <return>An ObjectBag instance.</return>
	Function Create:ParticleBag(capacity:Int = 0)
	
		Local this:ParticleBag = New ParticleBag
		this._objects = New BaseParticle[capacity]
		Return this
		
	End Function
	
End Type


' ------------------------------------------------------------
' -- EachIn support
' ------------------------------------------------------------

Type ParticleBagEnum
	
	Field _bag:ParticleBag
	Field _pos:Int = 0

	Function Create:ParticleBagEnum(bag:ParticleBag)
		Local this:ParticleBagEnum = New ParticleBagEnum
		this._bag = bag
		Return this
	End Function

	Method HasNext:Int()
		Return Self._pos < Self._bag.getSize() 
	End Method

	Method NextObject:BaseParticle()
		Local obj:BaseParticle = Self._bag.get(Self._pos)
		Self._pos:+ 1
		Return obj
	End Method

End Type


' ------------------------------------------------------------
' -- Search support
' ------------------------------------------------------------

Function CompareParticleObjects:Int(obj1:BaseParticle, obj2:BaseParticle)
	If obj1.x_pos > obj2.x_pos Then
		Return 1
	ElseIf obj1.x_pos < obj2.x_pos Then
		Return -1
	Else
		Return 0	
	End If
End Function
