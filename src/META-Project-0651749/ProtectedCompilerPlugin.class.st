Class {
	#name : 'ProtectedCompilerPlugin',
	#superclass : 'OCStaticASTCompilerPlugin',
	#category : 'META-Project-0651749',
	#package : 'META-Project-0651749'
}

{ #category : 'as yet unclassified' }
ProtectedCompilerPlugin >> find: aSelector inMethodsOf: aClass [
	"""
		Checks whether the method is first encountered as public or private in the
		lookup tree, and returns the corresponding selector.
		If no method with that name is found, it returns the unmangled selector.
	"""
	| lookupClass |
	
	lookupClass := aClass.
	
	[ lookupClass isNil ] whileFalse: [ 
		lookupClass methodDict
			at: (self mangle: aSelector)
			ifPresent: [ ^ self mangle: aSelector ].
		
		lookupClass methodDict
			at: (aSelector)
			ifPresent: [ ^ aSelector ].
	
		lookupClass := lookupClass superclass.
	].

	^aSelector
	
]

{ #category : 'as yet unclassified' }
ProtectedCompilerPlugin >> mangle: aSelector [
	"Mangle the argument"
	^('__', aSelector) asSymbol
]

{ #category : 'as yet unclassified' }
ProtectedCompilerPlugin >> rewritePrivate: aMethodNode [
	"""
		Rewrite the 'private' method to mangle the selector and self and super sends.
	"""
	
	" Mangle self and super sends "
	aMethodNode nodesDo: [ :node |
		node isMessage ifTrue: [ 
			node isSelfSend ifTrue: [
				node
					renameSelector: (self find: node selector inMethodsOf: ast methodClass)
					andArguments: node arguments.
			].
			node isSuperSend ifTrue: [
				node
					renameSelector: (self find: node selector inMethodsOf: ast methodClass superclass)
					andArguments: node arguments.
			].
		]
	].
	
	" Mangle selector "
	aMethodNode renameSelector: (self mangle: ast selector) andArguments: ast arguments.
	
	^aMethodNode
]

{ #category : 'as yet unclassified' }
ProtectedCompilerPlugin >> rewritePublic: aMethodNode [
	"""
		Write a new 'public' method that simply calls the 'private' method
	"""
	| body |
	
	" Create new body ensuring to keep the right selector and arguments. "
	body := RBSequenceNode new.
	body addNode: (RBMessageNode
		receiver: RBVariableNode selfNode
		selector: (self mangle: aMethodNode selector)
		arguments: aMethodNode arguments).
	body addReturn.
	
	aMethodNode body: body.
	
	" Add <public> pragma "
	aMethodNode addPragma: (RBPragmaNode selector: #public arguments: #()).
	
	^aMethodNode
]

{ #category : 'private - transforming' }
ProtectedCompilerPlugin >> transform [
	"""
		#protected pragma present: replace name and proceed
		#public pragma present: proceed normally
		neither present: add <public> pragma to the ast and compile as new method
	"""
	self copyAST.
	
	" If marked as public -> compile normally "
	ast pragmaNamed: #public ifPresent: [ ^ast ].
	
	" If not marked as protected -> compile new method marked as public "
	ast pragmaNamed: #protected
		ifAbsent: [
			ast methodClass compile: (self rewritePublic: ast copy) formattedCode.
		].

	" Rewrite the method to mangle selectors of self and super sends "
	self rewritePrivate: ast.
]
