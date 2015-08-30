
try (destroydialog MapPathSet) catch()

--Global Variable
--=======================================================================================
--=======================================================================================

--global mapTypeList = #("Ambient Color", "Diffuse Color", "Specular Color", "Specualr Level", "Glossiness", "Self-Illumination", "Opacity", "Filter Color", "Bump", "Reflection", "Refraction", "Displacement")
global MapPathSet
global UseMap = #()
global MissingMap = #()
global RealUseMap = #()
global RealMissingMap = #()
global totalMapPathList = #() -- Store Total Map Path List(Single Array)
global totalObjectList=#() -- Store Total Objects List(Double Array)
global mapfiles=#()
global MapNameNum
global getImageFile = #()
global getfile = getfiles (maxfilepath + "*")
global getDirectory = getDirectories (maxfilepath + "\*")
global unSupportedType = #()

--Function
--=======================================================================================
--=======================================================================================


fn getMaterialType filepath objectNum = 
(
	if doesFileExist filePath == false then
	(
		appendIfUnique MissingMap filepath
		appendIfUnique totalMapPathList filepath
		
		if (totalObjectList[finditem totalMapPathList filepath] == undefined) then
		(
			append totalObjectList #()
			objectArrayNum = finditem totalMapPathList filepath
			appendIfUnique totalObjectList[objectArrayNum] objects[objectNum].name
		)
		else
		(
			objectArrayNum = finditem totalMapPathList filepath
			appendIfUnique totalObjectList[objectArrayNum] objects[objectNum].name
		)
	)
	else
	(
		appendIfUnique UseMap filepath
		appendIfUnique totalMapPathList filepath
		
		if (totalObjectList[finditem totalMapPathList filepath] == undefined) then
		(
			append totalObjectList #()
			objectArrayNum = finditem totalMapPathList filepath
			appendIfUnique totalObjectList[objectArrayNum] objects[objectNum].name
		)
		else
		(
			objectArrayNum = finditem totalMapPathList filepath
			appendIfUnique totalObjectList[objectArrayNum] objects[objectNum].name
		)
	)
)


