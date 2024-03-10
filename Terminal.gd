extends TextEdit

var realText = ""
var oldText = ""
enum PlayerPosition {
	START,
	TICKET_BOOTH,
	BEDROOM,
	HALLWAY1,
	KITCHEN,
	HALLWAY2,
	EQUIPMENT_ROOM,
	ANALYSYS_ROOM,
	EXTRACTION_ROOM
}
const readableNamePosMap = {
	PlayerPosition.START: "in the Train Station",
	PlayerPosition.TICKET_BOOTH: "at the window of the Ticket Booth",
	PlayerPosition.BEDROOM: "in your bedroom",
	PlayerPosition.HALLWAY1: "in a hallway with your room to the east, the kitchen to the west, and with the hallway continuing south",
	PlayerPosition.KITCHEN: "in the kitchen with a hallway to the east. There is a food dispenser, and you can !PUSH THE BUTTON! to get food",
	PlayerPosition.HALLWAY2: "in a hallway with the equipment room to the east, the analysis room to the west, the extraction room to the south, and with the hallway continuing north",
	PlayerPosition.EQUIPMENT_ROOM: "in the equipment room with all the equipment around you. There are large piles of components all around you, and the exit is to the west",
	PlayerPosition.ANALYSYS_ROOM: "in the analysis room with a lone computer terminal on a desk. The exit is to the east",
	PlayerPosition.EXTRACTION_ROOM: "in the extraction room where you will be extracting samples to analyize and send to the research department, with the exit to the north"
}
const firstEnterMap = {
	PlayerPosition.START: "",
	PlayerPosition.TICKET_BOOTH: "",
	PlayerPosition.HALLWAY1: "As you enter the hallway, you swear that last night to the north was where you entered, although now there is just a wall. You take note of this, but decide that it is probably best to just continue to the kitchen.",
	PlayerPosition.KITCHEN: "",
	PlayerPosition.HALLWAY2: "",
	PlayerPosition.EQUIPMENT_ROOM: "As you enter the equipment room, the voice starts talking again. \"NOW THAT YOU HAVE HAD BREAKFAST, YOU SHOULD GRAB ONE OF THE DRILL BITS, ONE OF THE DRILL RODS, AND A BOTTLE OF COOLING GEL. AND NOW THAT YOU'VE REACHED THE FACILITY, YOU CAN BE INFORMED ABOUT YOUR PURPOSE. YOUR PURPOSE IS TO DRILL DOWN AND COLLECT SAMPLES TO ANALYSE AND SEND TO OUR RESEARCH DEPARTMENT, WHO WILL USE THE INFO YOU COLLECT TO FURTHER HUMANITY AND SCIENCE. AFTER YOU GRAB THE ITEMS, PLEASE HEAD TO THE EXTRACTION ROOM.\"\n(hint: you can grab things with the grab, get, or take command)",
	PlayerPosition.ANALYSYS_ROOM: "",
	PlayerPosition.EXTRACTION_ROOM: "Now as you head into the extraction room, the voice says, \"THIS IS WHERE YOU WILL SPEND MUCH OF YOUR TIME. BEFORE YOU CAN START DRILLING, YOU WILL NEED TO !POUR IN THE COOLING GEL!, !PUT IN THE DRILL BIT!, AND FINALLY !ATTACH THE DRILL ROD!. AFTER YOU DO THAT I WILL CONTINUE EXPLAINING.\"",
	PlayerPosition.BEDROOM: "You enter the train and sit down. It's a long ride but you do eventually, finally, step foot into the underground facility. You read the hastily scribbled on piece of paper given to you by Dr. Madd and see that you need to go to block 2C, room 5H. Apparently that will be where you live and work. After talking to whoever is behind the booth at the entrance and going through security, you head into an elevator, select block 2C, go through the damp and creepy hallways, and reach room 5H. After getting in, you put down your few possesions, and collapse onto the bed. You wake up in a cold sweat because of a nightmare you had about something that appeared to be a biblically accurate angel telling you to \"watch out for the undertoad\" and \"follow Lutiture\".\n\nYou suddenly hear a voice seeming to be coming from all around you saying \"great, you've woken up. After you've gotten some breakfast from the kitchen, then please head to the equipment room so you can start your first day on the job.\""
}
var haveEntered = {
	PlayerPosition.BEDROOM: false,
	PlayerPosition.HALLWAY1: false,
	PlayerPosition.EQUIPMENT_ROOM: false,
	PlayerPosition.EXTRACTION_ROOM: false,
}
var roomExits = {
	PlayerPosition.START: {
		"north": PlayerPosition.TICKET_BOOTH,
		"south": null,
		"east": null,
		"west": null,
	},
	PlayerPosition.TICKET_BOOTH: {
		"north": null,
		"south": PlayerPosition.START,
		"east": null,
		"west": null,
	},
	PlayerPosition.BEDROOM: {
		"north": null,
		"south": null,
		"east": null,
		"west": PlayerPosition.HALLWAY1,
	},
	PlayerPosition.HALLWAY1: {
		"north": null,
		"south": PlayerPosition.HALLWAY2,
		"east": PlayerPosition.BEDROOM,
		"west": PlayerPosition.KITCHEN
	},
	PlayerPosition.HALLWAY2: {
		"north": PlayerPosition.HALLWAY1,
		"south": PlayerPosition.EXTRACTION_ROOM,
		"east": PlayerPosition.EQUIPMENT_ROOM,
		"west": PlayerPosition.ANALYSYS_ROOM
	},
	PlayerPosition.KITCHEN: {
		"north": null,
		"south": null,
		"east": PlayerPosition.HALLWAY1,
		"west": null
	},
	PlayerPosition.EXTRACTION_ROOM: {
		"north": PlayerPosition.HALLWAY2,
		"south": null,
		"east": null,
		"west": null
	},
	PlayerPosition.EQUIPMENT_ROOM: {
		"north": null,
		"south": null,
		"east": null,
		"west": PlayerPosition.HALLWAY2
	},
	PlayerPosition.ANALYSYS_ROOM: {
		"north": null,
		"south": null,
		"east": PlayerPosition.HALLWAY2,
		"west": null
	}
}
var playerPos: PlayerPosition = PlayerPosition.START
var itemsInRooms = {
	PlayerPosition.EQUIPMENT_ROOM: [
		Items.DRILL_BIT,
		Items.DRILL_ROD,
		Items.COOLING_GEL
	],
	PlayerPosition.EXTRACTION_ROOM: [],
	PlayerPosition.ANALYSYS_ROOM: [],
	PlayerPosition.KITCHEN: [],
	PlayerPosition.HALLWAY1: [],
	PlayerPosition.HALLWAY2: [],
	PlayerPosition.START: [],
	PlayerPosition.TICKET_BOOTH: [],
	PlayerPosition.BEDROOM: [],
}
var regeneratingItemRooms = [
	PlayerPosition.EQUIPMENT_ROOM
]
var nightSequenceCheckedRooms = []
var numNightSequencesSkipped = 0

