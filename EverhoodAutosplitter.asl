/*
* Everhood Autosplitter (by DeamonHunter)
*
* Special Thanks:
*  - Ero#1111 for making a script to find Unity's Scenemanager (Post: https://discord.com/channels/144133978759233536/144135003209596928/886305027466096700)
*  - Micrologist#2351 for documenting the offset to a scenes buildIndex (Post: https://discord.com/channels/144133978759233536/144134231201808385/845533849727533067)
*
* If someone wants to, here is a list of things that could be improved:
* - Starting on the difficulty selection.
* - Finishing without using a stopwatch. (This alone would remove a bunch of complexity.)
* - Fix up Incinerator/Dr Orange splits (Both of these don't cause a scene change.)
*/

state("Everhood") {
	int sceneCount : "UnityPlayer.dll", 0x15AFD28, 0x18; //SceneManager.sceneCount
	int buildIndex  : "UnityPlayer.dll", 0x15AFD28, 0x28, 0x0, 0x98; //SceneManager.scenes[0].buildIndex
}

startup {
	//Variables setup
	vars.originalOffset = timer.Run.Offset;	//Make sure we don't accidentally destroy an offset

	// Splitting Checks
	vars.haveArm = false;
	vars.preArmChecks = new Dictionary<int, Tuple<string, int>>(); //Checks before Arm has been gotten.
	vars.postArmChecks = new Dictionary<int, Tuple<string, int>>(); //Checks after Arm has been gotten.
	vars.requireArmChecks = new Dictionary<int, Tuple<string, int>>(); //Checks that absolutely require the arm to have been gotten.
	vars.creditChecks = new Dictionary<int, Tuple<string, int, int>>(); //Checks that are credits and thus need to wait until the scene has loaded properly
	vars.preArmChecksDone = new HashSet<string>();
	vars.postArmChecksDone = new HashSet<string>();

	// Credits delay
	vars.waitingOnCredit = Tuple.Create((string)null, -1, -1);
	vars.Stopwatch = new Stopwatch();

	//Settings
	settings.Add("Pre-Arm", true, "Pre-Arm");
	settings.Add("Tutorial", true, "Tutorial Area", "Pre-Arm");
	settings.Add("TutorialFrog", true, "Defeat Frog Armless.", "Tutorial");
	settings.Add("ATMFight", true, "Defeat ATM Armless.", "Tutorial");
	settings.Add("ZiggFight", true, "Defeat Zigg Armless.", "Tutorial");
	settings.Add("Incinerator", true, "Defeat Incinerator 2.", "Tutorial");
	settings.Add("PostMortem", true, "Complete Post Mortem.", "Tutorial");
	settings.Add("Gnomes", true, "Complete Gnomes.", "Tutorial");

	settings.Add("Circus+Forest", true, "Circus + Forest", "Pre-Arm");
	settings.Add("KartRace", true, "Finish Kart Race.", "Circus+Forest");
	settings.Add("GreenMage", true, "Defeat Green Mage Armless.", "Circus+Forest");
	settings.Add("EnterLab", false, "Get dragged into the Lab.", "Circus+Forest");
	settings.Add("Grundall", true, "Defeat Grundall Armless.", "Circus+Forest");
	settings.Add("Masterpiece", false, "Defeat Masterpiece.", "Circus+Forest");
	settings.Add("LeaveLab", true, "Leave the Lab.", "Circus+Forest"); //Todo: Make it a check for defeating Orange. (Note: Defeating Orange has no level transition)

	settings.Add("DND", true, "DND", "Pre-Arm");
	settings.Add("StartDND", false, "Start DND.", "DND");
	settings.Add("Goblin", true, "Defeat Goblin.", "DND");
	settings.Add("RastaDND", true, "Defeat Rasta.", "DND");
	settings.Add("DarkKnight", true, "Defeat Dark Knight.", "DND");
	settings.Add("RoboFlan", true, "Defeat Flan Mech.", "DND");
	settings.Add("RedWraith", true, "Defeat Red Wraith.", "DND");

	settings.Add("Castle", true, "Castle", "Pre-Arm");
	settings.Add("Cart", true, "Get through minecart Tunnel.", "Castle");
	settings.Add("FlanAndMuck", true, "Defeat Flan and Muck Armless.", "Castle");
	settings.Add("ExitMaze", false, "Exit the Maze.", "Castle");
	settings.Add("ExitCastle", true, "Exit the Castle.", "Castle");

	settings.Add("TheEnd", true, "The End?", "Pre-Arm");
	settings.Add("Zob", true, "Defeat Zob Armless.", "TheEnd");
	settings.Add("Rob", true, "Defeat Rob Armless.", "TheEnd");
	settings.Add("PurpleMage", true, "Defeat Purple Mage Armless.", "TheEnd");
	settings.Add("GoldPig", true, "Defeat Gold Pig Armless.", "TheEnd");
	settings.Add("Frog2", true, "Complete the Arm Tutorial.", "TheEnd");

	settings.Add("Post-Arm", true, "Post-Arm");
	settings.Add("Pacifist", true, "Pacifist Ending", "Post-Arm");
	settings.Add("ExitForest", true, "Exit the Forest after getting Pacifist Trigger.", "Pacifist");
	settings.Add("FrogWrath", false, "Defeat the Angry Frog.", "Pacifist");
	settings.Add("PacifistCredits", true, "Get Pacifist Credits.", "Pacifist");

	settings.Add("CircusNightClub", true, "(Genocide) Circus and Night Club", "Post-Arm");
	settings.Add("VampireArm", true, "Kill the name-changing Vampire.", "CircusNightClub");
	settings.Add("ZiggArm", true, "Kill Zigg.", "CircusNightClub");
	settings.Add("HigherBeings", true, "Get past the Heigher Beings.", "CircusNightClub");

	settings.Add("MidnightTown", true, "(Genocide) Midnight Town", "Post-Arm");
	settings.Add("RastaArm", true, "Kill Rasta.", "MidnightTown");
	settings.Add("TrashCanArm", true, "Kill the Trash Can.", "MidnightTown");
	settings.Add("Shopkeeper", true, "Kill the Shopkeeper.", "MidnightTown");
	settings.Add("GreenMage1Arm", false, "Attempt to the Green Mage the first time.", "MidnightTown");
	settings.Add("GreenMage2Arm", true, "Kill the Green Mage.", "MidnightTown");

	settings.Add("MushroomForest", true, "(Genocide) Mushroom Forest", "Post-Arm");
	settings.Add("ForestSpirit", true, "Kill the Forest Spirit.", "MushroomForest");
	settings.Add("GrundallArm", true, "Kill Grudall.", "MushroomForest");

	settings.Add("CastleArm", true, "(Genocide) Castle", "Post-Arm");
	settings.Add("LostALotArm", true, "Kill Lost-A-Lot.", "CastleArm");
	settings.Add("CartArm", true, "Kill the Cart Ghost.", "CastleArm");
	settings.Add("ZobAndRob", true, "Kill Zob and Rob.", "CastleArm");
	settings.Add("MazeMonsterArm", true, "Kill the Maze Monster.", "CastleArm");
	settings.Add("GoldPigArm", true, "Kill Gold Pig.", "CastleArm");
	settings.Add("FlanAndMuckArm", true, "Kill Flan And Muck.", "CastleArm");
	settings.Add("CursorArm", true, "Kill your Cursor.", "CastleArm");
	settings.Add("PurpleMageArm", true, "Kill Purple Mage..", "CastleArm");

	settings.Add("Genocide", true, "Genocide Ending", "Post-Arm");
	settings.Add("Sun", true, "Defeat Sun.", "Genocide");
	settings.Add("Cube", true, "Defeat Lost Spirit's Revenge.", "Genocide");
	settings.Add("Cube2", true, "Defeat Universe.", "Genocide");
	settings.Add("Buddah", false, "Defeat Buddah.", "Genocide");
	settings.Add("GenocideCredits", true, "Get Genocide Credits.", "Genocide");

	settings.Add("Extras", true, "(All Fights) The Extra fights");
	settings.Add("ATMArm", true, "Kill ATM.", "Extras");
	settings.Add("CakeRace", true, "Complete the Maze and win a Cake.", "Extras");
	settings.Add("SuperRacket", true, "Complete Super Racket.", "Extras");
	settings.Add("LightningMan", true, "Defeat the Lightning Man.", "Extras");
	settings.Add("SlimMushroom", true, "Defeat Brown Slim Mushroom.", "Extras");
	settings.Add("JumpRope", true, "Defeat Jump Rope.", "Extras");
	settings.Add("CatGod", true, "Defeat Cat God.", "Extras");
	settings.Add("SuperRacket2", true, "Complete Super Racket 2.", "Extras");
	settings.Add("DevGnomes", true, "Defeat Dev Gnomes.", "Extras");


	// Setting up triggers
	var cBI = (Func<string, int, Tuple<string, int>>)(
		(settingKey, levelToCheck) => {return Tuple.Create(settingKey, levelToCheck);
		});

	//Tutorial (Pre-Arm)
	vars.preArmChecks.Add(64, cBI("TutorialFrog", 7));
	vars.preArmChecks.Add(65, cBI("ATMFight", 9));
	vars.preArmChecks.Add(66, cBI("ZiggFight", 10));

	vars.preArmChecks.Add(19, cBI("PostMortem", 17));
	vars.preArmChecks.Add(20, cBI("Gnomes", 16));
	vars.preArmChecks.Add(15, cBI("Incinerator", 12));

	//Circus + Forest (Pre-Arm)
	vars.preArmChecks.Add(94, cBI("KartRace", 39));
	vars.preArmChecks.Add(67, cBI("GreenMage", 85));
	vars.preArmChecks.Add(58, cBI("EnterLab", 63));
	vars.preArmChecks.Add(48, cBI("Grundall", 63));
	vars.preArmChecks.Add(73, cBI("Masterpiece", 63));
	vars.preArmChecks.Add(63, cBI("LeaveLab", 58));

	//DND (Pre-Arm)
	vars.preArmChecks.Add(46, cBI("StartDND", 104));
	vars.preArmChecks.Add(96, cBI("Goblin", 101));
	vars.preArmChecks.Add(76, cBI("RastaDND", 102));
	vars.preArmChecks.Add(98, cBI("DarkKnight", 102));
	vars.preArmChecks.Add(97, cBI("RoboFlan", 108));
	vars.preArmChecks.Add(99, cBI("RedWraith", 109));

	//Castle (Pre-Arm)
	vars.preArmChecks.Add(68, cBI("Cart", 75));
	vars.preArmChecks.Add(71, cBI("FlanAndMuck", 77));
	vars.preArmChecks.Add(78, cBI("ExitMaze", 77));
	vars.preArmChecks.Add(80, cBI("ExitCastle", 62));

	//The End? (Pre-Arm)
	vars.preArmChecks.Add(91, cBI("Zob", 57));
	vars.preArmChecks.Add(87, cBI("Rob", 57));
	vars.preArmChecks.Add(74, cBI("PurpleMage", 57));
	vars.preArmChecks.Add(27, cBI("GoldPig", 83));
	vars.preArmChecks.Add(21, cBI("Frog2", 56));

	//Pacifist Ending
    vars.requireArmChecks.Add(58, cBI("ExitForest", 62));
	vars.postArmChecks.Add(113, cBI("FrogWrath", 120));
	vars.creditChecks.Add(120, Tuple.Create("PacifistCredits", 45, 300));

	//Circus And Night Club
	vars.postArmChecks.Add(29, cBI("VampireArm", 39));
	vars.postArmChecks.Add(66, cBI("ZiggArm", 10));
	vars.postArmChecks.Add(65, cBI("ATMArm", 9));
	vars.postArmChecks.Add(28, cBI("HigherBeings", 7));

	//Midnight Town
	vars.postArmChecks.Add(54, cBI("RastaArm", 41));
	vars.postArmChecks.Add(69, cBI("TrashCanArm", 41));
	vars.postArmChecks.Add(22, cBI("Shopkeeper", 55));
	vars.postArmChecks.Add(67, cBI("GreenMage1Arm", 46));
	vars.postArmChecks.Add(35, cBI("GreenMage2Arm", 46));

	//Mushroom Forest
	vars.postArmChecks.Add(25, cBI("ForestSpirit", 58));
	vars.postArmChecks.Add(48, cBI("GrundallArm", 44));

	//Castle
	vars.postArmChecks.Add(61, cBI("LostALotArm", 60));
	vars.postArmChecks.Add(68, cBI("CartArm", 75));
	vars.postArmChecks.Add(117, cBI("ZobAndRob", 77));
	vars.postArmChecks.Add(81, cBI("MazeMonsterArm", 78));
	vars.postArmChecks.Add(27, cBI("GoldPigArm", 79));
	vars.postArmChecks.Add(52, cBI("FlanAndMuckArm", 77));
	vars.postArmChecks.Add(31, cBI("CursorArm", 77));
	vars.postArmChecks.Add(74, cBI("PurpleMageArm", 82));

	//Genocide Path
	vars.postArmChecks.Add(14, cBI("Sun", 34));
	vars.postArmChecks.Add(34, cBI("Cube", 118));
	vars.postArmChecks.Add(106, cBI("Cube2", 24));
	vars.postArmChecks.Add(93, cBI("Buddah", 8));
	vars.creditChecks.Add(8, Tuple.Create("GenocideCredits", 45, 3225));

	//Extras
	vars.postArmChecks.Add(38, cBI("SuperRacket", 37));
	vars.postArmChecks.Add(40, cBI("CakeRace", 39));
	vars.postArmChecks.Add(33, cBI("LightningMan", 55));
	vars.postArmChecks.Add(72, cBI("SlimMushroom", 58));
	vars.postArmChecks.Add(116, cBI("JumpRope", 115));
	vars.postArmChecks.Add(114, cBI("DevGnomes", 45));
	vars.postArmChecks.Add(32, cBI("SuperRacket2", 26));

	//Cat God has two individual ways to complete it. (You can kill it and get a cutscene, or you can fail and be dumped into the world.)
	vars.preArmChecks.Add(13, cBI("CatGod", 111));
	vars.postArmChecks.Add(13, cBI("CatGod", 112));
}

