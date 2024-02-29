extends Control

@onready var server_button = $ServerButton
@onready var client_button = $ClientButton

# Called when the node enters the scene tree for the first time.
func _ready():
	server_button.grab_focus()

func _on_server_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/server.tscn")


func _on_client_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/login_screen.tscn")
