try (destroydialog BipedLayerShadow) catch()

--Global Variable
--=======================================================================================
--=======================================================================================

global modifierObjects = #()
global Layer0Mesh = #()
global Layer1Mesh = #()
global Layer2Mesh = #()
global Layer3Mesh = #()
global SelectedObject = #()
global SelectedObjectChild = #()
global ObjectChild = #()
global SelectedBiped

--Function
--=======================================================================================
--=======================================================================================

fn SelectShadowBipedObjectInLayer LayerName =
(
	local SelectedBipedObject
	clearselection()
	
	if LayerManager.getLayerFromName LayerName !=Undefined then
	(
		(LayerManager.getLayerFromName LayerName).select on
	)
	else
	(
		return()
	)
	
	for i in selection do
		(
			if (iskindof i Biped_Object == true) do
			(
				Select i
				SelectedBipedObject = i
				exit() 
			)
		)
		
	case of
	(
		(LayerName == "@Biped_Layer1_Shadow"):
			(
				biped.collapseAtLayer SelectedBipedObject.controller (0)
			)
		(LayerName == "@Biped_Layer2_Shadow"):
			(
				biped.collapseAtLayer SelectedBipedObject.controller (1)
				biped.collapseAtLayer SelectedBipedObject.controller (0)
			)
		(LayerName == "@Biped_Layer3_Shadow"):
			(
				biped.collapseAtLayer SelectedBipedObject.controller (2)
				biped.collapseAtLayer SelectedBipedObject.controller (1)
				biped.collapseAtLayer SelectedBipedObject.controller (0)
			)
	)
)

----------------------------------------------------------------------------------------------

fn HideAndUnhideLayer LayerArray = 
(
	for i in LayerArray do 
	(
		try
		(
			if i.ishidden == false then
			(
				hide i
			)
			else
			(
				unhide i
			)
		)
		catch()
	)
)

----------------------------------------------------------------------------------------------

fn ShadowOpacity LayerArray OpValue = 
(
	if isAnimPlaying() == true do
	(
		actionMan.executeAction 0 "50022"  -- Time: Forward Time One Unit
	)
	
	if (set animate on == false) then
		(
			for i in LayerArray do
			(
				i.visibility = bezier_float()
				i.visibility.controller.value = OpValue
			)
		)
		else
		(
			actionMan.executeAction 0 "50024" --set animate on/off
			for i in LayerArray do
			(
				i.visibility = bezier_float()
				i.visibility.controller.value = OpValue
			)
			actionMan.executeAction 0 "50024" --set animate on/off
		)
)

----------------------------------------------------------------------------------------------

fn selectSkinnedObject = 
(
	modifierObjects = #()
	
	for First in objects where First.modifiers[1] != undefined do
	(
		for Second in 1 to  First.modifiers.count where First.modifiers[Second].name == "Skin" do
		(
			if First.layer.name != "@Biped_Layer0_Shadow" and First.layer.name != "@Biped_Layer1_Shadow" and First.layer.name != "@Biped_Layer2_Shadow" and first.layer.name != "@Biped_Layer3_Shadow" do
			(
				append modifierObjects First
			)
		)
	)
	
	clearselection()
)

----------------------------------------------------------------------------------------------

fn DeleteShadow LayerName LayerArray= 
(
	try
	(
		if (LayerManager.getLayerFromName LayerName) != undefined then
		(
			if (LayerManager.getLayerFromName LayerName).current = true then
			(
				(LayerManager.getLayerFromName "0").current = true
				
				clearselection()
				
				(LayerManager.getLayerFromName LayerName).select on
				
				if $ != undefined do
				(
					delete $
				)
				
				LayerManager.deleteLayerByName LayerName
			)
			else
			(
				(LayerManager.getLayerFromName LayerName).select on
				
				if $ != undefined do
				(
					delete $
				)
				
				LayerManager.deleteLayerByName LayerName
			)
		)
		else
		(
			messagebox "Not Exist Shadow!"
		)
	)
	catch()

	selectSkinnedObject()
	LayerArray = #()
)

