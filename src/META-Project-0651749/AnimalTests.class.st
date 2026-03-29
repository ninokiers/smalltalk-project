Class {
	#name : 'AnimalTests',
	#superclass : 'TestCase',
	#category : 'META-Project-0651749',
	#package : 'META-Project-0651749'
}

{ #category : 'as yet unclassified' }
AnimalTests >> testAnimalEats [
	| animal |
	animal := Animal new.
	
	self assert: (animal eat: 'grass') equals: ('nom grass')
]
