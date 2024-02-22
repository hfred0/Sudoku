extends Node2D

enum Schwierigkeiten{
	voll,
	einfach,
	mittel,
	schwer,
	leet
}

const FeldGröße = 40

@export var Schwierigkeit:Schwierigkeiten
var selectFeld:int = -1
var currentFeld:int = 0
var FeldGrenze = []
var Bereich = []

var Ordnung = []
var falscheFelder = []
var mögFeld = []
var Felder = []
var festeFelder = []
var Spalten = []
var Zeilen = []
var Blöcke = []
var Knöpfe = []

#irgendein Weg zum Einstellen der Schwierigkeit im Spiel benötigt
func anzahlFelderBereich():
	match Schwierigkeit:
		0:
			Bereich = [9, 9, 9, 9]
		1:
			Bereich = [3, 5, 6, 7]
		2:
			Bereich = [3, 4, 5, 6]
		3:
			Bereich = [3, 3, 4, 5]
		4:
			Bereich = [0, 0, 0, 0]

#schaut, in welcher Spalte/Zeile/Block sich ein Feld befindet
func checkSpalte(Feld) -> int:
	return Feld % 9

func checkZeile(Feld) -> int:
	return floor(Feld / 9)

func checkBlock(Feld) -> int:
	return floor(Feld / 3 % 3) + floor(Feld / 27) * 3

#gibt Nummer der Spalte/Zeile/Block zurück
func retSpalte(Spalte) -> Array:
	var ret = []
	for i in range(9):
		ret.append(i * 9 + Spalte)
	return ret

func retZeile(Zeile) -> Array:
	var ret = []
	for i in range(9):
		ret.append(i % 9 + Zeile * 9)
	return ret

func retBlock(Block) -> Array:
	var ret = []
	for i in range(9):
		ret.append(i % 3 + floor(Block / 3) * 27 + Block % 3 * 3 + floor(i / 3) * 9)
	return ret

#schaut nach allen freien Zahlen für das Feld
func checkFreieNum(Feld):
	if Felder[Feld] == 0:
		var Zahlen = []
		var retZahlen = []
		
		Zahlen.append_array(Spalten[checkSpalte(Feld)])
		Zahlen.append_array(Zeilen[checkZeile(Feld)])
		Zahlen.append_array(Blöcke[checkBlock(Feld)])
		
		for i in range(9):
			if Zahlen.count(i + 1) == 0:
				retZahlen.append(i + 1)
		
		Zahlen.clear()
		return retZahlen
	else:
		return 0

#schreibt Zahl in die dementsprechende Spalte/Zeile/Block
func schreibeNum(Wert, Feld):
	if Felder[Feld] != 0:
		ersetzteNum(Wert, Feld)
	else:
		Felder[Feld] = Wert
		
		Spalten[checkSpalte(Feld)].append(Wert)
		Zeilen[checkZeile(Feld)].append(Wert)
		Blöcke[checkBlock(Feld)].append(Wert)
		
	var text = "%s"
	var Knopf = Knöpfe[Feld]
	if Wert:
		Knopf.setzeText(text % Wert)
	elif Wert == 0:
		Knopf.setzeText("")
	else:
		Knopf.setzeText("Blöd")

#ersetzt eine Zahl falls sich bereits ein Wert in einem Feld befindet
func ersetzteNum(Wert, Feld):
	var ogWert = Felder[Feld]
	var Knopf = Knöpfe[Feld]
	
	Spalten[checkSpalte(Feld)].erase(ogWert)
	Zeilen[checkZeile(Feld)].erase(ogWert)
	Blöcke[checkBlock(Feld)].erase(ogWert)
	
	Spalten[checkSpalte(Feld)].append(Wert)
	Zeilen[checkZeile(Feld)].append(Wert)
	Blöcke[checkBlock(Feld)].append(Wert)
	
	Felder[Feld] = Wert
	var text = "%s"
	Knopf.setzeText(text % Wert)

#hebt den Wert eines Feldes um 1 an und setzt auf 0 zurück falls Feld bei 9 ist
func wertAnheben(Feld):
	if festeFelder[Feld]:
		return
	elif Felder[Feld] < 9:
		schreibeNum(Felder[Feld] + 1, Feld)
	else:
		schreibeNum(0, Feld)
	kontrolle()

#senkt den Wert eines Feldes um 1 und setzt auf 9 zurück falls Feld bei 0 ist
func wertSenken(Feld):
	if festeFelder[Feld]:
		return
	elif Felder[Feld] > 0:
		schreibeNum(Felder[Feld] - 1, Feld)
	else:
		schreibeNum(9, Feld)
	kontrolle()

