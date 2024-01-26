extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	#SaveLoad.saveGame()#reset game
	SaveLoad.loadGame()
	
	#Lock and Unlock Stage Buttons
	for i in range($Stages.get_child_count()):
		Savefile.stages.append(i+1)
	for stage in $Stages.get_children():
		if str_to_var(stage.name) in range(Savefile.current_stage+1):
			stage.disabled = false
			stage.connect("pressed", start_combat.bind(stage.name))
		else:
			stage.disabled = true 
	print(Savefile.current_stage)
	
	if not $BGM.playing:
		await get_tree().create_timer(1).timeout
		$BGM.play()


func start_combat(stage_number:StringName):
	get_tree().change_scene_to_file("res://stage"+stage_number+".tscn")

func _on_start_button_pressed():
	pass


func _on_options_button_pressed():
	pass

func _on_quit_button_pressed():
	get_tree().quit()
