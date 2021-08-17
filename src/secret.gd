extends Area2D


export var secret:String
export var tile_top_left:Vector2
export var tile_bottom_right:Vector2
export var tile_map_path:String

func _on_somebody_enterd(body):
	if body is Player: 
		get_node(secret).visible = false
		var tile_map = get_node(tile_map_path)
		for i in range(tile_top_left.x, tile_bottom_right.x + 1):
			for j in range(tile_top_left.y, tile_bottom_right.y + 1):
				tile_map.set_cell(i, j, -1)
	return
