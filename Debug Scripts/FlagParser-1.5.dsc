Parser_Spinal_Parse_Flag_Map:
  type: command
  debug: false
  name: flaglookup
  description: Displays a Flag Map in a more readable way
  usage: /flaglookup [Object Type](:Specific Object) (Flag Root) (-d)
  permission: Spinalcraft.Permission.FLAGLOOKUP
  tab complete:
  - determine <context.raw_args.proc[Parser_Command_Suggestions]>
  aliases:
   - flup
  script:
  - if <context.args.is_empty>:
    - narrate "<red>Missing arguments."
    - stop
  - define lookup-object <context.args.get[1]>
  - define lookup-object-specific SELF
  - if <[lookup-object].contains_text[:]>:
    - define lookup-object-type <[lookup-object].split[:].first>
    - if <[lookup-object].split[:].size> > 1:
      - define lookup-object-specific <[lookup-object].split[:].last>
  - else:
    - define lookup-object-type <[lookup-object]>
  - if !<proc[Parser_Valid_Type].context[<[lookup-object-type].to_lowercase>]>:
    - narrate "<red>Invalid lookup type."
    - stop
  - define argument-flag <context.args.get[2].if_null[N/A]>
  - define show-data FALSE
  - if <[argument-flag]> == -d:
    - define show-data TRUE
    - define argument-flag N/A
  - if <[show-data]> != TRUE:
    - define show-data <context.args.get[3].if_null[FALSE]>
    - if <[show-data]> == -d:
      - define show-data TRUE
  - narrate targets:<player> "<green>Flag Lookup<white>: <n><gold>Object<gray>: <[lookup-object-type]><n><gold>Specifics<gray>: <[lookup-object-specific]><n><gold>Flag<gray>: <[argument-flag]>"
  - run Parser_Spinal_Parse_Object def.lookup-object:<[lookup-object-type]> def.lookup-specific:<[lookup-object-specific]> def.argument-flag:<[argument-flag]> def.show-data:<[show-data]>

Parser_Command_Suggestions:
    type: procedure
    debug: false
    definitions: arguments
    script:
    - define types <list[player|location|cuboid|entity|item|npc|server]>
    - define regex-tagged <element[.*:[\w\<\[\,]*\]\>]>
    - define regex-types <element[(player|location|cuboid|inventory|entity|item|npc|server):.*]>
    - if <[types].contains[<[arguments]>]> && !<[arguments].regex_matches[<[regex-tagged]>]> && <[arguments]> != server:
      - determine "<[arguments]>:"
    - if !<[arguments].regex_matches[<[regex-types]>]>:
      - define suggestions <[types].filter_tag[<[filter_value].starts_with[<[arguments]>]>]>
      - determine <[suggestions]>
    - if <[arguments].regex_matches[.*\s.+]>:
      - determine -d
    - if <[arguments].regex_matches[.*\s]>:
      - determine [Flag]
    - if <[arguments].regex_matches[<[regex-types]>]> && !<[arguments].regex_matches[<[regex-tagged]>]>:
      - determine <proc[Parser_Command_Suggestions_Specifics].context[<[arguments].before[:]>]>
    - determine <empty>

Parser_Command_Suggestions_Specifics:
    type: procedure
    debug: false
    definitions: argument
    script:
    - choose <[argument]>:
      - case player:
        - determine <server.online_players.parse[name].parse_tag[<[argument]>:<[parse_value]>]>
      - case location:
        - define loc <location[
        - define cation ]>
        - determine <[argument]>:<[loc]><player.cursor_on[5].format[$bx,$by,$bz,$world].if_null[]><[cation]>
      - case item:
        - define player <player.
        - define item item_in_hand>
        - determine <[argument]>:<[player]><[item]>
      - default:
        - determine <empty>

