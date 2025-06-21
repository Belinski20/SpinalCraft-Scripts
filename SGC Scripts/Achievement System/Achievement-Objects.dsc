## This is the Data Objects Portion of the Achievement System
#- This contains the methods used to intrepret the data into meaningful ways
# Data Object Methods
SGC_Achievement_Menu_Category_Data_Object:
    description: Creates and Opens the Category Menu
    debug: false
    type: procedure
    script:
    - define script <script[Achievement_File_Map]>
    - define category-objects <list[]>
    - foreach <[script].data_key[FILES].keys> as:id:
        - define yaml <[script].data_key[FILES].get[<[id]>].get[REF]>
        - define KEY <[script].data_key[FILES].get[<[id]>].get[KEY]>
        - definemap object:
            ICON: <yaml[<[yaml]>].read[<[KEY]>.ICON].if_null[NULL]>
            NAME: <yaml[<[yaml]>].read[<[KEY]>.DISPLAY].if_null[<[KEY]>]>
            FILEID: <[id]>
        - define category-objects:->:<[object]>
    - determine <[category-objects]>

SGC_Achievement_Menu_Directory_Data_Object:
    description: Creates and Opens the Category Menu
    debug: false
    type: procedure
    definitions: id
    script:
    - define script <script[Achievement_File_Map]>
    - define sub-category-objects <list[]>
    - define yaml <[script].data_key[FILES].get[<[id]>].get[REF]>
    - define key <[script].data_key[FILES].get[<[id]>].get[KEY]>
    - define sub-categories <yaml[<[yaml]>].list_keys[<[key]>].exclude[DISPLAY|ICON]>
    - foreach <[sub-categories]> as:sub-category:
        - definemap object:
            DISPLAY: <yaml[<[yaml]>].read[<[key]>.<[sub-category]>.DISPLAY].if_null[<[sub-category]>]>
            NAME: <[sub-category]>
            KEY: <[key]>
        - define sub-category-objects:->:<[object]>
    - determine <[sub-category-objects]>

SGC_Achievement_Data_Object:
    description: Makes a Data Object with all data on an achievement.
    debug: false
    type: procedure
    definitions: game-key[Example: SGC.H_BLACKJACK]|file-id[Example: 1,2,3]|achievement-key[Example: WIN_100]
    script:
    - define script <script[Achievement_File_Map]>
    - define yaml <[script].data_key[FILES].get[<[file-id]>].get[REF]>
    - define yaml-object <yaml[<[yaml]>].read[<[game-key]>.ACHIEVEMENTS.<[achievement-key]>]>
    - definemap data-object:
        KEY: <[game-key]>.<[achievement-key].if_null[INVALID]>
        NAME: <[yaml-object].get[NAME].if_null[INVALID]>
        DESCRIPTION: <[yaml-object].get[DESCRIPTION].if_null[INVALID].parsed>
        ICON: <[yaml-object].get[ICON].if_null[INVALID]>
        REWARD: <[yaml-object].get[REWARD].if_null[0]>
        STATS: <[yaml-object].get[STATS].if_null[INVALID]>
    - determine <[data-object]>