## Example
#- SGC:
#-  H_BLACKJACK:
#-   DISPLAY: High BlackJack
#-   ACHIEVEMENTS:
#-    WIN_100:
#-     name: High Stakes Winner
#-     description: Win 100 games of High Stakes BlackJack
#-     icon: netherstar
#-     reward: 100
#-     stats:
#-      H_BLACKJACK.WINS: 100
#-
#- MINIGAMES:
#-  SPLATTER:
#-   DISPLAY: Splatter
#-   ACHIEVEMENTS:
#-
#- PARKOUR:
#-  LEVEL-NAME:
#-   DISPLAY: Level Display Name
#-   ACHIEVEMENTS

# Players have Flag structure of SGC.ACHIEVEMENTS.<ACHIEVEMENT-KEY>
# If they have the ACHIEVEMENT-KEY then they have the achievement
# Players also need to have stats stored so we can pop the correct achievements and track the data
# Flag structure could be SGC.STATS.<GAME-STAT-IDENTIFIER> | This could be H_BLACKJACK.WINS

# We only really need to update achievements after a player plays a specific game or something specific happens.
# Since this is the case we can just only call the achievements to update for that specific game or instance to reduce load.

## ACHIEVEMENT COMMAND
SGC_Achievement_Command:
    type: command
    debug: false
    name: achievements
    description: Opens the achievements menu
    usage: /achievements
    aliases:
        - sgca
    permission: SGC.ACHIEVEMENTS
    script:
    - if <context.source_type> != PLAYER:
        - stop
    - run SGC_Achievement_Create_Menu_Category

## ACHIEVEMENT INVENTORIES
SGC_Achievement_SGC_Display_Directory:
    debug: false
    type: inventory
    inventory: chest
    gui: true
    title: <aqua>Achievements <gray>| Directory
    size: 54
    slots:
    - [SGC_Achievement_Return_Icon] [SGC_Achievement_Border_Icon] [SGC_Achievement_Border_Icon] [SGC_Achievement_Border_Icon] [SGC_Achievement_Border_Icon] [SGC_Achievement_Border_Icon] [SGC_Achievement_Border_Icon] [SGC_Achievement_Border_Icon] [SGC_Achievement_Border_Icon]
    - [SGC_Achievement_Border_Icon] [] [] [] [] [] [] [] [SGC_Achievement_Border_Icon]
    - [SGC_Achievement_Border_Icon] [] [] [] [] [] [] [] [SGC_Achievement_Border_Icon]
    - [SGC_Achievement_Border_Icon] [] [] [] [] [] [] [] [SGC_Achievement_Border_Icon]
    - [SGC_Achievement_Border_Icon] [] [] [] [] [] [] [] [SGC_Achievement_Border_Icon]
    - [SGC_Achievement_Border_Icon] [SGC_Achievement_Border_Icon] [SGC_Achievement_Border_Icon] [SGC_Achievement_Border_Icon] [SGC_Achievement_Border_Icon] [SGC_Achievement_Border_Icon] [SGC_Achievement_Border_Icon] [SGC_Achievement_Border_Icon] [SGC_Achievement_Border_Icon]

SGC_Achievement_Display_Page:
    debug: false
    type: inventory
    gui: true
    inventory: chest
    title: <aqua>Achievements <gray>|
    size: 54
    slots:
    - [] [SGC_Achievement_Border_Icon] [SGC_Achievement_Border_Icon] [SGC_Achievement_Border_Icon] [SGC_Achievement_Border_Icon] [SGC_Achievement_Border_Icon] [SGC_Achievement_Border_Icon] [SGC_Achievement_Border_Icon] [SGC_Achievement_Border_Icon]
    - [SGC_Achievement_Border_Icon] [] [] [] [] [] [] [] [SGC_Achievement_Border_Icon]
    - [SGC_Achievement_Border_Icon] [] [] [] [] [] [] [] [SGC_Achievement_Border_Icon]
    - [SGC_Achievement_Border_Icon] [] [] [] [] [] [] [] [SGC_Achievement_Border_Icon]
    - [SGC_Achievement_Border_Icon] [] [] [] [] [] [] [] [SGC_Achievement_Border_Icon]
    - [SGC_Achievement_Border_Icon] [SGC_Achievement_Border_Icon] [SGC_Achievement_Border_Icon] [SGC_Achievement_Border_Icon] [SGC_Achievement_Border_Icon] [SGC_Achievement_Border_Icon] [SGC_Achievement_Border_Icon] [SGC_Achievement_Border_Icon] [SGC_Achievement_Border_Icon]

