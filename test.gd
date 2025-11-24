extends Node2D

@onready var player = $Player

@export var fade_out_max_distance: float = 80.0
@export var player_radius: float = 40.0

var wind_time: float = 0.0
var grass_particles_nodes: Array[GrassParticlesNode] = []

func _ready():
	
	call_deferred("_find_grass_particles_nodes")
	call_deferred("_update_all_grass_particles_nodes")

func _find_grass_particles_nodes():
	grass_particles_nodes.clear()
	_find_grass_particles_nodes_recursive(self)

func _find_grass_particles_nodes_recursive(node: Node):
	if node is GrassParticlesNode:
		grass_particles_nodes.append(node)
	
	for child in node.get_children():
		_find_grass_particles_nodes_recursive(child)

func _process(delta):
	wind_time += delta * 1.0
	
	if player:
		for grass_node in grass_particles_nodes:
			grass_node.set_player_position(player.global_position)

func _update_fade_out_distance():
	_update_all_grass_particles_nodes()

func _update_all_grass_particles_nodes():
	var player_radius_blend = max(0.0, fade_out_max_distance - player_radius)
	for grass_node in grass_particles_nodes:
		if grass_node:
			grass_node.player_radius = player_radius
			grass_node.player_radius_blend = player_radius_blend

func _set(property: StringName, value) -> bool:
	if property == "fade_out_max_distance":
		fade_out_max_distance = value
		_update_fade_out_distance()
		return true
	elif property == "player_radius":
		player_radius = value
		_update_fade_out_distance()
		return true
	return false
