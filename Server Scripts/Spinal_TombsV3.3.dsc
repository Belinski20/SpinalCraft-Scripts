##--TOMB--##
Tomb_Handler:
    debug: false
    type: world
    events:
        on player_head physics location_flagged:TOMB:
        - chunkload add <context.location.chunk> duration:1s
        - if <context.location.has_flag[TOMB.OWNER]>:
            - determine cancelled
        on liquid spreads location_flagged:TOMB:
        - chunkload add <context.location.chunk> duration:1s
        - if <context.location.has_flag[TOMB.OWNER]>:
            - determine cancelled
        on player_head explodes location_flagged:TOMB:
        - chunkload add <context.location.chunk> duration:1s
        - if <context.location.has_flag[TOMB.OWNER]>:
            - determine cancelled
        on player_head destroyed by explosion location_flagged:TOMB:
        - chunkload add <context.location.chunk> duration:1s
        - if <context.location.has_flag[TOMB.OWNER]>:
            - determine cancelled
        on player dies:
        #- if <player.has_permission[Spinal.Tomb.Exempt]>:
        #    - determine cancelled
        - chunkload add <player.location.chunk> duration:1s
        - ~run Tomb_Remove_Broken_Stuff
        - define place-grave <proc[Tomb_Should_Place_Grave].context[<player>]>
        - if <[place-grave]>:
            - determine NO_Drops passively
            - determine NO_XP passively
            - run Tomb_Generate_Tomb def.death-location:<player.location.block>
            - stop
        - narrate targets:<player> "<dark_red>[Tombs]: <gray>You cannot be Entombed when you have nothing to bring to the afterlife."
        after player logs in:
        - if <player.has_flag[TOMB.LOCATIONS]>:
            - narrate "<dark_red>[Tombs]: <gray>You might have pending tombs still."
        after player right clicks player_head location_flagged:TOMB:
        - if !<context.location.has_flag[TOMB.OWNER]>:
            - stop
        - define tomb-location <context.location>
        - define tomb-owner <[tomb-location].flag[TOMB.OWNER]>
        - if <player.is_op> && !<player.is_sneaking> || <player> == <[tomb-owner]> && !<player.is_sneaking>:
            - define tomb-inventory <inventory[Tomb_Inventory]>
            - run Tomb_Populate_Inventory def.tomb-location:<[tomb-location]> def.tomb-inventory:<[tomb-inventory]>
            - flag <player> TOMB.OPENNED:<[tomb-location]>
            - run Tomb_Remove_Compass def.player:<player>
        - if <player> != <[tomb-location].flag[TOMB.OWNER]>:
            - narrate "<dark_red>[Tombs]: <gray>This is not the tomb your looking for...."
            - stop
        - if <player.is_sneaking>:
            - if <player.inventory.is_empty> && <player.equipment.exclude[<item[air]>].is_empty>:
                - experience give <[tomb-location].flag[TOMB.XP]>
                - playsound <player> sound:entity_player_levelup sound_category:master volume:1
                - flag <[tomb-owner]> TOMB.LOCATIONS.<[tomb-location].flag[TOMB.UUID]>:!
                - if <[tomb-location].has_flag[TOMB.EQUIPMENT]>:
                    - adjust <player> equipment:<[tomb-location].flag[TOMB.EQUIPMENT]>
                - if <[tomb-location].has_flag[TOMB.CONTENTS]>:
                    - inventory set destination:<player.inventory> origin:<[tomb-location].flag[TOMB.CONTENTS]>
                - flag <[tomb-location]> TOMB:!
                - modifyblock <[tomb-location]> air naturally:<item[diamond_pickaxe]>
                - run Tomb_Remove_Compass def.player:<player>
                - run Tomb_Remove_Compass def.player:<[tomb-owner]>
                - stop
            - narrate targets:<player> "<dark_red>[Tombs]: <gray>Your inventory must be empty for you to use this function!"
        on player closes Tomb_Inventory:
        - define location <player.flag[TOMB.OPENNED]>
        - flag <player> TOMB.OPENNED:!
        - if !<[location].has_flag[TOMB]>:
            - stop
        - flag <[location]> TOMB.CONTENTS:<context.inventory.list_contents>
        - flag <[location]> TOMB.EQUIPMENT:!
        - run Tomb_Remove_Compass def.player:<player>
        after player clicks item in Tomb_Inventory:
        - define open-tomb <player.flag[TOMB.OPENNED]>
        - define tomb-owner <[open-tomb].flag[TOMB.OWNER]>
        - if <context.inventory.is_empty>:
            - inventory close
            - flag <player> TOMB.LOCATIONS.<[open-tomb].flag[TOMB.UUID]>:!
            - experience give <[open-tomb].flag[TOMB.XP]>
            - playsound <player> sound:entity_player_levelup sound_category:master volume:1
            - flag <[open-tomb]> TOMB:!
            - flag <player> TOMB.OPENNED:!
            - modifyblock <[open-tomb]> air naturally:<item[diamond_pickaxe]>
        on player breaks player_head location_flagged:TOMB:
        - if !<context.location.has_flag[TOMB.OWNER]>:
            - stop
        - define tomb-owner <context.location.flag[TOMB.OWNER]>
        - define tomb-uuid <context.location.flag[TOMB.UUID]>
        - if <player.is_op>:
            - narrate targets:<player> "<dark_red>[Tombs]: <gray>This is not the tomb your looking for... but you broke it anyway..."
            - flag <[tomb-owner]> TOMB.VOID.<[tomb-uuid]>.CONTENTS:<proc[Tomb_Get_Contents].context[<context.location>]>
            - flag <[tomb-owner]> TOMB.VOID.<[tomb-uuid]>.UUID:<[tomb-uuid]>
            - flag <[tomb-owner]> TOMB.VOID.<[tomb-uuid]>.TIME:<[tomb-owner].flag[TOMB.LOCATIONS.<[tomb-uuid]>.TIME]>
            - flag <[tomb-owner]> TOMB.VOID.<[tomb-uuid]>.XP:<context.location.flag[TOMB.XP]>
            - flag <[tomb-owner]> TOMB.LOCATIONS.<[tomb-uuid]>:!
            - flag <context.location> TOMB:!
            - run Tomb_Remove_Compass def.player:<player>
            - run Tomb_Remove_Compass def.player:<[tomb-owner]>
            - stop
        - if <player> != <[tomb-owner]>:
            - narrate targets:<player> "<dark_red>[Tombs]: <gray>This is not the tomb your looking for...."
            - determine cancelled
        - if <player.inventory.is_empty> && <player.equipment.exclude[<item[air]>].is_empty>:
            - experience give <context.location.flag[TOMB.XP]>
            - playsound <player> sound:entity_player_levelup sound_category:master volume:1
            - flag <player> TOMB.LOCATIONS.<context.location.flag[TOMB.UUID]>:!
            - adjust <player> equipment:<context.location.flag[TOMB.EQUIPMENT]>
            - inventory set destination:<player.inventory> origin:<context.location.flag[TOMB.CONTENTS]>
            - modifyblock <context.location> air naturally:<item[diamond_pickaxe]>
            - flag <context.location> TOMB:!
            - run Tomb_Remove_Compass def.player:<player>
            - stop
        - narrate targets:<player> "<dark_red>[Tombs]: <gray>Your inventory must be empty for you to use this function!"
        - determine cancelled

