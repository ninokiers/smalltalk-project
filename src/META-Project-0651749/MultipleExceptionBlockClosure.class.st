Class {
	#name : 'MultipleExceptionBlockClosure',
	#superclass : 'Object',
	#instVars : [
		'block',
		'handlers',
		'current'
	],
	#category : 'META-Project-0651749',
	#package : 'META-Project-0651749'
}

{ #category : 'instance creation' }
MultipleExceptionBlockClosure class >> for: aBlock [
	^self new setBlock: aBlock; yourself.
]

{ #category : 'as yet unclassified' }
MultipleExceptionBlockClosure >> callNextHandler [
	current pass
]

{ #category : 'as yet unclassified' }
MultipleExceptionBlockClosure >> handle: anException with: aBlock [
	handlers add: anException -> aBlock.
	^self
]

{ #category : 'initialization' }
MultipleExceptionBlockClosure >> initialize [
	super initialize.
	handlers := SortedCollection sortBlock: [ :a :b |
		a key inheritsFrom: b key
	].
]

{ #category : 'initialization' }
MultipleExceptionBlockClosure >> setBlock: aBlock [
	block := aBlock.
	
]

{ #category : 'accessing' }
MultipleExceptionBlockClosure >> value: aValue [
	| nested |
	nested := [ block value: aValue ].
		
	handlers do: [ :handler |
		| previous |
		previous := nested.
		nested := [
			[ previous value ] on: handler key do: [ :err |
				current := err.
				handler value value: err.
			]
		]
	].

	^ nested value

]
