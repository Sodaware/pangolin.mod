' ------------------------------------------------------------------------------
' -- Pangolin.Entities -- ttypeid_byte_map.bmx
' --
' -- Standard map, but stores TTypeId keys with byte values.
' --
' -- Based on the brl.map TMap type.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2020 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.reflection

Private

Global nil:TTypeIdByteMap_Node = New TTypeIdByteMap_Node

nil._color  = TTypeIdByteMap.BLACK
nil._parent = nil
nil._left   = nil
nil._right  = nil

Type TTypeIdByteMap_KeyValue
	Field _key:TTypeId
	Field _value:Byte

	Method key:TTypeId()
		Return self._key
	End Method

	Method value:Byte()
		Return self._value
	End Method

End Type

Type TTypeIdByteMap_Node Extends TTypeIdByteMap_KeyValue

	Method nextNode:TTypeIdByteMap_Node()
		Local node:TTypeIdByteMap_Node = Self
		If node._right <> nil Then
			node = _right
			While node._left <> nil
				node = node._left
			Wend
			Return node
		EndIf

		Local parent:TTypeIdByteMap_Node=_parent
		While node = parent._right
			node = parent
			parent = parent._parent
		Wend
		Return parent
	End Method

	Method prevNode:TTypeIdByteMap_Node()
		Local node:TTypeIdByteMap_Node=Self
		If node._left <> nil Then
			node = node._left
			While node._right <> nil
				node = node._right
			Wend
			Return node
		EndIf
		Local parent:TTypeIdByteMap_Node=node._parent
		While node=parent._left
			node=parent
			parent=node._parent
		Wend
		Return parent
	End Method

	Method clear()
		self._parent = Null
		If self._left <> nil Then self._left.clear()
		If self._right <> nil Then self._right.clear()
	End Method

	Method copy:TTypeIdByteMap_Node(parent:TTypeIdByteMap_Node)
		Local t:TTypeIdByteMap_Node = New TTypeIdByteMap_Node
		t._key    = self._key
		t._value  = self._value
		t._color  = self._color
		t._parent = parent

		If _left <> nil then
			t._left=_left.Copy( t )
		EndIf

		If _right <> nil then
			t._right=_right.Copy( t )
		EndIf

		Return t
	End Method

	'***** PRIVATE *****

	Field _color:int
	Field _parent:TTypeIdByteMap_Node = nil
	Field _left:TTypeIdByteMap_Node   = nil
	Field _right:TTypeIdByteMap_Node  = nil

End Type

Public

Type TTypeIdByteMap_NodeEnumerator

	Field _node:TTypeIdByteMap_Node

	Method hasNext:Int()
		Return self._node <> nil
	End Method

	Method nextObject:Object()
		Local node:TTypeIdByteMap_Node = self._node
		self._node = Self._node.nextNode()

		Return node
	End Method

End Type

Type TTypeIdByteMap_KeyEnumerator Extends TTypeIdByteMap_NodeEnumerator
	Method NextObject:Object()
		Local node:TTypeIdByteMap_Node=_node
		_node=_node.NextNode()
		Return node._key
	End Method
End Type

rem
Type TTypeIdByteMap_ValueEnumerator Extends TTypeIdByteMap_NodeEnumerator
	Method NextObject:Object()
		Local node:TTypeIdByteMap_Node=_node
		_node=_node.NextNode()

		Return node._value
	End Method
End Type
End rem

Type TTypeIdByteMap_MapEnumerator
	Method ObjectEnumerator:TTypeIdByteMap_NodeEnumerator()
		Return _enumerator
	End Method
	Field _enumerator:TTypeIdByteMap_NodeEnumerator
End Type


Public

Type TTypeIdByteMap

	Field _size:Int = 0

	Method get:Byte(key:TTypeId)
		Local node:TTypeIdByteMap_Node = Self._findNode(key)

		If node <> nil then Return node._value
	End Method

	Method set(key:TTypeId, value:Byte)
		Self.Insert(key, value)
	End Method

?Not Threaded
	Method delete()
		self.clear()
	End Method