Tomb_Remove_Compass:
    debug: false
    type: task
    definitions: player
    script:
    - if <[player].has_flag[COMPASS.DISPLAY]>:
        - flag <[player]> COMPASS.DISPLAY:!
        - bossbar remove <[player].uuid>
    - if <[player].has_flag[TOMB.WAYPOINT]>:
        - define waypoint-id <[player].flag[TOMB.WAYPOINT]>
        - flag <[player]> TOMB.WAYPOINT:!
        - run Compass_Remove_Location def.id:<[waypoint-id]>

Tomb_Remove_Broken_Stuff:
    debug: false
    type: task
    script:
    - define broken-items <server.flag[TOMB.BROKEN].if_null[<list[]>]>
    - foreach <[broken-items]> as:item:
        - if <player.inventory.contains_item[<[item]>]>:
            - flag <player> TOMB.CONFISCATED.<[item]>
            - take item:<[item]>

Tomb_Flag_Broken_Stuff:
    debug: false
    type: task
    script:
    - flag server TOMB.BROKEN:->:SGC_MINI_ME

Tomb_Generate_Tomb:
    debug: false
    type: task
    definitions: death-location
    script:
    - define grave-location <proc[Tomb_Get_Valid_Grave_Location].context[<[death-location]>]>
    - if <[grave-location]>:
        - run Tomb_Place_Grave def.death-location:<[grave-location]>
        - narrate targets:<player> "<dark_red>[Tombs]: <gray>You died at <[grave-location].xyz> in the <proc[Tomb_Directory_Get_Dimension].context[<[death-location].world.name>]>"
        - narrate targets:<player> "<dark_red>[Tombs]: <gray>Use /tomb to manage your tombs!"
        - stop
    - define uuid <util.random_uuid>
    - flag <player> TOMB.VOID.<[uuid]>.TIME:<util.time_now>
    - flag <player> TOMB.VOID.<[uuid]>.CONTENTS:<player.inventory.list_contents.exclude[<item[air]>]>
    - flag <player> TOMB.VOID.<[uuid]>.XP:<player.xp_total.mul[<proc[Tomb_Get_XP_Modifier]>]>
    - flag <player> TOMB.VOID.<[uuid]>.UUID:<[uuid]>
    - flag server TOMB.<player.uuid>.<[uuid]>.CONTENTS:<player.inventory.list_contents.exclude[<item[air]>]>
    - flag server TOMB.<player.uuid>.<[uuid]>.UUID:<[uuid]>
    - flag server TOMB.<player.uuid>.<[uuid]>.TIME:<util.time_now>
    - narrate targets:<player> "<dark_red>[Tombs]: <gray>Sorry! We could not find where to put your stuff."
    - narrate targets:<player> "<dark_red>[Tombs]: <gray>Use /tomb retrieve to manage them!"
    - stop

Tomb_Inventory:
    debug: false
    type: inventory
    inventory: chest
    title: <dark_red>Tomb of the Dead <gray>|
    size: 54

Tomb_Populate_Inventory:
    debug: false
    type: task
    definitions: tomb-location|tomb-inventory
    script:
    - define player-name <[tomb-location].flag[TOMB.OWNER].name>
    - adjust def:tomb-inventory "title:<[tomb-inventory].title> <dark_aqua><[player-name]>"
    - inventory set destination:<[tomb-inventory]> origin:<proc[Tomb_Get_Contents].context[<[tomb-location]>]>
    - inventory open destination:<[tomb-inventory]>

Tomb_Get_Contents:
    debug: false
    type: procedure
    definitions: tomb-location
    script:
    - define contents <[tomb-location].flag[TOMB.CONTENTS]>
    - if <[tomb-location].has_flag[TOMB.EQUIPMENT]>:
        - define equipment <[tomb-location].flag[TOMB.EQUIPMENT]>
        - foreach <[equipment]> key:key as:val:
            - define contents:->:<[val]>
    - determine <[contents]>

Tomb_Should_Place_Grave:
    type: procedure
    debug: false
    script:
    #- if <player.is_op>:
    #    - determine FALSE
    - if <player.inventory.list_contents.is_empty>:
        - determine FALSE
    - determine TRUE

Tomb_Get_Expire_Time:
    type: procedure
    debug: false
    script:
    # Spinaling
    - if <player.has_permission[Spinalcraft.Tomb.1]>:
       - determine 5h
    # Donor
    - if <player.has_permission[Spinalcraft.Tomb.2]>:
       - determine 10h
    # Donor+
    - if <player.has_permission[Spinalcraft.Tomb.3]>:
       - determine 15h
    # Creator +
    - if <player.has_permission[Spinalcraft.Tomb.4]>:
       - determine 24h
    - determine 24h

Tomb_Get_XP_Modifier:
    type: procedure
    debug: false
    script:
    - if <player.has_permission[Spinalcraft.Tomb.1]>:
       - determine 0.2
    - if <player.has_permission[Spinalcraft.Tomb.2]>:
       - determine 0.4
    - if <player.has_permission[Spinalcraft.Tomb.3]>:
       - determine 0.6
    - if <player.has_permission[Spinalcraft.Tomb.4]>:
       - determine 0.8
    - if <player.has_permission[Spinalcraft.Tomb.5]>:
       - determine 0.8
    - determine 0

Tomb_Get_Valid_Grave_Location:
    type: procedure
    debug: false
    definitions: death-location
    script:
    - if <[death-location].is_spawnable>:
        - determine <[death-location]>
    - choose <[death-location].world.name>:
        - case world:
            - determine <proc[Tomb_Overworld_Valid_Grave_Location].context[<[death-location]>]>
        - case world_nether:
            - determine <proc[Tomb_Nether_Valid_Grave_Location].context[<[death-location]>]>
        - case world_the_end:
            - determine <proc[Tomb_End_Valid_Grave_Location].context[<[death-location]>]>

Tomb_Overworld_Valid_Grave_Location:
    type: procedure
    debug: false
    definitions: death-location
    script:
    - define SGC <cuboid[SGC]>
    - define temp-location <[death-location]>
    - if <[SGC].contains[<[death-location]>]>:
        - determine FALSE
    # Death in Void
    - if <[temp-location].world.min_height> > <[temp-location].y>:
        - determine <[temp-location].chunk.surface_blocks.random.up.if_null[FALSE]>
    # Death super high somehow
    - if <[temp-location].world.max_height> < <[temp-location].y>:
        - determine <[temp-location].chunk.surface_blocks.random.up.if_null[FALSE]>
    # Death in liquid
    - while <[temp-location].is_liquid>:
        - define temp-location <[temp-location].up>
        - if <[temp-location].material> == <material[air]>:
            - determine <[temp-location]>
    - while !<[temp-location].is_spawnable> && <[temp-location].material> == <material[air]>:
        - if <[temp-location].is_spawnable>:
            - while stop
        - if <[temp-location].below.is_liquid>:
            - while stop
        - define temp-location <[temp-location].below>
    - if <[temp-location].material> == <material[air]> || <[temp-location].is_spawnable>:
        - determine <[temp-location].up>
    - determine <[temp-location].chunk.surface_blocks.random.up.if_null[FALSE]>

