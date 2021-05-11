extends RichTextLabel

func _ready():
	pass

func add_hist(text):
	self.bbcode_text += text
	self.bbcode_text += '\n\n'
