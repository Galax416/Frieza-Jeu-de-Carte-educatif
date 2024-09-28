extends Control

var players = []  # Liste des joueurs
var card_scene = preload("res://scenes/card.tscn")

func _ready():
	players = PlayerData.players
	var player_list = $PlayerBoxColor/PlayerContainer
	for player in players:
		print("Joueur:", player.name, " Couleur:", player.color)
		var player_entry = create_player_entry(player)
		player_list.add_child(player_entry)
		var card_instance = card_scene.instantiate()  # Create a card instance
		var card_data = CardData.cards_data["Card1"]  
		card_instance.get_node("Label").text = card_data.name
		card_instance.get_node("ColorRect").color = player.color
		card_instance.get_node("TextureRect").texture = card_data.texture
		card_instance.position = Vector2(100 * player.index+250, 50)  # Example positioning logic
		$CardPos.add_child(card_instance)
		
	# Instancier la liste des joueurs
	$PlayerBoxColor.size=$PlayerBoxColor/PlayerContainer.get_rect().size
	$PlayerBoxColor/Color.size=$PlayerBoxColor/PlayerContainer.get_rect().size

# Créer une entrée pour chaque joueur
func create_player_entry(player):
	var hboxPlayerNameContainer = $PlayerBoxColor/PlayerContainer/PlayerNameContainer
	var hboxPlayerColorContainer = $PlayerBoxColor/PlayerContainer/PlayerColorContainer
	var hboxPlayerScoreContainer = $PlayerBoxColor/PlayerContainer/PlayerScoreContainer
	

	# Afficher le nom du joueur
	var name_label = Label.new()
	name_label.text = player.name
	hboxPlayerNameContainer.add_child(name_label)
	
	# Afficher la couleur du joueur
	var color_rect = ColorRect.new()
	color_rect.color = player.color
	color_rect.custom_minimum_size= Vector2(20, 20)  
	hboxPlayerColorContainer.add_child(color_rect)
	
	# Afficher le score du joueur
	var score_label = Label.new()
	score_label.text = str(player.score)
	hboxPlayerScoreContainer.add_child(score_label)
	
	return 


func _on_return_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")  # Lancer le jeu