fn getFilePath =
(
	UseMap = #()
	MissingMap = #()
	totalMapPathList = #()
	totalObjectList=#()
	
	--Search Objects
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
						if objects[objectNum].material.maps[mapNum] != undefined  do
						(
							case of
							(
								(classof objects[objectNum].material.maps[mapNum] == Bitmaptexture):
									(
										if objects[objectNum].material.maps[mapNum].filename != undefined do
										(
											filePath = objects[objectNum].material.maps[mapNum].filename
											getMaterialType filepath objectNum
										)
									)
								(classof objects[objectNum].material.maps[mapNum] == Normal_Bump):
									(
										if objects[objectNum].material.maps[mapNum].normal != undefined and objects[objectNum].material.maps[mapNum].normal.filename != undefined  do
										(
											filePath = objects[objectNum].material.maps[mapNum].normal.filename
											getMaterialType filepath objectNum
										)
										if objects[objectNum].material.maps[mapNum].bump_map != undefined and objects[objectNum].material.maps[mapNum].bump_map.filename != undefined do
										(
											filePath = objects[objectNum].material.maps[mapNum].bump_map.filename
											getMaterialType filepath objectNum
										)
									)
								(classof objects[objectNum].material.maps[mapNum] == Particle_Age):
									(
										if objects[objectNum].material.maps[mapNum].map1 != undefined and objects[objectNum].material.maps[mapNum].map1.filename != undefined do
										(
											filePath = objects[objectNum].material.maps[mapNum].map1.filename
											getMaterialType filepath objectNum
										)
										if objects[objectNum].material.maps[mapNum].map2 != undefined and objects[objectNum].material.maps[mapNum].map2.filename != undefined do
										(
											filePath = objects[objectNum].material.maps[mapNum].map2.filename
											getMaterialType filepath objectNum
										)
										if objects[objectNum].material.maps[mapNum].map3 != undefined and objects[objectNum].material.maps[mapNum].map3.filename != undefined do
										(
											filePath = objects[objectNum].material.maps[mapNum].map3.filename
											getMaterialType filepath objectNum
										)
									)
								defalut:
								(
									appendIfUnique unSupportedType (objects[objectNum].material.maps[mapNum] as string)

								)
							)
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
									case of
									(
										(classof objects[objectNum].material[multiMatNum].maps[mapNum] == Bitmaptexture):
											(
												if objects[objectNum].material[multiMatNum].maps[mapNum].filename != undefined do
												(
													filePath = objects[objectNum].material[multiMatNum].maps[mapNum].filename
													getMaterialType filepath objectNum
												)
											)
										(classof objects[objectNum].material[multiMatNum].maps[mapNum] == Normal_Bump):
											(
												if objects[objectNum].material[multiMatNum].maps[mapNum].normal != undefined and objects[objectNum].material[multiMatNum].maps[mapNum].normal.filename != undefined  do
												(
													filePath = objects[objectNum].material[multiMatNum].maps[mapNum].normal.filename
													getMaterialType filepath objectNum
												)
												if objects[objectNum].material[multiMatNum].maps[mapNum].bump_map != undefined  and objects[objectNum].material[multiMatNum].maps[mapNum].bump_map.filename != undefined do
												(
													filePath = objects[objectNum].material[multiMatNum].maps[mapNum].bump_map.filename
													getMaterialType filepath objectNum
												)
											)
										(classof objects[objectNum].material[multiMatNum].maps[mapNum] == Particle_Age):
											(
												if objects[objectNum].material[multiMatNum].maps[mapNum].map1 != undefined and objects[objectNum].material[multiMatNum].maps[mapNum].map1.filename != undefined do
												(
													filePath = objects[objectNum].material[multiMatNum].maps[mapNum].map1.filename
													getMaterialType filepath objectNum
												)
												if objects[objectNum].material[multiMatNum].maps[mapNum].map2 != undefined  and objects[objectNum].material[multiMatNum].maps[mapNum].map2.filename != undefined do
												(
													filePath = objects[objectNum].material[multiMatNum].maps[mapNum].map2.filename
													getMaterialType filepath objectNum
												)
												if objects[objectNum].material[multiMatNum].maps[mapNum].map3 != undefined  and objects[objectNum].material[multiMatNum].maps[mapNum].map3.filename != undefined do
												(
													filePath = objects[objectNum].material[multiMatNum].maps[mapNum].map3.filename
													getMaterialType filepath objectNum
												)
											)
										defalut:
										(
											appendIfUnique unSupportedType (objects[objectNum].material[multiMatNum].maps[mapNum] as string)
										)
									)
								)
							)
						)
					)
				)
			)
		)
	)
	
	for First in 1 to meditmaterials.count do
	(
		case of
		(
			(classof meditmaterials[First] == standardMaterial):
			(	
				--Search Maps
				for mapNum = 1 to meditmaterials[First].maps.count do
				(
					if meditmaterials[First].maps[mapNum] != undefined do
					(
						case of
						(
							(classof meditmaterials[First].maps[mapNum] == Bitmaptexture):
								(
									if meditmaterials[First].maps[mapNum].filename != undefined do
									(
											filepath = meditmaterials[First].maps[mapNum].filename
											if doesFileExist filePath == false then
											(
												appendIfUnique MissingMap filepath
												appendIfUnique totalMapPathList filepath
											)
											else
											(
												appendIfUnique UseMap filepath
												appendIfUnique totalMapPathList filepath
											)
									)
								)
							(classof meditmaterials[First].maps[mapNum] == Normal_Bump):
								(
									if meditmaterials[First].maps[mapNum].normal != undefined do
									(
										if meditmaterials[First].maps[mapNum].normal.filename != undefined do
										(
											filepath = meditmaterials[First].maps[mapNum].normal.filename
											if doesFileExist filePath == false then
											(
												appendIfUnique MissingMap filepath
												appendIfUnique totalMapPathList filepath
											)
											else
											(
												appendIfUnique UseMap filepath
												appendIfUnique totalMapPathList filepath
											)
										)
									)
									if meditmaterials[First].maps[mapNum].bump_map != undefined do
									(
										if meditmaterials[First].maps[mapNum].bump_map.filename != undefined do
										(
											filepath = meditmaterials[First].maps[mapNum].bump_map.filename
											if doesFileExist filePath == false then
											(
												appendIfUnique MissingMap filepath
												appendIfUnique totalMapPathList filepath
											)
											else
											(
												appendIfUnique UseMap filepath
												appendIfUnique totalMapPathList filepath
											)
										)
									)
								)
								
							(classof meditmaterials[First].maps[mapNum] == Particle_Age):
								(
									if meditmaterials[First].maps[mapNum].map1 != undefined do
									(
										if meditmaterials[First].maps[mapNum].map1.filename != undefined do
										(
											filepath = meditmaterials[First].maps[mapNum].map1.filename
											if doesFileExist filePath == false then
											(
												appendIfUnique MissingMap filepath
												appendIfUnique totalMapPathList filepath
											)
											else
											(
												appendIfUnique UseMap filepath
												appendIfUnique totalMapPathList filepath
											)
										)
									)
									if meditmaterials[First].maps[mapNum].map2 != undefined do
									(
										if meditmaterials[First].maps[mapNum].map2.filename != undefined do
										(
											filepath = meditmaterials[First].maps[mapNum].map2.filename
											if doesFileExist filePath == false then
											(
												appendIfUnique MissingMap filepath
												appendIfUnique totalMapPathList filepath
											)
											else
											(
												appendIfUnique UseMap filepath
												appendIfUnique totalMapPathList filepath
											)
										)
									)
									if meditmaterials[First].maps[mapNum].map3 != undefined do
									(
										if meditmaterials[First].maps[mapNum].map3.filename != undefined do
										(
											filepath = meditmaterials[First].maps[mapNum].map3.filename
											if doesFileExist filePath == false then
											(
												appendIfUnique MissingMap filepath
												appendIfUnique totalMapPathList filepath
											)
											else
											(
												appendIfUnique UseMap filepath
												appendIfUnique totalMapPathList filepath
											)
										)
									)
								)
							default:
								(
									appendIfUnique unSupportedType (meditmaterials[First].maps[mapNum] as string)
								)
						)
					)
				)
			)
			(classof meditmaterials[First] == multiMaterial):
			(
				for multiMatNum = 1 to meditmaterials[First].material.count do
				(
					if meditmaterials[First].material[multiMatNum] != undefined and classof meditMaterials[First].material[multiMatNum] == standardMaterial do
					(
						for mapNum = 1 to meditmaterials[First].material[multiMatNum].maps.count do
						(
							if meditmaterials[First].material[multiMatNum].maps[mapNum] != undefined  do
							(
								case of
								(
									(classof meditmaterials[First].material[multiMatNum].maps[mapNum] == Bitmaptexture):
										(
											if meditmaterials[First].material[multiMatNum].maps[mapNum].filename != undefined do
											(
												filepath = meditmaterials[First].material[multiMatNum].maps[mapNum].filename
												if doesFileExist filePath == false then
												(
													appendIfUnique MissingMap filepath
													appendIfUnique totalMapPathList filepath
												)
												else
												(
													appendIfUnique UseMap filepath
													appendIfUnique totalMapPathList filepath
												)
											)
										)
									(classof meditmaterials[First].material[multiMatNum].maps[mapNum] == Normal_Bump):
										(
											if meditmaterials[First].material[multiMatNum].maps[mapNum].normal != undefined do
											(
												if meditmaterials[First].material[multiMatNum].maps[mapNum].normal.filename != undefined do
											(
												filepath = meditmaterials[First].material[multiMatNum].maps[mapNum].normal.filename
												if doesFileExist filePath == false then
												(
													appendIfUnique MissingMap filepath
													appendIfUnique totalMapPathList filepath
												)
												else
												(
													appendIfUnique UseMap filepath
													appendIfUnique totalMapPathList filepath
												)
											)
											)
											if meditmaterials[First].material[multiMatNum].maps[mapNum].bump_map != undefined do
											(
												if meditmaterials[First].material[multiMatNum].maps[mapNum].bump_map.filename != undefined do
												(
													filepath = meditmaterials[First].material[multiMatNum].maps[mapNum].bump_map.filename
													if doesFileExist filePath == false then
													(
														appendIfUnique MissingMap filepath
														appendIfUnique totalMapPathList filepath
													)
													else
													(
														appendIfUnique UseMap filepath
														appendIfUnique totalMapPathList filepath
													)
												)
											)
										)
										
									(classof meditmaterials[First].material[multiMatNum].maps[mapNum] == Particle_Age):
										(
											if meditmaterials[First].material[multiMatNum].maps[mapNum].map1 != undefined do
											(
												if meditmaterials[First].material[multiMatNum].maps[mapNum].map1.filename != undefined do
												(
													filepath = meditmaterials[First].material[multiMatNum].maps[mapNum].map1.filename
													if doesFileExist filePath == false then
													(
														appendIfUnique MissingMap filepath
														appendIfUnique totalMapPathList filepath
													)
													else
													(
														appendIfUnique UseMap filepath
														appendIfUnique totalMapPathList filepath
													)
												)
											)
											if meditmaterials[First].material[multiMatNum].maps[mapNum].map2 != undefined do
											(
												if meditmaterials[First].material[multiMatNum].maps[mapNum].map2.filename != undefined do
												(
													filepath = meditmaterials[First].material[multiMatNum].maps[mapNum].map2.filename
													if doesFileExist filePath == false then
													(
														appendIfUnique MissingMap filepath
														appendIfUnique totalMapPathList filepath
													)
													else
													(
														appendIfUnique UseMap filepath
														appendIfUnique totalMapPathList filepath
													)
												)
											)
											if meditmaterials[First].material[multiMatNum].maps[mapNum].map3 != undefined do
											(
												if meditmaterials[First].material[multiMatNum].maps[mapNum].map3.filename != undefined do
												(
													filepath = meditmaterials[First].material[multiMatNum].maps[mapNum].map3.filename
													if doesFileExist filePath == false then
													(
														appendIfUnique MissingMap filepath
														appendIfUnique totalMapPathList filepath
													)
													else
													(
														appendIfUnique UseMap filepath
														appendIfUnique totalMapPathList filepath
													)
												)
											)
										)
									dafault:
										(
											appendIfUnique unSupportedType (meditmaterials[First].material[multiMatNum].maps[mapNum] as string)
										)
								)
							)
						)
					)
				)
			)
		)
	)

)

