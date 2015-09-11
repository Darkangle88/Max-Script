
try (destroydialog MapPathSet) catch()

--Global Variable
--=======================================================================================
--=======================================================================================

--global mapTypeList = #("Ambient Color", "Diffuse Color", "Specular Color", "Specualr Level", "Glossiness", "Self-Illumination", "Opacity", "Filter Color", "Bump", "Reflection", "Refraction", "Displacement")
global MapPathSet
global UseMap = #()
global MissingMap = #()
global totalMapPathList = #() -- Store Total Map Path List(Single Array)
global totalObjectList=#() -- Store Total Objects List(Double Array)
global mapfiles=#()
global MapNameNum
global getImageFile = #()
global getfile = getfiles (maxfilepath + "*")
global getDirectory = getDirectories (maxfilepath + "\*")

--Function
--=======================================================================================
--=======================================================================================

fn RemoveMissingDLL = 
(
	-- get list of missing plugin classes
	str = stringStream ""
	
	apropos "*missing*" to:str
	seek str 0
	cls = #()
	
	while not (eof str) do 
	(
		ln = readLine str
		tk = filterString ln " "
		if tk.count == 4 then 
		(
			clsName = tk[1]
			try 
			(
				val = (execute clsName)
				sc = superClassOf val
				-- Alternative: check for .classID == #(-1,0)
				if sc==MAXWrapper or sc==node or sc==material or sc==MAXWrapperNonRefTarg then
				(
					append cls val
					format "%: %\n" c val
				) 
				else 
				(
					format "Skipping % (%)\n" val sc
				)
			) 
			catch 
			(
				format "Cannot use % for searching missing plugins.\n" clsName
			)
			
		) 
		else 
		(
			format "Incorrect string found in missing plugin name list: %\n" tk
		)
	)
	-- now search for instances of those missing plugins
	c = 0
	foundMissing = #()
	
	for j = 1 to cls.count do 
	(
		cc = cls[j]
		ci = getClassInstances cc
		if ci.count > 0 then 
		(
			format "%: Found % instances of %: %\n" j ci.count cc ci
			for i = 1 to ci.count do 
			(
				-- get current class
				myClass = classOf cc
				append foundMissing myClass
				-- get list of all subclasses
				allClasses = myClass.classes
				for k = 1 to allClasses.count do 
				(
					-- search for useful replacement
					if allClasses[k].creatable then 
					(
						-- create new instance of default (first) class
						newInst = createInstance allClasses[k]
						try 
						(
							-- replace all instances (requires 3ds Max 2008+ or AVG extensions)
							q = replaceInstances ci[i] newInst
							c += 1
							-- and exit for k loop
							exit
						) 
						catch 
						(
							format "Error replacing %\n" ci[i]
							format "Exception: %\n" (getCurrentException())
						)
					)
				) -- end: for k
				-- todo: what happens if NO useful replacement was found?
			) -- end: for i
		) -- end: if
	) -- end: for j
	
	if c > 0 then 
	(
		-- produce summary message for user
		str = "Replaced "
		append str (c as string)
		append str " missing plugin(s) with default objects:\n"
		
		for i in foundMissing do 
		(
			append str "\t"
			append str (i as string)
			append str "\n"
		)
		append str "\nUSE RESULT WITH CAUTION!\nSAVE TO A DIFFERENT FILE NAME!"
		messageBox str title:"removeMissingPlugins v0.1" beep:true
		print foundMissing
	) 
	else 
	(
		messageBox "No missing plugins found" title:"removeMissingPlugins v0.1"
	)
)

-----------------------------------------------------------------------------------------

fn wipeBitmapTextures file:"" useFullPath:off =
(
	if useFullPath do file = pathConfig.mapPaths.getFullFilePath file
		
	for tx in (getclassinstances bitmaptexture asTrackViewPick:on) where iskindof tx.anim.filename String do 
	(
		f = tx.anim.filename
		
		if useFullPath do f = pathConfig.mapPaths.getFullFilePath f
			
		if (pathConfig.pathsResolveEquivalent f file) do
		(
			for s=1 to tx.client.numsubs where tx.client[s].value == tx.anim do tx.client[s].value = undefined
		)
	)
)

