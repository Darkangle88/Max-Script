global SnapShotLayer = LayerManager.getLayerFromName "@SnapShot"

fn SelectedObj = 
	(
		try
		(	
			if $ == undefined then
			(
				AutoAlign.SelectedObject.text = " "
			)
			else
			(
				AutoAlign.SelectedObject.text =  $.name
			)
		)
		catch()
	)
	
rollout AutoAlign "AutoAlign"
(
	groupbox MakeSnapShot "Make SnapShot" width:260 height:70
	edittext SelectedObject " Select Object:" offset:[12,-55] width:230
	button btnSnapShot "Make SnapShot"
	
	groupbox Align "Align Object" offset:[0,10] width:260 height: 205
	edittext AliObject "Source Object:" offset:[12,-188] width:230
	button btnAlignObject "Select" width:60
	
	edittext TarObject " Target Object:" offset:[12,5] width:230
	button btnTarObject "Select" width:60
	
	groupbox SelectFrame "Select Frame" offset:[10,0] width:240 height:45
	spinner InsertFirstFrame type:#integer scale:1 range:[-10000,100000,0] width:80 align:#left offset:[30,-30]
	spinner InsertLastFrame type:#integer scale:1 range:[-10000,100000,100]width:80 align:#right offset:[-30,-21]
	
	label centerofframe "~" offset:[0,-20]
	
	checkbox PositionSelect "Position" offset:[25,15]
	checkbox RotationSelect "Rotation" offset:[100,-20]
	checkbox ScaleSelect "Scale" offset:[180,-20]
	
	button btnAlign "Align" offset: [0,18] width:80

	
	groupbox ManageSnapShot "Snapshot Manager" offset:[0,5] width:260 height:90
	button btnHideAndUnhide "Hide/Unhide" offset:[-60,-70] width:100
	button btnFreezeAndUnfreeze "Freeze/Unfreeze" offset:[65,-26] width:100
	button btnSeeAllSnapShot "See All Snapshot" offset:[-60,5] width:100
	button btnDeleteAllSnapShot "Delete All Snapshot" offset:[65,-26] width:100

	button btnAbout "About" offset:[0,17]width:100

	
	on btnSnapShot pressed do
	(
		if  $ != undefined and selection.count == 1 do
		(
			snap = snapshot $
			snap.name = $.name + " SnapShot"
			snap.transform = $.transform
			deleteKeys snap #allkeys
			
			if snap.parent != undefined do
			(
				deleteitem snap.parent.children snap
			)
			
			for i = 0 to LayerManager.count-1 do
				(
					if   (LayerManager.getlayer i).name == "@SnapShot" then
					(
						SnapShotLayer = LayerManager.getLayerFromName "@SnapShot"
						SnapShotLayer.addnode snap
					)
					else
					(
						LayerManager.newLayerFromName "@SnapShot"
						SnapShotLayer = LayerManager.getLayerFromName "@SnapShot"
						SnapShotLayer.addnode snap
					)
				)
		)
	)
	
	on btnAlignObject pressed do
	(
		if classof $ == Biped_Object then
		(
			ScaleSelect.checked = false
			ScaleSelect.enabled = false
		)
		else
		(
			ScaleSelect.enabled = true
		)
		AliObject.text = $.name 
	)
	
	on btnTarObject pressed do
	(
		TarObject.text = $.name 
	)
	
	on btnAlign pressed do
	(
		undo on
		(
			Ali = GetNodeByName AliObject.text
			Tar = GetNodeByName Tarobject.text
			First = InsertFirstFrame.value
			Last = InsertLastFrame.value
			PreFrame = slidertime
			
			if classof Ali != Biped_Object then
			(
				if PositionSelect.checked == True do
				(
					slidertime = First-1
					for i in First to Last  do
					(
					slidertime  += 1
					Ali.pos = Tar.pos
					)
				)
				
				if RotationSelect.checked == True do
				(
					slidertime = First-1
					for i in First to Last  do
					(
					slidertime  += 1
					Ali.rotation.x_rotation = Tar.rotation.x_rotation
					Ali.rotation.y_rotation = Tar.rotation.y_rotation
					Ali.rotation.z_rotation = Tar.rotation.z_rotation
					)
				)
				
				if ScaleSelect.checked ==  True do
				(
					slidertime = First-1
					for i in First to Last  do
					(
					slidertime  += 1
					Ali.Scale = Tar.Scale
					)
				)
			)
			else
			(
				if PositionSelect.checked == True do
				(
					slidertime = First-1
					for i in First to Last  do
					(
					slidertime  += 1
					biped.setTransform Ali #pos Tar.pos true
					)
				)
				
				if RotationSelect.checked == True do
				(
					slidertime = First-1
					for i in First to Last  do
					(
						slidertime  += 1
						in coordsys local ( rotate Ali( Ali.transform.rotation * inverse Tar.transform.rotation ) ) 
					)
				)
			)
		)
		slidertime = PreFrame
	)
	
	on btnHideAndUnhide pressed do
	 (
		 if SnapShotLayer.ishidden == true then
		 (
			 SnapShotLayer.ishidden =false
		 )
		 else
		 (
			 SnapShotLayer.ishidden = true
		 )
	 )
	 
	 on btnFreezeAndUnfreeze pressed do
	 (
		 if SnapShotLayer.isfrozen == true then
		 (
			 SnapShotLayer.isfrozen =false
		 )
		 else
		 (
			 SnapShotLayer.isfrozen = true
		 )
	 )
	 
	on btnSeeAllSnapShot pressed do
	 (
		 macros.run "Layers" "LayerManager"
		 clearSelection()
		 try
		(
			SnapShotLayer.select true
		)
		catch
		(
			 messagebox "Don't exist Snapshot"
		)
	 )
	 
	on btnDeleteAllSnapShot pressed do
	 (
		 clearSelection()
		 rollout rollDeleteAllSnapShot "Delete All SnapShot"
		(
			label labelDeleteAllSnapShot "Delete All Snapshot"
			label AreYouSure "Are You Sure?"
			button btnYes "Yes" offset:[-35,3] width: 50
			button btnNo "No" offset:[30,-26.5] width: 50

			on btnYes pressed do 
			(
				try
				(
					(LayerManager.getlayer 0).current = true
					 SnapShotLayer.select true
					 delete $
					 LayerManager.deleteLayerByName "@SnapShot"
					destroydialog rollDeleteAllSnapShot
				)
				catch
				(
					 messagebox "Don't exist Snapshot"
					destroydialog rollDeleteAllSnapShot
				)
			)
				
			on btnNo pressed do
			(
				destroydialog rollDeleteAllSnapShot
			)
		)
		createdialog rollDeleteAllSnapShot width: 150 height: 75
	 )
	 
	
	on  btnAbout pressed do
	(
		rollout rollAbout "About"
		(
		    label ScriptName "Auto Align ver 0.8 (Beta)"
			progressBar horizLine "ProgressBar" height:3 enabled:true value:100 color:(color 10 10 0) align:#center
			label Contact "Email: jinsuckelf@naver.com"
			label Blank " "
			label Name "Made by Park Jin Seok"
			button Okay "Okay" width:50 offset:[0,5]
			
			on Okay pressed do
			(
				destroydialog rollAbout
			)
		)
		createdialog rollAbout width: 200 height: 120
	)
)
createdialog AutoAlign width: 280 height: 460

callbacks.addScript #selectionSetChanged "SelectedObj()" id:#myCallbackID
callbacks.removeScripts #preSystemShutdown id:#myCallbackID