----------------------------------------------------------------------------------------------

fn selectAllChildren TopNode = 
(
	append SelectedObject $
	append SelectedObjectChild $

	do
	(
		ObjectChild = #()
		
		for i in SelectedObjectChild do 
		(
			if i.children[1] != undefined do
			(			
				join ObjectChild i.children
			)
		)
		join SelectedObject ObjectChild
		SelectedObjectChild = ObjectChild
	) 
	while ObjectChild.Count > 0
	
	select SelectedObject
)

----------------------------------------------------------------------------------------------

fn getShadowObject LayerName LayerArray= 
(
	clearselection()
	
	if (LayerManager.getLayerFromName LayerName) != undefined do
	(
		(LayerManager.getLayerFromName LayerName).select on
	
		for i in selection do
		(
			if (iskindof i Editable_mesh == true) or (iskindof i Editable_Poly == true) or (iskindof i PolyMeshObject == true) do
			(
				append LayerArray i
			)
		)
	)
	
	clearselection()
)

----------------------------------------------------------------------------------------------

fn SelectedObj = 
(
	try
	(	
		if $ == undefined then
		(
			BipedLayerShadow.etBipedTopNodeName.text = " "
		)
		else
		(
			BipedLayerShadow.etBipedTopNodeName.text =  $.name
		)
	)
	catch()
)

----------------------------------------------------------------------------------------------