SGC_Achievement_Display_Categories:
    debug: false
    type: inventory
    inventory: hopper
    gui: true
    title: <aqua>Achievements <gray>| Categories
    slots:
    - [] [] [] [] []

## ACHIEVEMENT INVENTORY ICONS
SGC_Achievement_Unknown_Achievement_Icon:
    type: item
    material: book
    display name: <empty>
    lore:
        - <gray>Description

SGC_Achievement_Acquired_Achievement_Icon:
    type: item
    material: written_book
    display name: <empty>

SGC_Achievement_SubCategory_Icon:
    type: item
    material: book
    display name: <empty>

SGC_Achievement_Border_Icon:
    type: item
    material: purple_stained_glass_pane
    display name: " "

SGC_Achievement_Empty_Icon:
    type: item
    material: black_stained_glass_pane
    display name: " "

SGC_Achievement_Return_Icon:
    type: item
    material: paper
    display name: <aqua>Previous Menu

SGC_Achievement_Category_Icon:
    type: item
    material: book
    display name: <empty>

SGC_Achievement_Make_Icon:
    description: Returns a Book Icon with the Achievement name and Description appended to it.
    debug: false
    type: procedure
    definitions: data-object[Data Object made from SGC_Achievement_Data_Object]
    script:
    - define icon SGC_Achievement_Acquired_Achievement_Icon
    - adjust def:icon display:<aqua><[data-object].get[NAME]>
    - adjust def:icon lore:<white><[data-object].get[DESCRIPTION]>
    - determine <[icon]>

## ACHIEVEMENT CREATE MENUS
SGC_Achievement_Create_Menu_Category:
    description: Creates and Opens the Category Menu
    debug: false
    type: task
    script:
    # Get Categories from YAML
    - define categories <yaml[achievements].list_keys[]>
    # Setup Inventory
    - define menu <inventory[SGC_Achievement_Display_Categories]>
    # Create Icons
    - define icons <list[]>
    - foreach <[categories]> as:category:
        - define icon-material <yaml[achievements].read[<[category]>.ICON].if_null[NULL]>
        - define icon <item[SGC_Achievement_Category_Icon]>
        - if <[icon-material].as[material].if_null[FALSE]>:
            - define icon <item[<[icon-material]>]>
        - define category-name <yaml[achievements].read[<[category]>.DISPLAY].if_null[<[category]>]>
        - adjust def:icon display:<[category-name]>
        - flag <[icon]> KEY:<[category]>
        - define icons:->:<[icon]>
        - if <[icons].size> > 5:
            - define message "There are more than 5 achievement categories defined.<n><[categories].formatted><n>Limiting to the first 5."
            - run SGC_Achievement_Discord_Error_Message def.message:<[message]>
            - define icons:<-:<[icons].last>
            - foreach stop
    # Open Inventory
    - run SGC_Achievement_Populate_Inventory_Open def.menu:<[menu]> def.icons:<[icons]>

