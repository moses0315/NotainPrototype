extends CharacterBody2D

@onready var anim = $AnimationPlayer
@onready var sprite = $AnimatedSprite2D
@onready var healthbar = $Healthbar

@export var speed: int

@export var max_health: int
var health
@export var attack_power: int

var is_attacking = false
var is_hurt = false
var is_dead = false

var attack_ready
var player = null



func _ready():
	$AnimatedSprite2D/AttackArea2D/CollisionShape2D.disabled = true
	health = max_health
	healthbar.max_value = health
	
func _physics_process(delta):
	#Basic Enemy Process-------------------------
	healthbar.value = health
	if is_dead:
		return
		
	if not is_hurt and not is_attacking:
		if player == null:
			velocity.x = move_toward(velocity.x, 0, speed)
			anim.play("idle")
		elif attack_ready:
			velocity.x = move_toward(velocity.x, 0, speed)
			var direction = (player.position-position).normalized()
			if direction.x < 0:
				sprite.scale.x = -1
			elif direction.x >= 0:
				sprite.scale.x = 1
			attack()		
		else:
			var direction = (player.position-position).normalized()
			if direction.x < 0:
				sprite.scale.x = -1
			elif direction.x >=0:
				sprite.scale.x = 1
			velocity.x = direction.x * speed
			anim.play("run")
	elif is_hurt or is_attacking or attack_ready:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()

func attack():
	is_attacking = true
	anim.play("attack")

func take_damage(damage):
	if not is_dead:
		$AnimatedSprite2D/AttackArea2D/CollisionShape2D.set_deferred("disabled", true)
		$HitSound.stop()
		$MissSound.stop()
		is_attacking = false
		health -= damage
		is_hurt = true
		if health <= 0:
			is_dead = true
			anim.play("dead")
			$DeadSound.play()
			#healthbar.visible = false
			z_index = -1
			$CollisionShape2D.set_deferred("disabled", true)
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

func _on_player_dettection_area_2d_body_entered(body):
	player = body

func _on_player_dettection_area_2d_body_exited(body):
	#player = null
	pass

func _on_attack_dettection_area_2d_body_entered(body):
	attack_ready = true

func _on_attack_dettection_area_2d_body_exited(body):
	attack_ready = false

