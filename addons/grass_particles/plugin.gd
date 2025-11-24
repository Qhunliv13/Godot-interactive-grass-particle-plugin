@tool
extends EditorPlugin

const GrassParticlesNode = preload("res://addons/grass_particles/GrassParticlesNode.gd")
const GrassParticlesIcon = preload("res://addons/grass_particles/icon.png")

func _enter_tree():
	add_custom_type("GrassParticlesNode", "Node2D", GrassParticlesNode, GrassParticlesIcon)

func _exit_tree():
	remove_custom_type("GrassParticlesNode")

