' ------------------------------------------------------------------------------
' -- src/kernel/kernel_aware_interface.bmx
' --
' -- Allows an object to be aware of the kernel. Nothing fancy.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "game_kernel.bmx"

''' <summary>
''' Abstract type that allows another type to be aware of the kernel.
'''
''' Adds methods for setting the kernel and for autoloading services into fields that
''' have `autoload_service` in their meta data.
''' </summary>
Type KernelAwareInterface Abstract

	Field __kernel:GameKernel

	''' <summary>Set the GameKernel for the object.</summary>
	Method setKernel(kernel:GameKernel)
		Self.__kernel = kernel
	End Method

	''' <summary>Get the GameKernel for the object.</summary>
	Method getKernel:GameKernel()
		Return Self.__kernel
	End Method

	''' <summary>Autoload services into the current object from the kernel.</summary>
	Method autoloadServices(requireAutoloadFlag:Byte = True)

		Local typeData:TTypeId = TTypeId.ForObject(Self)
		Local baseType:TTypeId = TTypeId.ForName("GameService")

		For Local fieldData:TField = EachIn typeData.EnumFields()

			' Skip any field that doesn't have an autoload flag
			If requireAutoloadFlag And "" = fieldData.MetaData("autoload_service") Then Continue

			' Check this field is a service type
			Local fieldType:TTypeId = fielddata.TypeId()
			If fieldType = Null Then Continue

			' If this field type is a service, autoload it
			If Self._inherits(fieldType, baseType) Then
				fieldData.Set(Self, Self.__kernel.getService(fieldType))
			End If

		Next

	End Method

	''' <summary>
	''' Check if `fieldType` inherits `baseType`. Checks all parent types all
	''' the way to the root Object type.
	''' </summary>
	Method _inherits:Byte(fieldType:TTypeId, baseType:TTypeId)
		If fieldType.ExtendsType(baseType) Then Return True
		If fieldType.SuperType() = Null Then Return False

		Return Self._inherits(fieldType.SuperType(), baseType)
	End Method

End Type
