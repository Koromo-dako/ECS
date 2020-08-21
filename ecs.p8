pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
debug=true

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
	end
		d.timed=timed
		d.cursor=0
		if timed then d.timeremaining=50
		 end
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
																				up,down,input)
	local c={}
	c.left=left
	c.right=right
	c.up=up
	c.down=down
	c.input=input
	return c
end

//intentionb component
function newintention()
local i={}
i.left=false
i.right=false
i.up=false
i.down=false
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
	return p
end

//sprite component
function newsprite(sl,i)
	local s={}
	s.spritelist=sl
	s.index=i
	s.flip=false
	return s
end

//animation component
function newanimation(d,t)
 local a = {}
 a.timer = 0
 a.delay = d
 a.type  = t
 return a
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
 return e
end

function playerinput(ent)
			ent.intention.left=
			btn(ent.control.left)
			ent.intention.right=
			btn(ent.control.right)
			ent.intention.up=
			btn(ent.control.up)
			ent.intention.down=
			btn(ent.control.down)

			ent.intention.moving=ent.intention.left or
																								ent.intention.right or
																								ent.intention.up or
																								ent.intention.down
end

//function npcinput(ent)
//	ent.intention.left=true
//end

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

animationsystem = {}
animationsystem.update = function()
 for ent in all(entities) do
  if ent.sprite and ent.animation then
   if ent.animation.type=='idle'or (ent.intention and ent.animation.type=='walk' and ent.intention.moving) then
   -- increment the animation timer
	   ent.animation.timer += 1
	   -- if the timer is higher than the delay
	   if ent.animation.timer > ent.animation.delay then
	    -- increment then index ans reset the timer
	    ent.sprite.index += 1
	    if ent.sprite.index > #ent.sprite.spritelist then
	      ent.sprite.index = 2
	    end
	    ent.animation.timer = 0
	   end
	  else
	  ent.sprite.index=1

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

		--flip sprites?
		if ent.sprite and ent.intention then
			if ent.sprite.flip==false and ent.intention.left
			then ent.sprite.flip=true
			end
			if ent.sprite.flip and ent.intention.right
			then ent.sprite.flip=false
			end
		end

			if ent.sprite~=nil and
			ent.position ~=nil then
		sspr(ent.sprite.spritelist[ent.sprite.index][1],
		ent.sprite.spritelist[ent.sprite.index][2],
		ent.position.w,ent.position.h,
		ent.position.x,ent.position.y,
		ent.position.w,ent.position.h,
		ent.sprite.flip,false)

		end


		if debug then

		--draw bounding boxes
			if ent.position and ent.bounds then
			rect(ent.position.x+ent.bounds.xoff,
								ent.position.y+ent.bounds.yoff,
							ent.position.x+ent.bounds.xoff+ent.bounds.w-1,
							ent.position.y+ent.bounds.yoff+ent.bounds.h-1,
							10)

			end

		--draw trigger boxes
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

end



function _init()
	--creates new player
	player=newentity({
	//position
	position=newposition(64,64,8,8),
	//sprite
	sprite=newsprite({{8,0},{16,0},{24,0},{32,0},{40,0},{16,8},{24,8},{32,8},{40,8}},1),
	//control
	control=newcontrol(0,1,2,3,playerinput),
	//intention
	intention=newintention(),
	//bounds
	bounds=newbounds(1,4,6,4),
	//animation
	animation=newanimation(3,'walk'),
	//dialogue
	dialogue=newdialogue()
	})
	add(entities,player)

	--create a tree
		add(entities,
		newentity({
		//position
		position=newposition(24,80,16,16),
		//sprite
		sprite=newsprite({{64,0}},1),
		//bounds
		bounds=newbounds(6,8,4,4),
		//trigger
		trigger=newtrigger(0,0,16,16,
		function(self,other)
			if other==player then
				other.dialogue.set('hello tree. how are you today?',true)
			end
		end,'wait')
	})
)

	--create shop
			add(entities,
		newentity({
		position=newposition(80,60,32,32),
		sprite=newsprite({{0,32}},1),
		bounds=newbounds(2,16,28,14),
		trigger=newtrigger(22,26,7,6,
			function(self,other)
				if other==player
				then
					currentroom=shop
					player.position.x=308
					player.position.y=60
				end
			end,'always')
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
					currentroom=outside
					player.position.x=101
					player.position.y=90
				end
			end,'always')
		})
		)

	--heart
		add(entities,
		newentity({
		//position
		position=newposition(270,8,8,8),
		//sprite
		sprite=newsprite({{64,16}},1),
		//bounds
		bounds=newbounds(1,1,6,6)
		})
		)

		--sword
		add(entities,
		newentity({
		//position
		position=newposition(310,8,8,8),
		//sprite
		sprite=newsprite({{64,24}},1),
		//bounds
		bounds=newbounds(1,1,6,6)
		})
		)

		--shopkeep
		add(entities,
		newentity({
		//position
		position=newposition(292,16,8,8),
		//sprite
		sprite=newsprite({{72,16}},1),
		//bounds
		bounds=newbounds(1,1,6,6),
		//dialogue
		dialogue=newdialogue(),
		//trigger
		trigger=newtrigger(0,0,8,20,
	function(self,other)
	if other==player
then self.dialogue.set('welcome to the shop',true)
					other.dialogue.set('yo',true)
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
--check triggers
triggersystem.update()
--update new dialogue
dialoguesystem.update()

end

function _draw()
gs.update()
//print(canwalk(player.position.x,
//						player.position.y,0,0,2))

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
0000000000000000000000000000000000000000000000000000000000000000d885d885dd0000dd000000000000000000000000000000000000000044444444
000000000000000000000000000000000000000000000000000000000000000088888888dd0444dd000000000000000000000000000000000000000044444444
000000000000000000000000000000000000000000000000000000000000000088888888dd4444dd000000000000000000000000000000000000000044444444
000000000000000000000000000000000000000000000000000000000000000088888888dd0440dd000000000000000000000000000000000000000044444444
000000000000000000000000000000000000000000000000000000000000000088888888d700047d000000000000000000000000000000000000000055555555
0000000000000000000000000000000000000000000000000000000000000000d8888885d777747d000000000000000000000000000000000000000044444444
0000000000000000000000000000000000000000000000000000000000000000dd88885dd447744d000000000000000000000000000000000000000044444444
0000000000000000000000000000000000000000000000000000000000000000ddd885ddd444774d000000000000000000000000000000000000000055555555
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
