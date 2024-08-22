TimeTrial_Handler:
    debug: false
    type: world
    events:
        after player enters cuboid flagged:TIMETRIAL:
        - if !<context.area.has_flag[TIMETRIAL]>:
            - stop
        - run TimeTrial_Enter_Waypoint def.cuboid:<context.area>
        on player enters cuboid flagged:!TIMETRIAL:
        - if !<context.area.has_flag[TIMETRIALSTART]> || !<context.area.has_flag[TIMETRIAL]>:
            - stop
        - run TimeTrial_Start def.trial-name:<context.area.flag[TIMETRIAL.NAME]>
        on player quit flagged:TIMETRIAL:
        - flag <player> TIMETRIAL:!

TimeTrial_Start:
    description: Starts a Time Trial
    debug: false
    definitions: trial-name
    type: task
    script:
    - if !<server.has_flag[TIMETRIAL.<[trial-name]>]>:
        - stop
    - flag <player> TIMETRIAL.NAME:<[trial-name]>
    - flag <player> TIMETRIAL.WAYPOINT:1
    - flag <player> TIMETRIAL.START:<util.time_now>
    - actionbar targets:<player> "Time Trial Started!"
    - run TimeTrial_Waypoint_Lifespan

TimeTrial_Enter_Waypoint:
    description: Runs when a player enters a waypoint cuboid
    debug: false
    definitions: cuboid
    type: task
    script:
    - if !<[cuboid].has_flag[TIMETRIAL.WAYPOINT]>:
        - stop
    - define waypoint-id <[cuboid].flag[TIMETRIAL.WAYPOINT]>
    - if <player.flag[TIMETRIAL.WAYPOINT]> == <[waypoint-id]>:
        - playsound <player> sound:BLOCK_BEACON_ACTIVATE pitch:2 volume:1 sound_category:MASTER
        - run TimeTrial_Next_Waypoint def.current-waypoint:<[waypoint-id]>

TimeTrial_Display_Waypoint:
    description: Displays a waypoint at a given location
    debug: false
    definitions: location
    type: task
    script:
    - define duration <duration[0.5s]>
    - define particle electric_spark
    - effectlib type:animatedball origin:<[location].center> for:<player> effect_data:[duration=<[duration].in_milliseconds>;particle=<[particle]>]

TimeTrial_Next_Waypoint:
    description: Displays the next Waypoint for the Time Trial
    debug: false
    definitions: current-waypoint
    type: task
    script:
    - define trial-name <player.flag[TIMETRIAL.NAME]>
    - define max-waypoints <server.flag[TIMETRIAL.<[trial-name]>.WAYPOINTS].size>
    # Is this the last waypoint?
    - if <[max-waypoints]> <= <[current-waypoint]>:
        - run TimeTrial_Achievement_Check
        - stop
    - flag <player> TIMETRIAL.WAYPOINT:<[current-waypoint].add[1]>

TimeTrial_Waypoint_Lifespan:
    description: Controls the lifespan of a waypoint for a player
    debug: false
    type: task
    script:
    - define origin-waypoint <player.flag[TIMETRIAL.WAYPOINT]>
    - define time-trial-name <player.flag[TIMETRIAL.NAME]>
    - define location <server.flag[TIMETRIAL.<[time-trial-name]>.WAYPOINTS.<[origin-waypoint]>].if_null[INVALID]>
    - if <[location]> == INVALID:
        - stop
    - repeat 60 as:num:
        - if !<player.has_flag[TIMETRIAL.WAYPOINT]>:
            - stop
        - if <player.flag[TIMETRIAL.WAYPOINT]> != <[origin-waypoint]>:
            - run TimeTrial_Waypoint_Lifespan
            - stop
        - run TimeTrial_Display_Waypoint def.location:<[location]>
        - if <[num].mod[2]> == 0:
            - playsound <player> sound:BLOCK_NOTE_BLOCK_BIT pitch:0.75 volume:0.5 sound_category:MASTER
        - wait 0.5s
    - if !<player.has_flag[TIMETRIAL.WAYPOINT]>:
        - stop
    - if <player.flag[TIMETRIAL.WAYPOINT]> == <[origin-waypoint]>:
        - flag <player> TIMETRIAL:!
        - narrate targets:<player> "[Time Trials] Failed to reach the next waypoint."

TimeTrial_Achievement_Check:
    description: Checks if a player has beaten the time trail record for achievements
    debug: false
    type: task
    script:
    - if !<player.has_flag[TIMETRIAL.START]>:
        - flag <player> TIMETRIAL:!
        - stop
    - define total-time <util.time_now.duration_since[<player.flag[TIMETRIAL.START]>]>
    - define trial-name <player.flag[TIMETRIAL.NAME]>
    - narrate targets:<player> "[Time Trial] You completed the Trial in <[total-time].formatted>"
    - flag <player> TIMETRIAL:!
    #- choose <[trial-name].to_uppercase>:
    #    - case TTRIAL_GAMINGCENTER:
    #        - define target-time <duration[70s]>
    #        - if <[total-time].is_less_than_or_equal_to[<[target-time]>]>:
    #            - run SGC_ACHIEVEMENT_PLAYER_SET_STAT def.stat-key:SGC.TIMETRIAL.COMPLETE def.value:TRUE
    #            - run SGC_ACHIEVEMENT_PLAYER_CHECK_ACHIEVEMENTS def.game-key:SGC.LBY