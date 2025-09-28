extends PanelContainer

@onready var property_container = %VBoxContainer

var property
var frames_per_second : String

func _ready() -> void:
	# Set global reference to self in global singleton
	Global.debug = self
	
	# Hide panel on load
	visible = false
		
func _process(delta: float) -> void:
	if visible:
		# Use delta time to get approx. frames per second and round to two decimal places. !Disable VSync if fps is stuck at 60!
		frames_per_second = "%.2f" % (1.0/delta) # Gets frames per second every frame
		# frames_per_second = Engine.get_frames_per_second() # Gets frames per second every second
		#property.text = property.name + ": " + frames_per_second
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug"):
		visible = !visible
		
func add_property(title: String, value, order):
	var target
	target = property_container.find_child(title, true, false) # Tries to find a label node with same name
	if !target:
		target = Label.new()
		property_container.add_child(target)
		target.name = title
		target.text = target.name + ": " + str(value)
	elif visible:
		target.text = title + ": " + str(value)
		property_container.move_child(target, order)

func add_debug_property(title : String, value):
	property = Label.new()
