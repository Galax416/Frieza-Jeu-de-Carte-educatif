extends Node

var players = []  # Liste des joueurs
var card_scene = preload("res://card/card.tscn")

var step = 3 #0 = on place nos cartes , 1 = negociation step , 2 = deplacement de carte, 3 reponse into next turn
var turn = 0
var random_Card = randi_range(0, 15)

#@onready var cards_holder: HBoxContainer = $CardsHolder

func _ready():
	players = PlayerData.players
	var player_list = $PlayerBoxColor/PlayerContainer
	var cards_holder: HBoxContainer = $CanvasLayer/Field/CardsHolder
	var cards_field: Field = $CanvasLayer/Field
	for player in players:
		print("Joueur:", player.name, " Couleur:", player.color)
		var player_entry = create_player_entry(player)
		player_list.add_child(player_entry)
	
	# Instancier la liste des joueurs
	$PlayerBoxColor.size=$PlayerBoxColor/PlayerContainer.get_rect().size
	$PlayerBoxColor/Color.size=$PlayerBoxColor/PlayerContainer.get_rect().size
	
	_on_validate_card_pos_pressed()

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
	#var color_rect = ColorRect.new()
	#color_rect.color = player.color
	#color_rect.custom_minimum_size= Vector2(20, 20)  
	#hboxPlayerColorContainer.add_child(color_rect)
	
	var texture_rect = TextureRect.new()
	texture_rect.texture = player.background
	texture_rect.custom_minimum_size= Vector2(22, 24)  
	texture_rect.stretch_mode = TextureRect.STRETCH_TILE
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	hboxPlayerColorContainer.add_child(texture_rect)
	
	# Afficher le score du joueur
	var score_label = Label.new()
	score_label.text = str(player.score)
	hboxPlayerScoreContainer.add_child(score_label)
	
	return 


func _on_return_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://menu.tscn")  # Lancer le jeu

func clear( node):
	for statNode in node.get_children():
		node.remove_child(statNode)
		statNode.queue_free()
		pass
	pass
	
func _on_validate_card_pos_pressed() -> void:
	step=(step+1)%4
	players = PlayerData.players
	if step==0:
		$Label.text = "Lets Start : placez vos cartes"
		var cards_holder: HBoxContainer = $CanvasLayer/Field/CardsHolder
		var cards_field: Field = $CanvasLayer/Field
		random_Card = randi_range(0, 15)
		for card in cards_holder.get_children():
			card.queue_free()
		for player in players:
			# Création des cartes pour chaque joueurs
			var card_instance = card_scene.instantiate()  # Create a card instance
			var card_data = CardData.cards_data[str(random_Card)]  
			card_instance.get_node("Label").text = card_data.name
			card_instance.get_node("ColorRect").color = player.color
			card_instance.get_node("TextureRect").texture = card_data.texture
			card_instance.get_node("Background").texture = player.background
			adjust_label_font_size(card_instance.get_node("Label"))
			card_instance.position = Vector2(100 * player.index+5, 50)  # Example positioning logic
			card_instance.set_home_fied(cards_field)
			cards_holder.add_child(card_instance)
	elif step == 1:
		$Label.text = "Lets Debate !  :  Expliquez votre choix"
	elif step == 2 : 
		$Label.text = "A vos changement"
	else :
		$Label.text = "Réponse :" + str(CardData.cards_data[str(random_Card)].date)

func adjust_label_font_size(label: Label) -> void:
	label.add_theme_color_override("font_color", Color(1, 0, 0))
	var font = label.get_theme_font("font")
	var max_font_size = 18  # Starting with the current font size
	var target_width = label.get_rect().size.x  # The width of the Label itself

	while label.get_minimum_size().x > target_width and max_font_size > 5:
		max_font_size -= 1
		font.size = max_font_size
		label.add_theme_font("font", font)
