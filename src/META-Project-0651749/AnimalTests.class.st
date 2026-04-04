Class {
	#name : 'AnimalTests',
	#superclass : 'TestCase',
	#category : 'META-Project-0651749',
	#package : 'META-Project-0651749'
}

{ #category : 'tests' }
AnimalTests >> testAnimalDigest [
	| animal |
	animal := Animal new.
	
	self should: [animal digest: 'grass'] raise: MessageNotUnderstood
]

{ #category : 'as yet unclassified' }
AnimalTests >> testAnimalEat [
	| animal |
	animal := Animal new.
	
	self assert: (animal eat: 'grass') equals: ('nom grass')
]

{ #category : 'tests' }
AnimalTests >> testCowClassCreation [
	Animal
		subclass: #Cow
		instanceVariableNames: ''
		classVariableNames: ''
		package: 'META-Project-0651749'.
]

{ #category : 'tests' }
AnimalTests >> testCowDream [
	| cow |
	cow := Cow new.
	
	self assert: (cow perceive) equals: ('I can see the sun shining and notice that time goes by')
]

{ #category : 'tests' }
AnimalTests >> testCowEat [
	| cow |
	cow := Cow new.
	
	self assert: (cow eat: 'grass') equals: ('nom nom nom nom grass')
]

{ #category : 'tests' }
AnimalTests >> testCowInvalid [
	| cow |
	cow := Cow new.
	
	self should: [cow invalid] raise: MessageNotUnderstood
]
