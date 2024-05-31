extends PanelContainer

var diasDaSemana =[
	"Segunda-Feira",
	"Terça-Feira",
	"Quarta-Feira",
	"Quinta-Feira",
	"Sexta-Feira",
	"Sábado"]

# Called when the node enters the scene tree for the first time.
func _ready():
	%HoraEntrada.clear()
	%HoraSaida.clear()
	%DiaSemana.clear()
	for h in range(8, 23):
		var str = "%02d:00" % h
		%HoraEntrada.add_item(str)
		%HoraSaida.add_item(str)
	for dia in diasDaSemana:
		%DiaSemana.add_item(dia)
