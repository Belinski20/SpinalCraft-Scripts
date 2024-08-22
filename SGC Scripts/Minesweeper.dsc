Minesweeper_Command:
    type: command
    name: minesweeper
    description: Opens the Minesweeper Menu
    usage: /minesweeper
    permission: SGC.MINESWEEPER
    script:
    - inventory open destination:Minesweeper_Menu_Inventory

Minesweeper_Menu_Inventory:
    type: inventory
    debug: false
    inventory: hopper
    title: Minesweeper Menu
    gui: true
    slots:
    - [Minesweeper_Start_Button] [] [Minesweeper_Easy_Difficulty_Button] [] [Minesweeper_Resume_Button]

Minesweeper_Menu_Click_Events:
    debug: false
    type: world
    events:
        on player clicks Minesweeper_Start_Button in Minesweeper_Menu_Inventory:
        - flag <player> MINESWEEPER.PENDING:!
        - run Minesweeper_Start_Game def.difficulty:<context.inventory.slot[3].flag[MINESWEEPER_DIFFICULTY]>
        on player clicks Minesweeper_Easy_Difficulty_Button in Minesweeper_Menu_Inventory:
        - run Minesweeper_Change_Difficulty def.difficulty:EASY def.inventory:<context.inventory>
        on player clicks Minesweeper_Medium_Difficulty_Button in Minesweeper_Menu_Inventory:
        - run Minesweeper_Change_Difficulty def.difficulty:MEDIUM def.inventory:<context.inventory>
        on player clicks Minesweeper_Hard_Difficulty_Button in Minesweeper_Menu_Inventory:
        - run Minesweeper_Change_Difficulty def.difficulty:HARD def.inventory:<context.inventory>
        on player clicks Minesweeper_Resume_Button in Minesweeper_Menu_Inventory:
        - run Minesweeper_Resume_Game

Minesweeper_Game_Inventory:
    type: inventory
    debug: false
    inventory: chest
    title: Minesweeper
    size: 54
    gui: true
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    procedural items:
    - define items <list[]>
    - repeat 54:
        - define items:->:<item[Minesweeper_Game_Hidden_Button]>
    - determine <[items]>

Minesweeper_Game_Click_Events:
    debug: false
    type: world
    events:
        on player left clicks Minesweeper_Game_Hidden_Button in Minesweeper_Game_Inventory:
        - run Minesweeper_Reveal_Clicked_Slot def.inventory:<context.inventory> def.slot:<context.slot>
        on player right clicks Minesweeper_Game_Hidden_Button in Minesweeper_Game_Inventory:
        - ~run Minesweeper_Flag_Slot def.inventory:<context.inventory> def.slot:<context.slot>
        - run Minesweeper_Win_Check def.inventory:<context.inventory>
        on player right clicks Minesweeper_Flag_Button in Minesweeper_Game_Inventory:
        - if !<player.has_flag[MINESWEEPER.FINISHED]>:
            - run Minesweeper_UnFlag_Slot def.inventory:<context.inventory> def.slot:<context.slot>

Minesweeper_Game_Close_Event:
    debug: false
    type: world
    events:
        on player closes Minesweeper_Game_Inventory:
        - if !<player.has_flag[MINESWEEPER.FINISHED]>:
            - flag <player> MINESWEEPER.PENDING:<context.inventory>
        - else:
            - flag <player> MINESWEEPER.FINISHED:!
            - flag <player> MINESWEEPER.PENDING:!

Minesweeper_Flag_Slot:
    type: task
    debug: false
    definitions: inventory|slot
    script:
    - define flags <list[]>
    - define item <[inventory].slot[<[slot]>]>
    - if <[item].has_flag[MINESWEEPER]>:
        - define flags <[item].flag[MINESWEEPER].keys>
    - define bomb-flag <item[Minesweeper_Flag_Button]>
    - foreach <[flags]> as:key:
        - flag <[bomb-flag]> MINESWEEPER.<[key]>:<[item].flag[MINESWEEPER.<[key]>]>
    - inventory set destination:<[inventory]> slot:<[slot]> origin:<[bomb-flag]>
    - foreach <[flags]> as:flag:
        - inventory flag destination:<[inventory]> slot:<[slot]> MINESWEEPER.<[flag]>:<[item].flag[MINESWEEPER.<[flag]>]>

