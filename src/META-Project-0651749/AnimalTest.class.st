Class {
	#name : 'AnimalTest',
	#superclass : 'TestCase',
	#category : 'META-Project-0651749',
	#package : 'META-Project-0651749'
}

{ #category : 'running' }
AnimalTest >> setUp [
	| animal cow |
	
	super setUp.
	(Smalltalk hasClassNamed: #Cow) ifTrue: [ (Smalltalk at: #Cow) removeFromSystem ].
	(Smalltalk hasClassNamed: #Animal) ifTrue: [ (Smalltalk at: #Animal) removeFromSystem ].
	Smalltalk garbageCollect.
	
	animal := ShiftClassBuilder new
		superclass: Object;
		name: #Animal;
		package: 'META-Project-0651749';
		build;
		install.
		
	animal class compile: 'compiler ^super compiler addPlugin: ProtectedCompilerPlugin new; yourself'.
	
	animal
		compile: 'digest: food <protected> ^''nom '', food';
		compile: 'perceive <protected> ^''time goes by'''	;
		compile: 'eat: food ^self digest: food'.
		
	cow := ShiftClassBuilder new
		superclass: Animal;
		name: #Cow;
		package: 'META-Project-0651749';
		build;
		install.
	
	cow
		compile: 'digest: food <protected> ^''nom nom nom nom '', food';
		compile: 'invalid ^Animal new digest: ''apple''';
		compile: 'dream: food ^''I would like to '', (self eat: food)';
		compile: 'perceive ^''I can see the sun shining and notice that '', super perceive'	.
	
]

{ #category : 'tests' }
AnimalTest >> testAnimalDigest [
	"Requirement 1.1"
	| animal |
	animal := Animal new.
	
	self should: [animal digest: 'grass'] raise: MessageNotUnderstood
]

{ #category : 'as yet unclassified' }
AnimalTest >> testAnimalEat [
	"Requirement 1.1"
	| animal |
	animal := Animal new.
	
	self assert: (animal eat: 'grass') equals: ('nom grass')
]

{ #category : 'tests' }
AnimalTest >> testBackwardCompatibility [
	"Requirement 1.2"
	| cow |
	cow := Cow new.
	
	cow class compile: 'getClass ^self class'.
	
	self assert: (cow getClass) equals: (cow class).
	
	
]

{ #category : 'tests' }
AnimalTest >> testCowDream [
	"Requirement 1.1"
	| cow |
	cow := Cow new.
	
	self assert: (cow perceive) equals: ('I can see the sun shining and notice that time goes by')
]

{ #category : 'tests' }
AnimalTest >> testCowEat [
	"Requirement 1.1"
	| cow |
	cow := Cow new.
	
	self assert: (cow eat: 'grass') equals: ('nom nom nom nom grass')
]

{ #category : 'tests' }
AnimalTest >> testCowInvalid [
	"Requirement 1.1"
	| cow |
	cow := Cow new.
	
	self should: [cow invalid] raise: MessageNotUnderstood
]