-----------------------------------------------------------------------------------------

fn addmap mapfile =
(
	local mapfileN=mapfile as string
	
	local index=finditem mapfiles mapfileN
	
	if index == 0 do 
	(
		append mapfiles mapfileN
	)
)

-----------------------------------------------------------------------------------------

fn getAllMaterial = 
(
	UseMap = #()
	MissingMap = #()

	mapfiles=#()
	
	MapPathSet.lbUseMapName.items = #()
	MapPathSet.IbPathXMapO.items = #()
	MapPathSet.lbNotUseMapName.items = #()
	
	local mapPathList = getClassInstances bitmaptexture
	local PathOMapO = #()
	local PathXMapO = #()
	
	enumeratefiles addmap
	UseMap = deepcopy mapfiles
	
	mapfiles=#()

	enumeratefiles addmap #missing
	missingMap = deepcopy mapfiles
	
	for map in UseMap do
	(
		if doesFileExist map == true then
		(
			appendIfUnique PathOMapO map
		)
		else
		(
			appendIfUnique PathXMapO map
		)
	)
	
	MapPathSet.lbUseMapName.items = deepcopy PathOMapO
	MapPathSet.IbPathXMapO.items = deepcopy PathXMapO
	MapPathSet.lbNotUseMapName.items = deepcopy missingMap
)

-----------------------------------------------------------------------------------------

fn getObjectMaterial = 
(
	totalMapPathList = #()
	totalObjectList=#()
	
	local mapPathList = getClassInstances bitmaptexture
	
	for map in mapPathList do
	(
		append totalMapPathList map
		append totalObjectList #()
	)
	
	for objectNum = 1 to objects.count do
	(
		if objects[objectNum].material != undefined do
		(
			--Select Objects.Material(Standard or Multi)
			case of
			(
				(classof objects[objectNum].material == standardMaterial):
				(	
					--Search Maps
					for mapNum = 1 to objects[objectNum].mat.maps.count do
					(
						if objects[objectNum].material.maps[mapNum] != undefined do
						(
							objectArrayNum = finditem totalMapPathList (objects[objectNum].material.maps[mapNum])
							appendIfUnique totalObjectList[objectArrayNum] objects[objectNum].name
						)
					)
				)
				
			(classof objects[objectNum].material == multiMaterial):
				(
					for multiMatNum = 1 to objects[objectNum].material.count do
					(
						if objects[objectNum].material[multiMatNum] != undefined and classof objects[objectNum].material[multiMatNum] == standardMaterial then
						(
							for mapNum = 1 to objects[objectNum].material[multiMatNum].maps.count do
							(
								if objects[objectNum].material[multiMatNum].maps[mapNum] != undefined  do
								(
									objectArrayNum = finditem totalMapPathList (objects[objectNum].material[multiMatNum].maps[mapNum])
									appendIfUnique totalObjectList[objectArrayNum] objects[objectNum].name
								)
							)
						)
						else
						(
							
						)
					)
				)
			)
		)
	)
	
	for ObjectNum in totalObjectList do
	(
		if ObjectNum.count == 0 do
		(
				append ObjectNum "-None-"
		)
	)
)
-----------------------------------------------------------------------------------------

fn getFileNameInMaxPath selectName= 
(
	getImageFile = #()
	
	for getDirFirst in 1 to 50 do
	(
		if getDirectory[getDirFirst] == undefined do exit
		
		getDirectory = getDirectory + getDirectories (getDirectory[getDirFirst] + "\*")
	)

	for getImageFirst in 1 to getDirectory.count do
	(
		for First in 1 to getfile.count do
		(
			if (getFilenameFile selectName + getFilenameType selectName == getFilenameFile getfile[First] + getFilenameType getfile[First]) do
			(
				if getFilenameType getfile[First] == ".png" or getFilenameType getfile[First] == ".PNG" or  \
					getFilenameType getfile[First] == ".JPG" or getFilenameType getfile[First] == ".jpg" or getFilenameType getfile[First] == ".BMP" or getFilenameType getfile[First] == ".bmp" or \
					getFilenameType getfile[First] == ".JPEG" or getFilenameType getfile[First] == ".jpeg" or getFilenameType getfile[First] == ".TGA" or getFilenameType getfile[First] == ".tga" or \
					getFilenameType getfile[First] == ".TIFF" or getFilenameType getfile[First] == ".tiff" or getFilenameType getfile[First] == ".GIF" or getFilenameType getfile[First] == ".gif" do
				(
					appendIfUnique getImageFile getfile[First]
				)
			)
		)
		getfile = getfiles (getDirectory[getImageFirst] + "*")
	)
)