Minesweeper_UnFlag_Slot:
    type: task
    debug: false
    definitions: inventory|slot
    script:
    - define flags <list[]>
    - define item <[inventory].slot[<[slot]>]>
    - if <[item].has_flag[MINESWEEPER]>:
        - define flags <[item].flag[MINESWEEPER].keys.exclude[MINESWEEPER_FLAGGED]>
    - define hidden-button <item[Minesweeper_Game_Hidden_Button]>
    - foreach <[flags]> as:key:
        - flag <[hidden-button]> MINESWEEPER.<[key]>:<[item].flag[MINESWEEPER.<[key]>]>
    - inventory set destination:<[inventory]> slot:<[slot]> origin:<[hidden-button]>
    - foreach <[flags]> as:flag:
        - inventory flag destination:<[inventory]> slot:<[slot]> MINESWEEPER.<[flag]>:<[item].flag[MINESWEEPER.<[flag]>]>

Minesweeper_Start_Button:
    type: item
    material: green_stained_glass_pane
    display name: <&o.end_format><green>Start
    mechanisms:
        hides: all

Minesweeper_Flag_Button:
    type: item
    material: red_banner
    display name: <&o.end_format><red>Marked TNT
    mechanisms:
        hides: all
    flags:
        MINESWEEPER_FLAGGED: TRUE

Minesweeper_Easy_Difficulty_Button:
    type: item
    material: green_candle
    display name: <&o.end_format><green>Easy
    mechanisms:
        hides: all
    flags:
        MINESWEEPER_DIFFICULTY: EASY

Minesweeper_Medium_Difficulty_Button:
    type: item
    material: yellow_candle
    display name: <&o.end_format><yellow>Medium
    mechanisms:
        hides: all
    flags:
        MINESWEEPER_DIFFICULTY: MEDIUM

Minesweeper_Hard_Difficulty_Button:
    type: item
    material: red_candle
    display name: <&o.end_format><red>Hard
    mechanisms:
        hides: all
    flags:
        MINESWEEPER_DIFFICULTY: HARD

Minesweeper_Resume_Button:
    type: item
    material: stone
    display name: <&o.end_format><white>Resume
    mechanisms:
        hides: all

Minesweeper_Game_Hidden_Button:
    type: item
    material: gray_stained_glass_pane
    display name: <&o.end_format><gray>Click to Reveal
    mechanisms:
        hides: all

Minesweeper_Game_Bomb_Hint_Button:
    type: item
    material: light
    display name: <&o.end_format><gray>TNT is nearby
    mechanisms:
        hides: all

Minesweeper_Game_Bomb_Button:
    type: item
    material: tnt
    display name: <&o.end_format><dark_red>TNT
    mechanisms:
        hides: all

Minesweeper_Start_Game:
    type: task
    debug: false
    definitions: difficulty
    script:
    - define game-window <inventory[Minesweeper_Game_Inventory]>
    - define bomb-density <proc[Minesweeper_Get_Bomb_Density].context[<[difficulty]>]>
    - ~run Minesweeper_Generate_Puzzle def.inventory:<[game-window]> def.bomb-density:<[bomb-density]>
    - inventory open destination:<[game-window]>

Minesweeper_Get_Bomb_Density:
    type: procedure
    debug: false
    definitions: difficulty
    script:
    - choose <[difficulty]>:
        - case EASY:
            - determine 0.08
        - case MEDIUM:
            - determine 0.15
        - case HARD:
            - determine 0.21
        - default:
            - determine 0.08

