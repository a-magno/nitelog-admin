extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	Firebase.Auth.login_succeeded.connect(on_login_success)
	Firebase.Auth.login_failed.connect(on_login_failed)
	Firebase.Auth.signup_succeeded.connect(on_signup_success)
	Firebase.Auth.signup_failed.connect(on_signup_failed)

func get_data_login() -> Dictionary:
	return {
		"email": %Email.text,
		"password": %Password.text
	}

func get_data_signin() -> Dictionary:
	return {
		"name": %Nome.text,
		"email": %CadEmail.text,
		"password": %CadPassword.text
	}

func _wipe_fields():
	%Email.text = ""
	%Password.text = ""
	%Nome.text = ""
	%CadEmail.text = ""
	%CadPassword.text = ""

func _on_login_btn_pressed():
	var creds = get_data_login()
	Firebase.Auth.login_with_email_and_password(creds.email, creds.password)
	%Status.text = "[center][color=yellow]Logging in"
	_wipe_fields()

func _on_signup_btn_pressed():
	
	%Status.text = "[center][color=yellow]Signing up"

func on_login_success(auth):
	#print(auth)
	%Status.text = "[center][color=green]Login Success!"
	_wipe_fields()

func on_signup_success(auth):
	var is_anon = Firebase.Auth.auth_request_type == FirebaseAuth.Auth_Type.LOGIN_ANON

	var creds = get_data_signin()
	var user = User.new(creds["name"], creds["email"])
	#If auth is not anonymous
	if not is_anon:
		Global.register_user(user, creds["password"])
		%Status.text = "[center][color=green]Signed Up!"
	else:
		Firebase.Auth.delete_user_account()
	_wipe_fields()

func on_login_failed(err_code, msg): 
	print(err_code)
	print(msg)
	%ErrPopup.show()
	%ErrMsg.text = "[center]Login Failed. Error: [color=red]%s" % msg
	%Status.text = "[center][color=red]Failure"
	_wipe_fields()

func on_signup_failed(err_code, msg):
	print(err_code)
	print(msg)
	%ErrPopup.show()
	%ErrMsg.text = "[center]Signup Failed. Error: [color=red]%s" % msg
	%Status.text = "[center][color=red]Failure"
	_wipe_fields()

#func save_data():
	#var auth = Firebase.Auth.auth
	#if auth.localid:
		#var collection: FirestoreCollection = Firebase.Firestore.collection(Global.USER_COLLECTION_ID)
		#var test_data : Dictionary = User.new("De", "Pijama").get_data()
		#var task : FirestoreTask = collection.update(auth.localid, test_data)
#
#func load_data():
	#var auth = Firebase.Auth.auth
	#if auth.localid:
		#var collection: FirestoreCollection = Firebase.Firestore.collection(Global.USER_COLLECTION_ID)
		#var task: FirestoreTask = collection.get_doc(auth.localid)
		#var finished_task : FirestoreTask = await task.task_finished
		#var document = finished_task.document
