extends Control

const ADDRESS = "127.0.0.1"
const PORT = 9999

@onready var texture_rect = $AvatarCard/TextureRect
@onready var label = $AvatarCard/Label


func _ready():
	var packet = PacketPeerUDP.new()
	packet.connect_to_host(ADDRESS, PORT)
	request_authentication(packet)


func request_authentication(packet):
	# The value of 'get_authentication_token' should be set to true just so that the server understands the request
	var request = {'get_authentication_token': true, "user": AuthenticationCredentials.user, "token": AuthenticationCredentials.session_token}
	packet.put_var(JSON.stringify(request))
	#print(JSON.stringify(request))

	while packet.wait() == OK:
		var data = JSON.parse_string(packet.get_var())
		print("Get auth client",data)
		if data == AuthenticationCredentials.session_token:
			request_avatar(packet)
			break


func request_avatar(packet):
	# The value of 'get_avatar' should be set to true just so that the server understands the request
	var request = {'get_avatar': true, 'token': AuthenticationCredentials.session_token, "user": AuthenticationCredentials.user}
	packet.put_var(JSON.stringify(request))
	#print(JSON.stringify(request))
	while packet.wait() == OK:
		var data = JSON.parse_string(packet.get_var())
		#print(data)
		# Check if there's "avatar" in data 
		if "avatar" in data:
			# set the avatar in data into the texture variable
			var texture = load(data['avatar'])
			# Set the texture into the texture rect.
			texture_rect.texture = texture
			# Set the name in data into the label.text
			label.text = data['name']
			break
