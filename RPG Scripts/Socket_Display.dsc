Socket_Display:
    type: world
    debug: false
    events:
        on player right clicks block location_flagged:STATION.SOCKET:
        - if <player.has_flag[RPG.SOCKET.ITEM]>:
            - if <player.has_flag[RPG.SOCKET.ENTITIES]>:
                - foreach <player.flag[RPG.SOCKET.ENTITIES]> as:entity:
                    - flag <player> RPG.SOCKET.ENTITIES:<-:<[entity]>
                    - fakespawn <[entity]> cancel players:<player>
            - ~run Socket_Append_Lore save:item
            - define item <entry[item].created_queue.determination.first>
            - if <player.inventory.can_fit[<[item]>]>:
                - give <[item]>
                - flag <player> RPG.SOCKET:!
                - flag <player> RPG.STORAGE:!
            - else:
                - flag <player> RPG.STORAGE.SOCKET:<[item]>
                - actionbar targets:<player> "<gold>Hey! Seems your inventory is to full. Come back when you have room."
            - stop
        - run Socket_Display_Sequence def.item:<context.item> def.station-location:<context.location>
        on player join flagged:RPG.SOCKET.ITEM:
        - if <player.has_flag[RPG.SOCKET.ENTITIES]>:
            - foreach <player.flag[RPG.SOCKET.ENTITIES]> as:entity:
                    - flag <player> RPG.SOCKET.ENTITIES:<-:<[entity]>
                    - fakespawn <[entity]> cancel players:<player>
        - ~run Socket_Append_Lore save:item
        - define item <entry[item].created_queue.determination.first>
        - flag <player> RPG.STORAGE.SOCKET:<[item]>
        on player right clicks fake entity flagged:RPG.SOCKET.ITEM:
        - ratelimit <player> 1t
        - define clicked-slot <context.entity.flag[RPG.SOCKET]>
        - define held-item <player.item_in_hand>
        - if <player.has_flag[RPG.SOCKETS.<[clicked-slot]>]>:
            - define rune-id <player.flag[RPG.SOCKETS.<[clicked-slot]>]>
            - define rune <proc[socket_to_rune].context[<[rune-id]>]>
            - if <player.inventory.can_fit[<[rune]>]>:
                - give <[rune]>
                - adjust <context.entity.passenger> item:gray_stained_glass
                - adjust <context.entity.passenger> custom_name:Empty
                - flag <player> RPG.SOCKETS.<[clicked-slot]>:!
            - else:
                - actionbar targets:<player> "<red>Hey! Seems your inventory is to full to remove the rune. Come back when you have room."
                - stop
        - if !<[held-item].has_flag[RUNE]>:
            - stop
        - if <[held-item].flag[RUNE_TYPE]> == universal || <[held-item].flag[RUNE_TYPE]> == <player.flag[RPG.SOCKET.ITEM].as[item].flag[SOCKET_TYPE]>:
            - take iteminhand quantity:1
            - adjust <context.entity.passenger> item:<item[<[held-item].material>]>
            - adjust <context.entity.passenger> custom_name:<[held-item].flag[RUNE_DISPLAY_NAME]>
            - flag <player> RPG.SOCKETS.<[clicked-slot]>:<[held-item].flag[RUNE_ID]>
        - else:
            - actionbar targets:<player> "<red>Hey! Seems this rune is the wrong type for this equipment."
            - stop

Socket_Display_Entity:
    type: entity
    debug: false
    entity_type: armor_stand
    flags:
        socket: true
    mechanisms:
        visible: false
        gravity: false
        collidable: false

Item_Display_Entity:
    type: entity
    debug: false
    entity_type: armor_stand
    mechanisms:
        visible: false
        gravity: false
        collidable: false