start {
	vars.haveArm = false;
	vars.waitingOnCredit = Tuple.Create((string)null, -1, -1);
	vars.preArmChecksDone.Clear();
	vars.postArmChecksDone.Clear();
	vars.Stopwatch.Stop();

	if (old.buildIndex == 3 && current.buildIndex == 4) {
		//Set an offset just as we start so that we can have the timer
		//Also try to make sure we don't accidentally destroy an offset
		var startOffset = TimeSpan.FromSeconds(10);
		if (startOffset != timer.Run.Offset) {
			vars.originalOffset = timer.Run.Offset;
			timer.Run.Offset = startOffset;
		}
		return true;
	}
	return false;
}

split {
	/*
	* Credits need a bit of special work:
	* 1. Needs the right transition to occur.
	* 2. After transition occurs, it needs to wait until the scene is loaded.
	* 3. After the scene is loaded, there is a bit more time before the credits visually show. (300ms for Pacifist and 3225ms for Genocide)
	*/

	if (vars.waitingOnCredit.Item1 != null) {
		if (current.buildIndex == vars.waitingOnCredit.Item2) {
			if (vars.Stopwatch.IsRunning) {
				if (vars.Stopwatch.Elapsed.TotalMilliseconds >= vars.waitingOnCredit.Item3) {
					vars.Stopwatch.Stop();
					vars.waitingOnCredit = Tuple.Create((string)null, -1, -1);
					vars.postArmChecksDone.Add(vars.waitingOnCredit.Item1);
					return true;
				}
				return false;
			}

			if (current.sceneCount <= 1) {
				vars.Stopwatch.Restart();
				return false;
			}

			return false;
		}
		vars.waitingOnCredit = Tuple.Create((string)null, -1, -1);
		vars.Stopwatch.Stop();
	}

	if (old.buildIndex != current.buildIndex) {
		Tuple<string, int> levelToCheck;

		//Before Arm Checks
		if (vars.preArmChecks.TryGetValue(old.buildIndex, out levelToCheck)) {
			var name = levelToCheck.Item1;
			var index = levelToCheck.Item2;
			if (settings[name] && index == current.buildIndex && !vars.preArmChecksDone.Contains(name)){
				if (name == "Frog2") //Manual extra check so that pacifist splits don't split early.
					vars.haveArm = true;

				vars.preArmChecksDone.Add(name);
				return true;
			}
		}

		//After Arm Checks
		if (vars.postArmChecks.TryGetValue(old.buildIndex, out levelToCheck)) {
			var name = levelToCheck.Item1;
			var index = levelToCheck.Item2;
			if (settings[name] && index == current.buildIndex && !vars.postArmChecksDone.Contains(name)) {
				vars.haveArm = true;
				vars.postArmChecksDone.Add(name);
				return true;
			}
		}

		//Required Arm Checks
		if (vars.haveArm && vars.requireArmChecks.TryGetValue(old.buildIndex, out levelToCheck)) {
			var name = levelToCheck.Item1;
			var index = levelToCheck.Item2;
			if (settings[name] && index == current.buildIndex && !vars.postArmChecksDone.Contains(name)) {
				vars.haveArm = true;
				vars.postArmChecksDone.Add(name);
				return true;
			}
		}

		//Credits Checks
		Tuple<string, int, int> creditCheck;
		if (vars.creditChecks.TryGetValue(old.buildIndex, out creditCheck)) {
			var name = creditCheck.Item1;
			var index = creditCheck.Item2;
			var time = creditCheck.Item3;
			if (settings[name] && index == current.buildIndex && !vars.postArmChecksDone.Contains(name)) {
				vars.waitingOnCredit = creditCheck;
				return false;
			}
		}
	}

	return false;
}

reset {
	if (old.buildIndex == 3 && current.buildIndex == 4 || old.buildIndex == 4 && current.buildIndex == 3) {
		timer.Run.Offset = vars.originalOffset; //Try to make sure we don't completely destroy offsets.
		return true;
	}

	return false;
}

shutdown {
	timer.Run.Offset = vars.originalOffset; //Try to make sure we don't completely destroy offsets.
}

isLoading {
	//If sceneCount > 1 then Unity is loading another screen and Everhood only ever loads using this method.
	return current.sceneCount > 1;
}
