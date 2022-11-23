extends KinematicBody2D

enum {
	IDLE,
	WANDER,
	CHASE
}

const VELOCITY = 70
const ACCELERATION = 200
const KNOCKBACK_VELOCITY = 200
const FRICTION = KNOCKBACK_VELOCITY * 1.5
const ENEMY_DEATH_EFFECT = preload("res://Effects/EnemyDeathEffect.tscn")
onready var stats = $Stats
onready var detection_zone = $PlayerDetectionZone
onready var sprite = $AnimatedSprite
onready var soft_collision = $SoftCollision
onready var wander_ctrl = $WanderController
var knockback = Vector2.ZERO
var velocity = Vector2.ZERO
var state = IDLE

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
		WANDER:
			seek_player()
			if global_position.distance_to(wander_ctrl.wander_position) <= VELOCITY * delta:
				state = IDLE
			else:
				var direction = global_position.direction_to(wander_ctrl.wander_position).normalized()
				velocity = velocity.move_toward(direction * VELOCITY, ACCELERATION * delta)
		CHASE:
			if detection_zone.can_see_player():
				var player = detection_zone.player
				var direction = (player.global_position - self.global_position).normalized()
				velocity = velocity.move_toward(direction * VELOCITY, ACCELERATION * delta)
			else:
				state = WANDER
	
	var push_vec = soft_collision.get_push_vector()
	if push_vec != Vector2.ZERO:
		velocity += push_vec * delta * ACCELERATION
	sprite.flip_h = velocity.x < 0
	velocity = move_and_slide(velocity)

func seek_player():
	if detection_zone.can_see_player():
		state = CHASE

func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	knockback = area.direction * KNOCKBACK_VELOCITY

func _on_Stats_no_health():
	var death_effect = ENEMY_DEATH_EFFECT.instance()
	death_effect.position = self.position
	get_parent().add_child(death_effect)
	queue_free()

func _on_WanderController_wander_changed():
	if state == IDLE:
		state = WANDER