Display_Description_On_Look:
    debug: false
    type: world
    events:
        on player walks flagged:RPG.SOCKET.ENTITIES:
        - ratelimit <player> 1t
        - define fake-sockets <player.flag[RPG.SOCKET.ENTITIES]>
        - define found-socket false
        - foreach <[fake-sockets]> as:fake:
            - define direction-yaw <player.location.direction[<[fake].location>].yaw>
            - if <[direction-yaw].if_null[null]> == null:
                - foreach next
            - if <player.location.yaw.sub[<[direction-yaw]>].abs> <= 10 && !<[found-socket]>:
                - if <[fake].entity_type> == ARMOR_STAND && <[fake].has_flag[socket]>:
                    - define fake <[fake].passenger>
                    - adjust <[fake]> custom_name_visible:true
                    - adjust <[fake]> glowing:true
                    - define found-socket true
            - else:
                - if <[fake].entity_type> == ARMOR_STAND && <[fake].has_flag[socket]>:
                    - define fake <[fake].passenger>
                    - adjust <[fake]> custom_name_visible:false
                    - adjust <[fake]> glowing:false

Socket_Append_Lore:
    type: task
    debug: false
    script:
    - define line <element[<&5><&l><&m>+--------------------+]>
    - define item <player.flag[RPG.SOCKET.ITEM].as[item]>
    # remove all socket flags from the item
    - flag <[item]> RPG.SOCKETS:!
    - define lore <list[]>
    # give lore that the item is socketable
    - define lore:->:<&o.end_format><&8>Socketable
    - define current-socket 1
    # get the amount of sockets the item has in total
    - define total-sockets <[item].flag[SOCKET_MAX]>
    # placeholder for the socket lore position
    - define last-index <[item].lore.find_all_matches[<[line]>]>
    - if <[last-index].is_empty>:
        - define last-index 1
    - else:
        - define last-index <[last-index].last>
    - define rune-ids <list[]>
    - if <player.has_flag[RPG.SOCKETS]>:
        - foreach <player.flag[RPG.SOCKETS].keys> as:key:
            - define rune-ids:->:<player.flag[RPG.SOCKETS.<[key]>]>
    # if no runes equipped then the socket section is not needed
    - if <[rune-ids].size.is_more_than[0]>:
        - if <[last-index].equals[0]>:
            - define last-index 1
        # Add line before first socket
        - define lore:->:<[line]>
        - foreach <[rune-ids]> as:rune-id:
            # we found some runes equipped to the item
            - flag <[item]> RPG.SOCKETS.<[current-socket]>:<[rune-id]>
            - define rune <proc[socket_to_rune].context[<[rune-id]>]>
            # Add lore for the current socketed rune
            - define lore:->:<&nbsp><&nbsp><&o.end_format><[rune].flag[RUNE_DISPLAY_NAME]>
            - define current-socket:+:1
        # Add line under last socket
        - define lore:->:<[line]>
    - if <[item].lore.size.is_more_than[<[last-index]>]> && !<[item].lore.is_empty>:
        - define last-index:+:1
        - define lore <[lore].include[<[item].lore.get[<[last-index]>].to[<[item].lore.size>]>]>
    - adjust def:item lore:<[lore]>
    - flag <player> RPG.SOCKET.ITEM:!
    - flag <player> RPG.SOCKETS:!
    - determine <[item]>

Socket_Display_Sequence:
    type: task
    debug: false
    definitions: item|station-location
    script:
    # Item in Socket storage
    - if <player.has_flag[RPG.STORAGE.SOCKET]>:
        - define stored-item <player.flag[RPG.STORAGE.SOCKET]>
        - if <player.inventory.can_fit[<[stored-item]>]>:
            - define item-name <[stored-item].material.translated_name>
            - if <[stored-item].has_display>:
                - define item-name <[stored-item].display>
            - actionbar targets:<player> "<gold>Hey! Seems you left <reset><[stored-item].display> <gold>behind last time you were here."
            - give <[stored-item]>
            - flag <player> RPG.STORAGE.SOCKET:!
            - stop
        - else:
            - actionbar targets:<player> "<red>I can't socket another another item til you take your <reset><[stored-item].display> <red>away."
            - stop
    # Item does not have sockets
    - if <[item].material.name> == air:
        - stop
    - if !<[item].has_flag[SOCKET_MAX]>:
        - define item-name <[item].material.translated_name>
        - if <[item].has_display>:
            - define item-name <[item].display>
        - actionbar targets:<player> "<[item-name]> <red>does not have any sockets."
        - stop
    # Take item from the player
    - flag <player> RPG.SOCKET.ITEM:<[item]>
    - take iteminhand
    # Spawn Item onto Block
    - ~run Socket_Display_Place_Item def.item:<[item]> def.station-location:<[station-location]>
    # Display Runes with Animation
    - ~run Socket_Display_Place_Sockets def.item:<[item]> def.station-location:<[station-location]>