func go(args):
	print(args)
	var moveTo = "don't"
	for arg in args:
		if arg in ["north", "south", "east", "west"]:
			moveTo = arg
	if moveTo == "don't":
		insert_text_at_caret("sorry, but that isn't a direction.".to_upper(), 0)
		return
	if not (roomExits[playerPos][moveTo]) and roomExits[playerPos][moveTo] != 0:
		insert_text_at_caret("there's a wall there.".to_upper(), 0)
		return
	playerPos = roomExits[playerPos][moveTo]
	print(roomExits[playerPos])
	if playerPos == PlayerPosition.ANALYSYS_ROOM and Items.SAMPLE in inventory and day == 1:
		insert_text_at_caret("After entering the analysis room, the voice starts talking again. \"GREAT JOB SO FAR. YOU NOW NEED TO !PUT THE SAMPLE! INTO THE ANALYSIS UNIT. AFTER DOING THAT, !PRESS THE BUTTON! TO START ANALYSYS AND SEND THE NECESSARY INFORMATION TO THE RESEARCH DEPARTMENT.\"".to_upper(), 0)
	elif playerPos == PlayerPosition.ANALYSYS_ROOM and Items.SAMPLE in inventory and day == 2:
		insert_text_at_caret("After entering the analysis room, the voice says almost the same thing as yesterday. \"WONDERFUL WORK. YOU NOW NEED TO !PUT THE SAMPLE! INTO THE ANALYSIS UNIT. AFTER DOING THAT, !PRESS THE BUTTON! TO START ANALYSYS AND SEND THE NECESSARY INFORMATION TO THE RESEARCH DEPARTMENT. BE WARNED THAT WE HAVE HAD SOME TROUBLE TODAY WITH THE CHUTES SO YOU MAY NEED TO GRAB A PLUNGER FROM THE EQUIPMENT ROOM AND USE IT TO PLUNGE OUT THE SAMPLE.\"".to_upper(), 0)
	elif not firstEnterMap[playerPos] or haveEntered[playerPos]:
		insert_text_at_caret("done. you are now {}".replace("{}",readableNamePosMap[playerPos]).to_upper(), 0)
	else:
		haveEntered[playerPos] = true
		insert_text_at_caret(firstEnterMap[playerPos].to_upper(), 0)
	if isNightSequence and playerPos not in nightSequenceCheckedRooms and day == 1:
		roomsChecked += 1
		nightSequenceCheckedRooms.append(playerPos)
		if roomsChecked >= 4:
			insert_text_at_caret("Suddenly, you feel a chill along your spine. You turn around and...".to_upper(), 0)
			await get_tree().create_timer(2).timeout
			%Jumpscare.visible = true
			visible = false
			await get_tree().create_timer(RandomNumberGenerator.new().randf_range(1,4)).timeout
			%Jumpscare.visible = false
			visible = true
			nextDay()
			playerPos = PlayerPosition.BEDROOM
			text = text.replace("Suddenly, you feel a chill along your spine. You turn around and...".to_upper(), "")
			insert_text_at_caret("You wake up in a cold sweat and hear a semi-familiar voice saying, \"WELCOME TO YOUR SECOND DAY OF HARD WORK AND PERFECTLY LEGAL LABOR. YOU SHOULD BE ABLE TO GO TO THE KITCHEN, GET SOME BREAKFAST, AND PULL UP ANOTHER SAMPLE. THIS TIME IT WILL BE FURTHER DOWN, AS THE DRILL HAS BEEN DRILLING ALL NIGHT AND THE SAMPLE MAY BE MORE DANGEROUS. PROCEED WITH CAUTION.\"".to_upper(), 0)

