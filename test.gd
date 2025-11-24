extends Node2D

@onready var player = $Player

var grass_particles_nodes: Array[GrassParticlesNode] = []

func _ready():
	call_deferred("_find_grass_particles_nodes")

func _find_grass_particles_nodes():
	grass_particles_nodes.clear()
	_find_grass_particles_nodes_recursive(self)

func _find_grass_particles_nodes_recursive(node: Node):
	if node is GrassParticlesNode:
		grass_particles_nodes.append(node)
	
	for child in node.get_children():
		_find_grass_particles_nodes_recursive(child)

func _process(delta):
	if player:
		for grass_node in grass_particles_nodes:
			grass_node.set_player_position(player.global_position)