Socket_Display_Place_Item:
    type: task
    debug: false
    definitions: item|station-location
    script:
    - define visible-time 30s
    # Spawn Armor Stand so we can mount the Item to it to prevent it from flying
    - if <player.is_online>:
        - fakespawn Item_Display_Entity <[station-location].center.down[1.5]> players:<player> duration:<[visible-time]> save:item_stand
    # Add Armor Stand to player so we can remove them early if we need to
        - flag <player> RPG.SOCKET.ENTITIES:->:<entry[item_stand].faked_entity>
    # Spawn Item
        - fakespawn Item[item=<[item]>] <entry[item_stand].faked_entity.location.up[2]> players:<player> duration:<[visible-time]> save:item_entity
    # Mount Item on Armor Stand
        - adjust <entry[item_stand].faked_entity> passengers:<entry[item_entity].faked_entity>
    # Play Animation around item as runes load
        - effectlib type:circle origin:<[station-location].center.up[0.75]> for:<player> effect_data:[particle=villager_happy;duration=2200]
    # Add Item to player so we can remove them early if we need to
        - flag <player> RPG.SOCKET.ENTITIES:->:<entry[item_entity].faked_entity>

Socket_Display_Place_Sockets:
    type: task
    debug: false
    definitions: item|station-location
    script:
    - define visible-time 30s
    # Get the max amount of sockets the item has
    - define max-sockets <[item].flag[SOCKET_MAX]>
    - define slotted-sockets 0
    # Get the amount of socketed sockets the item has
    - if <[item].has_flag[RPG.SOCKETS]>:
        - define slotted-sockets <[item].flag[RPG.SOCKETS].keys.size>
    - define current-socket 0
    # Display Rune Spacing Start
    - define item-width 1
    - define total-width <[item-width].mul[<[max-sockets].sub[1]>]>
    - define half-width <[total-width].div[2]>
    - define starting-position <[station-location].center.up[1].left[<[half-width]>]>
    # Rune Spacing End
    - while <[current-socket]> < <[max-sockets]> && <player.has_flag[RPG.SOCKET.ITEM]>:
        - define rune-placeholder <item[gray_stained_glass]>
        - if <[slotted-sockets]> > <[current-socket]>:
            - define rune-id <[item].flag[RPG.SOCKETS].get[<[current-socket].add[1]>]>
            - define rune-placeholder <proc[socket_to_rune].context[<[rune-id]>]>
            - flag <player> RPG.SOCKETS.<[current-socket]>:<[rune-id]>
        # Spawn Armor Stand for Rune
        - if <player.is_online>:
            - fakespawn Socket_Display_Entity <[station-location].center.down[1.5]> players:<player> duration:<[visible-time]> save:item_stand
            - flag <player> RPG.SOCKET.ENTITIES:->:<entry[item_stand].faked_entity>
        # Spawn Rune and Mount to Armor Stand
        - if <player.is_online>:
            - fakespawn Item[item=<[rune-placeholder]>] <entry[item_stand].faked_entity.location.up[2]> players:<player> duration:<[visible-time]> save:item_entity
            - flag <player> RPG.SOCKET.ENTITIES:->:<entry[item_entity].faked_entity>
            - adjust <entry[item_stand].faked_entity> passengers:<entry[item_entity].faked_entity>
            - flag <entry[item_stand].faked_entity> RPG.SOCKET:<[current-socket]>
            - teleport <entry[item_stand].faked_entity> <[starting-position].down[1.5]>
            - flag <entry[item_stand].faked_entity> DISPLAY-POSITION:<[starting-position].down[1.5]>
            - if !<player.has_flag[RPG.SOCKETS.<[current-socket]>]>:
                - adjust <entry[item_entity].faked_entity> custom_name:Empty
            - else:
                - define rune <proc[socket_to_rune].context[<player.flag[RPG.SOCKETS.<[current-socket]>]>]>
                - adjust <entry[item_entity].faked_entity> custom_name:<[rune].flag[RUNE_DISPLAY_NAME]>
        - define starting-position <[starting-position].right[<[item-width]>]>
        - define current-socket:+:1
        - wait 5t