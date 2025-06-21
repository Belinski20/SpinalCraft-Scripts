## This is the Notification Portion of the Achievement System
#- This contains all methods which send messages
# Discord
SGC_Achievement_Discord_Display_Message:
    description: Sends a message when a player gets an achievement to discord
    debug: false
    type: task
    definitions: data-object|game-name
    script:
    - define description <[data-object].get[DESCRIPTION]>
    - if <[description].object_Type> == List:
        - define description <[description].get[1]>
    - discordmessage id:SpinalBot channel:<server.flag[DiscordChat]> embed:<discord_embed[thumbnail=https://mc-heads.net/avatar/<player.uuid>/50;title=<player.name> has received __*<[data-object].get[NAME]>*__;description=<[description].strip_color>;color=<color[#00FFFF]>;footer=<[game-name]> | Spinal Gaming Center]>

SGC_Achievement_Discord_Error_Message:
    description: Sends a message to the Denizens discord channel if errors are hit.
    debug: false
    type: task
    definitions: message[Error message to send to Discord]
    script:
    - discordmessage id:SpinalBot channel:"channel goes here" embed:<discord_embed[title=SGC Achievements;description=<[message]>;color=<color[#EBF609]>;footer=Spinalcraft <bungee.server>]>

# In-Game
SGC_Achievement_Player_Toast_Achievement:
    description: Gives the player the achievement and toasts them with it.
    debug: false
    type: task
    definitions: data-object[Data Object made from SGC_Achievement_Data_Object]|game-name
    script:
    - flag <player> SGC.ACHIEVEMENTS.<[data-object].get[KEY]>
    - define description <[data-object].get[DESCRIPTION]>
    - if <[description].object_type> == List:
        - define description <[description].first>
    - define announcement "<&color[#5eb8bd]><bold>[SGC] <proc[Spinal_Chat_Name_Proc]> has just earned the achievement <aqua>[<[data-object].get[NAME].on_hover[<dark_purple><[description]><n><gold><[game-name]> <gray>| <&color[#5eb8bd]><bold>Spinal Gaming Center]><aqua>]"
    - narrate targets:<server.online_players_flagged[!SGC.ACH.QUIET]> <[announcement]>
    - if <player.has_flag[SGC.ACH.QUIET]>:
      - narrate targets:<player> <[announcement]>
    - toast <[data-object].get[NAME]> targets:<player> icon:<[data-object].get[ICON]> frame:challenge
    - run sgc_master_token_reward def.winnings:<[data-object].get[REWARD]> def.game:ach
