' ------------------------------------------------------------------------------
' -- src/services/kernel_information_service.bmx
' --
' -- A GameService that acts as a proxy so other services can interact with the
' -- kernel without exposing implementation details.
' --
' -- This file is part of pangolin.mod (https://www.sodaware.net/pangolin/)
' -- Copyright (c) 2009-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


''' <summary>
''' A GameService that acts as a proxy so other services can interact with the
''' kernel without exposing implementation details.
''' </summary>
Type KernelInformationService Extends GameService

	Field _kernel:GameKernel

	''' <summary>Get the kernel.</summary>
	Method getKernel:GameKernel()
		Return self._kernel
	End Method

	''' <summary>Get all services currently registered with the kernel.</summary>
	Method getServices:GameServiceCollection()
		Return Self._kernel.getServices()
	End Method

	''' <summary>Get a single services by its type.</summary>
	''' <param name="serviceType">The TTypeId of the service to retrieve.</param>
	Method getService:GameService(serviceType:TTypeId)
		Return Self._kernel.getService(serviceType)
	End Method


	' ------------------------------------------------------------
	' -- Creation / Destruction
	' ------------------------------------------------------------

	''' <summary>Autoload services into the target object from the kernel.</summary>
	''' <param name="target">The object to inject services into.</param>
	''' <param name="requireAutoLoadFlag">If `True`, will only inject if the field as `autoload_service` meta data set.</param>
	Method injectServicesInto(target:Object, requireAutoloadFlag:Byte = True)

		Local typeData:TTypeId = TTypeId.ForObject(target)
		Local baseType:TTypeId = TTypeId.ForName("GameService")

		For Local fieldData:TField = EachIn typeData.EnumFields()

			' Skip any field that doesn't have an autoload flag.
			If requireAutoloadFlag And "" = fieldData.MetaData("autoload_service") Then Continue

			' Check this field is a service type.
			Local fieldType:TTypeId = fielddata.TypeId()
			If fieldType = Null Then Continue

			' If this field type is a service, autoload it.
			If Self._inherits(fieldType, baseType) Then
				fieldData.Set(target, Self.getService(fieldType))
			EndIf

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


	' ------------------------------------------------------------
	' -- Creation / Destruction
	' ------------------------------------------------------------

	Function Create:KernelInformationService(kernel:GameKernel)
		Local this:KernelInformationService = New KernelInformationService
		this._kernel	= kernel
		this._priority	= 0
		Return this
	End Function

End Type
