extends Node

var cert_name = "unistrapoly_certif.crt"
var key_name = "unistrapoly_key.key"


func _ready():
	var crypto = Crypto.new()
	var key = crypto.generate_rsa(4096)
	var cert = crypto.generate_self_signed_certificate(key, "CN=localhost,O=UnistraPoly,C=FR")
	cert.save("user://" + cert_name)
	key.save("user://" + key_name)
	print("Certificat créé")
