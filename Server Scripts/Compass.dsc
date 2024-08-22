Compass_Start_Command:
    type: command
    debug: false
    name: compass
    description: Turns the compass on/off
    usage: /compass
    permission: RPG.COMPASS.VISIBLE
    script:
    - if <context.source_type> != PLAYER:
        - stop
    - if <player.has_flag[COMPASS.DISPLAY]>:
        - flag <player> COMPASS.DISPLAY:!
        - bossbar remove <player.uuid>
    - else:
        - run Compass_Start

Compass_Add_Location_Command:
    type: command
    debug: false
    name: compass-add
    description: Adds a waypoint to the compass
    usage: /compass-add
    permission: RPG.COMPASS.ADD
    tab complete:
        - if <context.args.is_empty>:
            - determine <server.online_players.parse[name]>
        - if <context.args.size> == 1:
            - determine [Waypoint-Id]
        - if <context.args.size> == 2:
            - determine "[Location](format x,y,z,world)"
    script:
    - define player <server.match_player[<context.args.get[1]>].if_null[FALSE]>
    - if !<[player]>:
        - narrate "[COMPASS] <red><context.args.get[1]> is invalid."
        - stop
    - define waypoint-id <context.args.get[2]>
    - define location <location[<context.args.get[3]>].if_null[FALSE]>
    - if !<[location].is_truthy>:
        - narrate "[COMPASS] <red><context.args.get[3]> is an invalid location."
        - stop
    - narrate "[Compass] Adding Waypoint <[waypoint-id]> from <[player]>"
    - adjust <queue> linked_player:<[player]>
    - run Compass_Add_Location def.id:<[waypoint-id]> def.location:<[location]>

Compass_Remove_Location_Command:
    type: command
    debug: false
    name: compass-remove
    description: Removes a waypoint from the compass
    usage: /compass-remove
    permission: RPG.COMPASS.ADD
    tab complete:
        - if <context.args.is_empty>:
            - determine <server.online_players.parse[name]>
        - if <context.args.size> == 1:
            - determine [Waypoint-Id]
    script:
    - define player <server.match_player[<context.args.get[1]>].if_null[FALSE]>
    - if !<[player]>:
        - narrate "[COMPASS] <red><context.args.get[1]> is invalid."
        - stop
    - define waypoint-id <context.args.get[2]>
    - narrate "[Compass] Removing Waypoint <[waypoint-id]> from <[player]>"
    - adjust <queue> linked_player:<[player]>
    - run Compass_Remove_Location def.id:<[waypoint-id]>

Compass_Events:
    debug: false
    type: world
    events:
        on player walks flagged:COMPASS.DISPLAY:
        - ratelimit <player> 1t
        - run Compass_Update
        on player joins flagged:COMPASS.DISPLAY:
        - run Compass_Start
        on player quits flagged:COMPASS.DISPLAY:
        - bossbar remove <player.uuid>

Compass_Update:
    type: task
    debug: false
    script:
    - define compass-bar-id <player.flag[COMPASS.DISPLAY]>
    - if !<player.bossbar_ids.contains[<[compass-bar-id]>]>:
        - flag <player> COMPASS.DISPLAY:!
        - stop
    - bossbar update <[compass-bar-id]> title:<proc[Compass_Get_Title_Direction]>

Compass_Add_Location:
    type: task
    debug: false
    definitions: id|location
    script:
    - flag <player> COMPASS.LOCATIONS.<[id]>:<[location].center>

Compass_Remove_Location:
    type: task
    debug: false
    definitions: id
    script:
    - flag <player> COMPASS.LOCATIONS.<[id]>:!

Compass_Start:
    type: task
    debug: false
    script:
    - bossbar create <player.uuid> title:<proc[Compass_Get_Title_Direction]>
    - flag <player> COMPASS.DISPLAY:<player.uuid>

Compass_Cleanup:
    type: task
    debug: false
    script:
    - flag <player> COMPASS.DISPLAY:!
    - bossbar remove <player.uuid>

Compass_Get_Title_Direction:
    type: procedure
    debug: false
    script:
    - define player-yaw <player.location.yaw.round>
    - define 45-degree-left <[player-yaw].sub[45]>
    - if <[45-degree-left]> < 0:
        - define 45-degree-left <[45-degree-left].add[360]>
    - define compass-string <proc[Compass_Get_Display].context[<[player-yaw]>|<[45-degree-left]>]>
    - determine <[compass-string]>

Compass_Get_Locations:
    type: procedure
    debug: false
    definitions: player-yaw|left-bound|right-bound
    script:
    - if <player.has_flag[COMPASS.LOCATIONS]>:
        - foreach <player.flag[COMPASS.LOCATIONS].keys> as:key:
            - define loc <player.flag[COMPASS.LOCATIONS.<[key]>]>
            - if <player.location.world> != <[loc].world>:
                - foreach next
            - define loc-degree <player.location.direction[<[loc]>].yaw>
            - if <[left-bound]> <= <[loc-degree]> && <[loc-degree]> <= <[right-bound]>:
                - determine <[loc]>
    - determine FALSE

Compass_Get_Display:
    type: procedure
    debug: false
    definitions: player-yaw|left-bound
    script:
    - define compass-string ""
    - define left-bound-edit <[left-bound].sub[3]>
    - repeat 30:
        - define left-bound-edit <[left-bound-edit].add[3]>
        - define left-bound-range <[left-bound-edit].add[3]>
        # East
        - if <[left-bound-edit]> <= 270 && 270 < <[left-bound-range]>:
            - define compass-string <[compass-string]><white>E<gray>
            - repeat next
        # North
        - if <[left-bound-edit]> <= 180 && 180 < <[left-bound-range]>:
            - define compass-string <[compass-string]><white>N<gray>
            - repeat next
        # West
        - if <[left-bound-edit]> <= 90 && 90 < <[left-bound-range]>:
            - define compass-string <[compass-string]><white>W<gray>
            - repeat next
        # South 360
        - if <[left-bound-edit]> <= 360 && 360 < <[left-bound-range]>:
            - define compass-string <[compass-string]><white>S<gray>
            - define left-bound-edit <[left-bound-edit].sub[360]>
            - repeat next
        # South 0
        - if <[left-bound-edit]> <= 0 && 0 < <[left-bound-range]>:
            - define compass-string <[compass-string]><white>S<gray>
            - repeat next
        - define has-objective <proc[Compass_Get_Locations].context[<[player-yaw]>|<[left-bound-edit]>|<[left-bound-range]>]>
        - if <[has-objective]>:
            - if <player.location.y.round_down> < <[has-objective].y.round_down>:
                - define compass-string <[compass-string]><gold>🡅<gray>
                - repeat next
            - if <player.location.y.round_down> > <[has-objective].y.round_down>:
                - define compass-string <[compass-string]><gold>🡇<gray>
                - repeat next
            - define compass-string <[compass-string]><gold>⏺<gray>
            - repeat next
        - define compass-string <[compass-string]>-
    - determine <gray><[compass-string]>

