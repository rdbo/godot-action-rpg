extends KinematicBody2D

enum {
	MOVE,
	ROLL,
	ATTACK
}

# 'onready' variables will only be created after Player is ready
onready var animation_player = $AnimationPlayer
onready var animation_tree = $AnimationTree
onready var animation_state = animation_tree.get("parameters/playback")
onready var sword_hitbox = $HitboxPivot/SwordHitbox
onready var stats = PlayerStats
onready var hurtbox = $Hurtbox
onready var blink_player = $BlinkAnimationPlayer
var hurt_sound = preload("res://Player/PlayerHurt.tscn")

var state = MOVE
const MAX_VELOCITY = 80
const ACCELERATION = 500
const FRICTION = ACCELERATION
const ROLL_VELOCITY = MAX_VELOCITY * 1.5
var velocity = Vector2.ZERO

func _ready():
	animation_tree.active = true
	sword_hitbox.direction = animation_tree.get("parameters/Idle/blend_position")
	stats.connect("no_health", self, "queue_free")

func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
		ROLL:
			roll_state(delta)
		ATTACK:
			attack_state(delta)

func move():
	velocity = move_and_slide(velocity)

func move_state(delta):
	var input_vec = Vector2.ZERO
	input_vec.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vec.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	# Normalize input vector to prevent faster diagonal speed
	input_vec = input_vec.normalized()
	
	# Calculate acceleration based velocity
	if input_vec != Vector2.ZERO:
		# Choose proper animation (manual)
		# if input_vec.x > 0:
		#	animation_player.play("RunRight")
		#else:
		#	animation_player.play("RunLeft")
		
		# Choose proper animation
		# The animation will only update when the input
		# is pressed so that it remembers the last state
		# when transitioning. This is achieved by 
		# setting the Blend Position parameter
		animation_tree.set("parameters/Idle/blend_position", input_vec)
		animation_tree.set("parameters/Run/blend_position", input_vec)
		animation_tree.set("parameters/Attack/blend_position", input_vec)
		animation_tree.set("parameters/Roll/blend_position", input_vec)
		sword_hitbox.direction = input_vec
		animation_state.travel("Run")
		
		# Move towards the MAX_VELOCITY from the strength of the input, at a rate of ACCELERATION * delta
		velocity = velocity.move_toward(input_vec * MAX_VELOCITY, ACCELERATION * delta)
	else:
		# Set animation state to Idle
		animation_state.travel("Idle")
		# Calculate friction to stop player
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	# move_and_collide(velocity * delta)
	move()
	
	if Input.is_action_just_pressed("roll"):
		state = ROLL
	
	elif Input.is_action_just_pressed("attack"):
		state = ATTACK

func attack_state(_delta):
	velocity = Vector2.ZERO # Prevent sliding after attack
	animation_state.travel("Attack")

func attack_over():
	state = MOVE

func roll_state(_delta):
	velocity = animation_tree.get("parameters/Roll/blend_position") * ROLL_VELOCITY
	move()
	animation_state.travel("Roll")

func roll_over():
	velocity = Vector2.ZERO
	state = MOVE


func _on_Hurtbox_area_entered(_area):
	if not hurtbox.invincible:
		stats.health -= 1
		hurtbox.start_invincibility()
		get_tree().current_scene.add_child(hurt_sound.instance())


func _on_Hurtbox_invincibility_started():
	blink_player.play("Start")

func _on_Hurtbox_invincibility_ended():
	blink_player.play("Stop")
