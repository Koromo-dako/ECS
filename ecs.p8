pico-8 cartridge // http://www.pico-8.com
version 27
__lua__

debug=true

function newheart(x,y)
	--heart
	return
		newentity({
		--position
		position=newposition(x,y,8,8),
		--sprite
		--sprite=newsprite({{64,16}},1),
		sprite=newsprite({idle={images={{64,16}},flip=false}}),
		--bounds
		bounds=newbounds(1,1,6,6),
		item='heart'
		})
	end

database={}
	database.heart={
		maxstack=2,
		position={w=8,h=8},
		sprite={idle={images={{64,16}},flip=false}},
		newfunction=newheart
	}


cutscene={}
cutscene.scene={}
cutscene.step=1
cutscene.timer=0
cutscene.wait=function(t)
cutscene.timer+=1
if cutscene.timer>t
	then cutscene.advance()
	end
end
cutscene.advance=function()
	if #cutscene.scene>0 then
		cutscene.step+=1
		cutscene.timer=0
	end
end
cutscene.update=function()
	if #cutscene.scene>0 then
		if cutscene.step>#cutscene.scene then
			--reset
			cutscene.scene={}
			cutscene.step=1
			cutscene.timer=0
		else
			--run next part of scene
			local f=cutscene.scene[cutscene.step][1]
			local p1=cutscene.scene[cutscene.step][2]
			local p2=cutscene.scene[cutscene.step][3]
			local p3=cutscene.scene[cutscene.step][4]
			f(p1,p2,p3)
		end
	end
end

curtain = {}
curtain.state = 'up'
curtain.height = 0
curtain.speed = 4
curtain.set = function(s)
 curtain.state = s
 cutscene.advance()
end
curtain.draw = function()
  -- top
  rectfill(0,-1,128,curtain.height-1,0)
  --bottom
  rectfill(0,129,128,129-curtain.height,0)
end
curtain.update = function()
 if curtain.state == 'up' then
   if curtain.height > 0 then
     curtain.height -= curtain.speed
   end
 end
 if curtain.state == 'down' then
   if curtain.height <= 64 then
     curtain.height += curtain.speed
   end
 end
end

outside={}
outside.x=0
outside.y=0
outside.w=32
outside.h=16
outside.bg=0

shop={}
shop.x=32
shop.y=0
shop.w=11
shop.h=10
shop.bg=0

currentroom=outside
function setcurrentroom(room)
	currentroom=room
	cutscene.advance()
end

function moveroom(room,entity,x,y)
	cutscene.scene={
	{curtain.set,'down'},
	{cutscene.wait,20},
	{setcurrentroom,room},
	{entity.position.setposition,x,y},
	{curtain.set,'up'},
	{cutscene.wait,20}
}
end

--entity table
entities={}


function printoutline(t,x,y,c)
--draw outline
for xoff=-1,1 do
	for yoff=-1,1 do
		print(t,x+xoff,y+yoff,0)
	end
end
	--draw text
	print(t,x,y,c)
end

function ycomparison(a,b)
	if a.position==nil or b.position==nil
	then return false
	end

	return a.position.y+a.position.h
		>b.position.y+b.position.h
end

function sort(list,comparison)
	for i=1,#list do
		local j=i
		while j>1 and comparison(list[j-1],list[j])
	 do
			list[j],list[j-1]=
			list[j-1],list[j]
			j-=1
		end
	end
end


function canwalk(x,y)

return not fget(mget
	(x/8,y/8),7)

end

function newinventory(s,v,x,y,items)
	local i={}
	i.size=s
	i.visible=v
	i.x=x
	i.y=y
	i.items=items
	for x=i.size-#i.items,i.size do
			add(i.items,nil)
	end
	i.selected=1
	return i
end


function touching(x1,y1,w1,h1,
																		x2,y2,w2,h2)

	return x2<x1+w1 and
	x1<x2+w2 and
	y2<y1+h1 and
	y1<y2+h2

end

