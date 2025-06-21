## This is the Util Portion of the Achievement System
#- This contains the methods used by other main methods
# Methods
SGC_Achievement_Player_Has_Achievement:
    description: Returns if a player has the provided achievement already
    debug: false
    type: procedure
    definitions: achievement-name[Example: H_BLACKJACK.WIN_100]
    script:
    - define has-achievement <player.has_flag[SGC.ACHIEVEMENTS.<[achievement-name]>]>
    - determine <[has-achievement]>

SGC_Achievement_Player_Stat:
    description: Gets the value of a player's stat
    debug: false
    type: procedure
    definitions: stat-key[Example: H_BLACKJACK.WINS]
    script:
    - define value <player.flag[SGC.STATS.<[stat-key]>].if_null[0]>
    - determine <[value]>

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

SGC_Achievement_Get_Game_Achievements:
    description: Gets all Achievements for a given game and returns a list of Data Objects
    debug: false
    type: procedure
    definitions: file-id[Example: 1,2,3]|game-key[Example: SGC.H_BLACKJACK]
    script:
    - define script <script[Achievement_File_Map]>
    - define yaml <[script].data_key[FILES].get[<[file-id]>].get[REF]>
    - define achievement-list <list[]>
    - if !<yaml[<[yaml]>].contains[<[game-key]>]>:
        - determine <[achievement-list]>
    - define achievement-keys <yaml[<[yaml]>].list_keys[<[game-key]>.ACHIEVEMENTS].if_null[<list[]>]>
    - foreach <[achievement-keys]> as:key:
        - define data-object <[game-key].proc[SGC_Achievement_Data_Object].context[<[file-id]>|<[key]>]>
        - define achievement-list:->:<[data-object]>
    - determine <[achievement-list]>

SGC_Achievement_Game_Name_Proc:
  type: procedure
  debug: false
  script:
    - foreach <player.location.cuboids> as:cuboid:
      - if <cuboid[<[cuboid]>].note_name.starts_with[SGC_]>:
        - define game-raw <[cuboid].note_name.after[SGC_]>
        - foreach stop
      - foreach next
    - if <[game-raw].if_null[ERROR]> == ERROR:
      - define game-raw LBY
    - choose <[game-raw]>:
      - case BJH:
        - determine "BlackJack High Stakes"
      - case BJL:
        - determine "BlackJack Low Stakes"
      - case MATH:
        - determine MATH
      - case POT:
        - determine "Pottery Match"
      - case PRC:
        - determine "Playtime Redemption Center"
      - case CTD:
        - determine "Click the Differences"
      - case PPZ:
        - determine "Push Puzzle"
      - case VIL:
        - determine "Villager Races"
      - case DSN:
        - determine "Daily Spin"
      - case TTT:
        - determine "Tic Tac Toe"
      - case ST1:
        - determine "Slots V1"
      - case BTS:
        - determine Battleships
      - case BCT:
        - determine Baccarat
      - case RIA:
        - determine "Risk It All"
      - case SMN:
        - determine "Simon Says"
      - case LBY:
        - determine Lobby
      - default:
        - determine ERROR

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

SGC_STAT_DSP:
    description: This is used so print out Increment Achievement Stat information
    type: procedure
    debug: false
    definitions: stat[Example: BCT.CARDS]|max-val[Example: 10]
    script:
      - define curr-val <player.flag[SGC.STATS.<[stat]>].if_null[0]>
      - if <[curr-val]> < <[max-val]>:
        - determine <gray>[<[curr-val]>/<[max-val]>]
      - if <[curr-val]> >= <[max-val]>:
        - determine <gray>[<green><[max-val]><gray>/<green><[max-val]><gray>]

SGC_TIME_DSP:
    description: This is used so print out Time Achievement Stat information
    type: procedure
    debug: false
    definitions: stat[Example: BCT.CARDS]|max-val[Example: 144000]|type[Example: S,M,H]
    script:
      - define curr-val <player.flag[SGC.STATS.<[stat]>].if_null[0]>
      - define time 3600
      - if <[curr-val]> < <[max-val]>:
        - determine <gray>[<[curr-val].div[<[time]>].round_down_to_precision[0.1]>/<[max-val].div[<[time]>]>]
      - if <[curr-val]> >= <[max-val]>:
        - determine <gray>[<green><[max-val].div[<[time]>]><gray>/<green><[max-val].div[<[time]>]><gray>]

SGC_BOOL_DSP:
    description: This is used to print out Boolean Achievement Stat information
    type: procedure
    debug: false
    definitions: stat[Example: BCT.FOUND]|message[Example: FOUND]
    script:
      - define val <player.flag[SGC.STATS.<[stat]>].if_null[FALSE]>
      - if <[val]>:
        - determine <green><[message]>
      - determine <gray><[message]>

SGC_ACH_TRACK:
  type: task
  debug: false
  definitions: game-key|data-object
  script:
  - define file-id <[game-key].proc[SGC_Achievement_Key_To_Id]>
  - define script <script[Achievement_File_Map]>
  - define yaml <[script].data_key[FILES].get[<[file-id]>].get[REF]>
  - define game-name <yaml[<[yaml]>].read[<[game-key]>.DISPLAY].if_null[UNKNOWN]>
  - define stats <[data-object].get[STATS].keys>
  - define lines <list[<aqua><[data-object].get[NAME]>]>
  - foreach <[stats]> as:stat:
    - define goal <[data-object].get[STATS].get[<[stat]>]>
    - if <[goal].is_integer>:
        - define val <player.flag[SGC.STATS.<[stat]>].if_null[0]>
        - if <[data-object].contains[TIME]>:
            - define type <[data-object].get[TIME]>
            - choose <[type]>:
                - case HOURS:
                    - define amount 3600
                - case MINUTES:
                    - define amount 60
                - case DAYS:
                    - define amount 86400
                - default:
                    - define amount 1
            - define val <[val].div[<[amount]>].round_down_to_precision[0.1]>
            - define goal <[goal].div[<[amount]>].round_to_precision[0.1]>
    - else:
        - foreach next
    - define line "<gray>Current: <green><[val]> <gray>| <gold>Goal<gray>: <green><[goal]>"
    - define lines:->:<[line]>
  - sidebar set title:<gold><[game-name]> values:<[lines]> players:<player>
  - flag <player> SGC.ACH.TRACKING:<[data-object].get[KEY]>