Parser_Spinal_Parse_Object:
    type: task
    debug: false
    definitions: lookup-object|lookup-specific|argument-flag|show-data
    script:
    - if <[lookup-object]> == server:
      - define has-flag <server.has_flag[<[argument-flag]>]>
      - if !<[has-flag]> && <[argument-flag]> != N/A:
        - narrate targets:<player> "<red>The Object does not have a flag: <gold><[argument-flag]>"
        - stop
      - if <[argument-flag]> == N/A:
        - if <[lookup-specific]> == keys:
          - foreach <server.flag_map.keys> as:flag-key:
            - narrate targets:<player> <&color[#fd6b33]><[flag-key]>
          - stop
        - if <server.flag_map.keys.is_empty>:
          - narrate targets:<player> "<red>The Server does not have any flags"
          - stop
        - foreach <server.flag_map.keys> as:flag-key:
          - run Parser_Recursive_Flag_Parse def.flaggable-object:server def.flag:<[flag-key]> def.depth:0 def.show-data:<[show-data]>
        - stop
      - run Parser_Recursive_Flag_Parse def.flaggable-object:server def.flag:<[argument-flag]> def.depth:0 def.show-data:<[show-data]>
      - stop
    - else:
      - if <[lookup-object].to_lowercase> == player:
        - if <[lookup-specific]> == SELF:
          - define lookup-specific <player.uuid>
        - else:
          - define lookup-specific <server.match_offline_player[<[lookup-specific]>].if_null[FALSE]>
          - if <[lookup-specific]> == FALSE:
            - narrate targets:<player> "<red>Invalid Object Structure or Object Selection."
            - stop
          - define lookup-specific <[lookup-specific].uuid>
      - if <[lookup-object].to_lowercase> == location:
        - if <[lookup-specific]> == SELF:
          - define lookup-specific <player.cursor_on_solid[5].if_NULL[<player.location>]>
      - define object <element[<<[lookup-object]>[<[lookup-specific]>]>]>
      - if <[object]> == NULL:
        - narrate targets:<player> "<red>Invalid Object Structure or Object Selection."
        - stop
      - define object <[object].parsed.if_null[NULL]>
      - if <[object]> == NULL || <[object].object_type> == Element:
        - narrate targets:<player> "<red>Invalid Object Structure or Object Selection."
        - stop
      - define has-flag <[object].has_flag[<[argument-flag]>]>
    - if !<[has-flag]> && <[argument-flag]> != N/A:
      - narrate targets:<player> "<red>The Object does not have a flag: <gold><[argument-flag]>"
      - stop
    - if <[object]> != NULL:
      - if <[argument-flag]> == N/A:
        - if <[object].flag_map.keys.is_empty>:
          - narrate targets:<player> "<red>The Object does not have any flags"
          - stop
        - foreach <[object].flag_map.keys> as:flag-key:
          - run Parser_Recursive_Flag_Parse def.flaggable-object:<[object]> def.flag:<[flag-key]> def.depth:0 def.show-data:<[show-data]>
        - stop
      - run Parser_Recursive_Flag_Parse def.flaggable-object:<[object]> def.flag:<[argument-flag]> def.depth:0 def.show-data:<[show-data]>

Parser_Recursive_Flag_Parse:
    type: task
    debug: false
    definitions: flaggable-object|flag|depth|show-data
    script:
    - define max-depth 3
    - if <[depth]> > <[max-depth]>:
      - stop
    - define indent <empty>
    - repeat <[depth]>:
      - define indent <gray>|<[indent]>
      - repeat 3:
        - define indent " <[indent]>"
    - define text-flag <[flag].split[.].last>
    - if <[depth]> == 0:
      - narrate targets:<player> <&color[#fd6b33]><[text-flag]>
    - define text "<[indent]>- "
    - if <[flaggable-object]> == server:
      - if <proc[Parser_Valid_Type].context[<server.flag[<[flag]>].object_type.to_lowercase>]>:
        - narrate targets:<player> <[text]><proc[Parser_Server_Handler].context[<[flag]>|<[show-data]>]>
        - stop
      - if <[depth]> > 0:
          - narrate targets:<player> <[text]><&color[#ffbf58]><[text-flag]>
      - foreach <server.flag[<[flag]>].keys> as:key:
        - ~run Parser_Recursive_Flag_Parse def.flaggable-object:<[flaggable-object]> def.flag:<[flag]>.<[key]> def.depth:<[depth].add[1]> def.show-data:<[show-data]>
    - else:
      - if !<[flaggable-object].has_flag[<[flag]>]>:
        - stop
      - if <proc[Parser_Valid_Type].context[<[flaggable-object].flag[<[flag]>].object_type.to_lowercase>]>:
        - narrate targets:<player> <[text]><[flaggable-object].proc[Parser_Object_Handler].context[<[flag]>|<[show-data]>]>
        - stop
      - if <[depth]> > 0:
          - narrate targets:<player> <[text]><&color[#ffbf58]><[text-flag]>
      - foreach <[flaggable-object].flag[<[flag]>].keys> as:key:
        - ~run Parser_Recursive_Flag_Parse def.flaggable-object:<[flaggable-object]> def.flag:<[flag]>.<[key]> def.depth:<[depth].add[1]> def.show-data:<[show-data]>

Parser_Object_Handler:
    type: procedure
    debug: false
    definitions: object|flag|show-data
    script:
    - define color <proc[Parser_Color_Code].context[<[object].flag[<[flag]>].object_type>]>
    - define values <[object].flag[<[flag]>]>
    - define info <[values].proc[Parser_Object_Formatter].context[<[color]>]>
    - if <[show-data]>:
      - determine <[color]>[<[flag].split[.].last.on_hover[<white><[values]>]>]
    - else:
      - determine <[color]>[<[flag].split[.].last.on_hover[<white><[info]>]>]

Parser_Object_Formatter:
    type: procedure
    debug: false
    definitions: values|color
    script:
    - define type <[values].object_type>
    - define prefix <[color]><[type]><n><white>
    - choose <[type]>:
      - case List:
        - define list "|"
        - foreach <[values]> as:value:
          - if <[value].object_type> == Item:
            - define list "<[list]> <[value].material.translated_name> x<[value].quantity> |"
          - else:
            - define list "<[list]> <[value]> |"
        - determine <[prefix]><[list]>
      - case Inventory:
        - define list "|"
        - foreach <[values].list_contents.exclude[<item[air]>]> as:value:
          - define list "<[list]> <[value].material.translated_name> x<[value].quantity> |"
        - determine "<[prefix]>Owner: <[values].id_holder.name><n><[list]>"
      - case Time:
        - determine <[prefix]><[values].format>
      - case Duration:
        - determine <[prefix]><[values].formatted>
      - case Item:
        - define material "Material: <[values].material.translated_name><n>"
        - define item-name "Display Name: <[values].display.if_null[<[values].material.translated_name>]><n>"
        - define item-lore Lore:<n>
        - if !<[values].lore.is_empty>:
          - foreach <[values].lore> as:lore:
            - define item-lore <[item-lore]><[lore]><n>
        - define item-enchants Enchantments:<n>
        - foreach <[values].enchantment_map> key:enchant as:val:
          - define item-enchants "<[item-enchants]><[enchant].name> <[val]><n>"
        - define has-flags-boolean FALSE
        - if <[values].flag_map.keys.size> > 0:
          - define has-flags-boolean TRUE
        - define has-flags "Has Flags: <[has-flags-boolean]>"
        - determine <[prefix]><[material]><[item-name]><[item-lore]><[item-enchants]><[has-flags]>
      - case Location:
        - determine <[values].format[$bx, $by, $bz, $world]>
      - default:
        - determine <[prefix]><[values]>


Parser_Server_Handler:
    type: procedure
    debug: false
    definitions: flag|show-data
    script:
    - define color <proc[Parser_Color_Code].context[<server.flag[<[flag]>].object_type>]>
    - define values <server.flag[<[flag]>]>
    - define info <[values].proc[Parser_Object_Formatter].context[<[color]>]>
    - if <[show-data]>:
      - determine <[color]>[<[flag].split[.].last.on_hover[<white><[values]>]>]
    - else:
      - determine <[color]>[<[flag].split[.].last.on_hover[<white><[info]>]>]

Parser_Valid_Type:
    type: procedure
    debug: false
    definitions: object-type
    script:
    - choose <[object-type]>:
      - case player location cuboid inventory entity item npc server element duration list time:
        - determine true
      - default:
        - determine false

Parser_Color_Code:
    type: procedure
    debug: false
    definitions: object-type
    script:
    - choose <[object-type]>:
      - case Element:
        - define color <&color[#a5ccff]>
      - case Player:
        - define color <&color[#A5FFC6]>
      - case Location:
        - define color <&color[#6BFFC9]>
      - case Cuboid:
        - define color <&color[#6BFFC9]>
      - case Inventory:
        - define color <&color[#31FFEB]>
      - case Entity:
        - define color <&color[#A5FFC6]>
      - case Item:
        - define color <&color[#FFA5A8]>
      - case NPC:
        - define color <&color[#A5FFC6]>
      - case List:
        - define color <&color[#EAA5FF]>
      - case Duration:
        - define color <&color[#F0FFA5]>
      - case Time:
        - define color <&color[#F0FFA5]>
      - default:
        - define color <&color[#FFFFFF]>
    - determine <[color]>