function newdialogue()
	local d={}
	d.text={nil,nil}
	d.timed=false
	d.timeremaining=0
 d.cursor=0
	d.set=function(text,timed)
		--split text into 2 lines
		if #text>15 then

			local splitpos=15
			local spacefound=false
			while splitpos<#text and spacefound==false do
				if sub(text,splitpos,splitpos) == ' ' then
					spacefound=true
				end
				splitpos+=1
			end
		d.text[0]=sub(text,0,splitpos-1)
		d.text[1]=sub(text,splitpos,#text)
	else
		d.text[0]=text
		d.text[1]=nil
	end
		d.timed=timed
		d.cursor=0
		if timed then d.timeremaining=50
		 end
			cutscene.advance()
	 end
	return d
end


function newbounds(xoff,yoff,
																			w,h)
local b={}
b.xoff=xoff
b.yoff=yoff
b.w=w
b.h=h
return b
end

function newtrigger(xoff,yoff,
																			w,h,f,type)
local t={}
t.xoff=xoff
t.yoff=yoff
t.w=w
t.h=h
t.f=f
--type = 'once', 'always', and 'wait'
t.type=type
t.active=false
return t
end

//control component
function newcontrol(left,right,
																				up,down,z,x,input)
	local c={}
	c.left=left
	c.right=right
	c.up=up
	c.down=down
	c.z=z
	c.x=x
	c.input=input
	return c
end

//intention component
function newintention()
local i={}
i.left=false
i.right=false
i.up=false
i.down=false
i.z=false
i.x=false
i.moving=false
return i
end

//position component
function newposition(x,y,w,h)
	local p={}
	p.x=x
	p.y=y
	p.w=w
	p.h=h
	p.setposition=function(x,y)
		p.x=x
		p.y=y
		cutscene.advance()
	end
	return p
end

function newstate(initialstate,r)
local s={}
s.current=initialstate
s.previous=initialstate
s.rules=r
return s
end

//sprite component
function newsprite(sl)
	local s={}
	s.spritelist=sl
	s.index=1
	--s.flip=false
	return s
end

//animation component
function newanimation(l)
 local a = {}
 a.timer = 0
 a.delay = 3
 a.list  = l
 return a
end

function newbattle(hitboxes)
local b={}
b.hitboxes=hitboxes
return b
end

function newentity(componenttable)

 local e = {}
 e.position=componenttable.position or nil
 e.sprite=componenttable.sprite or nil
 e.control=componenttable.control or nil
 e.intention=componenttable.intention or nil
 e.bounds=componenttable.bounds or nil
 e.animation=componenttable.animation or nil
 e.trigger=componenttable.trigger or nil
 e.dialogue=componenttable.dialogue or nil
	e.state=componenttable.state or {current='idle'}
	e.inventory=componenttable.inventory or nil
	e.item=componenttable.item or false
	e.battle=componenttable.battle or nil
	e.gamestate='playing'
 return e
end

function playerinput(ent)

  if #cutscene.scene > 0 then
    ent.intention.left = false
    ent.intention.right = false
    ent.intention.up = false
    ent.intention.down = false
    ent.intention.o = false
    ent.intention.x = false
  else
    if ent.gamestate then
     if ent.gamestate == 'playing' then
      ent.intention.left = btn(ent.control.left)
      ent.intention.right = btn(ent.control.right)
      ent.intention.up = btn(ent.control.up)
      ent.intention.down = btn(ent.control.down)
      ent.intention.z = btnp(ent.control.z)
      ent.intention.x = btnp(ent.control.x)
						ent.intention.moving=ent.intention.left or
																											ent.intention.right or
																											ent.intention.up or
																											ent.intention.down
     elseif ent.gamestate == 'inventory' then
      ent.intention.left = btnp(ent.control.left)
      ent.intention.right = btnp(ent.control.right)
      ent.intention.up = btnp(ent.control.up)
      ent.intention.down = btnp(ent.control.down)
      ent.intention.z = btnp(ent.control.z)
      ent.intention.x = btnp(ent.control.x)
     end
    end
  end
end

--ent.intention.moving=ent.intention.left or
																					--ent.intention.right or
																					--ent.intention.up or
																					--ent.intention.down


controlsystem={}
controlsystem.update=function()
	for ent in all(entities) do
		if ent.control~=nil and
			ent.intention~=nil then
			ent.control.input(ent)
		end
	end
end

physicssystem={}
physicssystem.update=function()
	for ent in all(entities) do
		if ent.gamestate and ent.gamestate=='playing' then
			if ent.position and ent.bounds then

		local newx=ent.position.x
		local newy=ent.position.y

		if ent.intention then
			if ent.intention.left then
			newx-=1
			end
			if ent.intention.right then
			newx+=1
			end
			if ent.intention.up then
			newy-=1
			end
			if ent.intention.down then
			newy+=1
			end
			end


		local canmovex=true
		local canmovey=true

			--map collision


			--update x-position if able to move
			if not canwalk(newx+ent.bounds.xoff,ent.position.y+ent.bounds.yoff) or
						not canwalk(newx+ent.bounds.xoff+ent.bounds.w-1,ent.position.y+ent.bounds.yoff) or
						not canwalk(newx+ent.bounds.xoff+ent.bounds.w-1,ent.position.y+ent.bounds.yoff+ent.bounds.h-1) or
						not	canwalk(newx+ent.bounds.xoff,ent.position.y+ent.bounds.yoff+ent.bounds.h-1) then
			canmovex=false

			end

					--update y-position if able to move
			if not canwalk(ent.position.x+ent.bounds.xoff,newy+ent.bounds.yoff) or
						not	canwalk(ent.position.x+ent.bounds.xoff+ent.bounds.w-1,newy+ent.bounds.yoff) or
					 not	canwalk(ent.position.x+ent.bounds.xoff+ent.bounds.w-1,newy+ent.bounds.yoff+ent.bounds.h-1) or
					 not	canwalk(ent.position.x+ent.bounds.xoff,newy+ent.bounds.yoff+ent.bounds.h-1) then
			canmovey=false

			end




		--entity collision

			--check x
			for o in all(entities) do
					if o.position and o.bounds then
					if o ~=ent and
						touching(newx+ent.bounds.xoff,
															ent.position.y+ent.bounds.yoff,
															ent.bounds.w,
															ent.bounds.h,
															o.position.x+o.bounds.xoff,
															o.position.y+o.bounds.yoff,
															o.bounds.w,
															o.bounds.h)
						then
							canmovex=false
					end
				end
			end

			--check y
				for o in all(entities) do
					if o.position and o.bounds then
					if o ~=ent and
						touching(ent.position.x+ent.bounds.xoff,
															newy+ent.bounds.yoff,
															ent.bounds.w,
															ent.bounds.h,
															o.position.x+o.bounds.xoff,
															o.position.y+o.bounds.yoff,
															o.bounds.w,
															o.bounds.h)
						then
							canmovey=false
					end
				end
			end

	if canmovex
	then ent.position.x=newx
	end
	if canmovey
	then ent.position.y=newy
	end

			end
		end
	end
end

animationsystem = {}
animationsystem.update = function()
 for ent in all(entities) do
		if ent.gamestate and ent.gamestate=='playing' then
			if ent.sprite and ent.animation and ent.state then

				if ent.animation.list[ent.state.current] then
					--increment timer
					ent.animation.timer+=1
					--if timer > than delay
						if ent.animation.timer>ent.animation.delay then
							ent.sprite.index+=1
								if ent.sprite.index > #ent.sprite.spritelist[ent.state.current]['images'] then
									ent.sprite.index=1
								end
								ent.animation.timer=0
						end
					end
				end
  end
 end

end

triggersystem={}
triggersystem.update=function()
	for ent in all(entities) do
		if ent.position and ent.trigger then
			local triggered=false
			for o in all(entities) do
				if ent~= o and o.position and o.bounds then
					if touching(ent.position.x+ent.trigger.xoff,
														ent.position.y+ent.trigger.yoff,
														ent.trigger.w,
														ent.trigger.h,
														o.position.x+o.bounds.xoff,
														o.position.y+o.bounds.yoff,
														o.bounds.w,
														o.bounds.h)
					then
						--trigger is activated
						triggered=true

						if ent.trigger.type=='once' then
						ent.trigger.f(ent,o)
						ent.trigger=nil
							break
					 end
						if ent.trigger.type=='always' then
						ent.trigger.f(ent,o)
						ent.trigger.active=true
						end
						if ent.trigger.type=='wait' then
							if ent.trigger.active==false then
								ent.trigger.f(ent,o)
								ent.trigger.active=true
							end
						end
					end
				end
			end

if triggered==false then
ent.trigger.active=false
end

		end
	end
end

dialoguesystem={}
dialoguesystem.update=function()
	for ent in all(entities) do
		if ent.dialogue then
			if ent.dialogue.text[0] then

				--calculate length of text
					local len=#ent.dialogue.text[0]
					if ent.dialogue.text[1] and #ent.dialogue.text[1]>0 then
						len += #ent.dialogue.text[1]
					end

					if ent.dialogue.cursor<len then
						ent.dialogue.cursor+=1
					end
				if ent.dialogue.timed and
				 ent.dialogue.timeremaining>0 then
					ent.dialogue.timeremaining-=1
			 end
		 end
		end
	end
end

statesystem={}
statesystem.update=function()
	for ent in all(entities) do
		if ent.gamestate and ent.gamestate=='playing' then
			if ent.state and ent.state.rules then

				ent.state.previous=ent.state.current

				for s,r in pairs(ent.state.rules) do
					if r() then
						ent.state.current=s
					end
				end
			end
		end
	end
end

itemsystem={}
itemsystem.update=function()
	for ent in all(entities) do
		if ent.item then
			for o in all(entities) do
				if o~=ent and o.position and o.bounds and ent.position then
					if touching(ent.position.x,
																	ent.position.y,
																 ent.position.w,
																 ent.position.h,
																 o.position.x+o.bounds.xoff,
																 o.position.y+o.bounds.yoff,
																 o.bounds.w,
																 o.bounds.h) then
						if o.inventory then --and #o.inventory.items<o.inventory.size
							if o.intention and o.intention.x then

								--find an open slot
								--for p=1,o.inventory.size do
									--if o.inventory.items[p]==nil then
										--o.inventory.items[p]=ent
										--del(entities,ent)
										--break
									--end
								--end


								local found=false
								--is there an existing slot to stack the item?
								for p=1, o.inventory.size do
									if o.inventory.items[p] then
										if o.inventory.items[p]['id']==ent.item then
											if o.inventory.items[p]['num']<database[ent.item]['maxstack'] then
												o.inventory.items[p]['num']+=1
												del(entities,ent)
												found=true
												break
											end
										end
									end
								end

								--is there an open inventory slot?
								if found==false then
									for p=1,o.inventory.size do
										if o.inventory.items[p]==nil then
											o.inventory.items[p]={id=ent.item,num=1}
											del(entities,ent)
											break
										end
									end
								end


							end
						end
					end
				end
			end
		end
	end
end


gamestatesystem = {}
gamestatesystem.update = function()
 for ent in all(entities) do
  if ent.gamestate and ent.intention then
   if ent.intention.z and ent.intention.x then
    if ent.gamestate == 'playing' then
     ent.gamestate = 'inventory'
    else
     if ent.gamestate == 'inventory' then
      ent.gamestate = 'playing'
     end
    end
   end
  end
 end
end

inventorysystem = {}
inventorysystem.update = function()
 for ent in all(entities) do
  if ent.inventory and ent.inventory.visible then
   if ent.gamestate and ent.gamestate == 'inventory' then
    if ent.intention.left then
     ent.inventory.selected = max(1,ent.inventory.selected-1)
    elseif ent.intention.right then
     ent.inventory.selected = min(ent.inventory.selected+1,ent.inventory.size)
    elseif ent.intention.down then
     -- drop item
     -- if item exists at selected position
     if ent.inventory.items[ent.inventory.selected] then
      --local i = ent.inventory.items[ent.inventory.selected]
      --if i.position then
       -- update position
       --i.position.x = ent.position.x
       --i.position.y = ent.position.y+8
       --add(entities,i)
       --del(ent.inventory.items,i)
							--ent.inventory.items[ent.inventory.selected]=nil
      --end

				local id = ent.inventory.items[ent.inventory.selected]['id']
				local num = ent.inventory.items[ent.inventory.selected]['num']
				local f = database[id]['newfunction']

				add(entities,f(ent.position.x,ent.position.y))
				ent.inventory.items[ent.inventory.selected]['num'] -= 1
				if ent.inventory.items[ent.inventory.selected]['num'] < 1 then
					ent.inventory.items[ent.inventory.selected] = nil
				end

     end
    end
   end
  end
 end
end

gs={}
gs.update=function()
	cls()

	sort(entities,ycomparison)

	local camerax=player.position.x-64+
	(player.position.w/2)
	local cameray=player.position.y-64+
	(player.position.h/2)

	--camera centered on player
	camera(camerax,cameray)
	palt(0,false)
	palt(13,true)
	map()


	--draw all entities with sprite
		for ent in all(entities) do

		--draw entity
			if ent.sprite and ent.position and ent.state then

	 --reset sprite index if state changes
				if ent.state.current != ent.state.previous then
					ent.sprite.index=1
				end

					sspr(ent.sprite.spritelist[ent.state.current]['images'][ent.sprite.index][1],
										ent.sprite.spritelist[ent.state.current]['images'][ent.sprite.index][2],
										ent.position.w,ent.position.h,
										ent.position.x,ent.position.y,
										ent.position.w,ent.position.h,
									 ent.sprite.spritelist[ent.state.current]['flip'],false)

		end


		if debug then

		--draw bounding boxes yellow
			if ent.position and ent.bounds then
			rect(ent.position.x+ent.bounds.xoff,
								ent.position.y+ent.bounds.yoff,
							ent.position.x+ent.bounds.xoff+ent.bounds.w-1,
							ent.position.y+ent.bounds.yoff+ent.bounds.h-1,
							10)

			end

			--draw hitboxes
if ent.battle and ent.position and ent.state then
local s=ent.state.current
local hb=ent.battle.hitboxes[s]
if hb then
rect(ent.position.x+hb.xoff,
					ent.position.y+hb.yoff,
					ent.position.x+hb.xoff+hb.w,
					ent.position.y+hb.yoff+hb.h,
					9)
				end
			end
end

			--draw trigger boxes pink
					if ent.position and ent.trigger then
						local color
						if ent.trigger.active then color=2 else color=14 end
							rect(ent.position.x+ent.trigger.xoff,
									ent.position.y+ent.trigger.yoff,
									ent.position.x+ent.trigger.xoff+ent.trigger.w-1,
									ent.position.y+ent.trigger.yoff+ent.trigger.h-1,
									color)

			end
end
	camera()

		--draw room border
			--top border
			rectfill(-1,-1,128,(currentroom.y*8)-cameray,currentroom.bg)
			--bottom border
			rectfill(-1,(currentroom.y+currentroom.h)*8-cameray,128,128,currentroom.bg)
			--left border
			rectfill(-1,-1,(currentroom.x*8)-camerax,128,currentroom.bg)
			--right border
			rectfill((currentroom.x+currentroom.w)*8-camerax,-1,128,128,currentroom.bg)

		camera(camerax,cameray)

			--draw dialogue boxes
			for ent in all(entities) do
				if ent.dialogue and ent.position then
					if ent.dialogue.text[0] then
						if (ent.dialogue.timed==false) or
									(ent.dialogue.timed and ent.dialogue.timeremaining>0) then

--move text up if there are 2 lines
										local offset=0
										if ent.dialogue.text[1] then
											 if #ent.dialogue.text[1]>0
										then offset-=8
										end
										end

--line 1
						 texttodraw=sub(ent.dialogue.text[0],0,ent.dialogue.cursor)
							printoutline(texttodraw,ent.position.x,ent.position.y+offset-8,7)

--line 2
							if ent.dialogue.text[1] then
								texttodraw=sub(ent.dialogue.text[1],0,max(0,ent.dialogue.cursor-#ent.dialogue.text[0]))
								printoutline(texttodraw,ent.position.x,ent.position.y+offset,7)
							end

						end
					end
				end
			end

			camera()

--draw inventory
for ent in all(entities) do
	if ent.inventory and ent.inventory.visible then
		rectfill(ent.inventory.x,ent.inventory.y,4+ent.inventory.x+(ent.inventory.size*11),ent.inventory.y+15,0)
		rect(ent.inventory.x,ent.inventory.y,4+ent.inventory.x+(ent.inventory.size*11),ent.inventory.y+15,7)
		for i=1,ent.inventory.size do
			-- draw inventory slot
			--rectfill(ent.inventory.x+2+(11*(i-1)),ent.inventory.y+2,9+ent.inventory.x+4+(11*(i-1)),ent.inventory.y+13,0)
			--rect(ent.inventory.x+2+(11*(i-1)),ent.inventory.y+2,9+ent.inventory.x+4+(11*(i-1)),ent.inventory.y+13,7)
			-- draw item if one exists
			if ent.inventory.items[i] then
				--local e = ent.inventory.items[i]
				--sspr(e.sprite.spritelist[e.state.current]['images'][e.sprite.index][1],
									--e.sprite.spritelist[e.state.current]['images'][e.sprite.index][2],
									--e.position.w, e.position.h,
									--ent.inventory.x+4+(11*(i-1)), ent.inventory.y+4,
									--e.position.w, e.position.h,
									--e.sprite.spritelist[e.state.current]['flip'],false)
									local id = ent.inventory.items[i]['id']
      			local num = ent.inventory.items[i]['num']

									sspr(database[id]['sprite']['idle']['images'][1][1],
		           database[id]['sprite']['idle']['images'][1][2],
		           database[id]['position'].w, database[id]['position'].h,
		           ent.inventory.x+4+(11*(i-1)), ent.inventory.y+4,
		           database[id]['position'].w, database[id]['position'].h,
		           database[id]['sprite']['idle']['flip'],false)

											--number of stacked items
											if num>1 then
												print(num,ent.inventory.x+4+(11*(i-1)), ent.inventory.y+4,10)
										 end
			end
		end
		if ent.gamestate and ent.gamestate=='inventory' then
			rect(ent.inventory.x+2+(ent.inventory.selected-1)*11,
								ent.inventory.y+2,
								13+ent.inventory.x+(ent.inventory.selected-1)*11,
								ent.inventory.y+13,10)
		end
	end
end


		  curtain.draw()

end



function _init()
	--creates new player
	player=newentity({
	--position
	position=newposition(64,64,8,8),
	--sprite
	--sprite=newsprite({{8,0},{16,0},{24,0},{32,0},{40,0},{16,8},{24,8},{32,8},{40,8}},1),
 sprite=newsprite({idle={images={{16,0},{24,0},{32,0},{40,0},{16,8},{24,8},{32,8},{40,8}},flip=false},
																			standleft={images={{8,8}},flip=false},
																			standright={images={{8,8}},flip=false},
																			standup={images={{8,8}},flip=false},
																			standdown={images={{8,8}},flip=false},
																			moveright={images={{16,0}},flip=false},
																			moveleft={images={{16,8}},flip=false},
																			moveup={images={{32,8}},flip=false},
																			movedown={images={{32,0}},flip=false},
																			upleft={images={{24,8}},flip=false},
																			upright={images={{40,8}},flip=false},
																			downleft={images={{40,0}},flip=false},
																			downright={images={{24,0}},flip=false},
																			hitleft={images={{16,16},{16,16},{16,16},{16,16}},flip=false},
																			hitright={images={{16,16},{16,16},{16,16},{16,16}},flip=false},
																			hitup={images={{16,16},{16,16},{16,16},{16,16}},flip=false},
																			hitdown={images={{16,16},{16,16},{16,16},{16,16}},flip=false}
}),
	--control
	control=newcontrol(0,1,2,3,4,5,playerinput),
	--intention
	intention=newintention(),
	--bounds
	bounds=newbounds(1,4,6,4),
	--animation
	animation=newanimation({idle=true,moveright=true,moveleft=true,moveup=true,movedown=true}),
	--dialogue
	dialogue=newdialogue(),
	--state
	state=newstate('idle',{moveleft=function() return player.intention.left end,
																								moveright=function() return player.intention.right end,
																								moveup=function() return player.intention.up end,
																								movedown=function() return player.intention.down end,
																								upleft=function() return player.intention.up and player.intention.left end,
																								upright=function() return player.intention.up and player.intention.right end,
																								downleft=function() return player.intention.down and player.intention.left end,
																								downright=function() return player.intention.down and player.intention.right end,
																								standleft=function() return (not player.intention.left and player.state.current=='moveleft') or (player.state.current=='hitleft' and player.sprite.index>3) end,
																								standright=function() return (not player.intention.right and player.state.current=='moveright') or (player.state.current=='hitright' and player.sprite.index>3) end,
																								standup=function() return (not player.intention.up and player.state.current=='moveup') or (player.state.current=='hitup' and player.sprite.index>3) end,
																								standdown=function() return (not player.intention.down and player.state.current=='movedown') or (player.state.current=='hitdown' and player.sprite.index>3) end,
																								hitleft=function() return (player.state.current=='standleft' or player.state.current=='moveleft') and (player.intention.z and not player.intention.x) end,
																								hitright=function() return(player.state.current=='standright' or player.state.current=='moveright') and (player.intention.z and not player.intention.x) end,
																								hitup=function() return (player.state.current=='standup' or player.state.current=='moveup') and (player.intention.z and not player.intention.x) end,
																								hitdown=function() return (player.state.current=='standdown' or player.state.current=='movedown') and (player.intention.z and not player.intention.x) end,
																							 idle=function() return not player.intention.moving end}),
		--inventory
		inventory=newinventory(3,true,0,0,{}),
		battle=newbattle({hitleft={xoff=-9,yoff=0,w=8,h=8},
																				hitright={xoff=8,yoff=0,w=8,h=8},
																				hitup={xoff=0,yoff=-9,w=8,h=8},
																				hitdown={xoff=0,yoff=8,w=8,h=8}})
	})
	add(entities,player)

	--create a tree
		add(entities,
		newentity({
		//position
		position=newposition(24,80,16,16),
		//sprite
		--sprite=newsprite({{64,0}},1),
		sprite=newsprite({idle={images={{64,0}},flip=false}}),
		//bounds
		bounds=newbounds(6,8,4,4),
		//trigger
		trigger=newtrigger(0,0,16,16,
		function(self,other)
			if other==player then
				--cutscene
				cutscene.scene={

					{other.dialogue.set,'hello tree. how are you today?',true},
					{cutscene.wait,60},
					{other.dialogue.set,'not responding?',true},
					{cutscene.wait,50},
					{other.dialogue.set,'i guess i will leaf you alone',true},
					{cutscene.wait,50}


				}
			end
		end,'wait')
	})
)

	--create shop
			add(entities,
		newentity({
		position=newposition(80,60,32,32),
		--sprite=newsprite({{0,32}},1),
		sprite=newsprite({idle={images={{0,32}},flip=false}}),
		bounds=newbounds(2,16,28,14),
		trigger=newtrigger(22,26,7,6,
			function(self,other)
				if other==player
				then
					--currentroom=shop
				 --player.position.x=308
					--player.position.y=60
	moveroom(shop,other,308,60)
				end
			end,'wait')
		})
		)

 --shop exit
			add(entities,
		newentity({
		position=newposition(304,64,16,8),
		trigger=newtrigger(0,4,16,4,
			function(self,other)
				if other==player
				then
					--currentroom=outside
					--player.position.x=101
					--player.position.y=90
		moveroom(outside,other,101,90)
				end
			end,'wait')
		})
		)

	--heart
add(entities,newheart(270,8))
add(entities,newheart(100,30))
add(entities,newheart(70,40))
add(entities,newheart(30,30))

		--sword
		add(entities,
		newentity({
		//position
		position=newposition(310,8,8,8),
		//sprite
		--sprite=newsprite({{64,24}},1),
		sprite=newsprite({idle={images={{64,24}},flip=false}}),
		//bounds
		bounds=newbounds(1,1,6,6),
		//item
		item=true
	})
		)

		--shopkeep
		add(entities,
		newentity({
		//position
		position=newposition(292,16,8,8),
		//sprite
		--sprite=newsprite({{72,16}},1),
		sprite=newsprite({idle={images={{72,16}},flip=false}}),
		//bounds
		bounds=newbounds(1,1,6,6),
		//dialogue
		dialogue=newdialogue(),
		//trigger
		trigger=newtrigger(0,0,8,20,
	function(self,other)
	if other==player then
		cutscene.scene={
			{self.dialogue.set,'welcome to the shop.',true},
			{cutscene.wait,33},
			{self.dialogue.set,'what would you like?',true},
			{cutscene.wait,33}
		}
end
end,'wait')
		})
		)

end

function _update()
--check player movement
controlsystem.update()
--move entities
physicssystem.update()
--animates
animationsystem.update()
--check entity state
statesystem.update()
--check triggers
triggersystem.update()
--update new dialogue
dialoguesystem.update()
--update cutscene
cutscene.update()
--update curtain
curtain.update()
--item system
itemsystem.update()
--check gamestate
gamestatesystem.update()
--update inventory system
inventorysystem.update()
end

function _draw()
gs.update()
--if debug==true then
--print(#player.inventory.items,0,120,10)
--end
end


__gfx__
00000000dd7777dddd7777dddd7777dddd7777dddd7777dd0000000000000000ddd9a8999a989ddd33333333333333333333433333333333cccccccc3333b333
00000000d777777dd777777dd777777dd777777dd777777d0000000000000000dd9989aa8aa9999d33333333333333333333433333333333cccccccc333b3333
0070070077444477774444777744447777444477774444770000000000000000d9a9989988899a9d33344533333445333334453333344533ccc77ccc33b33333
0007700077400477774400777744447777444477774444770000000000000000998899aaa99989a933344533333445333334453333344533ccc777cc33b33333
0007700077400477774400777744007777400477770044770000000000000000899a9a9898a9998944444533333444443334453344444444cc77c7773b333333
0070070077444477774444777744007777400477770044770000000000000000d99aa99899a9a89933344533333445333334453333344533777ccccc3b333333
00000000d777777dd777777dd777777dd777777dd777777d0000000000000000dd9998a98899999d33344533333445333334453333344533cccccccc33333333
00000000dd7777dddd7777dddd7777dddd7777dddd7777dd0000000000000000dddd999a9999dddd33344533333445333334453333344533cccccccc33333333
0000000000000000dd7777dddd7777dddd7777dddd7777dd0000000000000000dddddd9945dddddd33334333333343330000000000000000fff4fff454444444
0000000000000000d777777dd777777dd777777dd777777d0000000000000000dddddd4445dddddd33334333333343330000000000000000fff4fff454444444
0000000000000000774444777700447777400477774400770000000000000000dddddd4445dddddd333445333334453300000000000000004444fff454444444
0000000000000000770044777700447777400477774400770000000000000000dddddd4445dddddd33344533333445330000000000000000fff4fff455555555
0000000000000000770044777744447777444477774444770000000000000000dddddd4445dddddd44444533333444440000000000000000fff4fff444445444
0000000000000000774444777744447777444477774444770000000000000000dddddd4445dddddd33344533333445330000000000000000fff4fff444445444
0000000000000000d777777dd777777dd777777dd777777d0000000000000000dddddd4445dddddd33344533333445330000000000000000fff4444444445444
0000000000000000dd7777dddd7777dddd7777dddd7777dd0000000000000000dddddd4445dddddd33344533333445330000000000000000fff4fff455555555
00000000dddd65dddd7777dd0000000000000000000000000000000000000000d885d885dd0000dd000000000000000000000000000000000000000044444444
00000000dd66665dd777777d000000000000000000000000000000000000000088888888dd0444dd000000000000000000000000000000000000000044444444
00000000d666666577bbbb77000000000000000000000000000000000000000088888888dd4444dd000000000000000000000000000000000000000044444444
00000000d664466577b00b77000000000000000000000000000000000000000088888888dd0440dd000000000000000000000000000000000000000044444444
00000000d664466577b00b77000000000000000000000000000000000000000088888888d700047d000000000000000000000000000000000000000055555555
00000000d646646577bbbb770000000000000000000000000000000000000000d8888885d777747d000000000000000000000000000000000000000044444444
00000000d6666665d777777d0000000000000000000000000000000000000000dd88885dd447744d000000000000000000000000000000000000000044444444
00000000dd66665ddd7777dd0000000000000000000000000000000000000000ddd885ddd444774d000000000000000000000000000000000000000055555555
0000000000000000000000000000000000000000000000000000000000000000ddd6dddd00000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000ddd6dddd00000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000ddd6dddd00000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000ddd6dddd00000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000ddd6dddd00000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000dd999ddd00000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000ddd9dddd00000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000ddd9dddd00000000000000000000000000000000000000000000000000000000
ddddddddddddddd88ddddddddddddddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddddddddddddd8558dddddddddddddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ddddddddddddd85ff58ddddddddddddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddddddddddd85ffff58dddddddddddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ddddddddddd85ffffff58ddddddddddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddddddddd85ffffffff58dddddddddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ddddddddd85ffffffffff58ddddddddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddddddd85ffffffffffff58dddddddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ddddddd85ffffffffffffff58ddddddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddddd85ffffffffffffffff58dddddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ddddd85ffffffffffffffffff58ddddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddd85ffffffffffffffffffff58dddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ddd85ffffffffffffffffffffff58ddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dd85ffffffffffffffffffffffff58dd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d85ffffffffffffffffffffffffff58d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
84444444444444444444444444444448000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d4444444444444444444444444444445000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d4444444444444444444444444444445000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d4444444444444444444444444444445000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d4444444444444444444444444444445000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d4447666664566666444488888888445000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d4446766664566666444488888888445000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d4446676664566666444488888888445000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d4446666664566666444488888888445000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d4444444444444444444488888888445000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d4445555554555555444488888888445000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d4446666664566666444488888888445000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d4446666664566666444489888888445000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d4446666664566666444488888888445000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d4444444444444444444488888888445000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d4444444444444444444488888888445000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d4444444444444444444488888888445000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000080808080800000000000000000000000808000000080000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f1f1f1f1f1f1f1f1f1f1f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0b0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0a0f1f1e1e1e1e1e1e1e1e1f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0c0f1f1e1e1e1e1e1e1e1e1f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0f0f0f0f0f0f0f0f0f0f0f0f0f0e0e0e0e0e0e0e0e0e0e0f0f0f0f0f0f0c0f1f2f2f2f2f2f2f2f2f1f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0f0f0f0f0f0f0f0f0f0f0f0f0f0e0e0e0e0e0e0e0e0e0e0f0f0f0f0f0f0c0f1f1e1e1e1e1e1e1e1e1f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0e0e0e0e0e0e0e0e0f0f0f0f0f0f0c0f1f1e1e1e1e1e1e1e1e1f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0e0e0e0e0e0e0e0f0f0f0f0f0f0c0f1f1e1e1e1e1e1e1e1e1f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0e0e0e0e0e0e0f0f0f0f0f0f0c0f1f1e1e1e1e1e1e1e1e1f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0e0e0e0e0e0f0f0f0f0f0f0c0f1f1f1f1f1f1f1e1e1f1f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0e0e0e0e0f0f0f0f0f0f0c0f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0e0e0e0f0f0f0f0f0f0c0f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0c0f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0c0f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0c0f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1b0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d1a0f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
