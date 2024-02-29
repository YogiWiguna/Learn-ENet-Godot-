extends Control

# make local addres and port
const ADDRESS = "127.0.0.1"
const PORT = 9999

# export the avatar scene 
@export_file("*.tscn") var avatar_screen_scene

@onready var error_label = $VBoxContainer/ErrorLabel
@onready var username = $VBoxContainer/Username
@onready var password = $VBoxContainer/Password
@onready var login_button = $VBoxContainer/LoginButton


func _ready():
	error_label.text = "Insert username and password"
	username.grab_focus()

func _on_username_text_submitted(new_text):
	# if the password text is not null go to function send_credentials
	if not password.text == null :
		send_credentials()
	else:
		error_label.text = "Insert password"
		password.grab_focus()

func _on_password_text_submitted(new_text):
	# if the username text is not null go to function send_credentials
	if not username.text == "":
		send_credentials()
	else:
		error_label.text = "Insert username"
		username.grab_focus()

func _on_login_button_pressed():
	if username.text == "":
		error_label.text = "Insert username"
		username.grab_focus()
	elif password.text == "":
		error_label.text = "Insert password"
		password.grab_focus()
	else:
		send_credentials()


func send_credentials():
	# make message for players credentials
	var message = {'authenticate_credentials': 
		{'user': username.text, 'password': password.text}}
	
	# instantiate a new PacketPeerUDP
	var packet = PacketPeerUDP.new()
	# Connect the packter into the host with default address and port
	packet.connect_to_host(ADDRESS, PORT)
	# Serialize (encrypted) the message dictionary into JSON object with JSON.stringify
	packet.put_var(JSON.stringify(message))
	
	# waits packets to arrive at the bound address. It will return an OK error if it receives a packets
	while packet.wait() == OK:
		# deserialize the packets and will return the with the token and player crendetials
		var response = JSON.parse_string(packet.get_var())
		print("Login", response)
		# Check it there's token string in response dictionary 
		if "token" in response:
			# Get the value of the token in response dictionary into the GLobal variable session_token
			AuthenticationCredentials.session_token = response['token']
			# GEt the value of the user in message dictionary into the Global variable user
			AuthenticationCredentials.user = message['authenticate_credentials']['user']
			# Set the error text into the logged!
			error_label.text = "logged!!"
			# Change the scene if succes 
			get_tree().change_scene_to_file(avatar_screen_scene)
			break
		
		# If there's no token in response go to else
		else:
			# Set the label text
			error_label.text = "login failed, check your credentials"
			break









