class_name Player
extends CharacterBody2D

@export var speed : float = 100
@onready var animation_tree: AnimationTree = $AnimationTree

var input : Vector2
var raw_input : Vector2
var playback : AnimationNodeStateMachinePlayback
const DIAGONAL_RELEASE_GRACE := 0.1
const CARDINAL_CONFIRM_TIME := 0.025
const DIRECTION_EPSILON := 0.01
const DIAGONAL_RELEASE_SETTLE_TIME := 0.04

func _ready():
	animation_tree.active = true
	playback = animation_tree["parameters/playback"]
	playback.start("parado")

func _physics_process(delta: float) -> void:
	raw_input = Input.get_vector("left", "right", "up", "down")
	input = _resolve_input(raw_input, delta)
	velocity = input * speed
	move_and_slide()
	update_animation_parameters(delta)
	select_animation()

func select_animation():
	if input == Vector2.ZERO:
		if playback.get_current_node() != "parado":
			playback.travel("parado")
	else:
		if playback.get_current_node() != "caminar":
			playback.travel("caminar")

var last_direction : Vector2 = Vector2.DOWN
var time_since_last_diagonal := INF
var last_diagonal_direction := Vector2.DOWN
var cardinal_transition_time := 0.0
var diagonal_release_settle_timer := 0.0
var pending_cardinal_input := Vector2.ZERO
var previous_raw_input := Vector2.ZERO

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
				# Filter out transient 1-frame cardinal directions when releasing diagonal input.
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

func _is_diagonal(direction: Vector2) -> bool:
	return abs(direction.x) > DIRECTION_EPSILON and abs(direction.y) > DIRECTION_EPSILON

func _resolve_input(current_raw_input: Vector2, delta: float) -> Vector2:
	var resolved_input := current_raw_input
	var was_diagonal := _is_diagonal(previous_raw_input)
	var is_cardinal_now := current_raw_input != Vector2.ZERO and not _is_diagonal(current_raw_input)
	var released_movement := (
		Input.is_action_just_released("left")
		or Input.is_action_just_released("right")
		or Input.is_action_just_released("up")
		or Input.is_action_just_released("down")
	)

	# If a diagonal changes to cardinal because one key was released, hold briefly
	# to avoid accidental cardinal drift while the player finishes releasing keys.
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
