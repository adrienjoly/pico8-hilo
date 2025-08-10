-- (WIP)

colors={10,11,3,13,9,8,14,2}
state="player1"

function _init()
 grids={generate_grid(),generate_grid()}
 sel_x=1
 sel_y=1
end

function _update()
 -- move cursor
 if btnp(0) then sel_x=max(1,sel_x-1) end -- left
 if btnp(1) then sel_x=min(3,sel_x+1) end -- right
 if btnp(2) then sel_y=max(1,sel_y-1) end -- up
 if btnp(3) then sel_y=min(3,sel_y+1) end -- down

 -- select
 if btnp(4) then
  --printh("selected: "..grid[sel_y][sel_x])
  local card=grids[1][sel_y][sel_x]
  card.visible=not card.visible
 end
end

function _draw()
 cls(0)
	render_grid(1,sel_x,sel_y)
	render_grid(2,-1,-1)
end

function generate_grid()
 local grid={}
 for y=1,3 do
  grid[y]={}
  for x=1,3 do
   local cell={
    visible=false,
    val=flr(rnd(13))-1, -- -1 to 11,
    color=colors[ceil(rnd(#colors))]
   }
   if (x==1 and y==1) or (x==3 and y==3) then
     cell.visible=true
   end
   grid[y][x]=cell
  end
 end
 return grid
end

function render_grid(player,sel_x,sel_y)
 local grid=grids[player]
 local start_x=(player-1)*127/2
 print("player "..player,start_x+2,(127/2)+4,6)
 local card_width=10
 local card_height=15
 local margin=5
 rect(start_x,0,start_x+(127-margin*6)/2-1,127/2-1,6)
 for y=1,3 do
  for x=1,3 do
   local gx=start_x+margin+(x-1)*(card_width+margin)
   local gy=margin+(y-1)*(card_height+5)
   local card=grid[y][x]
   local val=card.val
   local color=card.color
   local selected=x==sel_x and y==sel_y
   if card.visible==false then
    color=5 -- dark
    val="x"
   end

   -- highlight selection
   if not selected then
       rectfill(gx-2,gy-2,gx+card_width-1,gy+card_height-1,color)
   else
       rect(gx-2,gy-2,gx+card_width-1,gy+card_height-1,color)
   end

   -- draw number
   local text_color=color
   if not selected then
    text_color=0 -- black text on color background
   end
   print(val,gx,gy,text_color)
  end
 end
end
