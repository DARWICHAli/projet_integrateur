extends RichTextLabel

func _ready():
	pass

func add_hist(text):
	var save = self.bbcode_text
	self.bbcode_text = '\n\n'
	self.bbcode_text += text + save
	#var save = self.bb_code_text