func give(args):
	print(args)
	if playerPos == PlayerPosition.TICKET_BOOTH:
		if "ticket" in args:
			if Items.YOUR_TICKET in inventory:
				inventory.remove_at(inventory.find(Items.YOUR_TICKET))
				roomExits[playerPos]["east"] = PlayerPosition.BEDROOM
				insert_text_at_caret("You ring the bell sitting on the desk once and the grate slides up. You cannot see anything within, but you push your ticket in and someone says in a robotic voice \"THANK YOU FOR TRAVELING WITH US. THE TRAIN SHOULD BE ARRIVING MOMENTARILY.\" As they say that, the train pulls in. You can now head east onto the train.".to_upper(), 0)
			else:
				insert_text_at_caret("You have already given your ticket!".to_upper(), 0)
		elif "dick" in args or "cock" in args or "penis" in args:
			insert_text_at_caret("...what is wrong with you?", 0)
		else:
			insert_text_at_caret("You can only give your ticket!".to_upper(), 0)
	else:
		insert_text_at_caret("There's no one around!".to_upper(), 0)

var gottenFood = false
var canSleep = false
var numberOfFoodAttempts = 0
func push(args):
	print(args)
	if playerPos == PlayerPosition.KITCHEN:
		if "button" in args:
			if not gottenFood:
				inventory.append(Items.FOOD)
				insert_text_at_caret("As you push the button, food spills out into a pre-prepared bowl. A robotic voice says \"THANK YOU FOR CHOOSING ANDRETIC FOOD SERVICES. YOUR NEXT MEAL WILL BE AVAILABLE IN [6] HOURS.\" You should probably now !EAT THE FOOD! and then head to the equipment room.".to_upper(), 0)
				gottenFood = true
			else:
				insert_text_at_caret("You try to push the button, but a robotic voice stops you. \"NOT ENOUGH TIME HAS ELAPSED FOR YOU TO HAVE ANOTHER MEAL PROVIDED TO YOU. TRY AGAIN IN [incomprehensible number] HOURS.\"".to_upper(), 0)
				numberOfFoodAttempts += 1
				if numberOfFoodAttempts>9:
					insert_text_at_caret("\nAfter pressing the button ten times without waiting, the machine refuses to give you food no matter how long you wait. You slowly starve to death, and wonder why you did that.".to_upper(), 0)
					end_game("starvation", "bad")
		else:
			insert_text_at_caret("...What are you trying to push?".to_upper(), 0)
	elif playerPos == PlayerPosition.ANALYSYS_ROOM:
		if "button" in args:
			if samplePutIn and day == 1:
				insert_text_at_caret("You press the button and the machine starts whirring. After a while you hear a loud clunk and the voice announce, \"The sample has been analysed and sent to the research department. You may now have dinner and go to sleep.\"".to_upper(), 0)
				gottenFood = false
				canSleep = true
				itemsInRooms[playerPos].remove_at(itemsInRooms[playerPos].find(Items.SAMPLE))
				samplePutIn = false
			elif samplePutIn and day == 2:
				insert_text_at_caret("You press the button and the machine starts whirring. After a while you hear a loud clunk and the voice announce, \"The sample has been analysed and sent to the research department. You may now have dinner and go to sleep.\"".to_upper(), 0)
				gottenFood = false
				canSleep = true
				itemsInRooms[playerPos].remove_at(itemsInRooms[playerPos].find(Items.SAMPLE))
				samplePutIn = false
				continueLooping = false
			elif canSleep:
				insert_text_at_caret("You've already sent off the sample!".to_upper(), 0)
			else:
				insert_text_at_caret("You need to first put the sample in!".to_upper(), 0)
		else:
			insert_text_at_caret("...What are you trying to push?".to_upper(), 0)
	else:
		insert_text_at_caret("There is nothing you can push here.".to_upper(), 0)

