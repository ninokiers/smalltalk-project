Class {
	#name : 'ProtectedCompilerPlugin',
	#superclass : 'OCStaticASTCompilerPlugin',
	#category : 'META-Project-0651749',
	#package : 'META-Project-0651749'
}

{ #category : 'as yet unclassified' }
ProtectedCompilerPlugin >> mangle: aSelector [
	^('__', aSelector) asSymbol
]

{ #category : 'as yet unclassified' }
ProtectedCompilerPlugin >> rewritePrivate: aMethodNode [
	aMethodNode nodesDo: [ :node |
		node isMessage ifTrue: [ 
			((node isSelfSend) or: (node isSuperSend)) ifTrue: [
				node renameSelector: (self mangle: node selector) andArguments: node arguments.
			]
		]
	].
	
	aMethodNode renameSelector: (self mangle: ast selector) andArguments: ast arguments.
	^aMethodNode
]

{ #category : 'as yet unclassified' }
ProtectedCompilerPlugin >> rewritePublic: aMethodNode [
	| body |
	
	body := RBSequenceNode new.
	body addNode: (RBMessageNode
		receiver: RBVariableNode selfNode
		selector: (self mangle: aMethodNode selector)
		arguments: aMethodNode arguments).
	body addReturn.
	
	aMethodNode body: body.
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