fn getBipedInmodifierObjects = 
(
	for First in modifierObjects do --Get object from 'modifierObjects' Array
	(
		for Second in 1 to 10 do
		(
			select First
			setCommandPanelTaskMode #modify
			
			if (iskindof (execute ("$'"+(skinOps.GetBoneName $.modifiers[#Skin] Second 1)+ "'")) Biped_Object) == true do
			(
				--Set SelectedBiped
				SelectedBiped = (execute ("$'"+(skinOps.GetBoneName $.modifiers[#Skin] Second 1)+ "'"))
				return()
			)
		)			
	)
	clearselection()
)

----------------------------------------------------------------------------------------------

fn CreateShadow LayerArray LayerName = 
(	
	if classof $ == Biped_Object then
	(
		if LayerManager.getLayerFromName LayerName == undefined  then
		(
			LayerManager.newLayerFromName LayerName -- Make Layer  "LayerName" 
			(LayerManager.getLayerFromName LayerName).current = true
			
			LayerArray = deepcopy modifierObjects 

			while $.parent != undefined do
			(
				select $.parent
			)
			
			append SelectedObject $
			append SelectedObjectChild $

			do
			(
				ObjectChild = #()
				
				for i in SelectedObjectChild do 
				(
					if i.children[1] != undefined do
					(			
						join ObjectChild i.children
					)
				)
				
				join SelectedObject ObjectChild
				SelectedObjectChild = ObjectChild
				
			) 
			while ObjectChild.Count > 0
			
			select SelectedObject
			
			SelectedObject = #()
			SelectedObjectChild = #() 
			
			selectmore LayerArray
			
			maxOps.cloneNodes $ cloneType:#copy newNodes:&CopyObject
			select CopyObject
			for i in Selection do (LayerManager.getLayerFromName LayerName).addnode i
			hide CopyObject
			Freeze CopyObject
			CopyObject.showFrozenInGray = on
			
			LayerArray = #()
			
			getShadowObject LayerName LayerArray

			unhide LayerArray
			
			for i in LayerArray do
			(
				i.visibility = bezier_float()
				i.visibility.controller.value = 1.0
			)
		)
		else
		(
			return messagebox "Already Exist Shadow"
			clearselection()
		)
	)
	else
	(
		messagebox "Select Biped Object!"
	)
)

--UI 
--==============================================================================================2
--==============================================================================================

rollout BipedLayerShadow "Biped Layer Shadow"
(
	--Declare-------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------
	
	groupbox gbselectObject "Selected Object" width: 210 height: 40
	edittext etBipedTopNodeName  width:180 offset:[4,-30]
	
	----------------------------------------------------------------------------------------------
	
	groupbox gbBiped_Layer "Biped Layer"  width:210 height:325 offset:[0,10]
	
	----------------------------------------------------------------------------------------------
	
	label labalBiped_Layer0 "Original Layer Shadow" align:#left  offset:[10,-310]
	button btnBiped_Layer0CreateShadow "Create Shadow" across:2 width:90
	button btnBiped_Layer0DeleteShadow "Delete Shadow" width:90 across:2
	button btnBiped_Layer0Hide "Hide & UnHide" across:2 width:90
	spinner spBiped_Layer0Opacity "Opacity" width:75 range:[0,1,1]
	progressBar horizLineBiped_Layer0 "ProgressBar" height:1 width: 200 enabled:true value:100 color:(color 10 10 0) align:#center
	
	----------------------------------------------------------------------------------------------
	
	label labelBiped_Layer1 "Layer - 1 Shadow" align:#left offset:[10,0]
	button btnBiped_Layer1CreateShadow "Create Shadow" across:2 width:90
	button btnBiped_Layer1DeleteShadow "Delete Shadow" width:90 
	button btnBiped_Layer1Hide "Hide & UnHide" across:2 width:90
	spinner spBiped_Layer1Opacity "Opacity" width:75 range:[0,1,1]
	progressBar horizLine1 "ProgressBar" height:1 width: 200 enabled:true value:100 color:(color 10 10 0) align:#center
	
	----------------------------------------------------------------------------------------------	
	
	label labelBiped_Layer2 "Layer - 2 Shadow" align:#left offset:[10,0]
	button btnBiped_Layer2CreateShadow "Create Shadow" across:2 width:90
	button btnBiped_Layer2DeleteShadow "Delete Shadow" width:90
	button btnBiped_Layer2Hide "Hide & UnHide" across:2 width:90
	spinner spBiped_Layer2Opacity "Opacity" width:75 range:[0,1,1]
	progressBar horizLine2 "ProgressBar" height:1 width: 200 enabled:true value:100 color:(color 10 10 0) align:#center

	------------------------------------------------------------------------------------------d----
	
	label labelBiped_Layer3 "Layer - 3 Shadow" align:#left offset:[10,0]
	button btnBiped_Layer3CreateShadow "Create Shadow" across:2 width:90
	button btnBiped_Layer3DeleteShadow "Delete Shadow" width:90
	button btnBiped_Layer3Hide "Hide & UnHide" across:2 width:90
	spinner spBiped_Layer3Opacity "Opacity" width:75 range:[0,1,1]
	
	----------------------------------------------------------------------------------------------
	
	groupbox gbLayerProperties "Layer Controller" offset:[0,20]  width: 210 height: 110
	button btnPreLayer "Pre" across:3 offset:[-10,-93] width:40 
	button btnNextLayer "Next"  offset:[-10,-93] width:40 align:#left
	edittext etLayerNumber " " offset:[-35,-93] width:25 
	button btnCreateLayer "Create Layer" across:2  width:95
	button btnCollapseLayer "Collapse Layer" width:95
	button btnDeleteLayer "Delete Layer" across:2 width:95
	button btnDeleteAllShadow "Delete All Shadow"  width:95
	button AboutInformation "About Script" offset:[0,15] width: 100
	
	--Implementation------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------
	
	on BipedLayerShadow open do
	(
		if viewport.GetTransparencyLevel() == 1 do
		(
			viewport.SetTransparencyLevel 2
		)
		
		SelectedBiped = undefined
		
		selectSkinnedObject()
		getBipedInmodifierObjects()
		getShadowObject "@Biped_Layer0_Shadow" Layer0Mesh
		getShadowObject "@Biped_Layer1_Shadow" Layer1Mesh
		getShadowObject "@Biped_Layer2_Shadow" Layer2Mesh
		getShadowObject "@Biped_Layer3_Shadow" Layer3Mesh
		etLayerNumber.text = biped.getCurrentLayer SelectedBiped.controller as string
	)
	
	----------------------------------------------------------------------------------------------
	
	on BipedLayerShadow close do
	(
		callbacks.removeScripts id:#myCallbackID
	)
	
	--Layer 0-------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------
	
	on btnBiped_Layer0Hide pressed do
	(
		if (LayerManager.getLayerFromName "@Biped_Layer0_Shadow") != undefined do
		(
			HideAndUnhideLayer Layer0Mesh
		)
	)
	----------------------------------------------------------------------------------------------
	
	on spBiped_Layer0Opacity changed Num do 
	(
		if (LayerManager.getLayerFromName "@Biped_Layer0_Shadow") != undefined do
		(
			ShadowOpacity Layer0Mesh Num
		)
	)
	----------------------------------------------------------------------------------------------
	
	on btnBiped_Layer0CreateShadow pressed do
	(
		CreateShadow Layer0Mesh "@Biped_Layer0_Shadow"
		Layer0Mesh = #()
		getShadowObject "@Biped_Layer0_Shadow" Layer0Mesh 
		print Layer0mesh
	)

	----------------------------------------------------------------------------------------------
	
	on btnBiped_Layer0DeleteShadow pressed do
	(
		DeleteShadow "@Biped_Layer0_Shadow" Layer0Mesh
	)
	
	--Layer 1-------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------
	
	on btnBiped_Layer1Hide pressed do
	(
		if (biped.numLayers SelectedBiped.controller > 0) and (LayerManager.getLayerFromName "@Biped_Layer1_Shadow") != undefined do
		(
			HideAndUnhideLayer Layer1Mesh
		)
	)
	----------------------------------------------------------------------------------------------
	
	on spBiped_Layer1Opacity changed Num do 
	(
		if (biped.numLayers SelectedBiped.controller > 0) and (LayerManager.getLayerFromName "@Biped_Layer1_Shadow") != undefined do
		(
			print "babasdadawdawd"
			ShadowOpacity Layer1Mesh Num
		)
	)
	----------------------------------------------------------------------------------------------
	
	on btnBiped_Layer1CreateShadow pressed do
	(
		if (biped.numLayers SelectedBiped.controller > 0) then
		(
			CreateShadow Layer1Mesh "@Biped_Layer1_Shadow"
			SelectShadowBipedObjectInLayer "@Biped_Layer1_Shadow"
			Layer1Mesh = #()
			getShadowObject "@Biped_Layer1_Shadow" Layer1Mesh 
			print Layer1mesh
		)
		else
		(
			messagebox "Don't exist Layer 1"
		)
	)

	----------------------------------------------------------------------------------------------
	
	on btnBiped_Layer1DeleteShadow pressed do
	(
		if (biped.numLayers SelectedBiped.controller > 0) do
		(
			DeleteShadow "@Biped_Layer1_Shadow" Layer1Mesh
		)
	)

	--Layer 2-------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------
	
	on btnBiped_Layer2Hide pressed do
	(
		if (biped.numLayers SelectedBiped.controller > 1) and (LayerManager.getLayerFromName "@Biped_Layer2_Shadow") != undefined do
		(
			HideAndUnhideLayer Layer2Mesh
		)
	)
	----------------------------------------------------------------------------------------------
	
	on spBiped_Layer2Opacity changed Num do 
	(
		if (biped.numLayers SelectedBiped.controller > 1) and (LayerManager.getLayerFromName "@Biped_Layer2_Shadow") != undefined do
		(
			ShadowOpacity Layer2Mesh Num
		)
	)
	----------------------------------------------------------------------------------------------
	
	on btnBiped_Layer2CreateShadow pressed do
	(
		if (biped.numLayers SelectedBiped.controller > 1) then
		(
			CreateShadow Layer2Mesh "@Biped_Layer2_Shadow"
			SelectShadowBipedObjectInLayer "@Biped_Layer2_Shadow"
			Layer2Mesh = #()
			getShadowObject "@Biped_Layer2_Shadow" Layer2Mesh 
			print Layer2mesh
		)
		else
		(
			messagebox "Don't exist Layer 2"
		)
	)

	----------------------------------------------------------------------------------------------
	
	on btnBiped_Layer2DeleteShadow pressed do
	(
		if (biped.numLayers SelectedBiped.controller > 1) do
		(
			DeleteShadow "@Biped_Layer2_Shadow" Layer2Mesh
		)
	)
	
	--Layer 3-------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------
	
	on btnBiped_Layer3Hide pressed do
	(
		if (biped.numLayers SelectedBiped.controller > 2) and (LayerManager.getLayerFromName "@Biped_Layer3_Shadow") != undefined do
		(
			HideAndUnhideLayer Layer3Mesh
		)
	)
	----------------------------------------------------------------------------------------------
	
	on spBiped_Layer3Opacity changed Num do 
	(
		if (biped.numLayers SelectedBiped.controller > 2) and (LayerManager.getLayerFromName "@Biped_Layer3_Shadow") != undefined do
		(
			ShadowOpacity Layer3Mesh Num
		)
	)
	----------------------------------------------------------------------------------------------
	
	on btnBiped_Layer3CreateShadow pressed do
	(
		if (biped.numLayers SelectedBiped.controller > 2) then
		(
			CreateShadow Layer3Mesh "@Biped_Layer3_vzShadow"
			SelectShadowBipedObjectInLayer "@Biped_Layer3_Shadow"
			Layer3Mesh = #()
			getShadowObject "@Biped_Layer3_Shadow" Layer3Mesh 
			print Layer3mesh
		)
		else
		(
			messagebox "Don't exist Layer 3"
		)
	)

	----------------------------------------------------------------------------------------------
	
	on btnBiped_Layer3DeleteShadow pressed do
	(
		if (biped.numLayers SelectedBiped.controller > 2) do
		(
			DeleteShadow "@Biped_Layer3_Shadow" Layer3Mesh
		)
	)
	
	----------------------------------------------------------------------------------------------
	--Layer Controller-----------------------------------------------------------------------------
	
	on btnCreateLayer pressed do
	(
		biped.createLayer SelectedBiped.controller (biped.numLayers SelectedBiped.controller+1) ("Layer " + ((biped.numLayers SelectedBiped.controller+1) as string))
		biped.setCurrentLayer SelectedBiped.controller (biped.numLayers SelectedBiped.controller)
		etLayerNumber.text = biped.getCurrentLayer SelectedBiped.controller as string
		btnDeleteLayer.enabled = true
		btnPreLayer.enabled = true
			
		if biped.getCurrentLayer SelectedBiped.controller == biped.numLayers SelectedBiped.controller then
		(
			btnNextLayer.enabled = false
		)
		else
		(
			btnNextLayer.enabled = true
		)
	)
	----------------------------------------------------------------------------------------------
	
	on btnCollapseLayer pressed do
	(
		try
		(
			etLayerNum = execute etLayerNumber.text 
			biped.collapseAtLayer SelectedBiped.controller (etLayerNum-1)
			etLayerNumber.text = biped.getCurrentLayer SelectedBiped.controller as string
		)
		catch
		(
			
		)
	)

	----------------------------------------------------------------------------------------------
	
	on btnDeleteLayer pressed do
	(
		if biped.getCurrentLayer SelectedBiped.controller != 0 do
		(
			biped.deleteLayer SelectedBiped.controller (biped.getCurrentLayer SelectedBiped.controller)
		)
		
		if  biped.getCurrentLayer SelectedBiped.controller == 0 do
			(
				btnPreLayer.enabled = false
				btnDeleteLayer.enabled = false
			)
			
		if biped.getCurrentLayer SelectedBiped.controller == biped.numLayers SelectedBiped.controller do
			(
				btnNextLayer.enabled = false
			)
		etLayerNumber.text = biped.getCurrentLayer SelectedBiped.controller as string
	)
	
	----------------------------------------------------------------------------------------------
	
	on btnDeleteAllShadow pressed do
	(
		if (LayerManager.getLayerFromName "@Biped_Layer0_Shadow") != undefined  do
		(
			print "aaaaaaaa"
			DeleteShadow "@Biped_Layer0_Shadow" Layer0Mesh
		)
		
		if (LayerManager.getLayerFromName "@Biped_Layer1_Shadow") != undefined  do
		(
			DeleteShadow "@Biped_Layer1_Shadow" Layer1Mesh
		)
		
		if (LayerManager.getLayerFromName "@Biped_Layer2_Shadow") != undefined  do
		(
			DeleteShadow "@Biped_Layer2_Shadow" Layer2Mesh
		)
				
		if (LayerManager.getLayerFromName "@Biped_Layer3_Shadow") != undefined  do
		(
			DeleteShadow "@Biped_Layer3_Shadow" Layer3Mesh
		)
	)
	
	on btnNextLayer pressed do
	(
		try
		(
			etLayerNum = execute etLayerNumber.text
			btnDeleteLayer.enabled = true
			if biped.numLayers SelectedBiped.controller != etLayerNum then
			(
				biped.setCurrentLayer SelectedBiped.controller (etLayerNum + 1)
				if biped.getCurrentLayer SelectedBiped.controller == 1 do
				(
					btnPreLayer.enabled = true
				)
				if biped.getCurrentLayer SelectedBiped.controller == biped.numLayers SelectedBiped.controller do
				(
					btnNextLayer.enabled = false
				)
			)
			etLayerNumber.text = biped.getCurrentLayer SelectedBiped.controller as string
		)
		catch
		(
			etLayerNumber.text = biped.getCurrentLayer SelectedBiped.controller as string
			
			if biped.getCurrentLayer SelectedBiped.controller == biped.numLayers SelectedBiped.controller do
			(
				btnNextLayer.enabled = false
			)
		)
	)
	
	on btnPreLayer pressed do
	(
		try
		(
			etLayerNum = execute etLayerNumber.text
			if biped.numLayers SelectedBiped.controller != 0 then
			(
				biped.setCurrentLayer SelectedBiped.controller (etLayerNum - 1)
				
				if biped.getCurrentLayer SelectedBiped.controller == (biped.numLayers SelectedBiped.controller)-1 do
				(
					btnNextLayer.enabled = true
				)
				
				if  biped.getCurrentLayer SelectedBiped.controller == 0 then
				(
					btnPreLayer.enabled = false
					btnDeleteLayer.enabled = false
				)
			)
			else
			(
				btnPreLayer.enabled = false
			)
			etLayerNumber.text = biped.getCurrentLayer SelectedBiped.controller as string
		)
		catch
		(
			etLayerNumber.text = biped.getCurrentLayer SelectedBiped.controller as string
			if  biped.getCurrentLayer SelectedBiped.controller == 0 then
			(
				btnPreLayer.enabled = false
				btnDeleteLayer.enabled = false
			)
		)
	)
	----------------------------------------------------------------------------------------------
	
	on AboutInformation pressed do
	(
		rollout rollAbout "About"
		(
			label ScriptName "Biped Layer Shadow ver.1.0"
			progressBar horizLine "ProgressBar" height:3 enabled:true value:100 color:(color 10 10 0) align:#center
			label Contact "Email: jinsuckelf@naver.com"
			button Okay "Okay" width:50 offset:[0,5]
			
			on Okay pressed do
			(
				destroydialog rollAbout
				
			)
		)
		createdialog rollAbout width: 200 height: 80
	)
)
createdialog BipedLayerShadow width: 235 height: 540

callbacks.addScript #selectionSetChanged "SelectedObj()" id:#myCallbackID