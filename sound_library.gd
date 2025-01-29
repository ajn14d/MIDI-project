# sound_library.gd
extends Node

class_name SoundLibrary  # This makes it a reusable class

var fp1 = "res://keys/"
var fp2 = ".mp3"
var counter = 36  # Starting MIDI pitch
var sound_library = {}

# Function to load all sounds
func load_sounds():
	for j in range(2, 6):  # Octaves 2 to 5
		for i in ["C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab", "A", "Bb", "B"]:  # Notes in an octave
			var sound_path = fp1 + i + str(j) + fp2
			sound_library[counter] = load(sound_path)
			counter += 1  # Increment the pitch number
	sound_library[counter] = load(fp1 + "C6" + fp2)  # Example for C6

# Function to get the sound for a specific pitch
func get_sound(pitch: int) -> AudioStream:
	return sound_library.get(pitch, null)  # Return the sound if it exists, otherwise null
