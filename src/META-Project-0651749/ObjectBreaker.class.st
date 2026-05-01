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
	"Signals the DoesNotSupportSuperSends error if the method contains super sends"
	| hasSuperSends |
	
	hasSuperSends := aMethod ast allChildren
		anySatisfy: [ :node | node isMessage and: [ node isSuperSend ] ].
	
	hasSuperSends ifTrue: [ ObjectCentricDebuggingDoesNotSupportSuperSends signal ].
]

{ #category : 'cleanup' }
ObjectBreaker >> clear [
	"Cleanup: reroute the object to the original class and remove the anonymous class"
	self rerouteClass: originalClass.
	anonymousClass removeFromSystem.
]

{ #category : 'creation' }
ObjectBreaker >> createAnonymousSubclass [
	"Creates an anonymous subclass of the linked object's class"
	
	targetObject ifNil: [ ^nil ]. "If no object is linked -> exit and return nil"
	
	anonymousClass := ShiftClassBuilder new
		superclass: originalClass;
		name: 'Anonymous', originalClass name;
		package: 'META-Project-0651749';
		build;
		install.
	
]

{ #category : 'invalidate' }
ObjectBreaker >> installMethod: aSelector [
	"Install a copy of the original method on the anonymous class"
	| method |
	method := originalClass >> aSelector.
	
	self assertNoSuperSendIn: method.
	
	anonymousClass compile: method sourceCode.
	
	^anonymousClass >> aSelector.
	
]

{ #category : 'accessing' }
ObjectBreaker >> object [
	"Return the target object"
	^targetObject
]

{ #category : 'creation' }
ObjectBreaker >> object: anObject [
   "Initialize the object breaker"
	targetObject := anObject.
	originalClass := anObject class.
	^self
		createAnonymousSubclass;
		rerouteClass: anonymousClass;
		yourself.
]

{ #category : 'as yet unclassified' }
ObjectBreaker >> onMessageSend [
	"Calls onMessageSendIn:when: with every method of the class that doesn't contain a super send"
	originalClass methodsDo: [ :method |
		[ self onMessageSendIn: method selector ]
			on: ObjectCentricDebuggingDoesNotSupportSuperSends
			do: [ " nothing " ]
	]
]

{ #category : 'wrapping' }
ObjectBreaker >> onMessageSendIn: aSelector [
	"Calls onMessageSendIn:when: with the conditional argument being always true"
	^self onMessageSendIn: aSelector when: [ :send | true ]
]

{ #category : 'wrapping' }
ObjectBreaker >> onMessageSendIn: aSelector when: aBlock [
	"""
		Install a wrapper method on the anonymous class with breaks
		on message sends, when the specific condition is met.
	"""
	| method link |
	
	method := self installMethod: aSelector.
	
	"MetaLink calls 'Halt now' when the condition is met"
	link := MetaLink new
		metaObject: Halt;
		selector: #now;
		control: #before;
		condition: aBlock arguments: #(#node).
	
	"Link all message send nodes"
	method ast sendNodes do: [ :node |
		node link: link
	].
]

{ #category : 'creation' }
ObjectBreaker >> rerouteClass: aClass [
	"Change the class of the target object"
	targetObject primitiveChangeClassTo: aClass basicNew.
]
