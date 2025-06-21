## This is the Calls Portion of the Achievement System
## This contains all methods you would use to increment stats or check achievement progress
#- Method
SGC_Achievement_Player_Check_Achievements:
    description: Check if a player should trigger any achievements for the provided game
    debug: false
    type: task
    definitions: game-key[Example: SGC.H_BLACKJACK]
    script:
    - if <queue.definitions.is_empty>:
        - define message "Tried to run SGC_Achievement_Player_Check_Achievements with no game-key.<n>Is this missing?<n>Stopping task to prevent errors."
        - run SGC_Achievement_Discord_Error_Message def.message:<[message]>
        - stop
    - define script <script[Achievement_File_Map]>
    - define file-id <[game-key].proc[SGC_Achievement_Key_To_ID]>
    - if <[file-id]> == -1:
        - define message "Tried to run SGC_Achievement_Player_Check_Achievements with unmapped key <[game-key].before[.]>.<n>Is this missing?<n>Stopping task to prevent errors."
        - run SGC_Achievement_Discord_Error_Message def.message:<[message]>
        - stop
    - define yaml <[script].data_key[FILES].get[<[file-id]>].get[REF]>
    - define achievements <[file-id].proc[SGC_Achievement_Get_Game_Achievements].context[<[game-key]>]>
    - define game-name <yaml[<[yaml]>].read[<[game-key]>.DISPLAY].if_null[UNKNOWN]>
    - foreach <[achievements]> as:achievement:
        - if <[achievement].get[KEY].proc[SGC_Achievement_Player_Has_Achievement]>:
            - foreach next
        - if <player.flag[SGC.ACH.TRACKING].if_null[FALSE]> == <[achievement].get[KEY]>:
            - run SGC_ACH_TRACK def.game-key:<[game-key]> def.data-object:<[achievement]>
        - define requirements <[achievement].get[STATS]>
        - define meets-requirements <[requirements].proc[SGC_Achievement_Player_Meets_Requirements]>
        - if <[meets-requirements]>:
            - run SGC_Achievement_Player_Toast_Achievement def.data-object:<[achievement]> def.game-name:<[game-name]>
            - run SGC_Achievement_Discord_Display_Message def.data-object:<[achievement]> def.game-name:<[game-name]>
            - if <player.flag[SGC.ACH.TRACKING].if_null[FALSE]> == <[achievement].get[KEY]>:
                - flag <player> SGC.ACH.TRACKING:!
                - sidebar remove players:<player>

SGC_Achievement_Key_To_ID:
    description: Used to get the File Id from a given key
    debug: false
    type: procedure
    definitions: game-key[Example: SGC.H_BLACKJACK]
    script:
    - define key <[game-key].before[.]>
    - define script <script[Achievement_File_Map]>
    - foreach <[script].data_key[FILES].keys> as:id:
        - if <[script].data_key[FILES].get[<[id]>].get[KEY]> == <[key]>:
            - determine <[id]>
    - determine -1

SGC_Achievement_Player_Increment_Stat:
    description: Increments the Integer/Decimal stat by a given amount. Will error when amount is not decimal/integer.
    debug: false
    type: task
    definitions: stat-key[Example: H_BLACKJACK.WINS]|amount[Example: 1]
    script:
    - if !<[amount].is_decimal>:
        - define message "Tried to Increment <player.name>'s stat:<[stat-key]> by <[amount]>.<n>This method should only be used to increment by decimals/integer.<n>No Changes were made."
        - run SGC_Achievement_Discord_Error_Message def.message:<[message]>
        - stop
    - flag <player> SGC.STATS.<[stat-key]>:+:<[amount]>

SGC_Achievement_Player_Set_Stat:
    description: Sets the stat to the given value
    debug: false
    type: task
    definitions: stat-key[Example: EasterEgg.FOUND_1]|value[Example: TRUE]
    script:
    - flag <player> SGC.STATS.<[stat-key]>:<[value]>
