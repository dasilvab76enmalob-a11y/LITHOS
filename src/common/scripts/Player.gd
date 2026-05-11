class_name Player
extends CharacterBody2D

@export var speed : float = 60.0 
@export var run_speed : float = 150.0 
@onready var animation_tree: AnimationTree = $AnimationTree

# --- CONFIGURACIÓN DE CÁMARAS ---
@onready var camara_proxima: Camera2D = $Camera2D 
@onready var camara_mundo: Camera2D = get_tree().root.find_child("Camara Mundo", true, false)

var modo_mapa : bool = false
var input : Vector2
var raw_input : Vector2
var playback : AnimationNodeStateMachinePlayback

const DIAGONAL_RELEASE_GRACE := 0.1
const CARDINAL_CONFIRM_TIME := 0.025
const DIRECTION_EPSILON := 0.01
const DIAGONAL_RELEASE_SETTLE_TIME := 0.04

# Variables de dirección
var last_direction : Vector2 = Vector2.DOWN
var time_since_last_diagonal := INF
var last_diagonal_direction := Vector2.DOWN
var cardinal_transition_time := 0.0
var diagonal_release_settle_timer := 0.0
var pending_cardinal_input := Vector2.ZERO
var previous_raw_input := Vector2.ZERO

func _ready():
	animation_tree.active = true
	playback = animation_tree["parameters/playback"]
	playback.start("parado")
	
	if camara_proxima: camara_proxima.enabled = true
	if camara_mundo: camara_mundo.enabled = false

func _physics_process(delta: float) -> void:
	raw_input = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	input = _resolve_input(raw_input, delta)
	
	var is_running_input = Input.is_action_pressed("run")
	var current_speed = run_speed if is_running_input else speed
	
	var final_velocity = raw_input
	if final_velocity.length() > 0:
		final_velocity.x = sign(raw_input.x) if abs(raw_input.x) > 0 else 0
		final_velocity.y = sign(raw_input.y) if abs(raw_input.y) > 0 else 0
		final_velocity = final_velocity.normalized()
	
	velocity = final_velocity * current_speed
	move_and_slide()
	global_position = global_position.snapped(Vector2.ONE)
	
	if camara_proxima and camara_proxima.enabled:
		camara_proxima.global_position = global_position
		
	update_animation_parameters(delta)
	select_animation()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
			alternar_camara()

func alternar_camara():
	if camara_proxima == null or camara_mundo == null:
		return
	modo_mapa = !modo_mapa
	camara_proxima.enabled = !modo_mapa
	camara_mundo.enabled = modo_mapa

func select_animation():
	var is_running_input = Input.is_action_pressed("run")
	
	if input == Vector2.ZERO:
		if playback.get_current_node() != "parado":
			playback.travel("parado")
	else:
		if is_running_input:
			if playback.get_current_node() != "correr":
				playback.travel("correr")
		else:
			if playback.get_current_node() != "caminar":
				playback.travel("caminar")

func update_animation_parameters(delta: float):
	if input != Vector2.ZERO:
		var current_direction := input.normalized()
		if _is_diagonal(current_direction):
			last_direction = current_direction
			last_diagonal_direction = current_direction
			time_since_last_diagonal = 0.0
			cardinal_transition_time = 0.0
		else:
			if _is_diagonal(last_direction):
				cardinal_transition_time += delta
				if cardinal_transition_time >= CARDINAL_CONFIRM_TIME:
					last_direction = current_direction
			else:
				last_direction = current_direction
				cardinal_transition_time = 0.0
			time_since_last_diagonal += delta
	else:
		cardinal_transition_time = 0.0
		time_since_last_diagonal += delta
		if time_since_last_diagonal <= DIAGONAL_RELEASE_GRACE:
			last_direction = last_diagonal_direction
	
	animation_tree.set("parameters/parado/blend_position", last_direction)
	animation_tree.set("parameters/caminar/blend_position", last_direction)
	animation_tree.set("parameters/correr/blend_position", last_direction)

func _is_diagonal(direction: Vector2) -> bool:
	return abs(direction.x) > DIRECTION_EPSILON and abs(direction.y) > DIRECTION_EPSILON

func _resolve_input(current_raw_input: Vector2, delta: float) -> Vector2:
	var resolved_input := current_raw_input
	var was_diagonal := _is_diagonal(previous_raw_input)
	var is_cardinal_now := current_raw_input != Vector2.ZERO and not _is_diagonal(current_raw_input)
	var released_movement := (Input.is_action_just_released("ui_left") or Input.is_action_just_released("ui_right") or Input.is_action_just_released("ui_up") or Input.is_action_just_released("ui_down"))

	if diagonal_release_settle_timer <= 0.0 and was_diagonal and is_cardinal_now and released_movement:
		diagonal_release_settle_timer = DIAGONAL_RELEASE_SETTLE_TIME
		pending_cardinal_input = current_raw_input
		resolved_input = Vector2.ZERO
	elif diagonal_release_settle_timer > 0.0:
		diagonal_release_settle_timer -= delta
		if current_raw_input == Vector2.ZERO:
			resolved_input = Vector2.ZERO
			diagonal_release_settle_timer = 0.0
			pending_cardinal_input = Vector2.ZERO
		elif _is_diagonal(current_raw_input):
			resolved_input = current_raw_input
			diagonal_release_settle_timer = 0.0
			pending_cardinal_input = Vector2.ZERO
		elif current_raw_input != pending_cardinal_input:
			resolved_input = current_raw_input
			diagonal_release_settle_timer = 0.0
			pending_cardinal_input = Vector2.ZERO
		elif diagonal_release_settle_timer > 0.0:
			resolved_input = Vector2.ZERO
		else:
			resolved_input = current_raw_input
			pending_cardinal_input = Vector2.ZERO

	previous_raw_input = current_raw_input
	return resolved_input
