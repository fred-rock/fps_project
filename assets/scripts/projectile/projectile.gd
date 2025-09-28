class_name Projectile extends RigidBody3D

@export var speed: float = 20.0
@export var damage: int = 10
@export var lifetime: float = 5.0
@export var projectile_gravity_scale: float = 0.0  # Set to 0 for straight projectiles, higher for arced

var direction: Vector3
var shooter: Node  # Reference to who shot this projectile

func _ready() -> void:
	# Set gravity scale for projectile physics
	gravity_scale = projectile_gravity_scale
	
	# Set up collision detection
	body_entered.connect(_on_body_entered)
	
	# Auto-destroy after lifetime expires
	var timer = Timer.new()
	timer.wait_time = lifetime
	timer.timeout.connect(_on_lifetime_expired)
	timer.one_shot = true
	add_child(timer)
	timer.start()

func launch(launch_direction: Vector3, launch_speed: float = -1) -> void:
	direction = launch_direction.normalized()
	var final_speed = launch_speed if launch_speed > 0 else speed
	
	# Set initial velocity
	linear_velocity = direction * final_speed
	
	# Optional: Orient the projectile to face movement direction
	look_at(global_position + direction, Vector3.UP)

func _on_body_entered(body: Node) -> void:
	# Don't collide with the shooter
	if body == shooter:
		return
	
	# Handle damage if the target has a health system
	if body.has_method("take_damage"):
		body.take_damage(damage)
	
	# Create impact effect (optional)
	_create_impact_effect()
	
	# Destroy the projectile
	queue_free()

func _create_impact_effect() -> void:
	# Add particle effects, sound, etc. here
	print("Projectile hit at: ", global_position)

func _on_lifetime_expired() -> void:
	queue_free()

# Optional: Add homing behavior
func set_homing_target(target: Node3D, homing_strength: float = 2.0) -> void:
	var tween = create_tween()
	tween.set_loops()
	tween.tween_method(_update_homing_direction, 0.0, 1.0, 0.1)
	tween.tween_callback(_update_homing_direction.bind(target, homing_strength))

func _update_homing_direction(target: Node3D, strength: float, _t: float) -> void:
	if not is_instance_valid(target):
		return
	
	var target_direction = (target.global_position - global_position).normalized()
	direction = direction.lerp(target_direction, strength * get_physics_process_delta_time())
	linear_velocity = direction * speed
