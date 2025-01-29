extends Node

@onready var audio_player_template = $AudioStreamPlayer2D  # Template AudioStreamPlayer node to copy
var active_players = {}  # Keep track of active players for each note
var sound_library : SoundLibrary  # Reference to the SoundLibrary class

# Declare an empty dictionary to hold references to the white key press sprites
var key_presses = {}

# Function to adjust the volume based on MIDI velocity
func adjust_volume_based_on_velocity(velocity: int) -> float:
	# Map velocity from 0-127 to a range of 0.1 (softer) to 1.0 (louder)
	return clamp((velocity / 127.0) * 0.9 + 0.1, 0.1, 1.0)

func _ready():
	OS.open_midi_inputs()
	print(OS.get_connected_midi_inputs())
	
	# Instantiate and load sounds from the SoundLibrary
	sound_library = SoundLibrary.new()
	sound_library.load_sounds()

	# Dynamically store references to all white key press sprites (from pitch 36 to pitch 84)
	for i in range(36, 85):  # MIDI pitch 36 (C2) to 84 (C7)
		var key_name = "KeyPress/WhiteKeyPress" + str(i)  # Construct the name of the sprite (e.g., "WhiteKeyPress36")
		key_presses[i] = get_node(key_name)  # Store the reference to the key in the dictionary

	# Hide all white key presses at the start
	for key in key_presses.values():
		key.visible = false

# Handle MIDI input events
func _input(event):
	if event is InputEventMIDI:
		if event.channel == 0 and sound_library.get_sound(event.pitch) != null:
			if event.velocity > 0:  # Note pressed
				print("Playing sound for MIDI pitch:", event.pitch)
				
				# Toggle visibility for the corresponding white key sprite
				toggle_white_key_visibility(event.pitch, true)
				
				# Create a new AudioStreamPlayer2D for this note if not already created
				if event.pitch not in active_players:
					var new_player = audio_player_template.duplicate()  # Create a copy of the template
					new_player.name = "AudioPlayer_" + str(event.pitch)  # Name it based on pitch
					add_child(new_player)  # Add to the current node
					active_players[event.pitch] = new_player  # Track it
				
				# Set the sound for this note and adjust the volume based on velocity
				var volume = adjust_volume_based_on_velocity(event.velocity)
				active_players[event.pitch].stream = sound_library.get_sound(event.pitch)
				active_players[event.pitch].volume_db = volume * 10.0  # Adjusting volume (in dB)
				active_players[event.pitch].play()
				
			else:  # Note released
				if event.pitch in active_players:
					active_players[event.pitch].stop()  # Stop the corresponding sound
					active_players.erase(event.pitch)  # Remove the player from the dictionary
					
				# Toggle visibility off for the corresponding white key sprite
				toggle_white_key_visibility(event.pitch, false)

# Function to toggle visibility for the corresponding white key sprite based on pitch
func toggle_white_key_visibility(pitch: int, visible: bool):
	if key_presses.has(pitch):
		key_presses[pitch].visible = visible
