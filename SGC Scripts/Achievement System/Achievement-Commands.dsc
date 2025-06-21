## This is the Command Portion of the Achievement System
#- This contains all commands which a player would run
# Commands
SGC_Achievement_Command:
    type: command
    debug: false
    name: achievements
    description: Opens the achievements menu
    usage: /achievements
    aliases:
        - a
        - ach
        - achoo
    permission: SGC.ACHIEVEMENTS
    script:
    - if <context.source_type> != PLAYER:
        - stop
    - run SGC_Achievement_Create_Menu_Category

# Methods
SGC_Achievement_Load_Yaml:
    description: Loads the SGC-Achievements file
    debug: false
    type: task
    script:
    - foreach <script[Achievement_File_Map].data_key[FILES].keys> as:id:
        - define file <script[Achievement_File_Map].data_key[FILES].get[<[id]>].get[FILE]>
        - define ref <script[Achievement_File_Map].data_key[FILES].get[<[id]>].get[REF]>
        - ~yaml load:<[file]> id:<[ref]>
        - announce to_ops "<[file]> loaded"

## TODO
SGC_Achievement_Purge:
    description: Purges all players Stats and Achievements
    debug: false
    type: task
    script:
    - narrate "Purging player Stats and Achievements"
    - flag <server.players> SGC.STATS:!
    - flag <server.players> SGC.ACHIEVEMENTS:!