SGC_Achievement_Create_Menu_Achievement:
    description: Creates and Opens the Achievement Menu
    debug: false
    type: task
    definitions: key[Example: SGC.H_BLACKJACK]|name[Example: High BlackJack]
    script:
    # Get Data Objects from YAML
    - define data-objects <[key].proc[SGC_Achievement_Get_Game_Achievements]>
    # Setup Inventory
    - define menu <inventory[SGC_Achievement_Display_Page]>
    - adjust def:menu "title:<[menu].title> <[name]>"
    # Create Icons
    - define icons <list[]>
    # Create Special Back Icon
    - define item <item[sgc_achievement_return_icon]>
    - flag <[item]> KEY:<[key].before[.]>
    - define icons:->:<[item]>
    # Create Normal Icons
    - foreach <[data-objects]> as:object:
        - define item <item[SGC_Achievement_Unknown_Achievement_Icon]>
        - adjust def:item display:<gray><[object].get[NAME]>
        - adjust def:item lore:<gray><[object].get[DESCRIPTION]>
        - if <player.has_flag[SGC.ACHIEVEMENTS.<[object].get[KEY]>]>:
            - define item <item[SGC_Achievement_Acquired_Achievement_Icon]>
            - adjust def:item display:<white><[object].get[NAME]>
            - adjust def:item lore:<[object].get[DESCRIPTION]>
        - define icons:->:<[item]>
    # Open Inventory
    - run SGC_Achievement_Populate_Inventory_Open def.menu:<[menu]> def.icons:<[icons]>

SGC_Achievement_Create_Menu_Directory:
    description: Creates and Opens the Directory Menu
    debug: false
    type: task
    definitions: key[Examples: SGC, MINIGAMES, Parkour]
    script:
    # Get Sub Categories from YAML
    - define sub-categories <yaml[achievements].list_keys[<[key]>].exclude[DISPLAY|ICON]>
    # Setup Inventory
    - define menu <inventory[SGC_Achievement_SGC_Display_Directory]>
    # Create Icons
    - define icons <list[]>
    - foreach <[sub-categories]> as:sub-category:
        - define icon <item[SGC_Achievement_SubCategory_Icon]>
        - define name <yaml[achievements].read[<[key]>.<[sub-category]>.DISPLAY].if_null[<[sub-category]>]>
        - adjust def:icon "display:<gold><[name]> <aqua>Achievements"
        - define player-achievement-count <player.flag[SGC.ACHIEVEMENTS.<[key]>.<[sub-category]>].size.if_null[0]>
        - define total-achievements <yaml[achievements].list_keys[<[key]>.<[sub-category]>.ACHIEVEMENTS].size>
        - define percent-complete <[player-achievement-count].div[<[total-achievements]>].if_null[0].mul[100].round_to_precision[1]>
        - define progress <proc[SGC_Achievement_Create_Progress_String].context[<[percent-complete]>]>
        - adjust def:icon "lore:<white>Completion: <[progress]>"
        - flag <[icon]> KEY:<[key]>.<[sub-category]>
        - define icons:->:<[icon]>
    # Open Inventory
    - run SGC_Achievement_Populate_Inventory_Open def.menu:<[menu]> def.icons:<[icons]>

SGC_Achievement_Create_Progress_String:
    description: Creates a progress bar for % completion
    debug: false
    type: procedure
    definitions: percent-complete
    script:
    - define size 20
    - define colored-bars <[size].mul[<[percent-complete].div[100]>].round_to_precision[1]>
    - define bar ""
    - repeat <[colored-bars]>:
        - define bar <[bar]><gold>❙
    - repeat <[size].sub[<[colored-bars]>]>:
        - define bar <[bar]><gray>❙
    - determine "<[bar]> <gold><[percent-complete]><&pc>"

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
    - inventory open destination:<[menu]>