--------------------------------------------------------------------------------------

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
				
				if getFilenameType getfile[First] == ".png" or getFilenameType getfile[First] == ".PNG" or getFilenameType getfile[First] == ".JPG" or getFilenameType getfile[First] == ".jpg" or getFilenameType getfile[First] == ".BMP" or getFilenameType getfile[First] == ".bmp" or getFilenameType getfile[First] == ".JPEG" or getFilenameType getfile[First] == ".jpeg" or getFilenameType getfile[First] == ".TGA" or getFilenameType getfile[First] == ".tga" or getFilenameType getfile[First] == ".TIFF" or getFilenameType getfile[First] == ".tiff" or getFilenameType getfile[First] == ".GIF" or getFilenameType getfile[First] == ".gif" do
				(
					appendIfUnique getImageFile getfile[First]
				)
			)
		)
		getfile = getfiles (getDirectory[getImageFirst] + "*")
	)
)

--------------------------------------------------------------------------------------

fn FindArrayList = 
(
	MapPathSet.lbUseMapName.items = #()
	MapPathSet.IbPathXMapO.items = #()
	MapPathSet.lbNotUseMapName.items = #()
	
	local lbUseMap = #()
	local IbXO = #()

	
	for FirstNum in 1 to RealUseMap.count do
	(
		if Usemap.count != 0 and finditem Usemap RealUseMap[FirstNum] != 0 then
		(
			appendIfUnique lbUseMap RealUseMap[FirstNum]
		)
		else
		(
			appendIfUnique IbXO RealUseMap[FirstNum]
		)
	)
	
	for CompareFirstNum in 1 to unSupportedType.count do
	(
		UnSupportedNum = finditem unSupportedType unSupportedType[CompareFirstNum]
		for CompareSecondNum in 1 to  RealUseMap.count do
		(
			RealUseMapNum = finditem RealUseMap RealUseMap[CompareSecondNum]
			--print RealUseMap[RealUseMapNum]
			if (unSupportedType[UnSupportedNum]) == (RealUseMap[RealUseMapNum]) do
			(
				deleteitem IbXO RealUseMap[RealUseMapNum]
			)
		)
	)
	
	MapPathSet.lbUseMapName.items = deepcopy  lbUseMap
	MapPathSet.IbPathXMapO.items = deepcopy IbXO
	MapPathSet.lbNotUseMapName.items = deepcopy RealMissingMap
	MapPathSet.lbUnsupportedMaterial.items = deepcopy unSupportedType
)

