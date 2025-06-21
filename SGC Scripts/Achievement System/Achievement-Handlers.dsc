## This is the Handler Portion of the Achievement System
## This contains the world events that trigger for the inventory clicks
#- Handler Methods
# First Menu
SGC_Achievement_Category_Click:
    debug: false
    type: world
    events:
        on player clicks item in SGC_Achievement_Display_Categories:
        - if <context.item.material.name> == air || <context.item> == <item[SGC_Achievement_Empty_Icon]>:
            - stop
        - if !<context.item.has_flag[KEY]>:
            - define message "Return Icon in <context.inventory.title> is missing flag:Key"
            - run SGC_Achievement_Discord_Error_Message def.message:<[message]>
            - stop
        - define sub-category-key <context.item.flag[KEY]>
        - run SGC_Achievement_Create_Menu_Directory def.id:<[sub-category-key]>

# Second Menu
SGC_Achievement_Directory_Click:
    debug: false
    type: world
    events:
        on player clicks SGC_Achievement_Remove_Tracker_Icon in SGC_Achievement_SGC_Display_Directory:
        - flag <player> SGC.ACH.TRACKING:!
        - sidebar remove players:<player>
        on player clicks SGC_Achievement_Return_Icon in SGC_Achievement_SGC_Display_Directory:
        - run SGC_Achievement_Create_Menu_Category
        on player clicks SGC_Achievement_SubCategory_Icon in SGC_Achievement_SGC_Display_Directory:
        - if !<context.item.has_flag[KEY]>:
            - define message "Return Icon in <context.inventory.title> is missing flag:Key"
            - run SGC_Achievement_Discord_Error_Message def.message:<[message]>
            - stop
        - define sub-category-key <context.item.flag[KEY]>
        - define file-id <context.item.flag[ID]>
        - define script <script[Achievement_File_Map]>
        - define yaml <[script].data_key[FILES].get[<[file-id]>].get[REF]>
        - define sub-category-name <yaml[<[yaml]>].read[<[sub-category-key]>.DISPLAY]>
        - run SGC_Achievement_Create_Menu_Achievement def.file-id:<[file-id]> def.key:<[sub-category-key]> def.name:<[sub-category-name]>
        on player clicks SGC_Achievement_Quiet_Icon in SGC_Achievement_SGC_Display_Directory:
        - ratelimit <player> 1s
        - playsound sound:ui_button_click <player> sound_category:master
        - if <player.has_flag[SGC.ACH.QUIET]>:
          - flag <player> SGC.ACH.QUIET:!
          - narrate targets:<player> format:sgc_pref "<green>You turned on achievement messages for other players"
          - inventory set slot:54 destination:<context.inventory> origin:<item[SGC_ACHIEVEMENT_QUIET_ICON]>
        - else:
          - flag <player> SGC.ACH.QUIET
          - narrate targets:<player> format:sgc_pref "<red>You turned off achievement messages for other players"
          - inventory adjust slot:54 destination:<context.inventory> skull_skin:<script[sgc_ach_quiet_icon_toggle].data_key[OFF]>

# Third Menu
SGC_Achievement_Page_Click:
    debug: false
    type: world
    events:
        on player clicks SGC_Achievement_Remove_Tracker_Icon in SGC_Achievement_Display_Page:
        - flag <player> SGC.ACH.TRACKING:!
        - sidebar remove players:<player>
        on player clicks SGC_Achievement_Return_Icon in SGC_Achievement_Display_Page:
        - if !<context.item.has_flag[KEY]>:
            - define message "Return Icon in <context.inventory.title> is missing flag:Key"
            - run SGC_Achievement_Discord_Error_Message def.message:<[message]>
            - stop
        - define file-id <context.item.flag[KEY]>
        - run SGC_Achievement_Create_Menu_Directory def.id:<[file-id]>
        on player clicks SGC_Achievement_Unknown_Achievement_Icon in SGC_Achievement_Display_Page:
        - if !<context.item.has_flag[KEY]>:
            - define message "Achievement in <context.inventory.title> is missing flag:Key"
            - run SGC_Achievement_Discord_Error_Message def.message:<[message]>
            - stop
        - define achievement-key <context.item.flag[KEY]>
        - define game-key <[achievement-key].before_last[.]>
        - define achievement-key <[achievement-key].after_last[.]>
        - define file-id <[game-key].proc[SGC_Achievement_Key_To_ID]>
        - define data-object <[game-key].proc[SGC_Achievement_Data_Object].context[<[file-id]>|<[achievement-key]>]>
        - run SGC_ACH_TRACK def.game-key:<[game-key]> def.data-object:<[data-object]>
        on player clicks SGC_Achievement_Quiet_Icon in SGC_Achievement_Display_Page:
        - ratelimit <player> 1s
        - playsound sound:ui_button_click <player> sound_category:master
        - if <player.has_flag[SGC.ACH.QUIET]>:
            - flag <player> SGC.ACH.QUIET:!
            - narrate targets:<player> format:sgc_pref "<green>You turned on achievement messages for other players"
            - inventory set slot:54 destination:<context.inventory> origin:<item[SGC_ACHIEVEMENT_QUIET_ICON]>
        - else:
          - flag <player> SGC.ACH.QUIET
          - narrate targets:<player> format:sgc_pref "<red>You turned off achievement messages for other players"
          - inventory adjust slot:54 destination:<context.inventory> skull_skin:<script[sgc_ach_quiet_icon_toggle].data_key[OFF]>

