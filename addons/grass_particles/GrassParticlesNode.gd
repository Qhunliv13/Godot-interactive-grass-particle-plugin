@tool
extends Node2D
class_name GrassParticlesNode

const GRASS_PARTICLES_SCENE = preload("res://addons/grass_particles/GrassParticles.tscn")

@onready var grass_particles: GPUParticles2D = null

var wind_time: float = 0.0

@export_group("Player Settings")
@export var player_position: Vector2 = Vector2.ZERO
@export var player_radius: float = 40.0
@export var player_radius_blend: float = 40.0

@export_group("Wind Settings")
@export var wind_strength: float = 0.25
@export var wind_frequency: float = 0.03
@export var wind_direction: Vector2 = Vector2(1.0, 0.0)

@export_group("Grass Settings")
@export var grass_range: float = 500.0
@export var grass_amount: int = 12100
@export var visibility_range: float = 2000.0

func _ready():
	_instance_grass_particles()

func _update_grid_parameters():
	if grass_particles and grass_particles.process_material and grass_amount > 0:
		var required_grid_size = grass_range * 1.1
		
		var rows = ceil(sqrt(grass_amount))
		
		var spacing = required_grid_size / rows
		
		grass_particles.process_material.set_shader_parameter("rows", rows)
		grass_particles.process_material.set_shader_parameter("spacing", spacing)
		grass_particles.process_material.set_shader_parameter("grass_range", grass_range)

func _instance_grass_particles():
	if grass_particles:
		grass_particles.queue_free()
		grass_particles = null
	
	var instance = GRASS_PARTICLES_SCENE.instantiate()
	var unique_instance = instance.duplicate(true)
	instance.queue_free()
	
	add_child(unique_instance)
	grass_particles = unique_instance
	
	if grass_particles:
		grass_particles.lifetime = 999999.0
		grass_particles.explosiveness = 1.0
		grass_particles.amount = grass_amount
		grass_particles.visibility_rect = Rect2(-visibility_range * 0.5, -visibility_range * 0.5, visibility_range, visibility_range)
		
		if grass_particles.material:
			grass_particles.material = grass_particles.material.duplicate()
		
		if grass_particles.process_material:
			grass_particles.process_material = grass_particles.process_material.duplicate()
			_update_grid_parameters()
		
		grass_particles.restart()
		grass_particles.emitting = true
		
		_update_shader_parameters()

func _process(delta):
	wind_time += delta * 1.0
	_update_shader_parameters()
	if grass_particles and visibility_range > 0:
		grass_particles.visibility_rect = Rect2(-visibility_range * 0.5, -visibility_range * 0.5, visibility_range, visibility_range)

func _update_shader_parameters():
	if grass_particles and grass_particles.material:
		var material = grass_particles.material
		material.set_shader_parameter("player_pos", player_position)
		material.set_shader_parameter("player_radius", player_radius)
		material.set_shader_parameter("player_radius_blend", player_radius_blend)
		material.set_shader_parameter("wind_time", wind_time)
		material.set_shader_parameter("wind_strength", wind_strength)
		material.set_shader_parameter("wind_frequency", wind_frequency)
		material.set_shader_parameter("wind_direction", wind_direction)

func set_player_position(pos: Vector2):
	player_position = pos

func get_grass_particles() -> GPUParticles2D:
	return grass_particles

func _set(property: StringName, value) -> bool:
	if property == "visibility_range":
		visibility_range = value
		if grass_particles and visibility_range > 0:
			grass_particles.visibility_rect = Rect2(-visibility_range * 0.5, -visibility_range * 0.5, visibility_range, visibility_range)
		notify_property_list_changed()
		return true
	elif property == "grass_range":
		grass_range = value
		if grass_particles and grass_particles.process_material:
			_update_grid_parameters()
			grass_particles.restart()
		notify_property_list_changed()
		return true
	elif property == "grass_amount":
		grass_amount = value
		if grass_particles:
			grass_particles.amount = grass_amount
			_update_grid_parameters()
			grass_particles.restart()
		notify_property_list_changed()
		return true
	return false

func _notification(what):
	if what == NOTIFICATION_EXIT_TREE:
		if grass_particles:
			grass_particles.queue_free()
			grass_particles = null
