extends Node
class_name State

#State class to be extendes by each state

signal Transitioned

#Runs upon entering the state
func Enter():
	pass

#Runs upon exiting the state
func Exit():
	pass
	
#Runs in the place of _process()
func Update(_delta: float):
	pass
	
#Runs in the place of _physics_process()
func Physics_Update(_delta: float):
	pass
