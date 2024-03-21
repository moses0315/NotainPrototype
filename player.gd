extends CharacterBody2D

@onready var healthbar = $Healthbar
@onready var anim = $AnimationPlayer
@onready var sprite = $AnimatedSprite2D

const speed = 250

var health = 200
var attack_power = 10
var is_attacking = false
var is_rolling = false
var is_hurt = false
var is_dead = false


func _ready():
	$AnimatedSprite2D/AttackArea2D/CollisionShape2D.disabled = true
	healthbar.max_value = health
	
func _physics_process(delta):
	healthbar.value = health
	if is_dead:
		return

	var direction = Input.get_axis("left", "right")
	
	if not is_attacking:
		if direction == -1:
			sprite.scale.x = -1
		elif direction == 1:
			sprite.scale.x = 1
			
	if is_attacking or is_hurt:
		velocity.x = move_toward(velocity.x, 0, speed)
	elif is_rolling:
		velocity.x = direction * speed * 2
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
	if Input.is_action_pressed("roll"):
		is_rolling = true
		is_attacking = false
		anim.play("roll")
		
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
		elif anim_name == "roll":
			is_rolling = false
			anim.play("idle")