--------------------------------------------------------------------------------------

fn Changemap selectNameInList changeMapPath = 
(
	for First in 1 to meditmaterials.count do
	(
		case of
		(
			(classof meditmaterials[First] == standardMaterial):
			(	
				--Search Maps
				for mapNum = 1 to meditmaterials[First].maps.count do
				(
					if meditmaterials[First].maps[mapNum] != undefined do
					(
						case of
						(
							(classof meditmaterials[First].maps[mapNum] == Bitmaptexture):
								(
									if meditmaterials[First].maps[mapNum].filename == selectNameInList do
									(
										meditMaterials[First].maps[mapNum].filename = changeMapPath
									)
								)
							(classof meditmaterials[First].maps[mapNum] == Normal_Bump):
								(
									if meditmaterials[First].maps[mapNum].normal != undefined and meditmaterials[First].maps[mapNum].normal.filename == selectNameInList do
									(
										meditmaterials[First].maps[mapNum].normal.filename = changeMapPath
									)
									if meditmaterials[First].maps[mapNum].bump_map != undefined and meditmaterials[First].maps[mapNum].bump_map.filename == selectNameInList do
									(
										meditmaterials[First].maps[mapNum].bump_map.filename = changeMapPath
									)
								)
								
							(classof meditmaterials[First].maps[mapNum] == Particle_Age):
								(
									if meditmaterials[First].maps[mapNum].map1 != undefined and meditmaterials[First].maps[mapNum].map1.filename == selectNameInList do
									(
										meditmaterials[First].maps[mapNum].map1.filename  = changeMapPath
									)
									if meditmaterials[First].maps[mapNum].map2 != undefined and meditmaterials[First].maps[mapNum].map2.filename == selectNameInList do
									(
										meditmaterials[First].maps[mapNum].map2.filename  = changeMapPath
									)
									if meditmaterials[First].maps[mapNum].map3 != undefined and meditmaterials[First].maps[mapNum].map3.filename == selectNameInList do
									(
										meditmaterials[First].maps[mapNum].map3.filename  = changeMapPath
									)
								)
							dafault:
									(
										appendIfUnique unSupportedType (meditmaterials[First].maps[mapNum] as string)
									)
						)
					)
				)
			)
			(classof meditmaterials[First] == multiMaterial):
			(
				for multiMatNum = 1 to meditmaterials[First].material.count do
				(
					if meditmaterials[First].material[multiMatNum] != undefined and classof meditMaterials[First].material[multiMatNum] == standardMaterial do
					(
						for mapNum = 1 to meditmaterials[First].material[multiMatNum].maps.count do
						(
							if meditmaterials[First].material[multiMatNum].maps[mapNum] != undefined  do
							(
								case of
								(
									(classof meditmaterials[First].material[multiMatNum].maps[mapNum] == Bitmaptexture):
										(
											if meditmaterials[First].material[multiMatNum].maps[mapNum].filename == selectNameInList do
											(
												meditmaterials[First].material[multiMatNum].maps[mapNum].filename = changeMapPath
											)
										)
									(classof meditmaterials[First].material[multiMatNum].maps[mapNum] == Normal_Bump):
										(
											if meditmaterials[First].material[multiMatNum].maps[mapNum].normal != undefined and meditmaterials[First].material[multiMatNum].maps[mapNum].normal.filename == selectNameInList do
											(
												meditmaterials[First].material[multiMatNum].maps[mapNum].normal.filename = changeMapPath
											)
											if meditmaterials[First].material[multiMatNum].maps[mapNum].bump_map != undefined and meditmaterials[First].material[multiMatNum].maps[mapNum].bump_map.filename == selectNameInList do
											(
												meditmaterials[First].material[multiMatNum].maps[mapNum].bump_map.filename = changeMapPath
											)
										)
										
									(classof meditmaterials[First].material[multiMatNum].maps[mapNum] == Particle_Age):
										(
											if meditmaterials[First].material[multiMatNum].maps[mapNum].map1 != undefined and meditmaterials[First].material[multiMatNum].maps[mapNum].map1.filename == selectNameInList do
											(
												meditmaterials[First].material[multiMatNum].maps[mapNum].map1.filename  = changeMapPath
											)
											if meditmaterials[First].material[multiMatNum].maps[mapNum].map2 != undefined and meditmaterials[First].material[multiMatNum].maps[mapNum].map2.filename == selectNameInList do
											(
												meditmaterials[First].material[multiMatNum].maps[mapNum].map2.filename  = changeMapPath
											)
											if meditmaterials[First].material[multiMatNum].maps[mapNum].map3 != undefined and meditmaterials[First].material[multiMatNum].maps[mapNum].map3.filename == selectNameInList do
											(
												meditmaterials[First].material[multiMatNum].maps[mapNum].map3.filename  = changeMapPath
											)
										)
									dafault:
										(
											appendIfUnique unSupportedType (meditmaterials[First].material[multiMatNum].maps[mapNum] as string)
										)	
								)
							)
						)
					)
				)
			)
		)
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
						if objects[objectNum].material.maps[mapNum] != undefined  do
						(
							case of
							(
								(classof objects[objectNum].material.maps[mapNum] == Bitmaptexture):
									(
										if objects[objectNum].material.maps[mapNum].filename == selectNameInList do
										(
											objects[objectNum].material.maps[mapNum].filename = changeMapPath
										)
									)
								(classof objects[objectNum].material.maps[mapNum] == Normal_Bump):
									(
										if objects[objectNum].material.maps[mapNum].normal != undefined and objects[objectNum].material.maps[mapNum].normal.filename == selectNameInList do
										(
											objects[objectNum].material.maps[mapNum].normal.filename = changeMapPath
										)
										
										if objects[objectNum].material.maps[mapNum].bump_map != undefined and objects[objectNum].material.maps[mapNum].bump_map.filename == selectNameInList do
										(
											objects[objectNum].material.maps[mapNum].bump_map.filename = changeMapPath
										)
									)
								(classof objects[objectNum].material.maps[mapNum] == Particle_Age):
									(
										if objects[objectNum].material.maps[mapNum].map1 != undefined  and objects[objectNum].material.maps[mapNum].map1.filename == selectNameInList do
										(
											objects[objectNum].material.maps[mapNum].map1.filename = changeMapPath
										)
										
										if objects[objectNum].material.maps[mapNum].map2 != undefined and objects[objectNum].material.maps[mapNum].map2.filename == selectNameInList do
										(
											objects[objectNum].material.maps[mapNum].map2.filename = changeMapPath
										)
										
										if objects[objectNum].material.maps[mapNum].map3 != undefined and objects[objectNum].material.maps[mapNum].map3.filename == selectNameInList do
										(
											objects[objectNum].material.maps[mapNum].map3.filename = changeMapPath											
										)
									)
								dafault:
										(
											appendIfUnique unSupportedType (objects[objectNum].material.maps[mapNum] as string)
										)	
							)
						)
					)
				)
				(classof objects[objectNum].material == multiMaterial):
				(
					for multiMatNum = 1 to objects[objectNum].material.count do
					(
						if objects[objectNum].material[multiMatNum] != undefined and classof objects[objectNum].material[multiMatNum] == standardMaterial do
						(
							for mapNum = 1 to objects[objectNum].material[multiMatNum].maps.count do
							(
								if objects[objectNum].material[multiMatNum].maps[mapNum] != undefined  do
								(
									case of
									(
										(classof objects[objectNum].material[multiMatNum].maps[mapNum] == Bitmaptexture): 
											( 
												if objects[objectNum].material[multiMatNum].maps[mapNum].filename == selectNameInList do
												(
													objects[objectNum].material[multiMatNum].maps[mapNum].filename == changeMapPath
												)
											)
										(classof objects[objectNum].material[multiMatNum].maps[mapNum] == Normal_Bump):
											(
												if objects[objectNum].material[multiMatNum].maps[mapNum].normal != undefined and objects[objectNum].material[multiMatNum].maps[mapNum].normal.filename == selectNameInList do
												(
													objects[objectNum].material[multiMatNum].maps[mapNum].normal.filename = changeMapPath
												)
												if objects[objectNum].material[multiMatNum].maps[mapNum].bump_map != undefined and objects[objectNum].material[multiMatNum].maps[mapNum].bump_map.filename == selectNameInList do
												(
													objects[objectNum].material[multiMatNum].maps[mapNum].bump_map.filename = changeMapPath
												)
											)
										(classof objects[objectNum].material[multiMatNum].maps[mapNum] == Particle_Age):
											(
												if objects[objectNum].material[multiMatNum].maps[mapNum].map1 != undefined and objects[objectNum].material[multiMatNum].maps[mapNum].map1.filename == selectNameInList do
												(
													objects[objectNum].material[multiMatNum].maps[mapNum].map1.filename = changeMapPath
												)
												if objects[objectNum].material[multiMatNum].maps[mapNum].map2 != undefined and objects[objectNum].material[multiMatNum].maps[mapNum].map2.filename == selectNameInList do
												(
													objects[objectNum].material[multiMatNum].maps[mapNum].map2.filename = changeMapPath
												)
												if objects[objectNum].material[multiMatNum].maps[mapNum].map3 != undefined and objects[objectNum].material[multiMatNum].maps[mapNum].map3.filename == selectNameInList do
												(
													objects[objectNum].material[multiMatNum].maps[mapNum].map3.filename = changeMapPath
												)
											)
										dafault:
											(
												appendIfUnique unSupportedType (objects[objectNum].material[multiMatNum].maps[mapNum] as string)
											)	
									)
								)
							)
						)
					)
				)
			)
		)
	)
)