func eat(args):
	print(args)
	if "dick" in args or "cock" in args or "penis" in args or "pussy" in args or "ass" in args or "vagina" in args or "butt" in args:
		insert_text_at_caret("What is WRONG with you!?".to_upper(), 0) 
	elif Items.FOOD in inventory and not canSleep:
		inventory.remove_at(inventory.find(Items.FOOD))
		insert_text_at_caret("As you eat the food(which actually tastes suprisingly decent), you start to reconsider what led you to wanting to be locked in a metal box with no one else for any length of time. You then realise it was because of Dr. Madd and you being very broke. You should probably now head to the equipment room and follow the strange voice's directions.".to_upper(), 0)
	elif Items.FOOD in inventory:
		inventory.remove_at(inventory.find(Items.FOOD))
		insert_text_at_caret("You eat your dinner and ponder why this job is so high paying. You would consider leaving, but you can't as that wall is still in the way. You decide that the only thing to do is go to your bedroom and !SLEEP!.".to_upper(), 0)

func end_game(ending: String, kind: String):
	commands = {}
	insert_text_at_caret("\nYou have reached an ending. This is the {} ending, and is classified as a [] ending. You can play again by restarting the game.".replace("{}", ending).replace("[]", kind), 0)

func grab(args):
	if playerPos not in itemsInRooms.keys():
		insert_text_at_caret("That item isn't in the room!".to_upper(), 0)
		return
	if len(args)<1:
		insert_text_at_caret("You need to specify what to grab!".to_upper(), 0)
		return
	for item in idItemMap.values():
		if item in args:
			args[0] = item
			break
	if args[0] in idItemMap.values():
		if reverseidItemMap[args[0]] in itemsInRooms[playerPos]:
			if playerPos not in regeneratingItemRooms:
				itemsInRooms[playerPos].remove_at(itemsInRooms[playerPos].find(reverseidItemMap[args[0]]))
			inventory.append(reverseidItemMap[args[0]])
			insert_text_at_caret("Grabbed.".to_upper(), 0)
		else:
			insert_text_at_caret("That item isn't in the room!".to_upper(), 0)
	else:
		insert_text_at_caret("That isn't an item!".to_upper(), 0)

var coolingGelPoured = false
var drillBitPutIn = false
var drillRodAttached = false
var numMaintenceToDo = 0
var alreadyDrilled = false

