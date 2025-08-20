-- github.com/adrienjoly/pico8-hilo
colors={10,11,3,13,9,8,14,2}
numbers={-1,0,1,2,3,4,5,6,7,8,9,10,11}

function _init()
 deck=generate_random_deck()
 grids={generate_grid(),generate_grid()}
 state="player1"
 last_card=draw_from_deck()
 new_card=nil
 sel_x=1
 sel_y=1
end

function _update()
 print("state before: "..state)
 check_hilos()
 if state=="player1" then
  -- pick new card or last card
  if btnp(❎) then
   state="drewnewcard"
   new_card=draw_from_deck()
  elseif btnp(🅾️) and last_card then
   state="selectedlastcard"
  end
 elseif state=="drewnewcard" then
	 assert(new_card)
	 -- select card in grid, to replace
	 selection_in_grid()
	 local selected_card=grids[1][sel_y][sel_x]
	 if btnp(🅾️) then
	  set_card_in(grids[1],new_card,sel_x,sel_y)
	  new_card=nil
	  state="player2"
	 elseif btnp(❎) then
	  set_last_card(new_card)
	  new_card=nil
	  state="discardednewcard"
	 end
	elseif state=="discardednewcard" then
	 assert(not new_card)
	 -- select card in grid, to reveal
	 selection_in_grid()
	 local selected_card=grids[1][sel_y][sel_x]
	 if btnp(🅾️) and not selected_card.visible then
	  selected_card.visible=true
	  state="player2"
	 end	
 elseif state=="selectedlastcard" then
	 assert(last_card)
	 -- select card in grid, to replace
	 selection_in_grid()
	 local selected_card=grids[1][sel_y][sel_x]
	 if btnp(❎) then
	  state="player1"
	 elseif btnp(🅾️) then
	  set_card_in(grids[1],last_card,sel_x,sel_y)
	  state="player2"
	 end
	elseif state=="player2" then
	 -- computer/ai's turn
	 -- dumb implem:
	 -- d1. draw
	 local new_card=draw_from_deck()
	 -- d2. replace first card in grid
	 local grid_card=pick_first_hidden(grids[2])
  if not grid_card then
   state="endofgame"
  else
   set_card_in(grids[2],new_card,sel_x,sel_y)
   state="player1"
  end
	end
 print("state after: "..state)
end

function check_hilos()
 for player=1,2 do
  local grid=grids[player]
  check_hilos_for(grid)
 end
end
 
function check_hilos_for(grid)
 if #grid<3 and #grid[1]<3 then
  return
 end
 -- check horizontal hilos
 if #grid[1]==3 then
  for row in all(grid) do
   if is_hilo_row(row) then
    dispose_cards(row)
    del(grid,row)
    return check_hilos_for(grid)
   end
  end
 end
 -- check vertical hilos
 if #grid==3 then
  for x=1,3 do
   local col={grid[1][x],grid[2][x],grid[3][x]}
   if is_hilo_row(col) then
    dispose_cards(col)
    deli(grid[1],x)
    deli(grid[2],x)
    deli(grid[3],x)
    return check_hilos_for(grid)
   end
  end
 end
 -- check diagonal hilos
 if #grid==3 and #grid[1]==3 then
  -- 1. top-left to bottom-right
  local diag={grid[1][1],grid[2][2],grid[3][3]}
  if is_hilo_row(diag) then
   dispose_cards(diag)
   deli(grid[1],1)
   deli(grid[2],2)
   deli(grid[3],3)
   -- todo: allow vertical merge instead of horizontal
   return
  end
  -- 2. bottom-left to top-right
  diag={grid[3][1],grid[2][2],grid[1][3]}
  if is_hilo_row(diag) then
   dispose_cards(diag)
   deli(grid[3],1)
   deli(grid[2],2)
   deli(grid[1],3)
   -- todo: allow vertical merge instead of horizontal
  end
 end
end

function dispose_cards(cards)
 local sorted_cards=sort_asc(cards)
 set_last_card(sorted_cards[1])
 add(deck,sorted_cards[2])
 add(deck,sorted_cards[3])
end

function is_hilo_row(row)
 return #row==3 and row[1].color == row[2].color == row[3].color
end

function set_card_in(grid,card,x,y)
	local target=grid[y][x]
 card.visible=true
 grid[y][x]=card
 set_last_card(target)
end

function set_last_card(card)
	if last_card then
	 add(deck,last_card)
	end
	last_card=card
end

function pick_first_hidden(grid)
 for y=1,3 do
  for x=1,3 do
   local candidate=grid[y][x]
   if not candidate.visible then
    return {x=x,y=y,color=candidate.color,number=candidate.number}
   end
  end
 end
 return nil
end

function _draw()
 cls(0)
	render_grid(1,sel_x,sel_y)
	render_grid(2,-1,-1)
	if last_card then
	 print("last card: ",0,80,5)
	 print(last_card.number,40,80,last_card.color)
 end
	print("state: "..state,0,90,5)
	if state=="player1" then
	 print("your turn!",0,100,6)
	 if last_card then
	  print("draw new card: ❎, use last: 🅾️",0,110,6)
	 else
	  print("draw new card: ❎",0,110,6)
	 end
	elseif state=="drewnewcard" then
	 print("new card: ",0,100,6)
	 print(new_card.number,40,100,new_card.color)
	 print("select: ⬅️➡️⬆️⬇️🅾️, discard: ❎",0,110,6)
	elseif state=="discardednewcard" then
	 print("select a card to reveal",0,100,6)
	 print("select: ⬅️➡️⬆️⬇️🅾️",0,110,6)
	elseif state=="selectedlastcard" then
	 print("select: ⬅️➡️⬆️⬇️🅾️, cancel: ❎",0,110,6)
	end
end

function selection_in_grid()
	 if btnp(0) then sel_x=max(1,sel_x-1) end -- left
	 if btnp(1) then sel_x=min(3,sel_x+1) end -- right
	 if btnp(2) then sel_y=max(1,sel_y-1) end -- up
	 if btnp(3) then sel_y=min(3,sel_y+1) end -- down
end

function generate_random_deck()
 local all_cards={}
 local nb_cards=#colors*#numbers --104
 for c in all(colors) do
  for n in all(numbers) do
   local card={color=c,number=n}
   add(all_cards,card)
  end
 end
 assert(#all_cards==nb_cards)
 local randomized={}
 for i=1,nb_cards do
  local rnd_index=ceil(rnd(#all_cards))
  add(randomized,all_cards[rnd_index])
  deli(all_cards,rnd_index)
 end
 assert(#randomized==nb_cards)
 assert(#all_cards==0)
 return randomized
end

function draw_from_deck()
 local card=deck[1]
 deli(deck,1)
 return card
end

function generate_grid()
 local grid={}
 for y=1,3 do
  grid[y]={}
  for x=1,3 do
   local card=draw_from_deck()
   local cell={
    visible=false,
    number=card.number,
    color=card.color
   }
   -- todo: let the player pick which cards to reveal
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
 for y=1,#grid do
  for x=1,#grid[1] do
   local gx=start_x+margin+(x-1)*(card_width+margin)
   local gy=margin+(y-1)*(card_height+5)
   local card=grid[y][x]
   local number=card.number
   local color=card.color
   local selected=x==sel_x and y==sel_y
   if card.visible==false then
    color=5 -- dark
    number="x"
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
   print(number,gx,gy,text_color)
  end
 end
end