## ACHIEVEMENT MENU HANDLERS
SGC_Achievement_Directory_Click:
    debug: false
    type: world
    events:
        on player clicks SGC_Achievement_Return_Icon in SGC_Achievement_SGC_Display_Directory:
        - run SGC_Achievement_Create_Menu_Category
        on player clicks SGC_Achievement_SubCategory_Icon in SGC_Achievement_SGC_Display_Directory:
        - if !<context.item.has_flag[KEY]>:
            - define message "Return Icon in <context.inventory.title> is missing flag:Key"
            - run SGC_Achievement_Discord_Error_Message def.message:<[message]>
            - stop
        - define sub-category-key <context.item.flag[KEY]>
        - define sub-category-name <yaml[achievements].read[<[sub-category-key]>.DISPLAY]>
        - run SGC_Achievement_Create_Menu_Achievement def.key:<[sub-category-key]> def.name:<[sub-category-name]>

SGC_Achievement_Page_Click:
    debug: false
    type: world
    events:
        on player clicks SGC_Achievement_Return_Icon in SGC_Achievement_Display_Page:
        - if !<context.item.has_flag[KEY]>:
            - define message "Return Icon in <context.inventory.title> is missing flag:Key"
            - run SGC_Achievement_Discord_Error_Message def.message:<[message]>
            - stop
        - define sub-category-key <context.item.flag[KEY]>
        - run SGC_Achievement_Create_Menu_Directory def.key:<[sub-category-key]>

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
        - run SGC_Achievement_Create_Menu_Directory def.key:<[sub-category-key]>

## ACHIEVEMENT YAML
SGC_Achievement_Reset_Yaml:
    description: Creates/Resets the SGC-Achievement file and provides an example
    debug: false
    type: task
    script:
    - yaml create id:achievements
    - yaml id:achievements set SGC.GAME.DISPLAY:GAME-NAME
    - yaml id:achievements set SGC.GAME.ACHIEVEMENTS.ACHIEVEMENT.NAME:NAME
    - yaml id:achievements set SGC.GAME.ACHIEVEMENTS.ACHIEVEMENT.DESCRIPTION:DESCRIPTION
    - yaml id:achievements set SGC.GAME.ACHIEVEMENTS.ACHIEVEMENT.ICON:dirt
    - yaml id:achievements set SGC.GAME.ACHIEVEMENTS.ACHIEVEMENT.REWARD:100
    - yaml id:achievements set SGC.GAME.ACHIEVEMENTS.ACHIEVEMENT.STATS.EXAMPLE_STAT_1:5
    - yaml id:achievements set SGC.GAME.ACHIEVEMENTS.ACHIEVEMENT.STATS.EXAMPLE_STAT_2:5
    - ~yaml savefile:SGC-Achievements.yml id:achievements
    - narrate targets:<player> "[SGC-Achievements] File Created With Example!"

SGC_Achievement_Load_Yaml:
    description: Loads the SGC-Achievements file
    debug: false
    type: task
    script:
    - ~yaml load:SGC-Achievements.yml id:achievements
    - narrate targets:<player> "[SGC-Achievements] SGC Achievements File Loaded!"

## ACHIEVEMENT DATA OBJECTS
SGC_Achievement_Data_Object:
    description: Makes a Data Object with all data on an achievement.
    debug: false
    type: procedure
    definitions: game-key[Example: SGC.H_BLACKJACK]|achievement-key[Example: WIN_100]
    script:
    - define yaml-object <yaml[achievements].read[<[game-key]>.ACHIEVEMENTS.<[achievement-key]>]>
    - definemap data-object:
        KEY: <[game-key]>.<[achievement-key].if_null[INVALID]>
        NAME: <[yaml-object].get[NAME].if_null[INVALID]>
        DESCRIPTION: <[yaml-object].get[DESCRIPTION].if_null[INVALID].parsed>
        ICON: <[yaml-object].get[ICON].if_null[INVALID]>
        REWARD: <[yaml-object].get[REWARD].if_null[0]>
        STATS: <[yaml-object].get[STATS].if_null[INVALID]>
    - determine <[data-object]>