?

	Method size:Int()
		Return Self._size
	End Method

	Method clear()
		If self._root = nil then Return

		Self._root.clear()
		Self._root = nil
	End Method

	Method isEmpty:Byte()
		Return self._root = nil
	End Method

	Method insert(key:TTypeId, value:Byte)
		Assert key Else "Can't insert empty key into byte map"

		Local node:TTypeIdByteMap_Node   = _root
		Local parent:TTypeIdByteMap_Node = nil
		Local cmp:Int

		While node <> nil
			parent = node
			cmp    = key.Compare(node._key)

			If cmp > 0 Then
				node = node._right
			ElseIf cmp < 0 Then
				node = node._left
			Else
				node._value = value
				Return
			EndIf
		Wend

		Self._size:+ 1

		node         = New TTypeIdByteMap_Node
		node._key    = key
		node._value  = value
		node._color  = RED
		node._parent = parent

		If parent = nil Then
			Self._root = node
			Return
		EndIf

		If cmp > 0 Then
			parent._right = node
		Else
			parent._left = node
		EndIf

		Self._insertFixup(node)

	End Method

	Method contains:int(key:TTypeId)
		Return Self._findNode(key) <> nil
	End Method

	Method valueForKey:Byte(key:TTypeId)
		Local node:TTypeIdByteMap_Node = self._findNode(key)
		If node <> nil then Return node._value
	End Method

	Method remove:Byte(key:TTypeId)
		Local node:TTypeIdByteMap_Node = self._findNode(key)
		If node = nil then Return False

		Self._removeNode(node)
		Self._size:- 1

		Return True
	End Method

	Method keys:TTypeIdByteMap_MapEnumerator()
		Local nodeenum:TTypeIdByteMap_NodeEnumerator = New TTypeIdByteMap_KeyEnumerator
		Local mapenum:TTypeIdByteMap_MapEnumerator   = New TTypeIdByteMap_MapEnumerator

		nodeenum._node      = Self._firstNode()
		mapenum._enumerator = nodeenum

		Return mapenum
	End Method

	rem
	Method values:TTypeIdByteMap_MapEnumerator()
		Local nodeenum:TTypeIdByteMap_NodeEnumerator=New TTypeIdByteMap_ValueEnumerator
		nodeenum._node=_FirstNode()
		Local mapenum:TTypeIdByteMap_MapEnumerator=New TTypeIdByteMap_MapEnumerator
		mapenum._enumerator=nodeenum
		Return mapenum
	End Method
	End rem

	Method copy:TTypeIdByteMap()
		Local map:TTypeIdByteMap=New TTypeIdByteMap
		map._root=_root.Copy( nil )
		Return map
	End Method


	Method objectEnumerator:TTypeIdByteMap_NodeEnumerator()
		Local nodeenum:TTypeIdByteMap_NodeEnumerator=New TTypeIdByteMap_NodeEnumerator
		nodeenum._node=_FirstNode()
		Return nodeenum
	End Method

	'***** PRIVATE *****

	Method _firstNode:TTypeIdByteMap_Node()
		Local node:TTypeIdByteMap_Node=_root
		While node._left<>nil
			node=node._left
		Wend
		Return node
	End Method

	Method _lastNode:TTypeIdByteMap_Node()
		Local node:TTypeIdByteMap_Node = self._root
		While node._right <> nil
			node = node._right
		Wend
		Return node
	End Method

	Method _findNode:TTypeIdByteMap_Node(key:TTypeId)
		Local node:TTypeIdByteMap_Node = self._root

		While node <> nil
			Local cmp:int = key.compare(node._key)
			If cmp > 0 Then
				node = node._right
			ElseIf cmp < 0 Then
				node = node._left
			Else
				Return node
			EndIf
		Wend

		Return node
	End Method

	Method _removeNode(node:TTypeIdByteMap_Node)
		Local splice:TTypeIdByteMap_Node
		Local child:TTypeIdByteMap_Node

		If node._left = nil Then
			splice = node
			child  = node._right
		ElseIf node._right = nil Then
			splice = node
			child  = node._left
		Else
			splice = node._left
			While splice._right <> nil
				splice=splice._right
			Wend
			child=splice._left
			node._key=splice._key
			node._value=splice._value
		EndIf
		Local parent:TTypeIdByteMap_Node = splice._parent
		If child<>nil
			child._parent=parent
		EndIf
		If parent=nil
			_root=child
			Return
		EndIf
		If splice=parent._left
			parent._left=child
		Else
			parent._right=child
		EndIf

		If splice._color=BLACK _DeleteFixup child,parent
	End Method

	Method _insertFixup( node:TTypeIdByteMap_Node )
		Local uncle:TTypeIdByteMap_Node

		While node._parent._color = RED And node._parent._parent <> nil
			If node._parent = node._parent._parent._left Then
				uncle = node._parent._parent._right
				If uncle._color = RED Then
					node._parent._color = BLACK
					uncle._color = BLACK
					uncle._parent._color = RED
					node = uncle._parent
				Else
					If node = node._parent._right Then
						node = node._parent
						self._rotateLeft(node)
					EndIf
					node._parent._color = BLACK
					node._parent._parent._color = RED
					self._rotateRight(node._parent._parent)
				EndIf
			Else
				uncle = node._parent._parent._left
				If uncle._color = RED Then
					node._parent._color = BLACK
					uncle._color = BLACK
					uncle._parent._color = RED
					node = uncle._parent
				Else
					If node = node._parent._left Then
						node = node._parent
						self._rotateRight(node)
					EndIf
					node._parent._color = BLACK
					node._parent._parent._color = RED
					self._rotateLeft(node._parent._parent)
				EndIf
			EndIf
		Wend
		_root._color=BLACK
	End Method

	Method _rotateLeft(node:TTypeIdByteMap_Node)
		Local child:TTypeIdByteMap_Node = node._right
		node._right = child._left
		If child._left <> nil Then
			child._left._parent = node
		EndIf
		child._parent = node._parent
		If node._parent <> nil Then
			If node = node._parent._left Then
				node._parent._left = child
			Else
				node._parent._right = child
			EndIf
		Else
			_root = child
		EndIf
		child._left=node
		node._parent=child
	End Method

	Method _rotateRight( node:TTypeIdByteMap_Node )
		Local child:TTypeIdByteMap_Node=node._left
		node._left=child._right
		If child._right<>nil
			child._right._parent=node
		EndIf
		child._parent=node._parent
		If node._parent<>nil
			If node=node._parent._right
				node._parent._right=child
			Else
				node._parent._left=child
			EndIf
		Else
			_root=child
		EndIf
		child._right=node
		node._parent=child
	End Method

	Method _deleteFixup(node:TTypeIdByteMap_Node, parent:TTypeIdByteMap_Node)
		Local sib:TTypeIdByteMap_Node

		While node<>_root And node._color=BLACK
			If node=parent._left

				sib=parent._right

				If sib._color=RED
					sib._color=BLACK
					parent._color=RED
					_RotateLeft parent
					sib=parent._right
				EndIf

				If sib._left._color=BLACK And sib._right._color=BLACK
					sib._color=RED
					node=parent
					parent=parent._parent
				Else
					If sib._right._color=BLACK
						sib._left._color=BLACK
						sib._color=RED
						_RotateRight sib
						sib=parent._right
					EndIf
					sib._color=parent._color
					parent._color=BLACK
					sib._right._color=BLACK
					_RotateLeft parent
					node=_root
				EndIf
			Else
				sib = parent._left

				If sib._color=RED
					sib._color=BLACK
					parent._color=RED
					_RotateRight parent
					sib=parent._left
				EndIf

				If sib._right._color=BLACK And sib._left._color=BLACK
					sib._color=RED
					node=parent
					parent=parent._parent
				Else
					If sib._left._color=BLACK
						sib._right._color=BLACK
						sib._color=RED
						_RotateLeft sib
						sib=parent._left
					EndIf
					sib._color=parent._color
					parent._color=BLACK
					sib._left._color=BLACK
					_RotateRight parent
					node=_root
				EndIf
			EndIf
		Wend
		node._color=BLACK
	End Method

	Const RED:int   = -1
	Const BLACK:int = 1

	Field _root:TTypeIdByteMap_Node = nil

End Type
