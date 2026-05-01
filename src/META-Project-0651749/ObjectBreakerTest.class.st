Class {
	#name : 'ObjectBreakerTest',
	#superclass : 'TestCase',
	#category : 'META-Project-0651749',
	#package : 'META-Project-0651749'
}

{ #category : 'running' }
ObjectBreakerTest >> setUp [
	| humanClass |
	
	super setUp.
	(Smalltalk hasClassNamed: #Human) ifTrue: [ (Smalltalk at: #Human) removeFromSystem ].
	Smalltalk garbageCollect.
	
	humanClass := ShiftClassBuilder new
		superclass: Object;
		name: #Human;
		package: 'META-Project-0651749';
		build;
		install.
	
	humanClass
		compile: 'greet ^''Hello'''.
	
]

{ #category : 'tests' }
ObjectBreakerTest >> testObjectBreakerCreation [
	"Requirement 2"
	| human breaker|
	human := Human new.
	breaker := ObjectBreaker for: human.
	
	self assert: (breaker object) equals: human.
	
	breaker clear.
	
]
