Class {
	#name : 'ObjectBreakerTest',
	#superclass : 'TestCase',
	#category : 'META-Project-NK000073',
	#package : 'META-Project-NK000073'
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
		
	humanClass
		compile: 'customClass ^super class'.
	
	humanClass
		compile: 'add: aNumber to: anotherNumber ^aNumber + anotherNumber'.
	
	humanClass
		compile: 'subtract: aNumber from: anotherNumber ^anotherNumber - aNumber'.
	
]

{ #category : 'tests' }
ObjectBreakerTest >> testDoesNotSupportSuperSends [
	| human breaker|
	human := Human new.
	breaker := ObjectBreaker for: human.
	
	self should: [ breaker onMessageSendIn: #customClass ] raise: ObjectCentricDebuggingDoesNotSupportSuperSends.
	self shouldnt: [ breaker onMessageSendIn: #greet ] raise: ObjectCentricDebuggingDoesNotSupportSuperSends.
	
	breaker clear.
]

{ #category : 'tests' }
ObjectBreakerTest >> testObjectBreakerCreation [
	| human breaker|
	human := Human new.
	breaker := ObjectBreaker for: human.
	
	"Test that the object gets created successfully."
	self assert: (breaker object) equals: human.
	self assert: (human class) equals: AnonymousHuman.
	
	"Test all methods of class (all should function normally)."
	self assert: (human greet) equals: 'Hello'.
	self assert: (human customClass) equals: AnonymousHuman .
	self assert: (human add: 1 to: 1) equals: 2.
	self assert: (human subtract: 2 from: 4) equals: 2.
	
	"Test that clearing the breaker cleans up properly."
	breaker clear.
	self assert: (human class) equals: Human.
	self deny: (Smalltalk hasClassNamed: #AnonymousHuman).
	
]

{ #category : 'tests' }
ObjectBreakerTest >> testOnMessageSend [
	| human breaker |
	human := Human new.
	breaker := ObjectBreaker for: human.
	
	"Confirm that the object breaks on all objects with message sends."
	breaker onMessageSend.
	self should: [ human add: 2 to: 2 ] raise: Halt.
	self should: [ human subtract: 2 from: 4 ] raise: Halt.
	self shouldnt: [ human greet ] raise: Halt.
	
	breaker clear.
]

{ #category : 'tests' }
ObjectBreakerTest >> testOnMessageSendIn [
	| human breaker |
	human := Human new.
	breaker := ObjectBreaker for: human.
	
	"Confirm that the object breaks on the specific selector, but not on another."
	breaker onMessageSendIn: #add:to:.
	self should: [ human add: 2 to: 2 ] raise: Halt.
	self shouldnt: [ human subtract: 2 from: 4 ] raise: Halt.
	
	breaker clear.
]

{ #category : 'tests' }
ObjectBreakerTest >> testOnMessageSendInWhen [
	| human breaker |
	human := Human new.
	breaker := ObjectBreaker for: human.
	
	"Confirm that the object breaks when the condition is met."
	breaker onMessageSendIn: #add:to: when: [ :send | send selector = #+ ].
	self should: [ human add: 2 to: 2 ] raise: Halt.
	
	"Confirm that the object does not break when the condition is not met."
	breaker onMessageSendIn: #subtract:from: when: [ :send | send selector = #+ ].
	self shouldnt: [ human subtract: 2 from: 4 ] raise: Halt.
	
	breaker clear.
	
	
]
