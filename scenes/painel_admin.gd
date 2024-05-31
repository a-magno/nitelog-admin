extends Control

func _ready():
	%QRLifetime.value = Global.QR_LIFETIME
	%DomainURI.text = Global.DOMAIN_URI

func _on_button_pressed():
	print("Test")

func _on_spin_box_value_changed(value):
	if value <= 0:
		value = Global.QR_LIFETIME
	else:
		Global.QR_LIFETIME = value as int
	Global.save_config()

func _on_domain_uri_text_submitted(new_text : String):
	if new_text.length() <= 0:
		%DomainURI.text = Global.DOMAIN_URI
	else:
		print("Inclui RegEx depois")
		Global.DOMAIN_URI = new_text
	var err = Global.save_config()
	Notifications.add_notify_label("Configs saved", 0.5)
	
func is_user_admin():
	var auth = Firebase.Auth.auth
	print(auth.localid)


func _on_qr_lifetime_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ENTER:
			%QRLifetime.release_focus()
