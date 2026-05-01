Class {
	#name : 'ObjectBreaker',
	#superclass : 'Object',
	#instVars : [
		'targetObject',
		'originalClass',
		'anonymousClass'
	],
	#category : 'META-Project-0651749',
	#package : 'META-Project-0651749'
}

{ #category : 'instance creation' }
ObjectBreaker class >> for: anObject [
	^self new object: anObject
]

{ #category : 'asserting' }
ObjectBreaker >> assertNoSuperSendIn: aMethod [
	"""
		Signals the DoesNotSupportSuperSends error if the method contains super sends.
	"""
	| ast |
	
	ast := RBParser parseMethod: aMethod sourceCode.
	
	ast nodesDo: [ :node |
		(node isSuperSend) ifTrue: [ ObjectCentricDebuggingDoesNotSupportSuperSends signal ]
	].
]

{ #category : 'as yet unclassified' }
ObjectBreaker >> createAnonymousSubclass [
	"""
		Creates an anonymous subclass of the linked object's class.
	"""
	
	" If no object is linked -> exit and return nil "
	targetObject ifNil: [ ^nil ].
	
	" Create anonymous class "
	anonymousClass := ShiftClassBuilder new
		superclass: originalClass;
		name: 'Anonymous', originalClass name;
		package: 'META-Project-0651749';
		build;
		install.
	
]

{ #category : 'as yet unclassified' }
ObjectBreaker >> installWrapperOn: aSelector condition: conditionBlock [
	"""
		Install a wrapper method on the anonymous class for a specific method
		of the original class.
	"""
	| method |
	
	method := originalClass >> aSelector.
	
	self assertNoSuperSendIn: method.
	
	anonymousClass compile: method sourceCode.
	
	
]

{ #category : 'accessing' }
ObjectBreaker >> object [
	^targetObject
]

{ #category : 'accessing' }
ObjectBreaker >> object: anObject [
	targetObject := anObject.
	originalClass := anObject class.
	^self
		createAnonymousSubclass;
		yourself.
]

{ #category : 'as yet unclassified' }
ObjectBreaker >> onMessageSendIn: aSelector [
	^self onMessageSendIn: aSelector when: [ :send | true ]
]

{ #category : 'as yet unclassified' }
ObjectBreaker >> onMessageSendIn: aSelector when: aBlock [
	"""
		Install a wrapper method on the anonymous class for a specific method
		of the original class.
	"""
	| method |
	
	method := originalClass >> aSelector.
	
	self assertNoSuperSendIn: method.
	
	anonymousClass compile: method sourceCode.
	
]
