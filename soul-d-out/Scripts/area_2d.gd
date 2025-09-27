extends Area2D

# Store the checkpoint position
var checkpoint_position: Vector2

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body is CharacterBody2D:
		checkpoint_position = global_position
		print("Checkpoint saved at:", checkpoint_position)
		# You can also call a method on the player to update its checkpoint
		if body.has_method("set_checkpoint"):
			body.set_checkpoint(checkpoint_position)