func pour(args):
	if len(args)<1:
		insert_text_at_caret("You need to specify what to pour!".to_upper(), 0)
		return
	if args[0] in idItemMap.values():
		if reverseidItemMap[args[0]] in inventory:
			if playerPos == PlayerPosition.EXTRACTION_ROOM:
				if reverseidItemMap[args[0]] == Items.COOLING_GEL:
					if not coolingGelPoured:
						inventory.remove_at(inventory.find(reverseidItemMap[args[0]]))
						coolingGelPoured = true
						numMaintenceToDo += 1
						insert_text_at_caret("Cooling gel poured in. {}/3 maintence tasks to do.".replace("{}", str(numMaintenceToDo)).to_upper(), 0)
					else:
						insert_text_at_caret("You've already done that!".to_upper(), 0)
				elif reverseidItemMap[args[0]] == Items.FOOD:
					insert_text_at_caret("Don't waste food!".to_upper(),0)
				else:
					insert_text_at_caret("You can't pour that!".to_upper(), 0)
			else:
				insert_text_at_caret("Why would you pour that there?".to_upper(), 0)
		else:
			insert_text_at_caret("That item isn't in your inventory!".to_upper(), 0)
	else:
		insert_text_at_caret("That isn't an item!".to_upper(), 0)

var samplePutIn = false

func put(args):
	if len(args)<1:
		insert_text_at_caret("You need to specify what to put in!".to_upper(), 0)
		return
	if args[0] in idItemMap.values():
		if reverseidItemMap[args[0]] in inventory:
			if playerPos == PlayerPosition.EXTRACTION_ROOM:
				if reverseidItemMap[args[0]] == Items.DRILL_BIT:
					if not drillBitPutIn:
						inventory.remove_at(inventory.find(reverseidItemMap[args[0]]))
						drillBitPutIn = true
						numMaintenceToDo += 1
						insert_text_at_caret("Drill bit put in. {}/3 maintence tasks to do.".replace("{}", str(numMaintenceToDo)).to_upper(), 0)
					else:
						insert_text_at_caret("You've already done that!".to_upper(), 0)
				else:
					insert_text_at_caret("Why would you do that?".to_upper(),0)
			elif playerPos == PlayerPosition.ANALYSYS_ROOM:
				if reverseidItemMap[args[0]] == Items.SAMPLE:
					inventory.remove_at(inventory.find(reverseidItemMap[args[0]]))
					samplePutIn = true
					insert_text_at_caret("You put the sample in to the machine. Now you need to !PUSH THE BUTTON!.".to_upper(), 0)
				else:
					insert_text_at_caret("Why would you do that?".to_upper(),0)
			else:
				insert_text_at_caret("Why would you put that there?".to_upper(), 0)
		else:
			insert_text_at_caret("That item isn't in your inventory!".to_upper(), 0)
	else:
		insert_text_at_caret("That isn't an item!".to_upper(), 0)

func attach(args):
	if len(args)<1:
		insert_text_at_caret("You need to specify what to attach!".to_upper(), 0)
		return
	if args[0] in idItemMap.values():
		if reverseidItemMap[args[0]] in inventory:
			if playerPos == PlayerPosition.EXTRACTION_ROOM:
				if reverseidItemMap[args[0]] == Items.DRILL_ROD:
					if not drillRodAttached:
						if drillBitPutIn:
							inventory.remove_at(inventory.find(reverseidItemMap[args[0]]))
							drillRodAttached = true
							numMaintenceToDo += 1
							insert_text_at_caret("Drill rod attached. {}/3 maintence tasks to do.".replace("{}", str(numMaintenceToDo)).to_upper(), 0)
						else:
							insert_text_at_caret("You need to first put in the drill bit.".to_upper(), 0)
					else:
						insert_text_at_caret("You've already done that!".to_upper(), 0)
				else:
					insert_text_at_caret("Why would you do that?".to_upper(),0)
			else:
				insert_text_at_caret("Why would you attach that there?".to_upper(), 0)
		else:
			insert_text_at_caret("That item isn't in your inventory!".to_upper(), 0)
	else:
		insert_text_at_caret("That isn't an item!".to_upper(), 0)

