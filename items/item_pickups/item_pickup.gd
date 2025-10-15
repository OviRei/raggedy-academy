@tool
class_name ItemPickup extends Node2D

@export var item_data : ItemData : set = _set_item_data

@onready var area_2d: Area2D = $Area2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var is_picked_up_data: PersistentDataHandler = $IsPickedUp

var is_picked_up : bool = false


func _ready() -> void:
	_update_texture()
	if Engine.is_editor_hint():
		return
	area_2d.body_entered.connect( _on_body_entered )
	
	is_picked_up_data.data_loaded.connect( set_item_state )
	set_item_state()

func set_item_state():
	is_picked_up = is_picked_up_data.value
	if is_picked_up:
		visible = false
		queue_free()

func _on_body_entered( b ) -> void:
	if b is Player:
		if item_data:
			if PlayerManager.INVENTORY_DATA.add_item( item_data ) == true:
				item_picked_up()
	pass


func item_picked_up() -> void:
	area_2d.body_entered.disconnect( _on_body_entered )
	SodaAudioManager.play_sfx("res://items/item_pickups/item_pickup.wav")
	visible = false
	is_picked_up_data.set_value()
	queue_free()
	pass


func _set_item_data( value : ItemData ) -> void:
	item_data = value
	_update_texture()
	pass


func _update_texture() -> void:
	if item_data and sprite_2d:
		sprite_2d.texture = item_data.texture
	pass
