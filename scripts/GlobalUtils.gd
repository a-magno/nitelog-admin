extends Node

const CONFIG_ENCRYPT_PASS := ""

var active_list_data : Dictionary

var debug = true
var USER_COLLECTION_ID = "users"
var ATTENDANCE_COLLECTION_ID = "attendance-lists"
var QR_LIFETIME = 10
var DOMAIN_URI = "https://nitelog-1e1a5.web.app/"

var crypto = Crypto.new()
var key = CryptoKey.new()

var config : ConfigFile
var CONFIG_SAVE_PATH_DEBUG := "res://"
var CONFIG_SAVE_PATH := "user://"
var CONFIG_FILE_NAME := "config"

func _ready():
	config = ConfigFile.new()
	load_config()
	#key = crypto.generate_rsa(4096)
	#if not FileAccess.file_exists(CONFIG_SAVE_PATH+"nitelog.key"):
		#key.save(CONFIG_SAVE_PATH+"nitelog.key")

#region ConfigHandling
func save_config():
	#key.load(CONFIG_SAVE_PATH+"nitelog.key")
	#var encrypted_uri = crypto.encrypt(key, DOMAIN_URI.to_utf8_buffer() )
	var save_path = "{0}{1}.cfg".format([CONFIG_SAVE_PATH, CONFIG_FILE_NAME])
	config.set_value("Collection_IDs", "user_collection_id", USER_COLLECTION_ID)
	config.set_value("Collection_IDs", "attendance_collection_id", ATTENDANCE_COLLECTION_ID)
	config.set_value("Global Config", "qr_lifetime", QR_LIFETIME)
	config.set_value("Global Config", "domain_uri", DOMAIN_URI)

	if debug:
		config.save_encrypted_pass("{0}{1}.cfg".format([CONFIG_SAVE_PATH_DEBUG, CONFIG_FILE_NAME]), CONFIG_ENCRYPT_PASS)
		return OK
	else:
		config.save_encrypted_pass(save_path, CONFIG_ENCRYPT_PASS)
		return OK
	return ERR_FILE_CANT_WRITE

func load_config():
	var has_config
	var load_path = "{0}{1}.cfg".format([CONFIG_SAVE_PATH, CONFIG_FILE_NAME])
	#key.load(CONFIG_SAVE_PATH+"nitelog.key")
	
	if debug:
		has_config = config.load_encrypted_pass("{0}{1}.cfg".format([CONFIG_SAVE_PATH_DEBUG, CONFIG_FILE_NAME]), CONFIG_ENCRYPT_PASS)
	else:
		has_config = config.load_encrypted_pass(load_path, CONFIG_ENCRYPT_PASS)

	if has_config == OK:
		USER_COLLECTION_ID = config.get_value("Collection_IDs", "user_collection_id")
		ATTENDANCE_COLLECTION_ID = config.get_value("Collection_IDs", "attendance_collection_id")
		QR_LIFETIME = config.get_value("Global Config", "qr_lifetime")
		
		#var decrypted_uri = crypto.decrypt(key, config.get_value("Global Config", "domain_uri"))
		#assert(DOMAIN_URI.to_utf8_buffer() == decrypted_uri, "Decrypted data does not match!")
		#DOMAIN_URI = decrypted_uri
		DOMAIN_URI = config.get_value("Global Config", "domain_uri")
	else:
		save_config()
#endregion

func register_user( user : User, user_password ):
	Firebase.Auth.signup_with_email_and_password(user.email, user_password)
	var localid = Firebase.Auth.auth.localid
	user.userId = localid
	save_to_database( USER_COLLECTION_ID, localid, user.get_data() )

func query_database( collection : String, filter : Dictionary = {}, limit := 1 ) -> Array:
	#var auth = Firebase.Auth.auth
	var results : Array = []
	for key in filter.keys():
		var query : FirestoreQuery = FirestoreQuery.new()
		query.from(collection)
		query.order_by(key, FirestoreQuery.DIRECTION.ASCENDING)
		query.where(key, query.OPERATOR.EQUAL, filter[key])
		query.limit(limit)
		
		var r : Array = await Firebase.Firestore.query(query).result_query
		results.push_back(r)
	
	check_and_delete_anon()
	return results[0]

func save_to_database( collection_id : String, doc_id : String, data : Dictionary ):
	var auth = Firebase.Auth.auth
	if auth:
		var collection : FirestoreCollection = Firebase.Firestore.collection(collection_id)
		var task : FirestoreTask = collection.add( doc_id, data )

func load_from_database( collection_id : String ):
	var auth = Firebase.Auth.auth
	if auth:
		var collection: FirestoreCollection = Firebase.Firestore.collection(collection_id)
		var task: FirestoreTask = collection.get_doc(auth.localid)
		var finished_task : FirestoreTask = await task.task_finished
		var document = finished_task.document

func check_and_delete_anon():
	var is_anon = Firebase.Auth.auth_request_type == FirebaseAuth.Auth_Type.LOGIN_ANON
	if is_anon:
		Firebase.Auth.delete_user_account()
	else:
		Firebase.Auth.logout()