Tomb_Nether_Valid_Grave_Location:
    debug: false
    type: procedure
    definitions: death-location
    script:
    - define temp-location <[death-location]>
    ## WORLD GENERATION COULD CHANGE THIS
    - define max-height 128
    # Death in Void
    - if <[death-location].world.min_height> > <[death-location].y>:
        - while <[temp-location].material> != <material[air]> && <[max-height]> < <[temp-location].y>:
            - define temp-location <[temp-location].up>
        - if <[temp-location].material> == <material[air]>:
            - determine <[temp-location]>
    # Death super high somehow
    - if <[max-height]> <= <[death-location].y> || !<[temp-location].is_spawnable> && <[temp-location].material> == <material[air]>:
        - while <[death-location].world.min_height> < <[temp-location].y>:
            - if <[temp-location].is_spawnable> && <[max-height]> > <[temp-location].y>:
                - while stop
            - define temp-location <[temp-location].below>
        - if <[temp-location].material> == <material[air]> || <[temp-location].is_spawnable>:
            - determine <[temp-location]>
    # Death in liquid
    - while <[temp-location].is_liquid>:
        - if <[max-height]> > <[temp-location].y>:
            - define temp-location <[temp-location].up>
        - if <[max-height]> == <[temp-location]>:
            - define temp-location <[death-location]>
    # Death location in valid air location
    - if <[temp-location].is_spawnable> && <[max-height]> > <[temp-location].y>:
        - determine <[temp-location]>
    # Find Random Death spot near solid block
    - define close-blocks <[temp-location].find_spawnable_blocks_within[20]>
    - if !<[close-blocks].is_empty>:
        - foreach <[close-blocks]> as:block:
            - if <[block].y> < <[max-height]>:
                - determine <[block]>
    - define close-blocks <[death-location].find_spawnable_blocks_within[50].exclude[<[close-blocks]>]>
    - if !<[close-blocks].is_empty>:
        - foreach <[close-blocks]> as:block:
            - if <[block].y> < <[max-height]>:
                - determine <[block]>
    - determine FALSE

Tomb_End_Valid_Grave_Location:
    debug: false
    type: procedure
    definitions: death-location
    script:
    - define temp-location <[death-location]>
    - define end-spawn <cuboid[TOMB.END].blocks>
    # Death in Void
    - if <[death-location].world.min_height> > <[temp-location].y>:
        - define surface-blocks <[temp-location].chunk.surface_blocks>
        - foreach <[surface-blocks]> as:location:
            - define location <[location].up>
            - if !<[end-spawn].contains[<[location].block>]> && <[location].is_spawnable>:
                - determine <[location]>
        - determine FALSE
    # Death super high somehow
    - if <[death-location].world.max_height> < <[temp-location].y>:
        - define surface-positions <[temp-location].chunk.surface_blocks>
        - foreach <[surface-positions]> as:location:
            - define location <[location].up>
            - if !<[end-spawn].contains[<[location].block>]> && <[location].is_spawnable>:
                - determine <[location]>
        - determine FALSE
    # Death in liquid
    - while <[temp-location].is_liquid>:
            - define temp-location <[temp-location].up>
    # Death location in valid air location
    - while !<[temp-location].is_spawnable> && <[temp-location].material> == <material[air]>:
        - if <[temp-location].is_spawnable>:
            - while stop
        - if <[temp-location].below.is_liquid>:
            - while stop
        - define temp-location <[temp-location].below>
    - if <[temp-location].material> == <material[air]> || <[temp-location].is_spawnable>:
        - if !<[end-spawn].contains[<[temp-location]>]>:
            - determine <[temp-location].up>
    # Find Random Death spot near solid block
    - foreach <[death-location].find_spawnable_blocks_within[20]> as:location:
        - if !<[end-spawn].contains[<[location].block>]>:
            - determine <[location]>
    - determine FALSE

Tomb_Place_Grave:
    type: task
    debug: false
    definitions: death-location
    script:
        - modifyblock <[death-location]> player_head
        - adjust <[death-location]> skull_skin:<player.skull_skin>
        - define expire-time <proc[Tomb_Get_Expire_Time]>
        - define uuid <util.random_uuid>
        - flag <player> TOMB.LOCATIONS.<[uuid]> expire:<[expire-time]>
        - flag <player> TOMB.LOCATIONS.<[uuid]>.TIME:<util.time_now>
        - flag <player> TOMB.LOCATIONS.<[uuid]>.EXPIRE:<[expire-time]>
        - flag <player> TOMB.LOCATIONS.<[uuid]>.LOCATION:<[death-location]>
        - flag <player> TOMB.LOCATIONS.<[uuid]>.UUID:<[uuid]>
        - flag <[death-location]> TOMB expire:<[expire-time]>
        - flag <[death-location]> TOMB.UUID:<[uuid]> expire:<[expire-time]>
        - flag <[death-location]> TOMB.OWNER:<player> expire:<[expire-time]>
        - flag <[death-location]> TOMB.CONTENTS:<player.inventory.slot[<util.list_numbers[to=36]>].exclude[<item[air]>]> expire:<[expire-time]>
        - flag <[death-location]> TOMB.EQUIPMENT:<player.equipment_map> expire:<[expire-time]>
        - flag <[death-location]> TOMB.XP:<player.xp_total.mul[<proc[Tomb_Get_XP_Modifier]>]> expire:<[expire-time]>
        - flag server TOMB.<player.uuid>.<[uuid]>.CONTENTS:<player.inventory.list_contents.exclude[<item[air]>]>
        - flag server TOMB.<player.uuid>.<[uuid]>.TIME:<util.time_now>
        - flag server TOMB.<player.uuid>.<[uuid]>.UUID:<[uuid]>

#---Directory-----------------------------------------------------------#
##--Items--##
Tomb_Preview_Icon:
    type: item
    material: chest
    display name: <gold>Preview Tomb

Tomb_Delete_Icon:
    type: item
    material: barrier
    display name: <Red>Remove Tomb
    lore:
    - <dark_red>Warning you will delete your tombs inventory permanently

Tomb_Open_Icon:
    type: item
    material: ender_chest
    display name: <light_purple>Open Tomb

Tomb_Verify_Delete_Icon:
    type: item
    material: barrier
    display name: <Red>Remove Tomb
    lore:
    - <dark_red>Warning! This is impossible to undo.
    - <dark_red>Warning! Staff cannot fix this action.
    - <dark_red>Warning! You have been warned

Tomb_Directory_Item:
    type: item
    material: player_head

Tomb_Redeem_Icon:
    type: item
    material: diamond
    display name: <light_purple>Retrieve Tomb
    lore:
    - <dark_green><italic>Cost: <green>20 Vote Coins

Tomb_Teleport_Icon:
    type: item
    material: ender_pearl
    display name: <aqua>Teleport near Tomb
    lore:
    - <dark_green><italic>Cost: <green>10 Vote Coins

Tomb_Buy_Back_Icon:
    type: item
    material: emerald
    display name: <green>Buy-Back Tomb
    lore:
    - <dark_green><italic>Cost: <green>30 Vote Coins

