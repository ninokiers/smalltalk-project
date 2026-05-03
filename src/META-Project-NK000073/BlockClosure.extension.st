Extension { #name : 'BlockClosure' }

{ #category : '*META-Project-NK000073' }
BlockClosure >> asMultipleExceptionBlockClosure [
	^MultipleExceptionBlockClosure for: self
]