## ACHIEVEMENT UTILS
SGC_Achievement_Get_Game_Achievements:
    description: Gets all Achievements for a given game and returns a list of Data Objects
    debug: false
    type: procedure
    definitions: game-key[Example: SGC.H_BLACKJACK]
    script:
    - define achievement-list <list[]>
    - if !<yaml[achievements].contains[<[game-key]>]>:
        - determine <[achievement-list]>
    - define achievement-keys <yaml[achievements].list_keys[<[game-key]>.ACHIEVEMENTS].if_null[<list[]>]>
    - foreach <[achievement-keys]> as:key:
        - define data-object <[game-key].proc[SGC_Achievement_Data_Object].context[<[key]>]>
        - define achievement-list:->:<[data-object]>
    - determine <[achievement-list]>

SGC_Achievement_Player_Stat:
    description: Gets the value of a player's stat
    debug: false
    type: procedure
    definitions: stat-key[Example: H_BLACKJACK.WINS]
    script:
    - define value <player.flag[SGC.STATS.<[stat-key]>].if_null[0]>
    - determine <[value]>

SGC_Achievement_Player_Has_Achievement:
    description: Returns if a player has the provided achievement already
    debug: false
    type: procedure
    definitions: achievement-name[Example: H_BLACKJACK.WIN_100]
    script:
    - define has-achievement <player.has_flag[SGC.ACHIEVEMENTS.<[achievement-name]>]>
    - determine <[has-achievement]>

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
    - define achievements <[game-key].proc[SGC_Achievement_Get_Game_Achievements]>
    - foreach <[achievements]> as:achievement:
        - if <[achievement].get[KEY].proc[SGC_Achievement_Player_Has_Achievement]>:
            - foreach next
        - define requirements <[achievement].get[STATS]>
        - define meets-requirements <[requirements].proc[SGC_Achievement_Player_Meets_Requirements]>
        - if <[meets-requirements]>:
            - run SGC_Achievement_Player_Toast_Achievement def.data-object:<[achievement]>

SGC_Achievement_Player_Meets_Requirements:
    description: Returns if a player meets all the requirements for the achievement
    debug: false
    type: procedure
    definitions: achievement-stats[Achievement Stat MapTag]
    script:
    - foreach <[achievement-stats]> as:stat key:key:
        - if !<player.has_flag[SGC.STATS.<[key]>]>:
            - determine FALSE
        - define value <player.flag[SGC.STATS.<[key]>]>
        - if <[value].is_decimal>:
            - if <[value].is_less_than[<[stat]>]>:
                - determine FALSE
        - else:
            - if <[value]> != <[stat]>:
                - determine FALSE
    - determine TRUE

SGC_Achievement_Player_Toast_Achievement:
    description: Gives the player the achievement and toasts them with it.
    debug: false
    type: task
    definitions: data-object[Data Object made from SGC_Achievement_Data_Object]
    script:
    - flag <player> SGC.ACHIEVEMENTS.<[data-object].get[KEY]>
    - toast <[data-object].get[NAME]> targets:<player> icon:<[data-object].get[ICON]> frame:challenge
    - announce <[data-object].get[NAME].on_hover[<[data-object].get[DESCRIPTION]>]> format:SGC_Achievement_Format
    - run sgc_master_reward def.winnings:<[data-object].get[REWARD]> def.game:ach

SGC_Achievement_Format:
    debug: false
    type: format
    format: <proc[Spinal_Chat_Name_Proc]> has just earned the achievement <aqua>[<[text]>]

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

## ACHIEVEMENT ERROR LOGGER
SGC_Achievement_Discord_Error_Message:
    description: Sends a message to the Denizens discord channel if errors are hit.
    debug: false
    type: task
    definitions: message[Error message to send to Discord]
    script:
    - discordmessage id:SpinalBot channel:1253549073940877372 embed:<discord_embed[title=SGC Achievements;description=<[message]>;color=<color[#EBF609]>;footer=Spinalcraft <bungee.server>]>