Minesweeper_Resume_Game:
    type: task
    debug: false
    script:
    - if !<player.has_flag[MINESWEEPER.PENDING]>:
        - narrate targets:<player> "<red>You do not have a game to resume."
        - inventory close
        - stop
    - define game-window <inventory[Minesweeper_Game_Inventory]>
    - inventory copy destination:<[game-window]> origin:<player.has_flag[MINESWEEPER.PENDING]>
    - inventory open destination:<[game-window]>

Minesweeper_Change_Difficulty:
    type: task
    debug: false
    definitions: difficulty|inventory
    script:
    - choose <[difficulty]>:
        - case EASY:
            - inventory set destination:<[inventory]> slot:3 origin:<item[Minesweeper_Medium_Difficulty_Button]>
        - case MEDIUM:
            - inventory set destination:<[inventory]> slot:3 origin:<item[Minesweeper_Hard_Difficulty_Button]>
        - case HARD:
            - inventory set destination:<[inventory]> slot:3 origin:<item[Minesweeper_EASY_Difficulty_Button]>
        - default:
            - inventory set destination:<[inventory]> slot:3 origin:<item[Minesweeper_EASY_Difficulty_Button]>

Minesweeper_Reveal_Clicked_Slot:
    type: task
    debug: false
    definitions: inventory|slot
    script:
    - define item <[inventory].slot[<[slot]>]>
    - if <[item].has_flag[MINESWEEPER.BOMB]>:
        - run Minesweeper_Reveal_Board def.inventory:<[inventory]>
        - run Minesweeper_Lose_Game
        - stop
    - if <[item].has_flag[MINESWEEPER.HINT]>:
        - run Minesweeper_Reveal_Hint def.inventory:<[inventory]> def.slot:<[slot]>
        - run Minesweeper_Win_Check def.inventory:<[inventory]>
        - stop
    - ~run Minesweeper_Recursive_Reveal_Neighbors def.inventory:<[inventory]> def.slot:<[slot]>
    - run Minesweeper_Win_Check def.inventory:<[inventory]>

Minesweeper_Recursive_Reveal_Neighbors:
    type: task
    debug: false
    definitions: inventory|slot
    script:
    - if <[inventory].slot[<[slot]>].material.name> == air:
        - stop
    - if <[inventory].slot[<[slot]>].has_flag[MINESWEEPER.REVEALED]>:
        - stop
    - if <[inventory].slot[<[slot]>].has_flag[MINESWEEPER_FLAGGED]>:
        - stop
    - if <[inventory].slot[<[slot]>].has_flag[MINESWEEPER.HINT]>:
        - run Minesweeper_Reveal_Hint def.inventory:<[inventory]> def.slot:<[slot]>
        - stop
    - inventory set destination:<[inventory]> origin:air slot:<[slot]>
    - define neighbors <proc[Minesweeper_Get_Neighbors].context[<[inventory]>|<[slot]>]>
    - foreach <[neighbors]> as:neighbor:
        - run Minesweeper_Recursive_Reveal_Neighbors def.inventory:<[inventory]> def.slot:<[neighbor]>

Minesweeper_Reveal_Hint:
    type: task
    debug: false
    definitions: inventory|slot
    script:
    - define item <[inventory].slot[<[slot]>]>
    - define hint <item[Minesweeper_Game_Bomb_Hint_Button]>
    - inventory set destination:<[inventory]> origin:<[hint]> slot:<[slot]>
    - inventory adjust destination:<[inventory]> slot:<[slot]> block_material:<material[light].with[level=<[item].flag[MINESWEEPER.HINT]>]>
    - inventory flag destination:<[inventory]> slot:<[slot]> MINESWEEPER.REVEALED:TRUE

Minesweeper_Reveal_Board:
    type: task
    debug: false
    definitions: inventory
    script:
    - define slot-id 0
    - foreach <[inventory].list_contents> as:item:
        - define slot-id:+:1
        - if <[item].material.name> == air:
            - foreach next
        - if <[item].has_flag[MINESWEEPER.REVEALED]>:
            - foreach next
        - if <[item].has_flag[MINESWEEPER.BOMB]>:
            - inventory set destination:<[inventory]> slot:<[slot-id]> origin:<item[Minesweeper_Game_Bomb_Button]>
            - foreach next
        - if <[item].has_flag[MINESWEEPER.HINT]>:
            - run Minesweeper_Reveal_Hint def.inventory:<[inventory]> def.slot:<[slot-id]>
            - foreach next
        - inventory set destination:<[inventory]> slot:<[slot-id]> origin:air

