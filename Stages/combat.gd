extends Node2D

@export var stage_number: int

var is_player_dead = false
var clear = false

func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _process(delta):
	#Play DeadBGM
	if $Player.is_dead and not is_player_dead:
		$BGM.stop()
		#$ClearBGM.stop()
		#$DeadBGM.play()
		is_player_dead = true
		clear = false
		await get_tree().create_timer(3).timeout
		get_tree().change_scene_to_file("res://main.tscn")

	
	#Play ClearBGM
	if clear or is_player_dead:
		return
	for enemy in $Enemies.get_children():
		if not enemy.is_dead:
			clear = false
			break
		else:
			clear = true
	if clear:
		#$BGM.stop()
		#$ClearBGM.play()
		if stage_number == Savefile.current_stage:
			Savefile.current_stage +=1
			SaveLoad.saveGame()
			print(Savefile.current_stage)
		await get_tree().create_timer(1).timeout
		$ClearCanvasLayer.visible = true

func _on_continue_button_pressed():
	get_tree().change_scene_to_file("res://main.tscn")


func _on_wave_1_body_entered(body):
	pass # Replace with function body.
func _on_wave_2_body_entered(body):
	pass # Replace with function body.
func _on_wave_3_body_entered(body):
	pass # Replace with function body.
