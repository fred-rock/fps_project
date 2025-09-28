class_name EnemyMovementState extends State

var ENEMY : Enemy
var ANIMATION : AnimationPlayer

func _ready() -> void:
	await owner.ready
	ENEMY = owner as Enemy
	ANIMATION = ENEMY.ANIMATIONPLAYER

func _process(delta: float) -> void:
	pass
