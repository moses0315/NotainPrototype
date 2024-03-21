extends CharacterBody2D

@onready var healthbar = $Healthbar
@onready var anim = $AnimationPlayer
@onready var sprite = $AnimatedSprite2D

const speed = 250

var health = 200
var attack_power = 20
var is_attacking = false
var is_rolling = false
var roll_cooldowned = true
var is_hurt = false
var is_dead = false


func _ready():
	$AnimatedSprite2D/AttackArea2D/CollisionShape2D.disabled = true
	healthbar.max_value = health
	
@warning_ignore("unused_parameter")
func _physics_process(delta):
	healthbar.value = health
	if is_dead:
		return

	var direction = Input.get_axis("left", "right")
	
	#Not change direction when attack or roll
	if not is_attacking and not is_rolling:
		if direction == -1:
			sprite.scale.x = -1
		elif direction == 1:
			sprite.scale.x = 1
			
	if is_attacking or is_hurt:
		velocity.x = move_toward(velocity.x, 0, speed)
	elif is_rolling:
		if sprite.scale.x == -1:
			velocity.x = -speed * 2.5
		elif sprite.scale.x == 1:
			velocity.x = speed * 2.5
	elif direction:
		velocity.x = direction * speed
		anim.play("run")
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		anim.play("idle")
			
	if not is_attacking and not is_rolling and not is_hurt:
		attack()
		roll()
	move_and_slide()
	
func attack():
	if Input.is_action_pressed("attack"):
		is_attacking = true
		is_rolling = false
		anim.play("attack")

func roll():
	if Input.is_action_pressed("roll") and roll_cooldowned:
		is_rolling = true
		is_attacking = false
		anim.play("roll")
		roll_cooldowned = false
		await get_tree().create_timer(1).timeout
		roll_cooldowned = true
		
func take_damage(damage):
	if not is_dead:
		$AnimatedSprite2D/AttackArea2D/CollisionShape2D.set_deferred("disabled", true)
		$HitSound.stop()
		$MissSound.stop()
		is_attacking = false
		is_rolling = false
		health -= damage
		is_hurt = true
		if health <= 0:
			is_dead = true
			anim.play("dead")
			$DeadSound.play()
			#$CollisionShape2D.set_deferred("disabled", true)
			await anim.animation_finished
		else:
			anim.play("hurt")


func _on_attack_area_2d_body_entered(body):
	body.take_damage(attack_power)
	$MissSound.stop()
	$HitSound.play()


func _on_animation_player_animation_finished(anim_name):
	if not is_dead:
		if anim_name == "hurt":
			is_hurt = false
			anim.play("idle")
		elif anim_name == "attack":
			is_attacking = false
			anim.play("idle")
		elif anim_name == "roll":
			is_rolling = false
			anim.play("idle")
