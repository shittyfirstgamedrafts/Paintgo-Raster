extends Node2D

var multiplier = 5 # How much we're zoomed in. SHould be at least 3 or else the program runs slowly

var img_width = 2304/multiplier # Should be viewport width / multiplier
var img_height = 1296/multiplier

var currentPos = Vector2(0,0)
var lastPos = Vector2(0,0)

var img = Image.create(img_width, img_height, false, Image.FORMAT_RGBA8)
var texture

var brushSize = 50

enum TOOLS {
	NONE,
	BRUSH,
	FILL
}

var currentTool = TOOLS.NONE # which tool are we using right now? 
var currentColor = Color.BLACK # Start out BLACK

var arrayOfFillPoints = [Vector2(0,0)]

class ColorPoint:
	var point: Vector2
	var color: Color

func _ready() -> void:
	
	$Sprite2D.scale = Vector2(multiplier,multiplier) # scale the board in accordance
	
	print("ready.")
	
	#White background
	for i in img_width: 
		for j in img_height:
			img.set_pixel(i, j, Color.WHITE)
	
	#Black border
	for i in img_width: 
		img.set_pixel(0, i, Color.BLACK)
		img.set_pixel(img_width, i, Color.BLACK)
		
	for i in img_width: 
		img.set_pixel(i, 0, Color.BLACK)
		img.set_pixel(i, img_height, Color.BLACK)
	
	texture = ImageTexture.create_from_image(img)
	$Sprite2D.texture = texture
	

func _process(_delta: float) -> void:
	var fillDone = false
	currentPos.x = int(get_viewport().get_mouse_position().x/multiplier)
	currentPos.y = int(get_viewport().get_mouse_position().y/multiplier)
	
	if currentTool == TOOLS.BRUSH and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT): #When you click
		_makeALine(currentPos.x, currentPos.y, lastPos.x, lastPos.y)
	#_makeALine(10, 10, 50, 20)
	
	elif currentTool == TOOLS.FILL:
		#print("fill")
		
		while !Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT): # Wait until click
			currentPos.x = int(get_viewport().get_mouse_position().x/multiplier)
			currentPos.y = int(get_viewport().get_mouse_position().y/multiplier)
			await get_tree().create_timer(0.01).timeout
		
		# If the while is broken, that means we just clicked
		img.set_pixel(currentPos.x, currentPos.y, currentColor)
	
		# Ok. This is when shiite gets serious. I'm gonna try the simplest algorithm first. 
		arrayOfFillPoints[0] = Vector2(currentPos.x, currentPos.y)
		
		var i = 0 # i indexes points in the arrayOfFillPoints
		var directionOptions = [Vector2(1,0),Vector2(-1,0), Vector2(0,1), Vector2(0,-1)]
		var currentPointToAnalyze
		
		while i < arrayOfFillPoints.size():
			
			var numberOfWhiteNeighborsForThisPixel = 0
			
			for direction in 4: # NSEW
				currentPointToAnalyze = Vector2(arrayOfFillPoints[i].x + directionOptions[fmod(direction,4)].x,arrayOfFillPoints[i].y + directionOptions[fmod(direction,4)].y) # I love long unruly lines of code. Like so long they're hardly even readable anymore. And this comment is making it even longer. yippee
				
				if img.get_pixel(currentPointToAnalyze.x, currentPointToAnalyze.y) != Color.WHITE:
					numberOfWhiteNeighborsForThisPixel += 1 
				else:
					img.set_pixel(currentPointToAnalyze.x, currentPointToAnalyze.y, currentColor)
					arrayOfFillPoints.append_array([currentPointToAnalyze])
				
				if numberOfWhiteNeighborsForThisPixel == 0:
					arrayOfFillPoints.erase(i) # clean up
			
			i += 1
			
			texture = ImageTexture.create_from_image(img)
			$Sprite2D.texture = texture
			await get_tree().create_timer(0.000000000000000000000000000001).timeout # otherwise the software freezes
		#print(arrayOfFillPoints.size())
		
		fillDone = true
		
		#print("fill done") 
		currentTool = TOOLS.NONE
	elif currentTool == TOOLS.NONE:
		# take a breath and reset
		arrayOfFillPoints = [Vector2(0,0)]
		
	texture = ImageTexture.create_from_image(img)
	$Sprite2D.texture = texture
	
	lastPos = currentPos # This line needs to stay last 
	

func _makeALine(x1, y1, x2, y2):
	var movingX = x1
	var movingY = y1
	
	var xIncrement = 1
	var yIncrement = 1
	
	# If you divide a number by its own absolute value, e.g. x/abs(x)
	# ... you get 1 if it was positive and -1 if it was negative. 
	# This is useful cuz we can set x and yIncrement to 1 and -1...
	# depending on whether x2 is bigger than movingX, for example. 
	var dimension = abs(y2-y1)+abs(x2-x1)
	
	for i in dimension: # stop running the code when we reach destination
		xIncrement = (x2-movingX)/abs(x2-movingX) # 1 if x2>movingX and -1 if x2<movingX
		yIncrement = (y2-movingY)/abs(y2-movingY) # 1 if y2>movingY and -1 if y2<movingY
		
		if abs(y2-movingY) > abs(x2-movingX): # If the difference between the ys is greater than the difference between the xs
			movingY += yIncrement
		else:
			movingX += xIncrement
			
		
		img.set_pixel(movingX, movingY, currentColor)
		texture = ImageTexture.create_from_image(img)
		$Sprite2D.texture = texture
	
	print("made a line")


func _on_blue_button_pressed() -> void:
	currentColor = Color.BLUE
	currentTool = TOOLS.BRUSH


func _on_green_button_pressed() -> void:
	currentColor = Color.GREEN
	currentTool = TOOLS.BRUSH


func _on_red_button_pressed() -> void:
	currentColor = Color.RED
	currentTool = TOOLS.BRUSH


'''func _on_fill_button_pressed() -> void:
	currentTool = TOOLS.FILL
	while !Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		currentPos.x = int(get_viewport().get_mouse_position().x/multiplier)
		currentPos.y = int(get_viewport().get_mouse_position().y/multiplier)
		
		img.set_pixel(currentPos.x, currentPos.y, currentColor)
		
		texture = ImageTexture.create_from_image(img)
		$Sprite2D.texture = texture
		await get_tree().create_timer(0.01).timeout
		
	print("fill done")
'''

func _on_fill_button_button_up() -> void:
	currentTool = TOOLS.FILL