Minesweeper_Get_Neighbors:
    type: procedure
    debug: false
    definitions: inventory|slot
    script:
    - define neighbor-list <list[]>
    - if <[slot]> > 9:
        - define neighbor-list:->:<[slot].sub[9]>
        - if <[slot].sub[1].mod[9]> != 0:
            - define neighbor-list:->:<[slot].sub[10]>
        - if <[slot].mod[9]> != 0:
            - define neighbor-list:->:<[slot].sub[8]>
    - if <[slot]> <= <[inventory].size.sub[9]>:
        - define neighbor-list:->:<[slot].add[9]>
        - if <[slot].sub[1].mod[9]> != 0:
            - define neighbor-list:->:<[slot].add[8]>
        - if <[slot].mod[9]> != 0:
            - define neighbor-list:->:<[slot].add[10]>
    - if <[slot].mod[9]> != 0:
        - define neighbor-list:->:<[slot].add[1]>
    - if <[slot].sub[1].mod[9]> != 0:
        - define neighbor-list:->:<[slot].sub[1]>
    - determine <[neighbor-list]>

Minesweeper_Neighboring_Bombs:
    type: procedure
    debug: false
    definitions: inventory|neighbors
    script:
    - define bombs 0
    - foreach <[neighbors]> as:neighbor:
        - if <[inventory].slot[<[neighbor]>].has_flag[MINESWEEPER.BOMB]>:
            - define bombs:+:1
    - determine <[bombs]>

Minesweeper_Bomb_Positions:
    type: procedure
    debug: false
    definitions: inventory|density
    script:
    - define bomb-positions <list[]>
    - define bomb-count <[inventory].size.mul[<[density]>].round_down>
    - define positions <util.list_numbers[to=<[inventory].size>]>
    - repeat <[bomb-count]>:
        - define bomb-position <[positions].random>
        - define bomb-positions:->:<[bomb-position]>
        - define positions:<-:<[bomb-position]>
    - determine <[bomb-positions]>

Minesweeper_Generate_Puzzle:
    type: task
    debug: false
    definitions: inventory|bomb-density
    script:
    - define bomb-positions <proc[Minesweeper_Bomb_Positions].context[<[inventory]>|<[bomb-density]>]>
    - define slot 0
    - foreach <[inventory].list_contents>:
        - define slot:+:1
        - if <[bomb-positions].contains[<[slot]>]>:
            - inventory flag destination:<[inventory]> slot:<[slot]> MINESWEEPER.BOMB
            - foreach next
        - define neighbors <proc[Minesweeper_Get_Neighbors].context[<[inventory]>|<[slot]>]>
        - define bomb-neighbors 0
        - foreach <[neighbors]> as:neighbor:
            - if <[bomb-positions].contains[<[neighbor]>]>:
                - define bomb-neighbors:+:1
        - if <[bomb-neighbors]> > 0:
            - inventory flag destination:<[inventory]> slot:<[slot]> MINESWEEPER.HINT:<[bomb-neighbors]>

Minesweeper_Win_Check:
    type: task
    debug: false
    definitions: inventory
    script:
    - if <[inventory].list_contents.count_matches[Minesweeper_Game_Hidden_Button]> == 0:
        - run Minesweeper_Win_Game

Minesweeper_Win_Game:
    type: task
    debug: false
    script:
    - playsound <player> sound:entity_player_levelup
    - narrate targets:<player> <green>Congratulations!
    - flag <player> MINESWEEPER.FINISHED

Minesweeper_Lose_Game:
    type: task
    debug: false
    script:
    - playsound <player> sound:entity_generic_explode
    - narrate targets:<player> "<red>Try again!"
    - flag <player> MINESWEEPER.FINISHED