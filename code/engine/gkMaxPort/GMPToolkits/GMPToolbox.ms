--//////////////////////////////////////////////////////////////////////////
--//
--// K&K Studio GameKnife ENGINE Source File
--//
--// Name:   	GMPToolbox.ms
--// Desc:		
--// 
--// Author:  Kaiming
--// Date:	2011/9/28 
--// Modify:	2011/9/28
--// 
--//////////////////////////////////////////////////////////////////////////

-- subrollout for scene access
rollout rltSubRolloutSceneAccess "Scene Task"
(
	edittext edtSceneName "Scene File:" fieldWidth:160 labelOnTop:true readOnly:true
	
	button btnInitScene "��������" height:20 width:150 
	button btnSyncScene "ͬ������" height:20 width:150 
	
	
	on btnSyncScene pressed do
	(
		GMPSyncScene()
	)


	on btnInitScene pressed do
	(
		if(edtSceneName.text == "") then
		(
			--theClasses = gkO.classes
			f = getSaveFileName \
				caption: "Save File As..."\
				filename: "GMP_default.GKS"\
				types:"gkScene(*.gks)"

			--theClasses = exporterPlugin.classes
			
			--print theClasses 
			
			if(f == undefine) then
			(
				messageBox "please choose to save as scene file" title:"not save"
			)
			else
			(
				exportFile f

				f = pathConfig.stripPathToLeaf f
				--print  f
			
				edtSceneName.text = f	
			)

	
		)
	)
)

materialcount = 1

