extends Node

var players = []  # Liste des joueurs
var card_scene = preload("res://card/card.tscn")
var card_Response = preload("res:///cardReponse.tscn")
var reponse_background = preload("res://asset/motifR.jpg")
var step = 3 #0 = on place nos cartes , 1 = negociation step , 2 = deplacement de carte, 3 reponse into next turn
var turn = 0
var random_Card = randi_range(0, 15)

#@onready var cards_holder: HBoxContainer = $CardsHolder
var player_score_labels = {}  # Dictionary to map player names to their score labels
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
	
	# Set the outline for the label
	name_label.add_theme_color_override("font_color", Color(1, 1, 1))  # Text color (white)
	name_label.add_theme_color_override("outline_color", Color(0, 0, 0))  # Outline color (black)
	name_label.add_theme_constant_override("outline_size", 3)  # Outline thickness
	
	hboxPlayerNameContainer.add_child(name_label)
	# Afficher la couleur du joueur
	#var color_rect = ColorRect.new()
	#color_rect.color = player.color
	#color_rect.custom_minimum_size= Vector2(20, 20)  
	#hboxPlayerColorContainer.add_child(color_rect)
	# Afficher la couleur du joueur
	var texture_rect = TextureRect.new()
	texture_rect.texture = player.background
	texture_rect.custom_minimum_size= Vector2(22, 24)
	texture_rect.stretch_mode = TextureRect.STRETCH_TILE
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	hboxPlayerColorContainer.add_child(texture_rect)
	
	# Afficher le score du joueur
	var score_label = Label.new()
	score_label.text = str(player.score)
	score_label.add_theme_color_override("font_color", Color(1, 1, 1))  # Optional: apply outline to score label as well
	score_label.add_theme_color_override("outline_color", Color(0, 0, 0))
	score_label.add_theme_constant_override("outline_size", 3)
	hboxPlayerScoreContainer.add_child(score_label)
	
	# Store the score label in the dictionary, keyed by player name
	player_score_labels[player.name] = score_label
	
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
		for child in $CanvasLayer/CardPos.get_children():
			child.queue_free()
		for card in cards_holder.get_children():
			card.queue_free()
		for player in players:
			# Création des cartes pour chaque joueurs
			var card_instance = card_scene.instantiate()  # Create a card instance
			var card_data = CardData.cards_data[str(random_Card)]  
			card_instance.get_node("Label").text = card_data.name
			card_instance.get_node("Owner").text = player.name
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
		calculate_score()
		$Label.text = "Réponse :" + str(CardData.cards_data[str(random_Card)].date)

func adjust_label_font_size(label: Label) -> void:
	#label.add_theme_color_override("font_color", Color(1, 0, 0))
	var font = label.get_theme_font("font")
	var max_font_size = 18  # Starting with the current font size
	var target_width = label.get_rect().size.x  # The width of the Label itself

	while label.get_minimum_size().x > target_width and max_font_size > 5:
		max_font_size -= 1
		font.size = max_font_size
		label.add_theme_font("font", font)

func calculate_score():
	var correct_date = CardData.cards_data[str(random_Card)].date
	var playzone_start = $"PlayZone/1".position.x  # Position pour -100
	var playzone_end = $"PlayZone/22".position.x  # Position pour 2000
	var timeline_start = -100
	var timeline_end = 2000
	var cards_holder: HBoxContainer = $CanvasLayer/Field/CardsHolder
	
	for card in cards_holder.get_children():
		var card_pos_x = card.position.x
		
		# Convertir la position x de la carte en une date sur la timeline
		var card_date = lerp(timeline_start, timeline_end, (card_pos_x - playzone_start) / (playzone_end - playzone_start))
		
		# Calculer la différence entre la date de la carte et la date correcte
		var year_diff = abs(card_date - correct_date)
		var score = 0
		
		if year_diff <= 50:
			score = 100
		else:
			score = 100 - int((year_diff - 50) / 50) * 10  # Enlever 10 points tous les 50 ans de différence
		score = max(score, 0)  # S'assurer que le score ne descend pas sous 0
		
		# Mettre à jour le score du joueur
		for player in players:
			if player.name == card.get_node("Owner").text:  # Associer le joueur à la carte
				player.score += score
				print("Joueur:", player.name, " Score:", player.score, " Différence année:", year_diff)
				
				# Mettre à jour le score dans l'interface
				update_player_score_in_container(player.name, player.score)
				
	# Ajouter une nouvelle carte à la bonne position sur le terrain
	var new_card = card_Response.instantiate()

	# Calculer la position x de la carte en fonction de la date correcte
	# Lier la date (correct_date) à une position X sur la frise
	var card_x_pos = lerp(playzone_start, playzone_end, float(correct_date  - timeline_start) / float(timeline_end - timeline_start))
	# Placer la nouvelle carte à la position calculée
	var card_width = new_card.get_rect().size.x
	new_card.position = Vector2(card_x_pos , $"PlayZone".position.y -50)  # Ajuster la position y si nécessaire

	# Définir les données de la nouvelle carte
	var card_data = CardData.cards_data[str(random_Card)]
	new_card.get_node("Label").text = card_data.name
	new_card.get_node("TextureRect").texture = card_data.texture
	new_card.get_node("Background").texture = reponse_background
	$CanvasLayer/CardPos.add_child(new_card)
	new_card.z_index = RenderingServer.CANVAS_ITEM_Z_MAX

	
func update_player_score_in_container(player_name: String, new_score: int):
	if player_name in player_score_labels:
		var score_label = player_score_labels[player_name]
		score_label.text = str(new_score)
