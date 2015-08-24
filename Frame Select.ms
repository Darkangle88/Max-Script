try (destroydialog FrameSelect) catch()

--Global Variable-------------------------------------------------------------------------
-----------------------------------------------------------------------------------------

global frameListArray = #()
global InTempFilePath = getdir #temp + "\\" + getfilenamefile maxfilename + ".txt"
global filePath = maxfilepath + getfilenamefile maxfilename + ".txt"

--function--------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------

fn FileOpenReOpenScript = 
(
	try 
	(
		destroydialog FrameSelect
		createdialog FrameSelect width: 200 height: 340
	) 
	catch
	(
		createdialog FrameSelect width: 200 height: 340
	)
)

-----------------------------------------------------------------------------------------

fn SaveFrameList =
(
	local TempFilePath = getdir #temp + "\\" + getfilenamefile maxfilename + ".txt"
	
	if doesfileexist TempFilePath == true  then
	(
		deletefile TempFilePath
		createInformationFile = createfile TempFilePath
		print frameListArray to:createInformationFile
		close createInformationFile
	)
	else
	(
		createInformationFile = createfile TempFilePath
		print frameListArray to:createInformationFile
		close createInformationFile
	)
)

-----------------------------------------------------------------------------------------

fn LoadListInTemp = 
(
	local TempFilePath = getdir #temp + "\\" + getfilenamefile maxfilename + ".txt"
	
	if doesfileexist TempFilePath == true  then
	(
		openInformationFile = openfile TempFilePath
		frameListArray = #()
		
		while not eof openInformationFile do
		(
			arrayAppend = readline openInformationFile
			arrayAppend = execute arrayAppend
			append frameListArray arrayAppend
		)
		
		close openInformationFile
	)
	else
	(
		return messagebox "Don't exist load file"
	)
)

-----------------------------------------------------------------------------------------


--UI-------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------

