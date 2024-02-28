#function and variable table (wished for by Matthias)
#
#Variables:
#
#FeldGröße : value for the size of a field in pixels
#Schwierigkeiten : difficulties
#Schwierigkeit : the current difficulty
#selectFeld : index of the currently selected field (-1 for none selected)
#currentFeld : used as an index for creating the numbers of the sudoku
#FeldGrenze : boundary for right/bottom edge of the field
#Bereich : an array of 4 values dependend on the difficulty, which are intended to set the amount of numbers which can be deleted
#falscheFelder : contains all fields which contain faulty/contradictory numbers
#mögFeld : contains all numbers for a field during number generation, which are still free to use
#Felder : contains the value of each field (0 for empty)
#festeFelder : contains all fields which cannot be changed
#Spalten : contains every value present in a column
#Zeilen : contains every value present in a row
#Blöcke : contains every value present in a 3x3 block
#Knöpfe : contain the instances of the 81 buttons
#
#Functions:
#
#anzahlFelderBereich() : sets the variable Bereich depending on the difficulty
#checkSpalte(Feld) : returns the column of a field
#checkZeile(Feld) : returns the row of a field
#checkBlock(Feld) : returns the 3x3 block a field is in
#retSpalte(Spalte) : returns all fields of a column
#retZeile(Zeile) : returns all fields of a row
#retBlock(Block) : returns all fields of a 3x3 block
#checkFreieNum(Feld) : returns all possible numbers for a field
#schreibeNum(Wert, Feld) : writes a value in a field; a field will be replaced if it already contains a value
#ersetzteNum(Wert, Feld) : raplaces the value of a field
#wertAnheben(Feld) : raises the value of a field by 1, writes 0 if the value is 9
#wertSenken(Feld) : lowers the value of field by 1, writes 9 if the value is 0
#löscheFelder() : sets the values of certain fields to 0 in order to make the game actually playable and makes the rest static (altough should probably be improved)
#erzeugeSpielfeld() : creates the numbers for the game
#erzeugeSpielbrett() : creates the buttons for the game board
#reset() : resets the game and creates a new set of numbers
#kontrolle() : checks which fields are incorrect
#testMaus() : checks if the cursor is outside the game board, and deselcts the selected field if it is
#felderMarkieren(Feld) : marks the fields in the same column/row/block of the selected field, as well as incorrect fields

extends Node2D

const FeldGröße = 40

@export var Schwierigkeit:Schwierigkeiten

var selectFeld:int = -1
var currentFeld:int = 0
var FeldGrenze:int
var Bereich = []

var falscheFelder = []
var mögFeld = []
var Felder = []
var festeFelder = []
var Spalten = []
var Zeilen = []
var Blöcke = []
var Knöpfe = []

enum Schwierigkeiten{
	voll,
	einfach,
	mittel,
	schwer,
	leer
}

func anzahlFelderBereich():
	match Schwierigkeit:
		0:
			Bereich = [9, 9, 9, 9]
		1:
			Bereich = [3, 4, 5, 7]
		2:
			Bereich = [3, 4, 4, 6]
		3:
			Bereich = [3, 3, 4, 5]
		4:
			Bereich = [0, 0, 0, 0]

func checkSpalte(Feld) -> int:
	return Feld % 9

func checkZeile(Feld) -> int:
	return floor(Feld / 9)

func checkBlock(Feld) -> int:
	return floor(Feld / 3 % 3) + floor(Feld / 27) * 3

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
		return retZahlen
	else:
		return 0

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

func wertAnheben(Feld):
	if festeFelder[Feld]:
		return
	elif Felder[Feld] < 9:
		schreibeNum(Felder[Feld] + 1, Feld)
	else:
		schreibeNum(0, Feld)
	kontrolle()

func wertSenken(Feld):
	if festeFelder[Feld]:
		return
	elif Felder[Feld] > 0:
		schreibeNum(Felder[Feld] - 1, Feld)
	else:
		schreibeNum(9, Feld)
	kontrolle()

#überarbeiten
func löscheFelder():
	for i in range(9):
		var Zahlen = []
		for o in range(81):
			if Felder[o] == i + 1:
				Zahlen.append(o)
		Zahlen.shuffle()
		for e in range(9 - Bereich[randi_range(0, 3)]):
			schreibeNum(0, Zahlen[e])
	for e in range(81):
		if Felder[e]:
			festeFelder.append(e)
			Knöpfe[e].statisch()
		else:
			festeFelder.append(0)

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

func erzeugeSpielbrett():
	for i in range(81):
		var Knopf = load("res://Knopf.tscn").instantiate()
		Knopf.index = i
		Knopf.position = Vector2(checkSpalte(i) * FeldGröße + 2 * (i / 3 % 3) - 2, checkZeile(i) * FeldGröße + 2 * floor(i / 27) - 2)
		Knöpfe.append(Knopf)
		add_child(Knopf)

func reset():
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
	
	for o in range(9):
		Spalten.append([])
		Zeilen.append([])
		Blöcke.append([])
	
	erzeugeSpielfeld()
	anzahlFelderBereich()
	löscheFelder()

func kontrolle():
	falscheFelder.clear()
	for i in range(81):
		var ogWert = Felder[i]
		schreibeNum(0, i)
		if !checkFreieNum(i).count(ogWert) and ogWert:
			falscheFelder.append(i)
		schreibeNum(ogWert, i)

func testMaus():
	var mPos = get_global_mouse_position()
	if mPos.x < -FeldGröße / 2 or mPos.x > FeldGrenze or mPos.y < -FeldGröße / 2 or mPos.y > FeldGrenze:
		selectFeld = -1

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