--------------------------------------------------------------------------------------

fn Changemap selectNameInList changeMapPath = 
(
	local mapPathList = getClassInstances bitmaptexture
	
	for map in mapPathList do
	(
		if map.filename == selectNameInList do
		(
			map.filename = changeMapPath
		)
	)
)

--------------------------------------------------------------------------------------
	
fn deletemap selectNameInList = 
(
	local mapPathList = getClassInstances bitmaptexture
	local defaultMtlLibFile = MeditUtilities.getDefaultLibraryFile()
	
	if defaultMtlLibFile != undefined do
	(
		defaultMtlLib = loadTempMaterialLibrary defaultMtlLibFile
	)
	
	for map in 1 to mapPathList.count do
	(
		if mapPathList[map].filename == selectNameInList do
		(
			wipeBitmapTextures file:mapPathList[map].filename
		)
	)
)

--------------------------------------------------------------------------------------


--UI
--=======================================================================================
--=======================================================================================

rollout MapPathSet "Map Path Set"
(	
	--------------------------------------------------------------------------------------
	
	ListBox lbUseMapName "Map (Path O, Map O)" width: 550 height: 8 selection:0
	ListBox IbPathXMapO "Map (Path X, Map O)" width: 550 height: 5 selection:0
	ListBox lbNotUseMapName "Missing Map / File (Path X, Map X)" offset:[0,50]width: 550 height: 8 selection:0
	
	--------------------------------------------------------------------------------------
	
	multiListBox mlbObject "Applied Object" width: 150 height: 10 align:#right offset:[0,-405] selection:0
	
	--------------------------------------------------------------------------------------
	
	button btnObjectSelect "Select Object" align:#right offset:[-5,5] width: 140
	button btnDeleteMaterialOfObject "Delete Object Material" offset:[286,0] width: 140
	button btnOpenFolderInExplorer "Open Folder In Explorer" offset:[-290,225] width: 140
	button btnDeleteMap "Delete Map Information" offset:[-135,-26] width: 140
	button btnResetAllMaterial "Reset All Material" offset:[20,-27] width: 140
	button btnFindPath "..." offset:[225,-55] width: 35
	button btnSetPath "Set Path" offset:[300,-26] width: 100
	button btnSameFilenameInMaxPath "Change Path" offset:[155,-194] width:70
	button btnRemoveMissingDLL "Remove Missing DLL" offset:[170,171]width: 140
	button btnAboutScript "About" offset:[300,-27] width: 100
	
	--------------------------------------------------------------------------------------
	
	edittext ChangeFilePath "File Path: " offset:[0,-52] width: 550
	
	--------------------------------------------------------------------------------------
	
	dropdownlist ddlSameFilenameInMaxPath "Same file name in the max file path"  width: 480 offset:[0,-210]
	
	--------------------------------------------------------------------------------------
	
	imgtag itImage  bitmap: (bitmap 145 145) offset:[570,-15]
	
	--------------------------------------------------------------------------------------
	
	label lbImage "Sample Image"  offset:[240,-167]
	
--=======================================================================================
--=======================================================================================
	
	on MapPathSet open do
	(
		getAllMaterial()
		getObjectMaterial()
	)
	
	--------------------------------------------------------------------------------------
	
	on btnRemoveMissingDLL pressed do
	(
		 rollout rollRemoveMissingDLL "Remove Missing DLL"
		(
			label labelRemoveMissingDLL "Remove Missing DLL"
			label AreYouSure "Are You Sure?"
			button btnYes "Yes" offset:[-35,3] width: 50
			button btnNo "No" offset:[30,-26.5] width: 50

			on btnYes pressed do
			(
				RemoveMissingDLL()
				destroydialog RemoveMissingDLL
			)
				
			on btnNo pressed do
			(
				destroydialog rollRemoveMissingDLL
			)
		)
		createdialog rollRemoveMissingDLL width: 200 height: 75
		
	)
	
	--------------------------------------------------------------------------------------
	on btnSameFilenameInMaxPath pressed do
	(
		if IbPathXMapO.selection !=0 and ddlSameFilenameInMaxPath.items.count > 0 then
		(
			Changemap IbPathXMapO.items[IbPathXMapO.selection] ddlSameFilenameInMaxPath.items[ddlSameFilenameInMaxPath.selection]
		)
		else
		(
			messagebox "Select Path!"
		)			
		
		IbPathXMapO.selection = 0
		
		getAllMaterial()
		getObjectMaterial()
	)
	
	--------------------------------------------------------------------------------------
	
	on btnDeleteMap pressed do
	(
		if IbPathXMapO.selection == 0 and lbUseMapName.selection == 0 and lbNotUseMapName.selection == 0 do
		(
			messagebox "Select Map!"
		)
		
		undo on
		(
			case of
			(
				(IbPathXMapO.selection !=0):
					(
						deletemap IbPathXMapO.items[IbPathXMapO.selection]
					)
				(lbUseMapName.selection != 0):
					(
						deletemap lbUseMapName.items[lbUseMapName.selection]
					)
				(lbNotUseMapName.selection != 0):
					(
						deletemap lbNotUseMapName.items[lbNotUseMapName.selection]
					)
			)
		)
		getAllMaterial()
		getObjectMaterial()
	)
	--------------------------------------------------------------------------------------
	
	on btnDeleteMaterialOfObject pressed do
	(
		clearselection()
		undo on
		(
			for i in 1 to mlbObject.items.count do
			(
				if mlbObject.selection[i]== true do
				(
					for objectName in objects where objectName.name == mlbObject.items[i] do
					(
						selectmore objectName
					)
				) 
			)
			if $ == undefined then
			(
				messagebox "Select object"
			)
			else
			(
				$.mat = undefined
			)
		)
		
		getAllMaterial()
		getObjectMaterial()
	)
	
	--------------------------------------------------------------------------------------
	
	on btnFindPath pressed do
	(
		getFilePathes = getOpenFileName caption:"Path Set "
		
		if getFilePathes != undefined do
		(
			changeFilePath.text = getFilePathes
		)
	)
	
	--------------------------------------------------------------------------------------
	
	on btnOpenFolderInExplorer pressed do
	(
		shellLaunch "explorer.exe" MapNameNum
	)
		
	--------------------------------------------------------------------------------------
	
	on IbPathXMapO selected Num do
	(
		try
		(
			itImage.bitmap = (openBitmap IbPathXMapO.items[IbPathXMapO.selection])
			
			ddlSameFilenameInMaxPath.items = #()
			
			for i in 1 to totalMapPathList.count do
			(
				if totalMapPathList[i].filename == IbPathXMapO.items[Num] do
				(
					mlbObject.items = totalObjectList[i]
				)
			)
			
			if Num != 0 do
			(
				lbUseMapName.selection = 0
				lbNotUseMapName.selection = 0
				btnOpenFolderInExplorer.enabled = false
				ddlSameFilenameInMaxPath.enabled = true
				btnSameFilenameInMaxPath.enabled = true
			)
			
			getFileNameInMaxPath IbPathXMapO.items[Num]
			
			ddlSameFilenameInMaxPath.items = getImageFile
		)
		catch()
	)
	
	--------------------------------------------------------------------------------------
	
	on lbUseMapName selected Num do
	(
		try
		(
			itImage.bitmap = (openBitmap lbUseMapName.items[lbUseMapName.selection])
			
			for i in 1 to totalMapPathList.count do
			(
				if totalMapPathList[i].filename == lbUseMapName.items[Num] do
				(
					mlbObject.items = totalObjectList[i]
				)
			)
			
			if Num != 0 do
			(
				IbPathXMapO.selection = 0
				lbNotUseMapName.selection = 0
				btnOpenFolderInExplorer.enabled = true
				ddlSameFilenameInMaxPath.enabled = false
				btnSameFilenameInMaxPath.enabled = false
				
				if (getfilesize lbUseMapName.items[Num]) > 0 then
				(
					bmShowImage.filename = lbUseMapName.items[Num]
				)
				else bmShowImage.bitmap = (bitmap 150 150) 
			)
			
			MapNameNum = Num
			MapNameNum = getFilenamePath lbUseMapName.items[Num]
		)
		catch()
	)
	
	--------------------------------------------------------------------------------------
	
	on lbNotUseMapName selected Num do
	(
		try
		(
			itImage.bitmap = (openBitmap lbNotUseMapName.items[IbPathXMapO.selection])
			
			for i in 1 to totalMapPathList.count do
			(
				if totalMapPathList[i].filename == lbNotUseMapName.items[Num] do
				(
					mlbObject.items = totalObjectList[i]
				)
			)

			if Num != 0 do
			(
				IbPathXMapO.selection = 0
				lbUseMapName.selection = 0
				btnOpenFolderInExplorer.enabled = false
				ddlSameFilenameInMaxPath.enabled = false
				btnSameFilenameInMaxPath.enabled = false
			)
		)
		catch()
	)
	
	--------------------------------------------------------------------------------------
	
	on btnObjectSelect pressed do
	(
		clearSelection()
		for i in 1 to mlbObject.items.count do
		(
			if mlbObject.selection[i]== true do
			(
				for objectName in objects where objectName.name == mlbObject.items[i] do
				(
					selectmore objectName
				)
			)
		)
	)
	
	--------------------------------------------------------------------------------------
	
	on btnResetAllMaterial pressed do
	 (
		 rollout rollResetAllMaterial "Reset All Material"
		(
			label labelResetAllMaterial "Reset All Material"
			label AreYouSure "Are You Sure?"
			button btnYes "Yes" offset:[-35,3] width: 50
			button btnNo "No" offset:[30,-26.5] width: 50

			on btnYes pressed do
			(
				undo on
				(
					macros.run "Medit Tools" "clear_medit_slots"
					
					for objectNum = 1 to objects.count do
					(
						objects[objectNum].material = undefined
					)
				)
				destroydialog rollResetAllMaterial
			)
				
			on btnNo pressed do
			(
				destroydialog rollResetAllMaterial
			)
		)
		createdialog rollResetAllMaterial width: 150 height: 75
		
		getAllMaterial()
		getObjectMaterial()
	 )
	
	--------------------------------------------------------------------------------------
	 
	on btnSetPath pressed do
	(
		if ChangeFilePath.text != "" then
		(
			undo on
			(
				case of
				(
					(IbPathXMapO.selection !=0):
						(
							ChangeMap IbPathXMapO.items[IbPathXMapO.selection] ChangeFilePath.text
							IbPathXMapO.selection = 0
						)
					(lbUseMapName.selection != 0):
						(
							ChangeMap lbUseMapName.items[lbUseMapName.selection] ChangeFilePath.text
							lbUseMapName.selection = 0
						)
					(lbNotUseMapName.selection != 0):
						(
							ChangeMap lbNotUseMapName.items[lbNotUseMapName.selection] ChangeFilePath.text
							lbNotUseMapName.selection = 0
						)
				)
			)
		)
		else
		(
			messagebox "Select Path!"
		)
		
		ChangeFilePath.text = ""
		getAllMaterial()
		getObjectMaterial()
	)
	 --------------------------------------------------------------------------------------

	on btnAboutScript pressed do 
	(
		rollout rollAbout "About"
		(
		    label ScriptName "Map Path Setter ver 0.5"
			progressBar horizLine "ProgressBar" height:3 enabled:true value:100 color:(color 10 10 0) align:#center
			label Contact "Email: jinsuckelf@naver.com"
			label github "Github: https://github.com/Darkangle88/Max-Script/"
			button Okay "Okay" width:50 offset:[0,5]
			
			on Okay pressed do
			(
				destroydialog rollAbout
			)
		)
		createdialog rollAbout width: 270 height: 100
	)
	
	 --------------------------------------------------------------------------------------
)
createdialog MapPathSet width: 750 height: 480
