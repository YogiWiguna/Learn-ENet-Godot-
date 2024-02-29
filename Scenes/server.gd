extends Node

const PORT = 9999

# Export the user database
@export var database_file_path = "res://Database/UserDatabase.json"

var database = {}
var logged_users = {}

# This creates a new instance of the UDPServer class that will allow us to listen to incoming connections
var server = UDPServer.new()


func _ready():
	# This will start the server and make listen to incoming connections
	server.listen(PORT)
	load_database(database_file_path)


func _process(delta):
	#  to check for any incoming messages. This method will not block the game loop
	server.poll()
	
	# to check whether a client sent a message. If it returns true, 
	if server.is_connection_available():
		# call the take_connection(), this method to obtain a PacketPeerUDP instance that we can use to read the incoming message
		# PacketPeerUDP is used on the client side (AvaterScreen.tscn and LoginScreen.tscn)
		var peer = server.take_connection()
		
		# Get the message (data) base from the peer (the user who login)
		var message = JSON.parse_string(peer.get_var())
		print("Server ", message)
		# If there is authenticate_credentials inside the message dictionary connect it into the authenticate_player function
		if "authenticate_credentials" in message:
			authenticate_player(peer, message)
		# If there is get_authentication_token inside the message dictionary connect it into the get_authentication_token function 
		elif "get_authentication_token" in message:
			get_authentication_token(peer, message)
		# IF there is get_avatar inside the message dictionary connect it into the get_avatar function
		elif "get_avatar" in message:
			get_avatar(peer, message)


func load_database(path_to_database_file):
	# Load the data base 
	var file = FileAccess.open(path_to_database_file, FileAccess.READ)
	# Get the file as the text 
	var file_content = file.get_as_text()
	
	# Set the value of file content into the database variable and also deserialize the file_content
	database = JSON.parse_string(file_content)
	print(database.keys())
	#print(database["user1"]["password"])
	#file.close()


func authenticate_player(peer, message):
	# get the key and value of the authenticate_credentials in message just sent from the user
	var credentials = message["authenticate_credentials"]
	# Check if there's key "user" in crendentials and key "password" in credentials
	if "user" in credentials and "password" in credentials:
		# Set the value of user in credentials into the user variable
		var user = credentials['user']
		# Set the value of password in credentials into the password variable
		var password = credentials['password']
		# Check if there's user in the database.keys, the user is from the user variable above
		# database.keys : ["user1", "user2"]
		if user in database.keys():
			# Check if password in the user database is match with the user's input 
			if database[user]['password'] == password:
				# If match , set the token random
				var token = randi()
				# Set the dictionary for token and user 
				var response = {'token': token, 'user': user}
				# Set the user with their token, so we can see who login the game
				logged_users[user] = token
				print(logged_users)
				# Set the response to the peer. So the data will be open on the login
				peer.put_var(JSON.stringify(response))
			else:
				# If the password does not match, send an empty string to the client to indicate that the authentication failed
				peer.put_var("")

#  to allow the player’s client to make a request to the server for their authentication token.
func get_authentication_token(peer, message):
	# Set the message into the credentials variable 
	var credentials = message
	# { "get_authentication_token": true, "token": 1035995740, "user": "user1" } in credentials
	#print("Get Auth Token: ",credentials)
	# Check if there's "user" in credentials
	if "user" in credentials:
		# Check if token in credentials is the same with token int logged_users
		if credentials['token'] == logged_users[credentials['user']]:
			# If match, set the token from logged user into the token variable
			var token = logged_users[credentials['user']]
			#var response = {'token': token, 'user': credentials['user']}
			# Set the data of token and put it to the peer connection, will be open in avatar_screen.tscn
			peer.put_var(JSON.stringify(token))


func get_avatar(peer, message):
	# Set the message into the dicionary variable
	var dictionary = message
	# Check if there's user in dictionary
	if "user" in dictionary:
		# Set the value of the "user" into the user variable
		var user = dictionary['user']
		# Check if the token in dictionary is same with the logged_user
		if dictionary['token'] == logged_users[user]:
			# Set avater from database (path) into the avatar variable
			var avatar = database[dictionary['user']]['avatar']
			# Set the nickname from database (path) into the nick_name variable
			var nick_name = database[dictionary['user']]['name']
			# Set the response with the dictionary of avatar and name variables 
			var response = {"avatar": avatar, "name": nick_name}
			# Set the data of response to the peer connection, will be open in the avatar_screen.tscn
			peer.put_var(JSON.stringify(response))