rollout FrameSelect "Frame Select"
(
	--declare--------------------------------------------------------------------------------
	-----------------------------------------------------------------------------------------
	edittext SelectedFrameName "Name " width:160 offset:[10,5]
	
	spinner InsertFirstFrame type:#integer scale:1 range:[-10000,100000,0] width:60 align:#left offset:[10,5]
	spinner InsertLastFrame type:#integer scale:1 range:[-10000,100000,100]width:60 align:#right offset:[-10,-21]
	
	label centerofframe "~" offset:[0,-20]
	
	button SaveSelectedFrame "Save" offset:[-35,5]width:45
	button DeleteSelectedFrame "Delete" offset:[35,-26]
	listbox SelectSavedFrameList "Frame List" offset:[0,5] items:#()
	groupbox ScriptInformation "Script Information" offset:[0,0] width:175 height:50
	button ImportInformation "Import" offset:[-35,-35]
	button ExportInformation "Export" offset:[35,-27]
	button AboutInformation "About" width:70 height:20 offset: [0,15]
	
	--Implementation------------------------------------------------------------------------
	-----------------------------------------------------------------------------------------
	
	on FrameSelect open do
	(
		SelectSavedFrameList.items = #()
		
		LoadListInTemp()
		
		for i in 1 to frameListArray.count do
		(
			append SelectSavedFrameList.items frameListArray[i][3]
		)
		
		SelectSavedFrameList.items = append SelectSavedFrameList.items ("@For Refresh")
		SelectSavedFrameList.items = deleteitem SelectSavedFrameList.items SelectSavedFrameList.items.count
	)
	
	-----------------------------------------------------------------------------------------
	
	--Insert First Frame in First Spinner 
	on  InsertFirstFrame entered do
	(
		animationrange  = interval InsertFirstFrame.value animationrange.end
	)	

	-----------------------------------------------------------------------------------------
	
	--Insert Last Frame in Second Spinner 
	on  InsertLastFrame entered do
	(
		animationrange  = interval animationrange.start InsertLastFrame.value
	)	
	
	-----------------------------------------------------------------------------------------
	
	--When a click Frame List
	on SelectSavedFrameList doubleClicked SelectedName do 
	(
		for i in 1 to frameListArray.count do
		(
			if SelectSavedFrameList.selected == frameListArray[i][3] do
			(
				animationrange = interval frameListArray[i][1] frameListArray[i][2]
			)
		)
	)
	
	-----------------------------------------------------------------------------------------
	
	--Save Button
	on SaveSelectedFrame pressed do
	(
		for i in 1 to SelectSavedFrameList.items.count do
		(
			if SelectedFrameName.text == SelectSavedFrameList.items[i] then
			(
				return messagebox "Duplicated Frame Name"
			)
		)
		
		if SelectedFrameName.text != "" then
		(
			SelectSavedFrameList.items = append SelectSavedFrameList.items (SelectedFrameName.text)
			frameName = SelectedFrameName.text
			frameName = #(InsertFirstFrame.value, InsertLastFrame.value, frameName)
			append frameListArray frameName
			
			SaveFrameList()
		)
		else
		(
			return messagebox "Insert Frame Name"
		)
		
	)
	
	-----------------------------------------------------------------------------------------
	
	--Delete Button
	on DeleteSelectedFrame pressed do
	(
		if SelectSavedFrameList.items.count > 0 and SelectSavedFrameList.selection > 0 and frameListArray.count > 0 do
		(
			frameListArray = deleteitem frameListArray SelectSavedFrameList.selection
			SelectSavedFrameList.items = deleteitem SelectSavedFrameList.items SelectSavedFrameList.selection
			
			SaveFrameList()
		)
	)
	
	-----------------------------------------------------------------------------------------
	
	on ImportInformation pressed do
	(
		local importFilePath = getOpenFileName caption:"Import List File"  types:"Text(*.txt)|*.txt" filename: (maxfilepath)
		
		if importFilePath != undefined do
		(
			if doesfileexist importFilePath == true  then
			(
				openInformationFile = openfile importFilePath
				frameListArray = #()
				
				while not eof openInformationFile do
				(
					arrayAppend = readline openInformationFile
					arrayAppend = execute arrayAppend
					append frameListArray arrayAppend
				)
				
				close openInformationFile
			)
			else
			(
				return messagebox "Don't exist load file"
			)
			
			SelectSavedFrameList.items = #()
			
			for i in 1 to frameListArray.count do
			(
				append SelectSavedFrameList.items frameListArray[i][3]
			)
			
			SelectSavedFrameList.items = append SelectSavedFrameList.items ("@For Refresh")
			SelectSavedFrameList.items = deleteitem SelectSavedFrameList.items SelectSavedFrameList.items.count
				
			SaveFrameList()
		)
	)
	
	-----------------------------------------------------------------------------------------
	
	on ExportInformation pressed do
	(
		local saveFilePath = getSaveFileName caption:"Export List File" filename:(filePath)  types:"Text(*.txt)|*.txt"
		
		if saveFilePath != undefined do
		(
			if doesfileexist saveFilePath == true  then
			(
				deletefile saveFilePath
				createInformationFile = createfile saveFilePath
				print frameListArray to:createInformationFile
				close createInformationFile
			)
			else
			(
				createInformationFile = createfile saveFilePath
				print frameListArray to:createInformationFile
				close createInformationFile
			)
		)
	)
	
	-----------------------------------------------------------------------------------------
	
	on AboutInformation pressed do
	(
		rollout rollAbout "About"
		(
			label ScriptName "Frame Selecter ver.1.1"
			progressBar horizLine "ProgressBar" height:3 enabled:true value:100 color:(color 10 10 0) align:#center
			label Contact "Email: jinsuckelf@naver.com"
			label Name "Park Jin Seok"
			button Okay "Okay" width:50 offset:[0,5]
			
			on Okay pressed do
			(
				destroydialog rollAbout
			)
		)
		createdialog rollAbout width: 200 height: 100
	)
)
createdialog FrameSelect width: 200 height: 340

--CallBack------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------

callbacks.addScript #filePostSave "SaveFrameList()" id:#myCallbackID
callbacks.addScript #filePostOpen "FileOpenReOpenScript()" id:#myCallback