#macht Felder frei
func löscheFelder():
	for i in range(9):
		var Zahlen = []
		for o in range(81):
			if Felder[o] == i + 1:
				Zahlen.append(o)
		Zahlen.shuffle()
		#for e in range(9 - round(randi_range(Bereich[0], Bereich[1]))):
		for e in range(9 - Bereich[randi_range(0, 3)]):
			schreibeNum(0, Zahlen[e])
	for e in range(81):
		if Felder[e]:
			festeFelder.append(e)
			Knöpfe[e].statisch()
		else:
			festeFelder.append(0)

#erzeugt die Zahlen vom Sudoku
func erzeugeSpielfeld() -> void:
	if currentFeld < 81:
		var mögNum = []
		
		for i in range(9):
			if checkFreieNum(currentFeld).count(i + 1) == mögFeld[currentFeld].count(i + 1):
				mögNum.append(i + 1)
		
		if mögNum:
			var num = mögNum.pick_random()
			
			schreibeNum(num, currentFeld)
			mögFeld[currentFeld].erase(num)
			currentFeld += 1
			erzeugeSpielfeld()
		else:
			mögFeld[currentFeld] = [1, 2, 3, 4, 5, 6, 7, 8, 9]
			currentFeld -= 1
			schreibeNum(0, currentFeld)
			erzeugeSpielfeld()
	else:
		currentFeld = 0
		return

#erzeugt das Brett (Vor Zuweisung der Zahlen verwenden!)
func erzeugeSpielbrett():
	for i in range(81):
		var Knopf = load("res://Knopf.tscn").instantiate()
		Knopf.index = i
		Knopf.position = Vector2(checkSpalte(i) * FeldGröße + 2 * (i / 3 % 3) - 2, checkZeile(i) * FeldGröße + 2 * floor(i / 27) - 2)
		Knöpfe.append(Knopf)
		add_child(Knopf)

#erzeugt alle Zahlen neu
func reset():
	Ordnung.clear()
	Felder.clear()
	mögFeld.clear()
	Spalten.clear()
	Zeilen.clear()
	Blöcke.clear()
	falscheFelder.clear()
	festeFelder.clear()
	
	for i in range(81):
		Knöpfe[i].setzeText("")
		Knöpfe[i].dynamisch()
		Felder.append(0)
		mögFeld.append([1, 2, 3, 4, 5, 6, 7, 8, 9])
		Ordnung.append(i)
	Ordnung.shuffle()
	
	for o in range(9):
		Spalten.append([])
		Zeilen.append([])
		Blöcke.append([])
	
	erzeugeSpielfeld()
	anzahlFelderBereich()
	löscheFelder()

#kontrolliert, ob ein Feld nicht möglich ist, ignoriert leere Felder
func kontrolle():
	falscheFelder.clear()
	for i in range(81):
		var ogWert = Felder[i]
		schreibeNum(0, i)
		if !checkFreieNum(i).count(ogWert) and ogWert:
			falscheFelder.append(i)
		schreibeNum(ogWert, i)

#schaut, ob sich die Maus im Spielfeld befindet
func testMaus():
	var mPos = get_global_mouse_position()
	if mPos.x < -FeldGröße / 2 or mPos.x > FeldGrenze or mPos.y < -FeldGröße / 2 or mPos.y > FeldGrenze:
		selectFeld = -1

#färbt Felder, welche sich in der selben Spalte/Zeile/Block wie das ausgewählte Feld befinden
#färbt falsche Zahlen
func felderMarkieren(Feld):
	if Feld + 1:
		var markFeld = []
		markFeld.append_array(retSpalte(checkSpalte(Feld)))
		markFeld.append_array(retZeile(checkZeile(Feld)))
		markFeld.append_array(retBlock(checkBlock(Feld)))
		for i in range(81):
			var ogFarbe = Knöpfe[i].get_color()
			if markFeld.count(i):
				Knöpfe[i].set_color(Color(0.97, 0.97, 1))
			else:
				Knöpfe[i].set_color(ogFarbe)
			if falscheFelder.count(i):
				Knöpfe[i].set_color(Color(1, 0, 0))
	else:
		for i in range(81):
			var ogFarbe = Knöpfe[i].get_color()
			Knöpfe[i].set_color(ogFarbe)
			if falscheFelder.count(i):
				Knöpfe[i].set_color(Color(1, 0, 0))

func _ready():
	Schwierigkeit = 4
	erzeugeSpielbrett()
	reset()
	FeldGrenze = FeldGröße / 2 * 9 + Knöpfe[40].position.x
	
	$Camera2D.position = Knöpfe[40].position

func _process(_delta):
	testMaus()
	for i in range(81):
		Knöpfe[i].set_color(Color(1, 1, 1))
	if Input.is_action_pressed("check"):
		felderMarkieren(selectFeld)


func _on_item_list_item_selected(index):
	Schwierigkeit = index

func _on_button_pressed():
	reset()
