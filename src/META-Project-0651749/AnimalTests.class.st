Class {
	#name : 'AnimalTests',
	#superclass : 'TestCase',
	#category : 'META-Project-0651749',
	#package : 'META-Project-0651749'
}

{ #category : 'running' }
AnimalTests >> setUp [
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
		compile: 'eat: food ^self digest: food';
		compile: 'digest: food <protected> ^''nom '', food';
		compile: 'perceive <protected> ^''time goes by'''	.
			
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