-- subrollout for object tasks
rollout rltSubRolloutObjectTask "Object Task"
(
	label l1 "�����������ļ�����"
	button btnCreateOBJ "CreateObj" height:20 width:150
	--button btnConvertOBJ "ConvertObj" height:20 width:150
	
	label l2 "��������洢"
	button btnSaveOBJ "SaveObj As" height:20 width:150
	
	label l3 "ͨ��ת��"
	button btnAutoMergeByMtl "1.�Զ����ݲ��ʺϲ�" height:20 width:150
	button btnTranslateMtl "2.ת����ѡ�������" height:20 width:150
	button btnSaveOBJFast "3.�洢��ѡ���嵽����" height:20 width:150
	
	label l4 "ȫ�ֹ���"
	button btnSelectByMaterial "+���ݲ���ѡ��" height:20 width:150
	button btnMergeBySelection "+�ϲ���ѡ" height:20 width:150
	button btnNameNormalize "+��������������" height:20 width:150
	button btnTextureRenamer "+��������������" height:20 width:150
	
	
	button btnRefreshMedit "+���³������ʵ��༭��" height:20 width:150
	
	button btnResolveMaterial "+ʹ���Ӳ���1" height:20 width:150
	
	button btnDetachByID "+��ID����" height:20 width:150
	
	button btnDivideMatByID "+�������" height:20 width:150

	
	
	function selectByMtl mtlindex =
	(
		select (for o in objects where o.material == sceneMaterials[mtlindex] collect o)	
	)
	
	function mergeSelection =
	(
		for obj in selection do
		(
			--converttomesh obj
			convertToPoly obj
		)
		
		objarr = for i in $ collect i
		motherobj = objarr[1]

		for i = 2 to selection.count do
		(	
			polyop.attach motherobj objarr[i]			
		)	
	)
	
	
	on btnDivideMatByID pressed do
	(
		--for i = 1 to 200 do
		--(		
			for o in objects do
			(
				strings = filterString (o.name) "@"
				if( strings != undefined) then
				(
					if (strings.count > 1) then
					(
						index = strings[strings.count] as integer
						if( classOf(o.material) == MultiMaterial) then
						(
							if( o.material[index] != undefined )then
							(				
								o.material = copy o.material[index]
								o.material.name = ("gkMtl" + index as string)
							)							
						)
			
					)
				)

			)
		--)
		
	)
	
	on btnDetachByID pressed do
	(	
		obj = $
		
		for i = 1 to 200 do
		(
			obj.selectByMaterial i
			polyOp.detachFaces obj (polyop.getFaceSelection obj)  delete:true asNode:true name:(obj.name + "@" + i as string)
			
			print ("matID:" + i as string + " processed.")
		)
		
	)
	
	
	
	on btnResolveMaterial pressed do
	(
		for obj in selection do
		(
			if ( classOf(obj.material) == multimaterial) then
			(
				obj.material = obj.material[1]
			)
		)	
	)
	on btnRefreshMedit pressed do
	(
		for i = 1 to sceneMaterials.count do
		(
			if (i < 25) then
				meditMaterials[i] = sceneMaterials[i]
		)
	)
	
	on btnNameNormalize pressed do
	(
		local mtlcount = 0
		for mtl in sceneMaterials do
		(
			mtlcount = mtlcount + 1
			scenePurname = maxFileName
			scenePurname = tolower scenePurname
			local index = findString scenePurname ".max"
			if (index != undefine) then
				scenePurname = substring scenePurname 1 (index-1)
			scenePurname = "mt_T(" + mtlcount as string + ")@" + scenePurname
			
			print scenePurname
			mtl.name = scenePurname
		)	
	)
	
	on btnTextureRenamer pressed do
	(
		local mtlcount = 0
		for mtl in sceneMaterials do
		(
				
			if ( classOf(mtl) == Standard) then
			(
			
				map = mtl.diffuseMap
			
				if( classOf(map) == BitmapTexture) then
				(
				outpath = (getdir #maxroot)	
				outpath = pathConfig.removePathLeaf outpath
				outpath = pathConfig.appendpath outpath "media/Textures/Temp/"
				outpath = outpath + mtl.name + ".dds"
				
				copyfile map.filename outpath
					
				print (map.filename + " to " + outpath)
				--copy to outpah
				map.filename = outpath
				map.reload
				--rm = map.bitmap
			
				)
			)
		)	
	)
	
	on btnTranslateMtl pressed do
	(
		for obj in selection do
		(

			
		myname = obj.material.name + "@gke"
		if ( classOf(obj.material) == Standard) then
		(
			
			map = obj.material.diffuseMap
				diffusecol = obj.material.diffuse
				specpow = obj.material.Glossiness
				speccol = obj.material.specular
			
			
			if( classOf(map) == BitmapTexture or classOf(map) == Bricks ) then
			(
			outpath = (getdir #maxroot)
			print "get bricks"
			
			outpath = pathConfig.removePathLeaf outpath
			outpath = pathConfig.appendpath outpath "media/Textures/Temp/"
			outpath = outpath + obj.material.name + ".tga"
			
			
			if( classOf(map) == BitmapTexture ) then
			(
				rm = map.bitmap
			)
			else			
			(
				print outpath
				rm = renderMap map size:[512,512] \
				fileName:outpath
				save rm
				close rm
			)
			
			normalpath = (getdir #maxroot)
			normalpath = pathConfig.removePathLeaf normalpath
			normalpath = pathConfig.appendpath normalpath "engine/assets/flat.tga"
			
				
			
			outpath = (getdir #maxroot)
			outpath = pathConfig.appendpath outpath "Maps/fx/shader/ksBase.fx"
			obj.material = DirectX_9_Shader effectfile:outpath
			obj.material.name = myname
			
			
			
			obj.material.g_SpecularPow = 4--specpow
			obj.material.g_Specular = color 0 0 0--speccol
			obj.material.g_Diffuse = color 128 128 128--speccol
			
			obj.material.seteffectbitmap 1 rm
			
			normalmap = openBitMap normalpath
			obj.material.seteffectbitmap 2 normalmap
			)
			else
			(

				
				outpath = (getdir #maxroot)
				outpath = pathConfig.appendpath outpath "Maps/fx/shader/ksBase.fx"
				obj.material = DirectX_9_Shader effectfile:outpath
				obj.material.name = myname
				obj.material.g_Diffuse = diffusecol
				normalpath = (getdir #maxroot)
				normalpath = pathConfig.removePathLeaf normalpath
				normalpath = pathConfig.appendpath normalpath "engine/assets/grey.tga"
				
				
				normalmap = openBitMap normalpath
				obj.material.seteffectbitmap 1 normalmap
				close normalmap
				
				normalpath = (getdir #maxroot)
				normalpath = pathConfig.removePathLeaf normalpath
				normalpath = pathConfig.appendpath normalpath "engine/assets/flat.tga"			
				normalmap = openBitMap normalpath
				obj.material.seteffectbitmap 2 normalmap	
			)
			
			continue
		)
		
		(
			outpath = (getdir #maxroot)
			outpath = pathConfig.appendpath outpath "Maps/fx/shader/ksBase.fx"
			obj.material = DirectX_9_Shader effectfile:outpath
			obj.material.name = myname
			normalpath = (getdir #maxroot)
			normalpath = pathConfig.removePathLeaf normalpath
			normalpath = pathConfig.appendpath normalpath "engine/assets/grey.tga"
			
			
			normalmap = openBitMap normalpath
			obj.material.seteffectbitmap 1 normalmap
			close normalmap
			
			normalpath = (getdir #maxroot)
			normalpath = pathConfig.removePathLeaf normalpath
			normalpath = pathConfig.appendpath normalpath "engine/assets/flat.tga"			
			normalmap = openBitMap normalpath
			obj.material.seteffectbitmap 2 normalmap
		)
		)
		
		
		for obj in selection do
		(
			for mtl in sceneMaterials do
			(
				if( obj.material.name ==  mtl.name) then
				(
					obj.material = mtl
				)
			)
		)
		
		--if map.classid
	)
	
	on btnAutoMergeByMtl pressed do
	(
		for i = 1 to sceneMaterials.count do
		(
			selectByMtl i
			mergeSelection()
		)			
	)
	
	on btnSelectByMaterial pressed do
	(
		
		selectByMtl materialcount
		
		materialcount = materialcount + 1
		
		if(materialcount > sceneMaterials.count) then
			materialcount = 1
	) 
	
	on btnMergeBySelection pressed do
	(
		mergeSelection()
	) 
	
	on btnCreateOBJ pressed do
	(
		GMPCreateObj()
	) 
	
	on btnSaveOBJ pressed do
	(
		if ($ == undefined) then
		()
		else
		(
			converttomesh $
			update $
			GMPSaveObjAs()
		)
	) 
	
	on btnSaveOBJFast pressed do
	(
		--thisqueue = #()
		thisqueue = selection as array
		count = 0
		for i = 1 to thisqueue.count do
		(
			if (thisqueue[i] == undefined) then
			()
			else
			(
				print "converting..."
				converttomesh thisqueue[i]
				update thisqueue[i]
				
				clearSelection()
				select thisqueue[i]
				
				if(count == 0) then
					GMPSaveObjFast false
				else
					GMPSaveObjFast true
				
				count = count +1
			)
		)
		
		
	)


		
)


-- subrollout for object tasks
rollout rltSubRolloutTodTask "Time of day Task"
(
	slider tilt "Time" orient:#horizon ticks:0 range:[0,24,0]
	
	on tilt changed val do GMPChangeTOD val


)


-- main toolbox holder
rollout rltGkMaxPortToolBox "GMP ToolBox"
(
	button btnDockLeft "<---" height:16 width:50 pos:[0,0]
	button btnUndock "GMP ToolBox" height:16 width:90 pos:[50,0] 
	button btnDockRight "--->" height:16 width:50 pos:[140,0] 
	
	subrollout rltToolHolder height:480 width:190 pos:[0,48]
	
	on btnDockLeft pressed do
	(
		try
			(
				local sDockState = cui.getDockState rltGkMaxPortToolBox
			)
			catch
			(--not a registered dialog bar
				local sDockState = undefined
			)
			
			if sDockState == undefined then
			(--register if not yet done
				cui.RegisterDialogBar rltGkMaxPortToolBox style:#() maxsize:[190,1200]
			)
			cui.DockDialogBar rltGkMaxPortToolBox #cui_dock_left
			
			--rltGkMaxPortToolBox.rltToolHolder.height = rltGkMaxPortToolBox .height - rltGkMaxPortToolBox.rltToolHolder.pos[2]
		
	)
	
		
	on btnDockRight pressed do
	(
		try
		(
			local sDockState = cui.getDockState rltGkMaxPortToolBox
		)
		catch
		(--not a registered dialog bar
			local sDockState = undefined
		)
		
		if sDockState == undefined then
		(--register if not yet done
			cui.RegisterDialogBar rltGkMaxPortToolBox style:#() maxsize:[190,1200]
		)
		cui.DockDialogBar rltGkMaxPortToolBox #cui_dock_right
		
		--rltCryMaxToolBox.rltToolHolder.height = rltCryMaxToolBox.height - rltCryMaxToolBox.rltToolHolder.pos[2]
	)
	
	on btnUndock pressed do
	(
		try
		(
			local sDockState = cui.getDockState rltGkMaxPortToolBox 
		)
		catch
		(--not a registered dialog bar
			local sDockState = undefined
		)
		
		if sDockState != undefined then
		(--float and undock if registerd
			cui.FloatDialogBar rltGkMaxPortToolBox 
			cui.UnRegisterDialogBar rltGkMaxPortToolBox 
		)
		
		--rltCryMaxToolBox.rltToolHolder.height = rltCryMaxToolBox.height - rltCryMaxToolBox.rltToolHolder.pos[2]
	)

)

-- initial work
createDialog (rltGkMaxPortToolBox) height:800 width:190 style:#(#style_titlebar, #style_resizing, #style_sysmenu) lockWidth:true


addSubrollout rltGkMaxPortToolBox.rltToolHolder rltSubRolloutSceneAccess
addSubrollout rltGkMaxPortToolBox.rltToolHolder rltSubRolloutObjectTask 
addSubrollout rltGkMaxPortToolBox.rltToolHolder rltSubRolloutTodTask 