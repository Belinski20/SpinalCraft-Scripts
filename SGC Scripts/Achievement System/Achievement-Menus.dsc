## This is the Menu Portion of the Achievement System
#- This contains a 3 inventories which display categories, sub-categories, and achievements
#- Menus
# First Menu
SGC_Achievement_Display_Categories:
    debug: false
    type: inventory
    inventory: hopper
    gui: true
    title: <aqua>Achievements <gray>| Categories
    slots:
    - [] [] [] [] []

# Second Menu
SGC_Achievement_SGC_Display_Directory:
    debug: false
    type: inventory
    inventory: chest
    gui: true
    title: <aqua>Achievements <gray>| Directory
    size: 54
    slots:
    - [SGC_Achievement_Return_Icon] [SGC_Achievement_Border_Icon] [SGC_Achievement_Border_Icon] [SGC_Achievement_Border_Icon] [SGC_Achievement_Border_Icon] [SGC_Achievement_Border_Icon] [SGC_Achievement_Border_Icon] [SGC_Achievement_Border_Icon] [SGC_Achievement_Remove_Tracker_Icon]
    - [SGC_Achievement_Border_Icon] [] [] [] [] [] [] [] [SGC_Achievement_Border_Icon]
    - [SGC_Achievement_Border_Icon] [] [] [] [] [] [] [] [SGC_Achievement_Border_Icon]
    - [SGC_Achievement_Border_Icon] [] [] [] [] [] [] [] [SGC_Achievement_Border_Icon]
    - [SGC_Achievement_Border_Icon] [] [] [] [] [] [] [] [SGC_Achievement_Border_Icon]
    - [SGC_Achievement_Border_Icon] [SGC_Achievement_Border_Icon] [SGC_Achievement_Border_Icon] [SGC_Achievement_Border_Icon] [SGC_Achievement_Border_Icon] [SGC_Achievement_Border_Icon] [SGC_Achievement_Border_Icon] [SGC_Achievement_Border_Icon] [SGC_Achievement_Quiet_Icon]

# Third Menu
SGC_Achievement_Display_Page:
    debug: false
    type: inventory
    gui: true
    inventory: chest
    title: <aqua>Achievements <gray>|
    size: 54
    slots:
    - [] [SGC_Achievement_Border_Icon] [SGC_Achievement_Border_Icon] [SGC_Achievement_Border_Icon] [SGC_Achievement_Border_Icon] [SGC_Achievement_Border_Icon] [SGC_Achievement_Border_Icon] [SGC_Achievement_Border_Icon] [SGC_Achievement_Remove_Tracker_Icon]
    - [SGC_Achievement_Border_Icon] [] [] [] [] [] [] [] [SGC_Achievement_Border_Icon]
    - [SGC_Achievement_Border_Icon] [] [] [] [] [] [] [] [SGC_Achievement_Border_Icon]
    - [SGC_Achievement_Border_Icon] [] [] [] [] [] [] [] [SGC_Achievement_Border_Icon]
    - [SGC_Achievement_Border_Icon] [] [] [] [] [] [] [] [SGC_Achievement_Border_Icon]
    - [SGC_Achievement_Border_Icon] [SGC_Achievement_Border_Icon] [SGC_Achievement_Border_Icon] [SGC_Achievement_Border_Icon] [SGC_Achievement_Border_Icon] [SGC_Achievement_Border_Icon] [SGC_Achievement_Border_Icon] [SGC_Achievement_Border_Icon] [SGC_Achievement_Quiet_Icon]

#- Menu Population Methods
# First Menu
SGC_Achievement_Create_Menu_Category:
    description: Creates and Opens the Category Menu
    debug: false
    type: task
    script:
    - define objects <proc[SGC_Achievement_Menu_Category_Data_Object]>
    # Setup Inventory
    - define menu <inventory[SGC_Achievement_Display_Categories]>
    # Create Icons
    - define icons <list[]>
    - foreach <[objects]> as:object:
        - define icon-material <[object].get[ICON]>
        - define icon <item[SGC_Achievement_Category_Icon]>
        - if <[icon-material].as[material].if_null[FALSE]>:
            - define icon <item[<[icon-material]>]>
        - adjust def:icon display:<[object].get[NAME]>
        - flag <[icon]> KEY:<[object].get[FILEID]>
        - define icons:->:<[icon]>
        - if <[icons].size> > 5:
            - define message "There are more than 5 achievement categories defined.<n><[objects].parse[NAME]><n>Limiting to the first 5."
            - run SGC_Achievement_Discord_Error_Message def.message:<[message]>
            - define icons:<-:<[icons].last>
            - foreach stop
    # Open Inventory
    - run SGC_Achievement_Populate_Inventory_Open def.menu:<[menu]> def.icons:<[icons]>