Tomb_Track_Icon:
    type: item
    material: filled_map
    display name: <yellow>Track Tomb
    lore:
    - <dark_green><italic>Cost: <gold>FREE
    - <aqua>Adds a waypoint to show you back to your Tomb

##--Inventories--#
Tomb_Directory:
    debug: false
    type: inventory
    inventory: chest
    gui: true
    title: <dark_aqua>Tomb Directory <gray>|
    size: 54

Tomb_Preview:
    debug: false
    type: inventory
    inventory: chest
    gui: true
    size: 54

Tomb_Editable:
    debug: false
    type: inventory
    inventory: chest
    size: 54

Tomb_Options:
    debug: false
    type: inventory
    inventory: hopper
    gui: true
    title: <dark_aqua>Tomb Options <gray>|

Tomb_Verify_Delete:
    debug: false
    type: inventory
    inventory: dropper
    gui: true
    title: <red>Verify you want to delete.
    slots:
    - [] [] []
    - [] [Tomb_Verify_Delete_Icon] []
    - [] [] []

##--COMMANDS--##
Tomb_Command_Suggestions:
    debug: false
    type: procedure
    definitions: argument#
    script:
    - if !<player.is_op>:
        - determine <list[retrieve|compass]>
    - if <[argument#]> == 1 && <player.is_op> && !<list[GeneralX|Belinski20].contains[<player.name>]>:
        - determine <list[retrieve|compass].include[<server.online_players.parse[name]>]>
    - if <[argument#]> == 2 && <player.is_op> && !<list[GeneralX|Belinski20].contains[<player.name>]>:
        - determine <list[retrieve|tomb]>
    - if <[argument#]> == 1 && <player.is_op> && <list[GeneralX|Belinski20].contains[<player.name>]>:
        - determine <list[retrieve|compass|review].include[<server.online_players.parse[name]>]>
    - if <[argument#]> == 2 && <player.is_op> && <list[GeneralX|Belinski20].contains[<player.name>]>:
        - determine <list[retrieve|review|tomb]>

Tomb_test_Directory:
    type: command
    debug: false
    name: tomb
    description: Opens the Different Tomb Directory
    usage: /tomb
    permission: Spinal.TOMBS.PLAYER
    tab completions:
        1: <proc[Tomb_Command_Suggestions].context[1]>
        2: <proc[Tomb_Command_Suggestions].context[2]>
    script:
    - define player <player>
    - define argument-1 <context.args.get[1].if_null[FALSE]>
    # Normal Player
    - if !<player.is_op>:
        - run Tomb_Command_Helper def.argument-1:<[argument-1]>
        - if <[argument-1]> != compass:
            - run Tomb_Display_Directory_Populate def.player:<[player]>
        - stop
    # OP Player
    - if <list[retrieve|review|compass].contains[<[argument-1]>]>:
        - run Tomb_Command_Helper def.argument-1:<[argument-1]>
        - if <[argument-1]> != compass:
            - run Tomb_Display_Directory_Populate def.player:<[player]>
        - stop
    - define argument-1 <server.match_offline_player[<[argument-1]>].if_null[FALSE]>
    - if !<[argument-1]>:
        - run Tomb_Display_Directory_Populate def.player:<[player]>
        - stop
    - define argument-2 <context.args.get[2].to_lowercase.if_null[tomb]>
    - if !<list[retrieve|review|tomb].contains[<[argument-2]>]>:
        - narrate targets:<player> "<dark_red>[Tombs]: <gray>Invalid action to do with this tomb."
        - stop
    - choose <[argument-2]>:
        - case retrieve:
            - flag <player> TOMB.DIRECTORY.VIEW:REDEEM
        - case review:
            - flag <player> TOMB.DIRECTORY.VIEW:ADMIN
        - case tomb:
            - flag <player> TOMB.DIRECTORY.VIEW:TOMB
        - default:
            - flag <player> TOMB.DIRECTORY.VIEW:TOMB
    - run Tomb_Display_Directory_Populate def.player:<[argument-1]>

Tomb_Command_Helper:
    debug: false
    type: task
    definitions: argument-1
    script:
    - flag <player> TOMB.DIRECTORY.VIEW:TOMB
    - if <[argument-1]>:
        - choose <[argument-1]>:
            - case retrieve:
                - flag <player> TOMB.DIRECTORY.VIEW:REDEEM
            - case review:
                - if <player.is_op>:
                    - flag <player> TOMB.DIRECTORY.VIEW:ADMIN
            - case compass:
                - run Tomb_Clean_Compass
                - stop
            - case default:
                - flag <player> TOMB.DIRECTORY.VIEW:TOMB

##--HANDLERS--#
Tomb_Handler_Directory:
    debug: false
    type: world
    events:
        on player clicks in Tomb_Directory:
        - if <context.slot> < 0:
            - stop
        - if <context.item> == <item[air]> || <context.clicked_inventory> != <context.inventory>:
            - stop
        - define tomb-uuid <context.item.flag[TOMB.UUID]>
        - define tomb-owner <context.item.flag[TOMB.OWNER]>
        - flag <player> TOMB.DIRECTORY.UUID:<[tomb-uuid]>
        - flag <player> TOMB.DIRECTORY.OWNER:<[tomb-owner]>
        - run Tomb_Display_Directory_Click

Tomb_Handler_Options:
    debug: false
    type: world
    events:
        on player clicks Tomb_Preview_Icon in Tomb_Options:
        - run Tomb_Display_Preview
        on player clicks Tomb_Teleport_Icon in Tomb_Options:
        - run Tomb_Teleport_Click
        on player clicks Tomb_Delete_Icon in Tomb_Options:
        - run Tomb_Display_Delete
        on player clicks Tomb_Redeem_Icon in Tomb_Options:
        - run Tomb_Redeem_Click
        on player clicks Tomb_Open_Icon in Tomb_Options:
        - run Tomb_Directory_Review_Editable
        on player clicks Tomb_Track_Icon in Tomb_Options:
        - run Tomb_Tracker_Click
        on player clicks Tomb_Buy_Back_Icon in Tomb_Options:
        - run Tomb_Buy_Back_Click
        on player clicks item in Tomb_Editable:
        - if <context.cursor_item> != <item[air]> && <context.inventory> == <context.clicked_inventory>:
            - determine cancelled
        on player drags item in Tomb_Editable:
        - if <context.inventory> == <context.clicked_inventory>:
            - determine cancelled
        on player closes Tomb_Editable:
        - define tomb-uuid <player.flag[TOMB.DIRECTORY.UUID]>
        - define tomb-owner <player.flag[TOMB.DIRECTORY.OWNER]>
        - define contents <context.inventory.list_contents.exclude[<item[air]>]>
        - if <[contents].is_empty>:
            - flag server TOMB.<[tomb-owner].uuid>.<[tomb-uuid]>:!
        - else:
            - flag server TOMB.<[tomb-owner].uuid>.<[tomb-uuid]>.CONTENTS:<[contents]>
        - flag <player> TOMB.DIRECTORY:!

Tomb_Handler_Delete:
    debug: false
    type: world
    events:
        on player clicks Tomb_Verify_Delete_Icon in Tomb_Verify_Delete:
        - run Tomb_Delete_Tomb

##--DISPLAY CHOOSE--#
Tomb_Display_Preview:
    debug: false
    type: task
    script:
    - define view <player.flag[TOMB.DIRECTORY.VIEW].if_null[TOMB]>
    - choose <[view]>:
        - case TOMB:
            - run Tomb_Directory_Preview
        - case REDEEM:
            - run Tomb_Directory_Redeem_Preview
        - case ADMIN:
            - run Tomb_Directory_Review_Preview
        - default:
            - run Tomb_Directory_Preview

Tomb_Display_Delete:
    debug: false
    type: task
    script:
    - define view <player.flag[TOMB.DIRECTORY.VIEW].if_null[TOMB]>
    - choose <[view]>:
        - case TOMB:
            - run Tomb_Directory_Delete
        - case REDEEM:
            - run Tomb_Directory_Redeem_Delete
        - case ADMIN:
            - run Tomb_Directory_Review_Delete
        - default:
            - run Tomb_Populate_Directory

Tomb_Delete_Tomb:
    debug: false
    type: task
    script:
    - define view <player.flag[TOMB.DIRECTORY.VIEW].if_null[TOMB]>
    - define tomb-uuid <player.flag[TOMB.DIRECTORY.UUID]>
    - define tomb-owner <player.flag[TOMB.DIRECTORY.OWNER]>
    - choose <[view]>:
        - case TOMB:
            - define location <[tomb-owner].flag[TOMB.LOCATIONS.<[tomb-uuid]>.LOCATION].if_null[FALSE]>
            - flag <[tomb-owner]> TOMB.LOCATIONS.<[tomb-uuid]>:!
            - if <[location]>:
                - flag <[location]> TOMB:!
            - else:
                - narrate targets:<player> "<dark_red>[Tombs]: <gray>The Tomb has already been Claimed or Expired!"
                - inventory close
                - stop
        - case REDEEM:
            - flag <[tomb-owner]> TOMB.VOID.<[tomb-uuid]>:!
        - case ADMIN:
            - flag server TOMB.<[tomb-owner].uuid>.<[tomb-uuid]>:!
            - narrate targets:<player> "<dark_red>[Tombs]: <gray>This Tomb <gold>could <gray>still exist in the world."
        - default:
            - define message "[Tombs]: <player.name> has View code of <[view]> which is invalid."
            - announce "<dark_red>[Tombs]: <gray><player.name> has View code of <[view]> which is invalid." to_console
            - discordmessage id:SpinalBot channel:1253549073940877372 embed:<discord_embed[title=Tomb Invalid View Code;description=<[message]>;color=<color[#EBF609]>;footer=Spinalcraft <bungee.server>]>
    - narrate targets:<player> "<dark_red>[Tombs]: <gray>This grave has been <red>permanently <gray>deleted"
    - flag <player> TOMB.DIRECTORY:!
    - inventory close

Tomb_Display_Directory_Click:
    debug: false
    type: task
    script:
    - define view <player.flag[TOMB.DIRECTORY.VIEW].if_null[TOMB]>
    - choose <[view]>:
        - case TOMB:
            - run Tomb_Directory_Click
        - case REDEEM:
            - run Tomb_Directory_Redeem_Click
        - case ADMIN:
            - run Tomb_Directory_Review_Click
        - default:
            - run Tomb_Populate_Directory

Tomb_Display_Directory_Populate:
    debug: false
    type: task
    definitions: player
    script:
    - define view <player.flag[TOMB.DIRECTORY.VIEW].if_null[TOMB]>
    - choose <[view]>:
        - case TOMB:
            - run Tomb_Populate_Directory def.player:<[player]>
        - case REDEEM:
            - run Tomb_Directory_Redeem_Populate def.player:<[player]>
        - case ADMIN:
            - run Tomb_Directory_Review_Populate def.player:<[player]>
        - default:
            - run Tomb_Populate_Directory

##--DIRECTORY TOMBS--#
Tomb_Populate_Directory:
    debug: false
    type: task
    definitions: player
    script:
    - ~run Tomb_Flag_List_Clean_Up def.player:<[player]>
    # If player has no Tombs end early
    - if !<[player].has_flag[TOMB.LOCATIONS]>:
        - narrate targets:<player> "<dark_red>[Tombs]: <gray><[player].name> has no Tombs."
        - stop
    - define tomb-list <list[]>
    - foreach <[player].flag[TOMB.LOCATIONS].keys> as:uuid:
        - if <[tomb-list].size> >= 54:
            - narrate targets:<player> "<dark_red>[Tombs]: <gray>Showing a subset of <[player].name>'s Tombs"
            - foreach stop
        - define tomb-item <item[Tomb_Directory_Item]>
        - adjust def:tomb-item skull_skin:eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvYjdjYWI1NmM4MmNiODFiZGI5OTc5YTQ2NGJjOWQzYmEzZTY3MjJiYTEyMmNmNmM1Mjg3MzAxMGEyYjU5YWVmZSJ9fX0=
        - define expire-time <duration[<[player].flag[TOMB.LOCATIONS.<[uuid]>.EXPIRE]>]>
        - define death-time <[player].flag[TOMB.LOCATIONS.<[uuid]>.TIME]>
        - define tomb-time <[expire-time].sub[<util.time_now.duration_since[<[death-time]>]>]>
        - if <[tomb-time].is_less_than[<duration[0s]>]>:
            - flag <[player]> TOMB.LOCATIONS.<[uuid]>:!
            - foreach next
        - define death-location <[player].flag[TOMB.LOCATIONS.<[uuid]>.LOCATION].world.name>
        - define world-name <proc[Tomb_Directory_Get_Dimension].context[<[death-location]>]>
        - adjust def:tomb-item "display:<[world-name]> <gray>Tomb | <[tomb-time].formatted>"
        - flag <[tomb-item]> TOMB.UUID:<[uuid]>
        - flag <[tomb-item]> TOMB.OWNER:<[player]>
        - define tomb-list:->:<[tomb-item]>
    - define directory <inventory[Tomb_Directory]>
    - adjust def:directory "title:<[directory].title> <[player].name>"
    - inventory set destination:<[directory]> origin:<[tomb-list]>
    - inventory open destination:<[directory]>

Tomb_Directory_Redeem_Populate:
    debug: false
    type: task
    definitions: player
    script:
    - if !<[player].has_flag[TOMB.VOID]>:
            - narrate targets:<player> "<dark_red>[Tombs]: <gray><[player].name> has no Tombs to Retrieve."
            - stop
    - if <[player].has_flag[TOMB.VOID]>:
        - if <[player].flag[TOMB.VOID].keys.is_empty>:
            - narrate targets:<player> "<dark_red>[Tombs]: <gray><[player].name> has no Tombs to Retrieve."
            - flag <[player]> TOMB.VOID:!
            - stop
    - define tomb-list <list[]>
    - foreach <[player].flag[TOMB.VOID].keys> as:uuid:
        - if <[tomb-list].size> >= 54:
            - narrate targets:<player> "<dark_red>[Tombs]: <gray>Showing a subset of <[player].name>'s Retrievable Tombs"
            - foreach stop
        - define tomb-item <item[Tomb_Directory_Item]>
        - adjust def:tomb-item skull_skin:eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvYjdjYWI1NmM4MmNiODFiZGI5OTc5YTQ2NGJjOWQzYmEzZTY3MjJiYTEyMmNmNmM1Mjg3MzAxMGEyYjU5YWVmZSJ9fX0=
        - define tomb-time <util.time_now.duration_since[<[player].flag[TOMB.VOID.<[uuid]>.TIME]>].formatted.if_null[unknown]>
        - adjust def:tomb-item "display:<light_purple>Retrievable <gray>Tomb | created <[tomb-time]> ago"
        - flag <[tomb-item]> TOMB.UUID:<[uuid]>
        - flag <[tomb-item]> TOMB.OWNER:<[player]>
        - define tomb-list:->:<[tomb-item]>
    - define directory <inventory[Tomb_Directory]>
    - adjust def:directory "title:<[directory].title> <[player].name>"
    - inventory set destination:<[directory]> origin:<[tomb-list]>
    - inventory open destination:<[directory]>

Tomb_Directory_Review_Populate:
    debug: false
    type: task
    definitions: player
    script:
    - define owner-uuid <[player].uuid>
    - if !<server.has_flag[TOMB.<[owner-uuid]>]>:
        - narrate targets:<player> "<dark_red>[Tombs]: <gray><[player].name> has no Tombs."
        - stop
    - define tomb-list <list[]>
    - define total-tombs <server.flag[TOMB.<[owner-uuid]>].keys.size.if_null[0]>
    - if <[total-tombs]> == 0:
        - narrate targets:<player> "<dark_red>[Tombs]: <gray><[player].name> has no Tombs."
        - stop
    - foreach <server.flag[TOMB.<[owner-uuid]>].keys> as:uuid:
        - if <[tomb-list].size> >= 54:
            - narrate targets:<player> "<dark_red>[Tombs]: <gray>Showing a subset of <[player].name>'s Tombs"
            - foreach stop
        - define tomb-time <util.time_now.duration_since[<server.flag[TOMB.<[owner-uuid]>.<[uuid]>.TIME]>]>
        - define tomb-item <item[Tomb_Directory_Item]>
        - adjust def:tomb-item skull_skin:eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvYjdjYWI1NmM4MmNiODFiZGI5OTc5YTQ2NGJjOWQzYmEzZTY3MjJiYTEyMmNmNmM1Mjg3MzAxMGEyYjU5YWVmZSJ9fX0=
        - adjust def:tomb-item "display:<gray>Tomb | <[tomb-time].formatted> Ago"
        - flag <[tomb-item]> TOMB.UUID:<[uuid]>
        - flag <[tomb-item]> TOMB.OWNER:<[player]>
        - define tomb-list:->:<[tomb-item]>
    - define directory <inventory[Tomb_Directory]>
    - adjust def:directory "title:<dark_aqua><[player].name> <gray>| Total: <gold><[total-tombs]>"
    - inventory set destination:<[directory]> origin:<[tomb-list]>
    - inventory open destination:<[directory]>

##--DIRECTORY TOMB CLICKS--#
Tomb_Directory_Click:
    debug: false
    type: task
    script:
    - define tomb-owner <player.flag[TOMB.DIRECTORY.OWNER]>
    - define options <inventory[Tomb_Options]>
    - adjust def:options "title:<[options].title> <[tomb-owner].name>"
    - inventory set destination:<[options]> slot:1 origin:<item[Tomb_Preview_Icon]>
    - inventory set destination:<[options]> slot:2 origin:<item[Tomb_Track_Icon]>
    - inventory set destination:<[options]> slot:3 origin:<item[Tomb_Teleport_Icon]>
    - inventory set destination:<[options]> slot:4 origin:<item[Tomb_Buy_Back_Icon]>
    - inventory set destination:<[options]> slot:5 origin:<item[Tomb_Delete_Icon]>
    - inventory open destination:<[options]>

Tomb_Directory_Redeem_Click:
    debug: false
    type: task
    script:
    - define tomb-owner <player.flag[TOMB.DIRECTORY.OWNER]>
    - define options <inventory[Tomb_Options]>
    - adjust def:options "title:<[options].title> <[tomb-owner].name>"
    - inventory set destination:<[options]> slot:1 origin:<item[Tomb_Preview_Icon]>
    - inventory set destination:<[options]> slot:3 origin:<item[Tomb_Redeem_Icon]>
    - inventory set destination:<[options]> slot:5 origin:<item[Tomb_Delete_Icon]>
    - inventory open destination:<[options]>

Tomb_Directory_Review_Click:
    debug: false
    type: task
    script:
    - define tomb-owner <player.flag[TOMB.DIRECTORY.OWNER]>
    - define options <inventory[Tomb_Options]>
    - adjust def:options "title:<[options].title> <[tomb-owner].name>"
    - inventory set destination:<[options]> slot:1 origin:<item[Tomb_Preview_Icon]>
    - inventory set destination:<[options]> slot:3 origin:<item[Tomb_Open_Icon]>
    - inventory set destination:<[options]> slot:5 origin:<item[Tomb_Delete_Icon]>
    - inventory open destination:<[options]>

##--DELETE ICON CLICKS--#
Tomb_Directory_Delete:
    debug: false
    type: task
    script:
    - define tomb-uuid <player.flag[TOMB.DIRECTORY.UUID]>
    - define tomb-owner <player.flag[TOMB.DIRECTORY.OWNER]>
    - if !<[tomb-owner].proc[Tomb_Exists].context[<[tomb-uuid]>]>:
        - flag <player> TOMB.DIRECTORY:!
        - narrate targets:<player> "<dark_red>[Tombs]: <gray>This Tomb was claimed or has Expired."
        - inventory close
        - stop
    - inventory open destination:<inventory[Tomb_Verify_Delete]>

Tomb_Directory_Redeem_Delete:
    debug: false
    type: task
    script:
    - define tomb-uuid <player.flag[TOMB.DIRECTORY.UUID]>
    - define tomb-owner <player.flag[TOMB.DIRECTORY.OWNER]>
    - if !<[tomb-owner].has_flag[TOMB.VOID.<[tomb-uuid]>]>:
        - flag <player> TOMB.DIRECTORY:!
        - narrate targets:<player> "<dark_red>[Tombs]: <gray>This Tomb was already Retrieved."
        - inventory close
        - stop
    - inventory open destination:<inventory[Tomb_Verify_Delete]>

Tomb_Directory_Review_Delete:
    debug: false
    type: task
    script:
    - define tomb-uuid <player.flag[TOMB.DIRECTORY.UUID]>
    - define tomb-owner <player.flag[TOMB.DIRECTORY.OWNER]>
    - if !<server.has_flag[TOMB.<[tomb-owner].uuid>.<[tomb-uuid]>]>:
        - flag <player> TOMB.DIRECTORY:!
        - narrate targets:<player> "<dark_red>[Tombs]: <gray>This Tomb was already Retrieved."
        - inventory close
        - stop
    - inventory open destination:<inventory[Tomb_Verify_Delete]>

##--TOMB OPTIONS DIRECTORY CLICK--#
Tomb_Teleport_Click:
    debug: false
    type: task
    script:
    - define cost 10
    - define tomb-uuid <player.flag[TOMB.DIRECTORY.UUID]>
    - define tomb-owner <player.flag[TOMB.DIRECTORY.OWNER]>
    - flag <player> TOMB.DIRECTORY:!
    - if !<[tomb-owner].proc[Tomb_Exists].context[<[tomb-uuid]>]>:
        - narrate targets:<player> "<dark_red>[Tombs]: <gray>This Tomb was claimed or has Expired."
        - inventory close
        - stop
    - inventory close
    - define tomb-location <[tomb-owner].flag[TOMB.LOCATIONS.<[tomb-uuid]>.LOCATION]>
    # Teleport to tomb location
    - if <player.flag[SPINAL.VOTE.COINS]> < <[cost]>:
        - narrate "<red>You do not have enough Vote Coins for this purchase!"
        - playsound targets:<player> sound:entity_llama_spit sound_category:MASTER pitch:.2
        - stop
    - define teleport-location FALSE
    - foreach <[tomb-location].find_spawnable_blocks_within[50]> as:loc:
        - wait .5s
        - define teleport-location <[loc]>
        - foreach stop
    - if !<[teleport-location]>:
        - narrate targets:<player> "<dark_red>[Tombs] <red>A safe location could not be found around your tomb....."
        - stop
    - flag <player> SPINAL.VOTE.COINS:-:<[cost]>
    - narrate targets:<player> "<dark_aqua>You bought <dark_red>Back to Tomb<dark_aqua> for <aqua>20 <dark_aqua>Vote Coins!"
    - narrate targets:<player> "<gray>Teleporting back in 3 seconds...."
    - wait 1s
    - narrate targets:<player> <gray>2...
    - wait 1s
    - narrate targets:<player> <gray>1...
    - wait 1s
    - actionbar targets:<player> "<dark_red>[Tombs] <gray>Teleporting you to a safe location around your tomb....."
    - teleport <player> <[teleport-location]>

Tomb_Buy_Back_Click:
    debug: false
    type: task
    script:
    - define cost 30
    - define tomb-uuid <player.flag[TOMB.DIRECTORY.UUID]>
    - define tomb-owner <player.flag[TOMB.DIRECTORY.OWNER]>
    - flag <player> TOMB.DIRECTORY:!
    - if !<[tomb-owner].proc[Tomb_Exists].context[<[tomb-uuid]>]>:
        - narrate targets:<player> "<dark_red>[Tombs]: <gray>This Tomb was claimed or has Expired."
        - inventory close
        - stop
    - inventory close
    # Check if the player inventory is empty
    - if !<player.inventory.is_empty>:
        - narrate targets:<player> "<dark_red>[Tombs]: <gray>Your inventory must be empty for you to use this function!"
        - stop
    # Check if the player can buy it
    - if <player.flag[SPINAL.VOTE.COINS]> < <[cost]>:
        - narrate "<red>You do not have enough Vote Coins for this purchase!"
        - playsound targets:<player> sound:entity_llama_spit sound_category:MASTER pitch:.2
        - stop
    - define tomb-location <[tomb-owner].flag[TOMB.LOCATIONS.<[tomb-uuid]>.LOCATION]>
    - chunkload add <[tomb-location].chunk> duration:1s
    - define inventory-contents <proc[Tomb_Get_Contents].context[<[tomb-location]>]>
    - flag <[tomb-location]> TOMB:!
    - flag <[tomb-owner]> TOMB.LOCATIONS.<[tomb-uuid]>:!
    - give <[inventory-contents]> to:<player.inventory>
    - run Tomb_Remove_Compass def.player:<player>
    - run Tomb_Remove_Compass def.player:<[tomb-owner]>

Tomb_Redeem_Click:
    debug: false
    type: task
    script:
    - define cost 20
    - define tomb-uuid <player.flag[TOMB.DIRECTORY.UUID]>
    - define tomb-owner <player.flag[TOMB.DIRECTORY.OWNER]>
    - flag <player> TOMB.DIRECTORY:!
    - if !<[tomb-owner].has_flag[TOMB.VOID.<[tomb-uuid]>]>:
        - narrate targets:<player> "<dark_red>[Tombs]: <gray>This Tomb was claimed or has Expired."
        - flag <[tomb-owner]> TOMB.VOID.<[tomb-uuid]>:!
        - inventory close
        - stop
    - inventory close
    # Check if the player inventory is empty
    - if !<player.inventory.is_empty>:
        - narrate targets:<player> "<dark_red>[Tombs]: <gray>Your inventory must be empty for you to use this function!"
        - stop
    # Check if the player can buy it
    - if <player.flag[SPINAL.VOTE.COINS]> < <[cost]>:
        - narrate "<red>You do not have enough Vote Coins for this purchase!"
        - playsound targets:<player> sound:entity_llama_spit sound_category:MASTER pitch:.2
        - stop
    - define inventory-contents <[tomb-owner].flag[TOMB.VOID.<[tomb-uuid]>.CONTENTS]>
    - define xp <[tomb-owner].flag[TOMB.VOID.<[tomb-uuid]>.XP]>
    - flag <[tomb-owner]> TOMB.VOID.<[tomb-uuid]>:!
    - give <[inventory-contents]> to:<player.inventory>
    - experience give <[xp]>
    - run Tomb_Remove_Compass def.player:<player>
    - run Tomb_Remove_Compass def.player:<[tomb-owner]>

Tomb_Tracker_Click:
    debug: false
    type: task
    script:
    - define tomb-uuid <player.flag[TOMB.DIRECTORY.UUID]>
    - define tomb-owner <player.flag[TOMB.DIRECTORY.OWNER]>
    - flag <player> TOMB.DIRECTORY:!
    - if !<[tomb-owner].proc[Tomb_Exists].context[<[tomb-uuid]>]>:
        - narrate targets:<player> "<dark_red>[Tombs]: <gray>This Tomb was claimed or has Expired."
        - inventory close
        - stop
    - inventory close
    - define tomb-location <[tomb-owner].flag[TOMB.LOCATIONS.<[tomb-uuid]>.LOCATION]>
    # Check if player already has the compass up
    - if !<player.has_flag[COMPASS.DISPLAY]>:
        - run Compass_Start
    # Clear previous Waypoints from compass
    - if <player.has_flag[TOMB.WAYPOINT]>:
        - define waypoint-id <player.flag[TOMB.WAYPOINT]>
        - flag <player> TOMB.WAYPOINT:!
        - run Compass_Remove_Location def.id:<[waypoint-id]>
    - flag <player> TOMB.WAYPOINT:<[tomb-uuid]>
    - run Compass_Add_Location def.id:<[tomb-uuid]> def.location:<[tomb-location]>

##--OPEN SELECTED TOMB--#
Tomb_Directory_Preview:
    debug: false
    type: task
    script:
    - define tomb-uuid <player.flag[TOMB.DIRECTORY.UUID]>
    - define tomb-owner <player.flag[TOMB.DIRECTORY.OWNER]>
    - flag <player> TOMB.DIRECTORY:!
    - if !<[tomb-owner].proc[Tomb_Exists].context[<[tomb-uuid]>]>:
        - narrate targets:<player> "<dark_red>[Tombs]: <gray>This Tomb was claimed or has Expired."
        - inventory close
        - stop
    - define tomb-location <[tomb-owner].flag[TOMB.LOCATIONS.<[tomb-uuid]>.LOCATION]>
    - define tomb-preview <inventory[Tomb_Preview]>
    - adjust def:tomb-preview "title:<dark_red>Tomb of the dead <gray>|"
    - run Tomb_Populate_Inventory def.tomb-location:<[tomb-location]> def.tomb-inventory:<[tomb-preview]>

Tomb_Directory_Redeem_Preview:
    debug: false
    type: task
    script:
    - define tomb-uuid <player.flag[TOMB.DIRECTORY.UUID]>
    - define tomb-owner <player.flag[TOMB.DIRECTORY.OWNER]>
    - flag <player> TOMB.DIRECTORY:!
    - if !<[tomb-owner].has_flag[TOMB.VOID.<[tomb-uuid]>]>:
        - narrate targets:<player> "<dark_red>[Tombs]: <gray>This Tomb was already Redeemed."
        - inventory close
        - stop
    - define contents <[tomb-owner].flag[TOMB.VOID.<[tomb-uuid]>.CONTENTS]>
    - define time <[tomb-owner].flag[TOMB.VOID.<[tomb-uuid]>.TIME]>
    - define age <util.time_now.duration_since[<[time]>]>
    - define tomb-preview <inventory[Tomb_Preview]>
    - adjust def:tomb-preview "title:<dark_aqua><[tomb-owner].name> <gray>| <gold><[age].formatted> Ago"
    - inventory set destination:<[tomb-preview]> origin:<[contents]>
    - inventory open destination:<[tomb-preview]>

Tomb_Directory_Review_Preview:
    debug: false
    type: task
    script:
    - define tomb-uuid <player.flag[TOMB.DIRECTORY.UUID]>
    - define tomb-owner <player.flag[TOMB.DIRECTORY.OWNER]>
    - flag <player> TOMB.DIRECTORY:!
    - if !<server.has_flag[TOMB.<[tomb-owner].uuid>.<[tomb-uuid]>]>:
        - narrate targets:<player> "<dark_red>[Tombs]: <gray>This Tomb was already Redeemed."
        - inventory close
        - stop
    - define contents <server.flag[TOMB.<[tomb-owner].uuid>.<[tomb-uuid]>.CONTENTS]>
    - define time <server.flag[TOMB.<[tomb-owner].uuid>.<[tomb-uuid]>.TIME]>
    - define age <util.time_now.duration_since[<[time]>]>
    - define tomb-preview <inventory[Tomb_Preview]>
    - adjust def:tomb-preview "title:<dark_aqua><[tomb-owner].name> | <gold><[age].formatted> Ago"
    - inventory set destination:<[tomb-preview]> origin:<[contents]>
    - inventory open destination:<[tomb-preview]>

Tomb_Directory_Review_Editable:
    debug: false
    type: task
    script:
    - define tomb-uuid <player.flag[TOMB.DIRECTORY.UUID]>
    - define tomb-owner <player.flag[TOMB.DIRECTORY.OWNER]>
    - if !<server.has_flag[TOMB.<[tomb-owner].uuid>.<[tomb-uuid]>]>:
        - narrate targets:<player> "<dark_red>[Tombs]: <gray>This Tomb was already Redeemed."
        - inventory close
        - stop
    - define contents <server.flag[TOMB.<[tomb-owner].uuid>.<[tomb-uuid]>.CONTENTS]>
    - define time <server.flag[TOMB.<[tomb-owner].uuid>.<[tomb-uuid]>.TIME]>
    - define age <util.time_now.duration_since[<[time]>]>
    - define tomb-preview <inventory[Tomb_Editable]>
    - adjust def:tomb-preview "title:<dark_aqua><[tomb-owner].name> | <gold><[age].formatted> Ago"
    - inventory set destination:<[tomb-preview]> origin:<[contents]>
    - inventory open destination:<[tomb-preview]>

##--UTIL--##
Tomb_Flag_List_Clean_Up:
    debug: false
    type: task
    definitions: player
    script:
    # Flag Cleanup
    - if <[player].has_flag[TOMB.LOCATIONS]>:
        - if <[player].flag[TOMB.LOCATIONS].keys.is_empty>:
            - flag <[player]> TOMB.LOCATIONS:!
    - if <[player].has_flag[TOMB.VOID]>:
        - if <[player].flag[TOMB.VOID].keys.is_empty>:
            - flag <[player]> TOMB.VOID:!

Tomb_Directory_Get_Dimension:
    debug: false
    type: procedure
    definitions: death-location
    script:
    - choose <[death-location]>:
            - case world:
                - determine <green>Overworld
            - case world_nether:
                - determine <red>Nether
            - case world_the_end:
                - determine <light_purple>End
            - default:
                - determine <empty>

Tomb_Exists:
    debug: false
    type: procedure
    definitions: tomb-owner|tomb-uuid
    script:
    - if !<[tomb-owner].has_flag[TOMB.LOCATIONS.<[tomb-uuid]>]>:
        - determine FALSE
    - define tomb-location <[tomb-owner].flag[TOMB.LOCATIONS.<[tomb-uuid]>.LOCATION]>
    - if !<[tomb-location].has_flag[TOMB]>:
        - determine FALSE
    - determine TRUE

Tomb_Clean_Old_Tombs:
    debug: false
    type: task
    script:
    - define max-tomb-lifetime <duration[7d]>
    - if !<server.has_flag[TOMB]>:
        - define message "No Tombs are saved serverside."
        - discordmessage id:SpinalBot channel:1253549073940877372 embed:<discord_embed[title=Spinal Tombs Cleaner;description=<[message]>;color=<color[#EBF609]>;footer=Spinalcraft <bungee.server>]>
    - define removed-tomb-count 0
    - foreach <server.flag[TOMB].keys> as:tomb-owner:
        - foreach <server.flag[TOMB.<[tomb-owner]>].keys> as:tomb-uuid:
            - define tomb-time <server.flag[TOMB.<[tomb-owner]>.<[tomb-uuid]>.TIME]>
            - if <util.time_now.duration_since[<[tomb-time]>].is_more_than[<[max-tomb-lifetime]>]>:
                - define removed-tomb-count:+:1
                - flag server TOMB.<[tomb-owner]>.<[tomb-uuid]>:!
    - define message "[Tombs]: Total of <[removed-tomb-count]> Tombs have been cleared."
    - discordmessage id:SpinalBot channel:1253549073940877372 embed:<discord_embed[title=Spinal Tombs Cleaner;description=<[message]>;color=<color[#EBF609]>;footer=Spinalcraft <bungee.server>]>

Tomb_Clean_Compass:
    debug: false
    type: task
    script:
    - if <player.has_flag[TOMB.WAYPOINT]>:
        - define waypoint-id <player.flag[TOMB.WAYPOINT]>
        - flag <player> TOMB.WAYPOINT:!
        - run Compass_Remove_Location def.id:<[waypoint-id]>
        - flag <player> COMPASS.DISPLAY:!
        - bossbar remove <player.uuid>