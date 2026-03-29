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

{ #category : 'private' }
Animal >> digest: food [
	<protected>
	^'nom ',food.
]

{ #category : 'accessing' }
Animal >> eat: arg1 [

	^ self digest: arg1
]

{ #category : 'private' }
Animal >> perceive [
	<protected>
	^ 'time goes by'
]