# Second Menu
SGC_Achievement_Create_Menu_Directory:
    description: Creates and Opens the Directory Menu
    debug: false
    type: task
    definitions: id
    script:
    - define sub-categories <proc[SGC_Achievement_Menu_Directory_Data_Object].context[<[id]>]>
    - define script <script[Achievement_File_Map]>
    - define yaml <[script].data_key[FILES].get[<[id]>].get[REF]>
    # Setup Inventory
    - define menu <inventory[SGC_Achievement_SGC_Display_Directory]>
    # Create Icons
    - define icons <list[]>
    - foreach <[sub-categories]> as:sub-category:
        - define key <[sub-category].get[KEY]>
        - define icon <item[SGC_Achievement_SubCategory_Icon]>
        - define name <[sub-category].get[DISPLAY]>
        - adjust def:icon "display:<gold><[name]> <aqua>Achievements"
        - define player-achievement-count <player.flag[SGC.ACHIEVEMENTS.<[key]>.<[sub-category].get[NAME]>].size.if_null[0]>
        - define total-achievements <yaml[<[yaml]>].list_keys[<[key]>.<[sub-category].get[NAME]>.ACHIEVEMENTS].size>
        - define percent-complete <[player-achievement-count].div[<[total-achievements]>].if_null[0].mul[100].round_to_precision[1]>
        - if <[percent-complete]> == 100:
            - adjust def:icon material:written_book
        - define progress <proc[SGC_Achievement_Create_Progress_String].context[<[percent-complete]>]>
        - adjust def:icon "lore:<white>Completion: <[progress]>"
        - flag <[icon]> ID:<[id]>
        - flag <[icon]> KEY:<[key]>.<[sub-category].get[NAME]>
        - define icons:->:<[icon]>
    # Open Inventory
    - run SGC_Achievement_Populate_Inventory_Open def.menu:<[menu]> def.icons:<[icons]>

# Third Menu
SGC_Achievement_Create_Menu_Achievement:
    description: Creates and Opens the Achievement Menu
    debug: false
    type: task
    definitions: file-id[Example: 1,2,3]|key[Example: SGC.H_BLACKJACK]|name[Example: High BlackJack]
    script:
    # Get Data Objects from YAML
    - define data-objects <[file-id].proc[SGC_Achievement_Get_Game_Achievements].context[<[key]>]>
    # Setup Inventory
    - define menu <inventory[SGC_Achievement_Display_Page]>
    - adjust def:menu "title:<[menu].title> <[name]>"
    # Create Icons
    - define icons <list[]>
    # Create Special Back Icon
    - define item <item[sgc_achievement_return_icon]>
    - flag <[item]> KEY:<[file-id]>
    - define icons:->:<[item]>
    # Create Normal Icons
    - foreach <[data-objects]> as:object:
        - define lore <[object].get[DESCRIPTION]>
        - if <[lore].object_type> == List:
            - define lore <[lore].set[<gray><[lore].first>].at[1]>
        - else:
            - define lore <gray><[lore]>
        - define item <item[SGC_Achievement_Unknown_Achievement_Icon]>
        - adjust def:item display:<gray><[object].get[NAME]>
        - adjust def:item lore:<[lore]>
        - if <player.has_flag[SGC.ACHIEVEMENTS.<[object].get[KEY]>]>:
            - define item <item[SGC_Achievement_Acquired_Achievement_Icon]>
            - if <[lore].object_type> == List:
                - define lore <[lore].set[<white><[lore].first.strip_color>].at[1]>
            - else:
                - define lore <white><[lore].strip_color>
            - adjust def:item display:<dark_green><[object].get[NAME]>
            - adjust def:item lore:<[lore]>
        - flag <[item]> KEY:<[object].get[KEY]>
        - define icons:->:<[item]>
    # Open Inventory
    - run SGC_Achievement_Populate_Inventory_Open def.menu:<[menu]> def.icons:<[icons]>

#- Open inventory Method
SGC_Achievement_Populate_Inventory_Open:
    description: Populates the given menu with the given icons.
    debug: false
    type: task
    definitions: menu[Inventory to put the icons in]|icons[List of icons to display]
    script:
    - define valid-slots <[menu].empty_slots>
    - define empty-slots <[valid-slots].sub[<[icons].size>]>
    - if <[empty-slots]> < 0:
        - define message "Invalid Icon Amount for Menu.<n>Tried to fix <[icons].size> Icons into <[valid-slots]> empty slots in <[menu].title>."
        - run SGC_Achievement_Discord_Error_Message def.message:<[message]>
        - stop
    - repeat <[empty-slots]>:
        - define icons:->:SGC_Achievement_Empty_Icon
    - foreach <[icons]> as:icon:
        - define index <[menu].first_empty>
        - if <[index]> == -1:
            - define message "Invalid Icon Amount for Menu.<n>Tried to fit <[icons].size> Icons into <[valid-slots]> empty slots in <[menu].title>."
            - run SGC_Achievement_Discord_Error_Message def.message:<[message]>
            - stop
        - inventory set slot:<[index]> destination:<[menu]> origin:<[icon]>
    - if <player.has_flag[SGC.ACH.QUIET]>:
        - define item <item[SGC_ACHIEVEMENT_QUIET_ICON]>
        - adjust def:item skull_skin:<script[sgc_ach_quiet_icon_toggle].data_key[OFF]>
        - inventory set slot:54 destination:<[menu]> origin:<[item]>
    - inventory open destination:<[menu]>