func activate(_args):
	if playerPos == PlayerPosition.EXTRACTION_ROOM and day == 1 and not alreadyDrilled and coolingGelPoured and drillBitPutIn and drillRodAttached:
		insert_text_at_caret("After activating the drill, you hear a different voice. \"THANK YOU FOR USING PLANKTON DRILLING'S NEW HYPERDRILL 2000,\" the voice says, \"THIS STATE-OF-THE-ART MODEL OUTPUTS ROUGHLY 5 CM CUBED SAMPLES INTO A CONTAINMENT TANK. THIS TANK IS DESIGNED TO HOLD UP TO 500 PASCALS OF FORCE, AND IS MADE OF TITANIUM SURROUNDED BY STEEL.\"\nAfter a couple of minutes of this kind of talk, the voice finally announces, \"THE SAMPLE IS READY.\"".to_upper(), 0)
		insert_text_at_caret("\n\nThe first voice then says, \"YOU MAY NOW !GRAB THE SAMPLE! AND BRING IT TO THE ANALYSIS ROOM.\"".to_upper(), 0)
		itemsInRooms[PlayerPosition.EXTRACTION_ROOM].append(Items.SAMPLE)
		alreadyDrilled = true
	elif playerPos == PlayerPosition.EXTRACTION_ROOM and day == 2 and not alreadyDrilled and coolingGelPoured and drillBitPutIn and drillRodAttached:
		insert_text_at_caret("After activating the drill, you hear something very similar to yesterday. \"THANK YOU FOR USING PLANKTON DRILLING'S NEW HYPERDRILL 2000,\" the voice says, as well as everything else from the previous day.\nAfter a couple of minutes of this kind of talk, the voice finally announces, \"THE SAMPLE IS READY.\" and the normal voice says \"WARNING: THE SAMPLE MAY BE MORE DANGEROUS THEN ANTICIPATED. PLEASE PROCEED WITH CAUTION.\"".to_upper(), 0)
		%Scratching.playing = true
		%Scratching.finished.connect(loop)
	elif playerPos == PlayerPosition.EXTRACTION_ROOM and alreadyDrilled:
		insert_text_at_caret("As you try, you find it won't let you. You decide to give up for now.".to_upper(), 0)
	else:
		insert_text_at_caret("You aren't even in the extraction room!".to_upper(), 0)

var continueLooping = true
func loop():
	if continueLooping:
		%Scratching.playing = true
	else:
		continueLooping = true

func nextDay():
	commands = {}
	insert_text_at_caret("Sorry, but this is the end of the game so far. Lemme know what you think!", 0)
	return
	numberOfFoodAttempts = 0
	numMaintenceToDo = 0
	samplePutIn = false
	coolingGelPoured = false
	drillBitPutIn = false
	drillRodAttached = false
	gottenFood = false
	alreadyDrilled = false
	canSleep = false
	day += 1
	isNightSequence = false
var isNightSequence = false
var roomsChecked = 0
func startNightSequence():
	numberOfFoodAttempts = 0
	numMaintenceToDo = 0
	samplePutIn = false
	coolingGelPoured = false
	drillBitPutIn = false
	drillRodAttached = false
	gottenFood = false
	alreadyDrilled = false
	canSleep = true
	isNightSequence = true
	roomsChecked = 0
	nightSequenceCheckedRooms = 0

func sleep(_args):
	if canSleep and playerPos == PlayerPosition.BEDROOM and day == 1 and not isNightSequence:
		insert_text_at_caret("You lie down in your bed and fall asleep.......\n\n\n\n\n\n\n\n\nSuddenly, you are jolted awake by something. You should probably go check in each room, to be safe.".to_upper(), 0)
		startNightSequence()
	elif canSleep and playerPos == PlayerPosition.BEDROOM and isNightSequence:
		insert_text_at_caret("You lie down in your bed and fall asleep...", 0)
		numNightSequencesSkipped += 1
		nextDay()
		

var commands = {
	"cmd_go": go,
	"north": func (_args): go(["north"]),
	"south": func (_args): go(["south"]),
	"east": func (_args): go(["east"]),
	"west": func (_args): go(["west"]),
	"cmd_give": give,
	"cmd_push": push,
	"cmd_eat": eat,
	"cmd_grab": grab,
	"cmd_pour": pour,
	"cmd_put": put,
	"cmd_attach": attach,
	"cmd_activate": activate,
	"cmd_sleep": sleep,
	"cmd_shader": func (_args): %"Post-Processing".visible = not %"Post-Processing".visible
}
const synonyms = {
	"go": "cmd_go",
	"move": "cmd_go",
	"n": "north",
	"s": "south",
	"e": "east",
	"w": "west",
	"give": "cmd_give",
	"your": "",
	"push": "cmd_push",
	"eat": "cmd_eat",
	"the": "",
	"container": "",
	"of": "",
	"cooling": "",
	"a": "",
	"drill": "",
	"in": "",
	"grab": "cmd_grab",
	"get": "cmd_grab",
	"take": "cmd_grab",
	"pour": "cmd_pour",
	"put": "cmd_put",
	"attach": "cmd_attach",
	"activate": "cmd_activate",
	"sleep": "cmd_sleep",
	"shader": "cmd_shader",
	"press": "cmd_push",
}