--------------------------------------------------------------------------------------
	
fn deletemap selectNameInList = 
(
	defaultMtlLibFile = MeditUtilities.getDefaultLibraryFile()
	if defaultMtlLibFile != undefined do
	(
		defaultMtlLib = loadTempMaterialLibrary defaultMtlLibFile
	)
	
	for First in 1 to meditmaterials.count do
	(
		case of
		(
			(classof meditmaterials[First] == standardMaterial):
			(	
				--Search Maps
				for mapNum = 1 to meditmaterials[First].maps.count do
				(
					if meditmaterials[First].maps[mapNum] != undefined do
					(
						case of
						(
							(classof meditmaterials[First].maps[mapNum] == Bitmaptexture):
								(
									if meditmaterials[First].maps[mapNum] != undefined and meditmaterials[First].maps[mapNum].filename == selectNameInList do
									(
										meditMaterials[First].maps[mapNum] = undefined
									)
								)
							(classof meditmaterials[First].maps[mapNum] == Normal_Bump):
								(
									if meditmaterials[First].maps[mapNum].normal != undefined and meditmaterials[First].maps[mapNum].normal.filename == selectNameInList do
									(
										meditmaterials[First].maps[mapNum].normal = undefined
									)
									if meditmaterials[First].maps[mapNum].bump_map != undefined and meditmaterials[First].maps[mapNum].bump_map.filename == selectNameInList do
									(
										meditmaterials[First].maps[mapNum].bump_map = undefined
									)
								)
								
							(classof meditmaterials[First].maps[mapNum] == Particle_Age):
								(
									if meditmaterials[First].maps[mapNum].map1 != undefined and meditmaterials[First].maps[mapNum].map1.filename == selectNameInList do
									(
										meditmaterials[First].maps[mapNum].map1 = undefined
									)
									if meditmaterials[First].maps[mapNum].map2 != undefined and meditmaterials[First].maps[mapNum].map2.filename == selectNameInList do
									(
										meditmaterials[First].maps[mapNum].map2 = undefined
									)
									if meditmaterials[First].maps[mapNum].map3 != undefined and meditmaterials[First].maps[mapNum].map3.filename == selectNameInList do
									(
										meditmaterials[First].maps[mapNum].map3 = undefined
									)
								)
						)
					)
				)
			)
			(classof meditmaterials[First] == multiMaterial):
			(
				for multiMatNum = 1 to meditmaterials[First].material.count do
				(
					if meditmaterials[First].material[multiMatNum] != undefined and classof meditMaterials[First].material[multiMatNum] == standardMaterial do
					(
						for mapNum = 1 to meditmaterials[First].material[multiMatNum].maps.count do
						(
							if meditmaterials[First].material[multiMatNum].maps[mapNum] != undefined  do
							(
								case of
								(
									(classof meditmaterials[First].material[multiMatNum].maps[mapNum] == Bitmaptexture):
										(
											if meditmaterials[First].material[multiMatNum].maps[mapNum].filename == selectNameInList and meditmaterials[First].material[multiMatNum].maps[mapNum].filename == selectNameInList do
											(
												meditmaterials[First].material[multiMatNum].maps[mapNum] = undefined
											)
										)
									(classof meditmaterials[First].material[multiMatNum].maps[mapNum] == Normal_Bump):
										(
											if meditmaterials[First].material[multiMatNum].maps[mapNum].normal != undefined and meditmaterials[First].material[multiMatNum].maps[mapNum].normal.filename == selectNameInList do
											(
												meditmaterials[First].material[multiMatNum].maps[mapNum].normal = undefined
											)
											if meditmaterials[First].material[multiMatNum].maps[mapNum].bump_map != undefined and meditmaterials[First].material[multiMatNum].maps[mapNum].bump_map.filename == selectNameInList do
											(
												meditmaterials[First].material[multiMatNum].maps[mapNum].bump_map = undefined
											)
										)
										
									(classof meditmaterials[First].material[multiMatNum].maps[mapNum] == Particle_Age):
										(
											if meditmaterials[First].material[multiMatNum].maps[mapNum].map1 != undefined and meditmaterials[First].material[multiMatNum].maps[mapNum].map1.filename == selectNameInList do
											(
												meditmaterials[First].material[multiMatNum].maps[mapNum].map1 = undefined
											)
											if meditmaterials[First].material[multiMatNum].maps[mapNum].map2 != undefined and meditmaterials[First].material[multiMatNum].maps[mapNum].map2.filename == selectNameInList do
											(
												meditmaterials[First].material[multiMatNum].maps[mapNum].map2 = undefined
											)
											if meditmaterials[First].material[multiMatNum].maps[mapNum].map3 != undefined and meditmaterials[First].material[multiMatNum].maps[mapNum].map3.filename == selectNameInList do
											(
												meditmaterials[First].material[multiMatNum].maps[mapNum].map3 = undefined
											)
										)
								)
							)
						)
					)
				)
			)
		)
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
						if objects[objectNum].material.maps[mapNum] != undefined  do
							(
								case of
								(
									(classof objects[objectNum].material.maps[mapNum] == Bitmaptexture):
										(
											if objects[objectNum].material.maps[mapNum] != undefined and objects[objectNum].material.maps[mapNum].filename == selectNameInList do
											(
												objects[objectNum].material.maps[mapNum] = undefined
											)
										)
									(classof objects[objectNum].material.maps[mapNum] == Normal_Bump):
										(
											if objects[objectNum].material.maps[mapNum].normal != undefined and objects[objectNum].material.maps[mapNum].normal.filename == selectNameInList do
											(
												objects[objectNum].material.maps[mapNum].normal = undefined
											)
											
											if objects[objectNum].material.maps[mapNum].bump_map != undefined and objects[objectNum].material.maps[mapNum].bump_map.filename == selectNameInList do
											(
												objects[objectNum].material.maps[mapNum].bump_map = undefined
											)
										)
									(classof objects[objectNum].material.maps[mapNum] == Particle_Age):
										(
											if objects[objectNum].material.maps[mapNum].map1 != undefined  and objects[objectNum].material.maps[mapNum].map1.filename == selectNameInList do
											(
												objects[objectNum].material.maps[mapNum].map1 = undefined
											)
											
											if objects[objectNum].material.maps[mapNum].map2 != undefined and objects[objectNum].material.maps[mapNum].map2.filename == selectNameInList do
											(
												objects[objectNum].material.maps[mapNum].map2 = undefined
											)
											
											if objects[objectNum].material.maps[mapNum].map3 != undefined and objects[objectNum].material.maps[mapNum].map3.filename == selectNameInList do
											(
												objects[objectNum].material.maps[mapNum].map3 = undefined								
											)
										)
								)
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
									case of
									(
										(classof objects[objectNum].material[multiMatNum].maps[mapNum] == Bitmaptexture): 
											( 
												if objects[objectNum].material[multiMatNum].maps[mapNum].filename == selectNameInList do
												(
													objects[objectNum].material[multiMatNum].maps[mapNum] = undefined
												)
											)
										(classof objects[objectNum].material[multiMatNum].maps[mapNum] == Normal_Bump):
											(
												if objects[objectNum].material[multiMatNum].maps[mapNum].normal != undefined and objects[objectNum].material[multiMatNum].maps[mapNum].normal.filename == selectNameInList do
												(
													objects[objectNum].material[multiMatNum].maps[mapNum].normal = undefined
												)
												if objects[objectNum].material[multiMatNum].maps[mapNum].bump_map != undefined and objects[objectNum].material[multiMatNum].maps[mapNum].bump_map.filename == selectNameInList do
												(
													objects[objectNum].material[multiMatNum].maps[mapNum].bump_map = undefined
												)
											)
										(classof objects[objectNum].material[multiMatNum].maps[mapNum] == Particle_Age):
											(
												if objects[objectNum].material[multiMatNum].maps[mapNum].map1 != undefined and objects[objectNum].material[multiMatNum].maps[mapNum].map1.filename == selectNameInList do
												(
													objects[objectNum].material[multiMatNum].maps[mapNum].map1 = undefined
												)
												if objects[objectNum].material[multiMatNum].maps[mapNum].map2 != undefined and objects[objectNum].material[multiMatNum].maps[mapNum].map2.filename == selectNameInList do
												(
													objects[objectNum].material[multiMatNum].maps[mapNum].map2 = undefined
												)
												if objects[objectNum].material[multiMatNum].maps[mapNum].map3 != undefined and objects[objectNum].material[multiMatNum].maps[mapNum].map3.filename == selectNameInList do
												(
													objects[objectNum].material[multiMatNum].maps[mapNum].map3 = undefined
												)
											) 
									)
								)
							)
						)
					)
				)
			)
		)
	)
)

