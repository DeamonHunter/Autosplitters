state("Everhood") {}

startup
{
	vars.Log = (Action<object>)(output => print("[Everhood] " + output));
	vars.OriginalOffset = timer.Run.Offset;
	vars.CompletedSplits = new HashSet<string>();
	vars.Items = new HashSet<string>();

	#region Settings
	dynamic[,] sett =
	{
		{ null, "Pre-Arm", true, "Pre-Arm" },
			{ "Pre-Arm", "Tutorial", true, "Tutorial Area" },
				{ "Tutorial", "064-007-pre", true, "Defeat Frog Armless." },
				{ "Tutorial", "065-009-pre", true, "Defeat ATM Armless." },
				{ "Tutorial", "066-010-pre", true, "Defeat Zigg Armless." },
				{ "Tutorial", "015-012-pre", true, "Defeat Incinerator 2." },
				{ "Tutorial", "019-017-pre", true, "Complete Post Mortem." },
				{ "Tutorial", "020-016-pre", true, "Complete Gnomes." },

			{ "Pre-Arm", "Circus+Forest", true, "Circus + Forest" },
				{ "Circus+Forest", "094-039-pre",  true, "Finish Kart Race." },
				{ "Circus+Forest", "067-085-pre",  true, "Defeat Green Mage Armless." },
				{ "Circus+Forest", "058-063-pre", false, "Get dragged into the Lab." },
				{ "Circus+Forest", "048-063-pre",  true, "Defeat Grundall Armless." },
				{ "Circus+Forest", "073-063-pre", false, "Defeat Masterpiece." },
				// Todo: Make it a check for defeating Orange. (Note: Defeating Orange has no level transition)
				{ "Circus+Forest", "063-058-pre",  true, "Leave the Lab." },

			{ "Pre-Arm", "DND", true, "DND" },
				{ "DND", "046-104-pre", false, "Start DND." },
				{ "DND", "096-101-pre",  true, "Defeat Goblin." },
				{ "DND", "076-102-pre",  true, "Defeat Rasta." },
				{ "DND", "098-102-pre",  true, "Defeat Dark Knight." },
				{ "DND", "097-108-pre",  true, "Defeat Flan Mech." },
				{ "DND", "099-109-pre",  true, "Defeat Red Wraith." },

			{ "Pre-Arm", "Castle", true, "Castle" },
				{ "Castle", "068-075-pre",  true, "Get through minecart Tunnel." },
				{ "Castle", "071-077-pre",  true, "Defeat Flan and Muck Armless." },
				{ "Castle", "078-077-pre", false, "Exit the Maze." },
				{ "Castle", "080-062-pre",  true, "Exit the Castle." },

			{ "Pre-Arm", "TheEnd", true, "The End?" },
				{ "TheEnd", "091-057-pre", true, "Defeat Zob Armless." },
				{ "TheEnd", "087-057-pre", true, "Defeat Rob Armless." },
				{ "TheEnd", "074-057-pre", true, "Defeat Purple Mage Armless." },
				{ "TheEnd", "027-083-pre", true, "Defeat Gold Pig Armless." },
				{ "TheEnd", "021-056-pre", true, "Complete the Arm Tutorial." },

		{ null, "Post-Arm", true, "Post-Arm" },
			{ "Post-Arm", "Pacifist", true, "Pacifist Ending" },
				{ "Pacifist", "058-062-post",    true, "Exit the Forest after getting Pacifist Trigger." },
				{ "Pacifist", "113-120-post",   false, "Defeat the Angry Frog." },
				{ "Pacifist", "PacifistCredits", true, "Get Pacifist Credits." },

			{ "Post-Arm", "CircusNightClub", true, "(Genocide) Circus and Night Club" },
				{ "CircusNightClub", "029-039-post", true, "Kill the name-changing Vampire." },
				{ "CircusNightClub", "066-010-post", true, "Kill Zigg." },
				{ "CircusNightClub", "028-007-post", true, "Get past the Heigher Beings." },

			{ "Post-Arm", "MidnightTown", true, "(Genocide) Midnight Town" },
				{ "MidnightTown", "054-041-post",  true, "Kill Rasta." },
				{ "MidnightTown", "069-041-post",  true, "Kill the Trash Can." },
				{ "MidnightTown", "022-055-post",  true, "Kill the Shopkeeper." },
				{ "MidnightTown", "067-046-post", false, "Attempt to the Green Mage the first time." },
				{ "MidnightTown", "035-046-post",  true, "Kill the Green Mage." },

			{ "Post-Arm", "MushroomForest", true, "(Genocide) Mushroom Forest" },
				{ "MushroomForest", "025-058-post", true, "Kill the Forest Spirit." },
				{ "MushroomForest", "048-044-post", true, "Kill Grudall." },

			{ "Post-Arm", "CastleArm", true, "(Genocide) Castle" },
				{ "CastleArm", "061-060-post", true, "Kill Lost-A-Lot." },
				{ "CastleArm", "068-075-post", true, "Kill the Cart Ghost." },
				{ "CastleArm", "117-077-post", true, "Kill Zob and Rob." },
				{ "CastleArm", "081-078-post", true, "Kill the Maze Monster." },
				{ "CastleArm", "027-079-post", true, "Kill Gold Pig." },
				{ "CastleArm", "052-077-post", true, "Kill Flan And Muck." },
				{ "CastleArm", "031-077-post", true, "Kill your Cursor." },
				{ "CastleArm", "074-082-post", true, "Kill Purple Mage.." },

			{ "Post-Arm", "Genocide", true, "Genocide Ending" },
				{ "Genocide", "014-034-post",    true, "Defeat Sun." },
				{ "Genocide", "034-118-post",    true, "Defeat Lost Spirit's Revenge." },
				{ "Genocide", "106-024-post",    true, "Defeat Universe." },
				{ "Genocide", "093-008-post",   false, "Defeat Buddah." },
				{ "Genocide", "GenocideCredits", true, "Get Genocide Credits." },

		{ null, "Extras", true, "(All Fights) The Extra fights" },
			{ "Extras", "065-009-post", true, "Kill ATM." },
			{ "Extras", "040-039-post", true, "Complete the Maze and win a Cake." },
			{ "Extras", "038-037-post", true, "Complete Super Racket." },
			{ "Extras", "033-055-post", true, "Defeat the Lightning Man." },
			{ "Extras", "072-058-post", true, "Defeat Brown Slim Mushroom." },
			{ "Extras", "116-115-post", true, "Defeat Jump Rope." },
			{ "Extras", "013-111-pre",  true, "Defeat Cat God." }, // fuck
			{ "Extras", "013-112-post", true, "Defeat Cat God." }, // why
			{ "Extras", "032-026-post", true, "Complete Super Racket 2." },
			{ "Extras", "114-045-post", true, "Defeat Dev Gnomes." }
	};

	for (int i = 0; i < sett.GetLength(0); ++i)
		settings.Add(sett[i, 1], sett[i, 2], sett[i, 3], sett[i, 0]);
	#endregion

	#region Credits Delays
	vars.Stopwatch = new Stopwatch();
	vars.CreditsDelay = new ExpandoObject();
	vars.CreditsDelay.Reset = (Action)(() =>
	{
		vars.CreditsDelay.Name = default(string);
		vars.CreditsDelay.Index = -1;
		vars.CreditsDelay.Time = -1;
		vars.Stopwatch.Reset();
	});
	vars.CreditsDelay.Reset();
	#endregion

	#region Split Checks
	vars.HasArm = false;
	vars.CreditsChecks = new Dictionary<int, dynamic[]>
	{
		{ 120, new dynamic[] { "PacifistCredits", 45, 0300 } },
		{ 008, new dynamic[] { "GenocideCredits", 45, 3225 } },
	};
	#endregion

	#region XML Parsing
	var MONO_VER = "mono_v2_x64";
	var xml = System.Xml.Linq.XDocument.Parse(File.ReadAllText(@"Components\" + MONO_VER + ".xml")).Element("mono");
	vars.Script = xml.Element("script").Elements().ToDictionary(e => e.Name, e => e.Value);
	vars.Engine = xml.Element("engine").Elements().ToDictionary(e => e.Name, e => e.Elements().ToDictionary(_e => _e.Name, _e => Convert.ToInt32(_e.Value, 16)));
	#endregion
}

init
{
	#region User Data
	var mainImage = "Assembly-CSharp";
	var classes = new Dictionary<string, int>
	{
		{ "EverhoodGameData", 0 },
			{ "LocalData", 0 }
	};
	#endregion

	vars.TaskCompleted = false;
	vars.CancelSource = new CancellationTokenSource();
	System.Threading.Tasks.Task.Run(async () =>
	{ task_start: try {
		var ptrSize = game.Is64Bit() ? 0x8 : 0x4;
		var image = IntPtr.Zero;
		var mono = new Dictionary<string, dynamic>();
		var sceneManager = IntPtr.Zero;

		#region Functions
		Func<IntPtr, IntPtr> rp = ptr => game.ReadPointer(ptr);
		Func<IntPtr, int> ri = ptr => game.ReadValue<int>(ptr);
		Func<IntPtr, ushort> rus = ptr => game.ReadValue<ushort>(ptr);
		Func<IntPtr, int, string> rs = (ptr, length) => game.ReadString(ptr, length, "");

		Func<bool> getSceneManager = () =>
		{
			var unityModule = game.ModulesWow64Safe().FirstOrDefault(m => m.ModuleName == "UnityPlayer.dll");
			if (unityModule == null) return false;

			sceneManager = new SignatureScanner(game, unityModule.BaseAddress, unityModule.ModuleMemorySize).Scan(
				new SigScanTarget(11, "41 83 3E 01 4C 8D 45")
				{ OnFound = (p, _, ptr) => p.Is64Bit() ? ptr + 0x4 + p.ReadValue<int>(ptr) : p.ReadPointer(ptr) });

			return sceneManager != IntPtr.Zero;
		};

		Func<bool> getMainImage = () =>
		{
			var monoModule = game.ModulesWow64Safe().FirstOrDefault(m => m.ModuleName == vars.Script["Module"]);
			if (monoModule == null) return false;

			var loaded_images = new SignatureScanner(game, monoModule.BaseAddress, monoModule.ModuleMemorySize).Scan(
				new SigScanTarget(int.Parse(vars.Script["SigOffset"]), vars.Script["SigPattern"])
				{ OnFound = (p, _, ptr) => p.Is64Bit() ? ptr + 0x4 + p.ReadValue<int>(ptr) : p.ReadPointer(ptr) });
			if (loaded_images == IntPtr.Zero) return false;

			var table_size = ri(rp(loaded_images) + vars.Engine["GHashTable"]["table_size"]);
			var table = rp(rp(loaded_images) + vars.Engine["GHashTable"]["table"]);
			for (var i = 0; i < table_size; ++i)
			{
				if (rs(rp(rp(table + ptrSize * i) + vars.Engine["Slot"]["key"]), 32) != mainImage) continue;
				image = rp(rp(table + ptrSize * i) + vars.Engine["Slot"]["value"]);
				return true;
			}

			return false;
		};

		Action<IntPtr, string> getFields = (klass, class_name) =>
		{
			vars.Log(string.Format("Found {0} at 0x{1}.", class_name, klass.ToString("X")));

			var field_count = ri(klass + vars.Engine["MonoClass"]["field_count"]);
			var fields = rp(klass + vars.Engine["MonoClass"]["fields"]);
			for (var i = 0; i < field_count; ++i)
			{
				var field = fields + vars.Engine["MonoClassField"]["size"] * i;
				var attrs = rus(rp(field + vars.Engine["MonoClassField"]["type"]) + vars.Engine["MonoType"]["attrs"]);
				if ((attrs & vars.Engine["MonoType"]["const_attr"]) != 0) continue;

				var isStatic = (attrs & vars.Engine["MonoType"]["static_attr"]) != 0;
				var offset = ri(field + vars.Engine["MonoClassField"]["offset"]);
				var field_name = ((string)rs(rp(field + vars.Engine["MonoClassField"]["name"]), 64)).Split('<', '>').FirstOrDefault(s => !string.IsNullOrEmpty(s));

				mono[class_name][field_name] = offset;
				vars.Log(string.Format("    {0,-6} {1,-32} // 0x{2:X3}", isStatic ? "static" : "", field_name + ";", offset));
			}
		};

		Func<bool> getClasses = () =>
		{
			mono.Clear();
			var class_count = ri(image + vars.Engine["MonoImage"]["class_cache_size"]);
			var class_cache = rp(image + vars.Engine["MonoImage"]["class_cache_table"]);

			for (var i = 0; i < class_count; ++i)
			{
				for (var klass = rp(class_cache + ptrSize * i); klass != IntPtr.Zero; klass = rp(klass + vars.Engine["MonoClass"]["next"]))
				{
					var class_name = rs(rp(klass + vars.Engine["MonoClass"]["name"]), 64);
					if (class_name == "" || !classes.ContainsKey(class_name)) continue;

					var parent = klass;
					for (var j = 0; j < classes[class_name]; ++j)
						parent = rp(parent + vars.Engine["MonoClass"]["parent"]);

					if (parent == IntPtr.Zero || rp(klass + vars.Engine["MonoClass"]["fields"]) == IntPtr.Zero) return false;

					var vtable_size = ri(parent + vars.Engine["MonoClass"]["vtable_size"]);
					var runtime_info = rp(rp(parent + vars.Engine["MonoClass"]["runtime_info"]) + vars.Engine["MonoClassRuntimeInfo"]["domain_vtables"]);
					var data = rp(runtime_info + vars.Engine["MonoVTable"]["vtable"] + ptrSize * vtable_size);

					mono[class_name] = new Dictionary<string, dynamic>();
					mono[class_name]["static"] = data;
					getFields(klass, class_name);

					if (mono.Count == classes.Count) return true;
				}
			}

			return false;
		};
		#endregion

		while (!getSceneManager())
		{
			vars.Log("SceneManager not found.");
			await System.Threading.Tasks.Task.Delay(1000, vars.CancelSource.Token);
		}

		while (!getMainImage())
		{
			vars.Log("Main image not found.");
			await System.Threading.Tasks.Task.Delay(1000, vars.CancelSource.Token);
		}

		while (!getClasses())
		{
			vars.Log("Not all classes found.");
			await System.Threading.Tasks.Task.Delay(5000, vars.CancelSource.Token);
		}

		/*******************************/
		vars.Scenes = new MemoryWatcherList
		{
			new MemoryWatcher<int>(new DeepPointer(sceneManager, 0x18)) { Name = "sceneCount" }, // SceneManager.sceneCount
			new MemoryWatcher<int>(new DeepPointer(sceneManager, 0x28, 0x0, 0x98)) { Name = "buildIndex" } // SceneManager.loadingScenes[0].buildIndex
		};

		var egd = mono["EverhoodGameData"];
		var ld = mono["LocalData"];
		vars.Data = new MemoryWatcherList
		{
			new MemoryWatcher<bool>(new DeepPointer(
				egd["static"] + egd["instance"],
				egd["data"],
				ld["killModeState"])) { Name = "killModeState" },

			new MemoryWatcher<int>(new DeepPointer(
				egd["static"] + egd["instance"],
				egd["data"],
				ld["inventoryItems"], 0x18)) { Name = "itemCount" },

			new MemoryWatcher<long>(new DeepPointer(
				egd["static"] + egd["instance"],
				egd["data"],
				ld["inventoryItems"], 0x10)) { Name = "items" },
		};

		vars.TaskCompleted = true;
		vars.Log("Mono task success.");
	}
	catch (ArgumentException) { goto task_start; }
	catch (Exception ex) { vars.Log("Mono task abort!\n" + ex); }});
}

onStart
{
	// Reset storage variables.
	vars.HasArm = false;
	vars.Items.Clear();
	vars.CompletedSplits.Clear();
	vars.CreditsDelay.Reset();
}

onReset
{
	// Reset the timer offset.
	timer.Run.Offset = vars.OriginalOffset;
}

update
{
	if (!vars.TaskCompleted) return false;

	vars.Scenes.UpdateAll(game);
	vars.Data.UpdateAll(game);

	// Just to make usage of the variables a bit easier.
	current.SceneCount = vars.Scenes["sceneCount"].Current;
	current.BuildIndex = vars.Scenes["buildIndex"].Current;
	current.ItemCount = vars.Data["itemCount"].Current;
}

start
{
	// Return early if the condition `old.BuildIndex == 3 && current.BuildIndex == 4` is false.
	if (old.BuildIndex != 3 || current.BuildIndex != 4) return;

	// The user may change their offset between runs. Save their old offset to set it back
	// after they reset.
	vars.OriginalOffset = timer.Run.Offset;
	timer.Run.Offset = TimeSpan.FromSeconds(10);
	return true;
}

split
{
	#region Item Splits
	// Check whether the player collected an item.
	if (old.ItemCount < current.ItemCount)
	{
		// I'm not sure if the game can give the user more than 1 item at once
		// or if the game could insert an item in a spot that isn't the list end.
		// To make sure, we just loop over the items list again.
		for (int i = 0; i < current.ItemCount; ++i)
		{
			// Get the address of the `_items` field of the list, add an offset to the ith item.
			var addr = vars.Data["items"].Current + 0x20 + 0x8 * i;

			// Get the item's name.
			var item = new DeepPointer((IntPtr)(addr), 0x14).DerefString(game, 32);

			// Return early if the item has already been collected once.
			if (vars.Items.Contains(item)) continue;

			vars.Items.Add(item);

			// If the item is The Arm, set a variable to represent that.
			if (item == "The Arm")
				vars.HasArm = true;

			// Split if the setting is enabled. This check needs to be in an if block,
			// otherwise the block will return early and skip any other potential items.
			var split = "item-" + item;
			vars.Log("New item: '" + split + "'.");
			if (settings[split]) return true;
		}
	}
	#endregion

	#region Scene Splits
	// Check whether the scene changed.
	if (old.BuildIndex != current.BuildIndex)
	{
		// If the credits check includes the old scene, set the vars.CreditsDelay variables.
		if (vars.CreditsChecks.TryGetValue(old.buildIndex, out check))
		{
			vars.CreditsDelay.Name = check[0];
			vars.CreditsDelay.Index = check[1];
			vars.CreditsDelay.Time = check[2];
		}

		// Split when the setting is enabled.
		var split = string.Format("{0:000}-{1:000}-{2}", old.BuildIndex, current.BuildIndex, vars.HasArm ? "post" : "pre");
		vars.Log("Scene change: '" + split + "'.");
		return settings[split];
	}
	#endregion

	#region Credits Splits
	// Return early if no credits delay is set.
	if (vars.CreditsDelay.Name == null) return;

	// Reset and return early if the current scene index is not the credits delay scene index.
	if (current.BuildIndex != vars.CreditsDelay.Index)
	{
		vars.CreditsDelay.Reset();
		return;
	}

	// Check whether the delay is running.
	if (vars.Stopwatch.IsRunning)
	{
		// Return early when the delay has not reached the target time.
		if (vars.Stopwatch.Elapsed.TotalMilliseconds < vars.CreditsDelay.Time) return;

		// Split when the delay has reached the target time.
		vars.CreditsDelay.Reset();
		vars.CompletedSplits.Add(vars.CreditsDelay.Name);
		return true;
	}

	// Restart the delay when loading finishes to check again if the scene index is correct.
	if (current.SceneCount <= 1)
		vars.Stopwatch.Restart();
	#endregion
}

reset
{
	return old.BuildIndex == 3 && current.BuildIndex == 4 ||
	       old.BuildIndex == 4 && current.BuildIndex == 3;
}

isLoading
{
	// Unity is loading when the scene count is greater than 1 (to ensure smooth transitioning).
	return current.SceneCount > 1;
}

exit
{
	// Cancel the task when it is still running.
	vars.CancelSource.Cancel();
}

shutdown
{
	// Reset the timer offset and cancel the task when it is still running.
	timer.Run.Offset = vars.OriginalOffset;
	vars.CancelSource.Cancel();
}