enum Items {
	YOUR_TICKET,
	FOOD,
	DRILL_BIT,
	DRILL_ROD,
	COOLING_GEL,
	SAMPLE
}
const readableNameItemMap = {
	Items.YOUR_TICKET: "YOUR TICKET",
	Items.FOOD: "SOME KIND OF BARELY EDIBLE FOOD",
	Items.DRILL_BIT: "A DRILL BIT",
	Items.DRILL_ROD: "A DRILL ROD",
	Items.COOLING_GEL: "A CONTAINER OF COOLING GEL",
	Items.SAMPLE: "A CONTAINER WITH A SAMPLE IN IT"
}
const idItemMap = {
	Items.YOUR_TICKET: "ticket",
	Items.FOOD: "food",
	Items.DRILL_BIT: "bit",
	Items.DRILL_ROD: "rod",
	Items.COOLING_GEL: "gel",
	Items.SAMPLE: "sample"
}
const reverseidItemMap = {
	"ticket": Items.YOUR_TICKET,
	"food": Items.FOOD,
	"bit": Items.DRILL_BIT,
	"rod": Items.DRILL_ROD,
	"gel": Items.COOLING_GEL,
	"sample": Items.SAMPLE
}
var inventory: Array[Items] = [
	Items.YOUR_TICKET
]

var day = 1

func _ready():
	grab_focus()
	set_caret_column(2, true, 0)
	insert_text_at_caret("The Drill version {}\n".replace("{}", Constants.VERSION).to_upper(), 0)
	insert_text_at_caret("Hint: words in exclamation marks !LIKE THESE! mean they are a command that you can run\nAlso, you can run !SHADER! to toggle on and off the shader.\n".to_upper(), 0)
	insert_text_at_caret("You have just woken up in a train station with your neck and head hurting, and after sleeping on a bench after your ticket declined and Dr. Madd told you you had to wait until the morning, who can blame you? Okay, okay, let me back up. Your life has been sad and lonely, until you met Dr. A.M. Madd. He saw something in you, and let you be a part of a privlidged underground facility meant to help further the study of the Earth. The hours are not great, and you will be living alone for weeks-months at a time, but the pay is amazing. If you do well for just the first 4 days, you will have enough money to pursue your interest in extreme ironing. You will even have enough money to hold out until your dreams pay off, as long as you don't stress eat 5 pounds of spaghetti in one sitting, which you have been known to do.\n\
You should probably !GO NORTH! to the ticket booth and !GIVE YOUR TICKET!\n> ".to_upper(), 0)
	oldText = text

func _input(event):
	if event is InputEventKey and event.is_action_pressed("enter"):
		realText = text.replace(oldText,"")
		parseInput()
		oldText = text
		realText = ""

var toldActivateMessage = false

func parseInput():
	insert_text_at_caret("\n", 0)
	editable = false
	var parsedInput = realText.to_lower().split(" ")
	if parsedInput[0] == "\n>":
		parsedInput.remove_at(0)
	var newParsedInput = parsedInput
	var i = 0
	for word in parsedInput:
		print(word)
		for synonym in synonyms.keys():
			print(synonym)
			print(synonyms[synonym])
			if word == synonym:
				newParsedInput[i] = synonyms[synonym]
				break
		i += 1
	print(newParsedInput)
	parsedInput = newParsedInput
	await get_tree().create_timer(1).timeout
	for word in parsedInput:
		if word in commands.keys():
			commands[word].call(parsedInput.slice(1))
			break
	if day == 1 and numMaintenceToDo>=3 and not toldActivateMessage:
		insert_text_at_caret("You hear the voice again. \"GOOD JOB. YOU HAVE SUCCESSFULLY PERFORMED THE BASIC MAINTENCE AND GOTTEN THE DRILL FULLY FUNCTIONING. YOU ARE NOW READY TO !ACTIVATE THE DRILL!, AND IT SHOULD SPIT UP A SAMPLE IN TO THE CHAMBER. AFTER THAT I WILL TALK TO YOU AGAIN.\"".to_upper(), 0)
		toldActivateMessage = true
	if playerPos != PlayerPosition.KITCHEN and numberOfFoodAttempts>2:
		numberOfFoodAttempts -= 1
	editable = true
	print(realText)
	insert_text_at_caret("\n> ", 0)
	oldText = text
