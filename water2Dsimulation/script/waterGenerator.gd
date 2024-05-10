extends Node2D
var objects: Array[Array] = []

@onready var cir_shape := CircleShape2D.new()
@export var tex: Texture2D
@export var spawnRad: float
var texSize: float = 48
@onready var attrForce: float = get_parent().attrForce
@onready var player = %"PlayerController"

var is_attracting = false

func _ready() -> void:
	for i in range(40):
		create_object(global_position + Vector2(randf()-0.5, randf()-0.5).normalized()*spawnRad*randf())
	cir_shape.radius = 4
	cir_shape.custom_solver_bias = 0.2

func create_object(pos: Vector2):
	var ps := PhysicsServer2D
	var object = ps.body_create()
	ps.body_set_space(object, get_world_2d().space)
	ps.body_add_shape(object, cir_shape)
	ps.body_set_param(object, ps.BODY_PARAM_FRICTION, 0.1)
	ps.body_set_param(object, ps.BODY_PARAM_MASS, 0.1)
	ps.body_set_mode(object, ps.BODY_MODE_RIGID_LINEAR)
	var trans := Transform2D(0, pos)
	ps.body_set_state(object, ps.BODY_STATE_TRANSFORM, trans)

	var rs := RenderingServer
	var img := rs.canvas_item_create()
	rs.canvas_item_set_parent(img, get_canvas_item())
	rs.canvas_item_add_texture_rect(img, Rect2(texSize/-2, texSize/-2, texSize, texSize), tex)
	rs.canvas_item_set_transform(img, trans)

	objects.append([object, img])

func _physics_process(delta):
	if Input.is_action_just_pressed("attract"):
		is_attracting = not is_attracting
		
	var index: int = 0
	for pair in objects:
		var object: RID = pair[0]
		var img: RID = pair[1]
		var trans: Transform2D = PhysicsServer2D.body_get_state(object, PhysicsServer2D.BODY_STATE_TRANSFORM)
		trans.origin -= global_position
		if trans.origin.y > 648 - global_position.y:
			objects.remove_at(index)
			PhysicsServer2D.free_rid(object)
			RenderingServer.free_rid(img)
		else:
			RenderingServer.canvas_item_set_transform(img, trans)
			if is_attracting and (player.global_position - global_position).distance_to(trans.origin) < 260 * %"PlayerController".scale.x:
				PhysicsServer2D.body_set_constant_force(object, ((player.global_position - global_position) - trans.origin).normalized()*attrForce)
			else:
				PhysicsServer2D.body_set_constant_force(object, Vector2.ZERO)
		index += 1

func _exit_tree():
	for pair in objects:
		var object: RID = pair[0]
		var img: RID = pair[1]
		PhysicsServer2D.free_rid(object)
		RenderingServer.free_rid(img)

func _process(delta: float) -> void:
	attrForce = get_parent().attrForce
