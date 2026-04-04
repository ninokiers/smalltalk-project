"
An abstract class representing an animal. The class implements the public method for the animal to eat, and the private methods for the animal to digest and perceive.
"
Class {
	#name : 'Animal',
	#superclass : 'Object',
	#category : 'META-Project-0651749',
	#package : 'META-Project-0651749'
}

{ #category : 'accessing' }
Animal class >> compiler [
	^super compiler addPlugin: ProtectedCompilerPlugin
]
