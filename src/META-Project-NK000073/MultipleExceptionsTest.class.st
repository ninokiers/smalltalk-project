Class {
	#name : 'MultipleExceptionsTest',
	#superclass : 'TestCase',
	#category : 'META-Project-NK000073',
	#package : 'META-Project-NK000073'
}

{ #category : 'tests' }
MultipleExceptionsTest >> testCallNextHandler [
	"Requirement 4: a handler should be able to use callNextHandler to call the next handler in the error hierarchy"
	| block trace |
	
	trace := OrderedCollection new.
	
	"A block that handles ZeroDivide, MessageNotUnderstood and Error"
	block := [ :arg | arg / 0 ] asMultipleExceptionBlockClosure.
	block
		handle: ZeroDivide with: [ :err | 
			trace add: #ZeroDivide.
			block callNextHandler
		];
		handle: MessageNotUnderstood with: [ :err |
			trace add: #MessageNotUnderstood.
			block callNextHandler
		];
		handle: Error with: [ :err |
			trace add: #Error.
			'An error occured.'
		].
	
	"Calling 1 / 0 should call the ZeroDivide handler and Error handler."
	self assert: (block value: 1) equals: 'An error occured.'.
	self assert: trace equals: (OrderedCollection new addAll: #(ZeroDivide Error); yourself).
	
	trace removeAll.
	
	"Calling nil / 0 should call the MessageNotUnderstood handler and Error handler."
	self assert: (block value: nil) equals: 'An error occured.'.
	self assert: trace equals: (OrderedCollection new addAll: #(MessageNotUnderstood Error); yourself).
	
	
]

{ #category : 'tests' }
MultipleExceptionsTest >> testMultipleExceptions [
	"Requirement 1: an extended block closure supports multiple exception handlers."
	| block |
	
	block := [ :arg | arg / 0 ] asMultipleExceptionBlockClosure.
	
	block
		handle: ZeroDivide with: [ :err | 'You divided by zero.' ];
		handle: MessageNotUnderstood with: [ :err | 'I cannot divide nil.' ].
	
	self assert: (block value: 1) equals: 'You divided by zero.'.
	self assert: (block value: nil) equals: 'I cannot divide nil.'.
]

{ #category : 'tests' }
MultipleExceptionsTest >> testNestedBlocks [
	"Requirement 3: nested on:do: blocks with handle:with: blocks should call the correct handler"
	| block |
	
	"Inner error matches -> inner handler is called"
	block := [ 
		([ :arg | arg / 0 ] asMultipleExceptionBlockClosure)
			handle: ZeroDivide with: [:err | 'You divided by zero.'];
			value: 1.
	].

	self assert: (block on: Error do: [:err | 'An error occured.']) equals: 'You divided by zero.'.
	
	"Inner error does not match -> outer error does -> outer handler is called"
	block := [ 
		([ :arg | arg / 0 ] asMultipleExceptionBlockClosure)
			handle: ZeroDivide with: [:err | 'You divided by zero.'];
			value: nil.
	].

	self assert: (block on: Error do: [:err | 'An error occured.']) equals: 'An error occured.'.
	
	"Both errors match -> innermost handler is called"
	block := [ 
		([ :arg | arg / 0 ] asMultipleExceptionBlockClosure)
			handle: ZeroDivide with: [:err | 'You divided by zero.'];
			value: 1.
	].

	self assert: (block on: ZeroDivide do: [:err | 'You actually divided by zero.']) equals: 'You divided by zero.'.
	
	"Neither error matches -> error is raised"
	block := [ 
		([ :arg | arg / 0 ] asMultipleExceptionBlockClosure)
			handle: ZeroDivide with: [:err | 'You divided by zero.'];
			value: nil.
	].

	self should: [ block on: ZeroDivide do: [:err | 'You actually divided by zero.'] ] raise: MessageNotUnderstood.
]

{ #category : 'tests' }
MultipleExceptionsTest >> testOrderOfSpecificity [
	"Requirement 2: handlers should be called in order of specificity"
	| block1 block2 |
	
	"Define ZeroDivide first and Error second"
	block1 := [ :arg | arg / 0 ] asMultipleExceptionBlockClosure.
	block1
		handle: ZeroDivide with: [ :err | 'You divided by zero.' ];
		handle: Error with: [ :err | 'An error occured.' ].
	
	"Define Error first and ZeroDivide second"
	block2 := [ :arg | arg / 0 ] asMultipleExceptionBlockClosure.
	block2
		handle: Error with: [ :err | 'An error occured.' ];
		handle: ZeroDivide with: [ :err | 'You divided by zero.' ].
	
	"Both should raise 'You divided by zero'."
	self assert: (block1 value: 1) equals: 'You divided by zero.'.
	self assert: (block2 value: 1) equals: 'You divided by zero.'.
]
