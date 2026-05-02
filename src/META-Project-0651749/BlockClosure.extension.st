Extension { #name : 'BlockClosure' }

{ #category : '*META-Project-0651749' }
BlockClosure >> asMultipleExceptionBlockClosure [
	^MultipleExceptionBlockClosure for: self
]
