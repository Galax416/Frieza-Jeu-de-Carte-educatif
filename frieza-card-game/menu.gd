extends Control

var players = []
var max_players = 5
var player_colors = [Color(1, 0, 0), Color(0, 1, 0), Color(0, 0, 1), Color(1, 1, 0), Color(1, 0, 1)]
var player_background = [preload("res://asset/motif1.jpg"),preload("res://asset/motif2.jpg"),preload("res://asset/motif3.jpg"),preload("res://asset/motif4.jpeg"),preload("res://asset/motif5.jpg")]
func _ready():
	_on_player_count_changed(2)
	
func _on_player_count_changed(value):
	var container = $VBoxContainer/NamesContainer
	clear_children(container)  # Supprimer les anciens champs
	for i in range(value):
		var name_field = LineEdit.new()
		name_field.placeholder_text = "Nom du joueur %d" % (i + 1)
		container.add_child(name_field)

func _on_start_button_pressed():
	PlayerData.players = []

	var player_count = $VBoxContainer/SpinBox.value
	var container = $VBoxContainer/NamesContainer
	for i in range(player_count):
		var player_data = {}
		player_data.index = i
		player_data.name = container.get_child(i).text  # Récupérer le nom du joueur
		player_data.color = player_colors[i]  # Assigner une couleur depuis la liste		
		player_data.score = 0  # Score initial
		player_data.background = player_background[i]
		PlayerData.players.append(player_data)
	if PlayerData.players.size() > 0:
		get_tree().change_scene_to_file("res://game.tscn") 

func clear_children(container):
	for child in container.get_children():
		child.queue_free()