--------------------------------------------------------------------------------------

fn addmap mapfile =
(
	local mapfileN=mapfile as string
	
	local index=finditem mapfiles mapfileN
	if index == 0 do 
	(
		append mapfiles mapfileN
	)
)

--------------------------------------------------------------------------------------

fn RealFindMap =
(
	RealUseMap = #()
	RealMissingMap = #()
	mapfiles=#()
	
	enumeratefiles addmap
	RealUseMap = deepcopy mapfiles
	mapfiles=#()
	enumeratefiles addmap #missing
	RealMissingMap = deepcopy mapfiles
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
	
	
	--------------------------------------------------------------------------------------
	
	edittext ChangeFilePath "File Path: " offset:[0,144] width: 550
	
	--------------------------------------------------------------------------------------
	
	dropdownlist ddlSameFilenameInMaxPath "Same file name in the max file path"  width: 480 offset:[0,-210]
	
	--------------------------------------------------------------------------------------
	
	ListBox lbUnsupportedMaterial "Unsupported Material List" height:10 width:150 offset:[575,-23]

--=======================================================================================
--=======================================================================================

	on MapPathSet open do
	(
		RealFindMap()
		getFilePath()
		FindArrayList()
	)
	
	--------------------------------------------------------------------------------------
	
	on btnSameFilenameInMaxPath pressed do
	(
		if IbPathXMapO.selection !=0 and ddlSameFilenameInMaxPath.items.count > 0 then
		(
			Changemap IbPathXMapO.items[IbPathXMapO.selection] ddlSameFilenameInMaxPath.items[ddlSameFilenameInMaxPath.selection]
			RealFindMap()
			getFilePath()
			FindArrayList()
		)
		else
		(
			messagebox "Select Path!"
		)			
			IbPathXMapO.selection = 0
	)
	
	--------------------------------------------------------------------------------------
	
	on btnDeleteMap pressed do
	(
		if IbPathXMapO.selection == 0 and lbUseMapName.selection == 0 and lbNotUseMapName.selection == 0 do
		(
			messagebox "Select Map"
			
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
			RealFindMap()
			getFilePath()
			FindArrayList()
		)
		
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
		getFilePath()

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
			ddlSameFilenameInMaxPath.items = #()
			for i in 1 to totalMapPathList.count do
			(
				if totalMapPathList[i] == IbPathXMapO.items[Num] do
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
			)
			
			MapNameNum = Num
			MapNameNum = getFilenamePath IbPathXMapO.items[Num]
			
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
			for i in 1 to totalMapPathList.count do
			(
				if totalMapPathList[i] == lbUseMapName.items[Num] do
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
		local NoneArray = #("-None-")
		try
		(
			for i in 1 to totalMapPathList.count do
			(
				if totalMapPathList[i] == lbNotUseMapName.items[Num] then
				(
					mlbObject.items = totalObjectList[i]
				)
				
				if finditem totalMapPathList  lbNotUseMapName.items[Num] == 0 do
				(
					mlbObject.items = NoneArray
				)
			)
	
			if Num != 0 do
			(
				IbPathXMapO.selection = 0
				lbUseMapName.selection = 0
				btnOpenFolderInExplorer.enabled = false 
				ddlSameFilenameInMaxPath.enabled = false
				
				bmShowImage.bitmap = (bitmap 150 150)
				
			)
			
			MapNameNum = Num
			MapNameNum = getFilenamePath lbNotUseMapName.items[Num]
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
				macros.run "Medit Tools" "clear_medit_slots"
				for objectNum = 1 to objects.count do
				(
					objects[objectNum].material = undefined
				)
				destroydialog rollResetAllMaterial
				RealFindMap()
				getFilePath()
				FindArrayList()
			)
				
			on btnNo pressed do
			(
				destroydialog rollResetAllMaterial
			)
		)
		createdialog rollResetAllMaterial width: 150 height: 75
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
				RealFindMap()
				getFilePath()
				FindArrayList()
			)
		)
		else
		(
			messagebox "Select Path!"
				
		)
		ChangeFilePath.text = ""
	
	)
	 --------------------------------------------------------------------------------------

)
createdialog MapPathSet width: 750 height: 500
