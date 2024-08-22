# Goal is to add an enchantment/flag which allows for a 3x3 mining/digging
Hammeraxe:
    type: item
    material: diamond_pickaxe
    display name: <&o.end_format><white>Hammer-axe
    lore:
    - <&o.end_format><&7>Increased Range I
    - <&o.end_format>A Pickaxe built to mine a 3x3x1 area
    flags:
        excavator: true
    mechanisms:
        repair_cost: 9999

Increased_Range_Handler:
    debug: false
    type: world
    events:
        on player damaged by freeze flagged:frozen:
        - determine cancelled
        on player breaks block with:item_flagged:excavator:
        - if <player.has_flag[mining_cooldown]>:
            - stop
        - flag <player> mining_cooldown
        - define is_sneaking <player.is_sneaking>
        - if <[is_sneaking]>:
            - stop
        - define target_block <context.location>
        - if <[target_block].material.name> == air:
            - stop
        - define blockface <player.eye_location.ray_trace[return=normal].vector_to_face>
        - choose <[blockface]>:
            - case UP DOWN:
                - define mining_cuboid <cuboid[<player.location.world.name>,<[target_block].x.add[1]>,<[target_block].y>,<[target_block].z.add[1]>,<[target_block].x.sub[1]>,<[target_block].y>,<[target_block].z.sub[1]>]>
            - case EAST WEST:
                - define mining_cuboid <cuboid[<player.location.world.name>,<[target_block].x>,<[target_block].y.add[1]>,<[target_block].z.add[1]>,<[target_block].x>,<[target_block].y.sub[1]>,<[target_block].z.sub[1]>]>
            - case NORTH SOUTH:
                - define mining_cuboid <cuboid[<player.location.world.name>,<[target_block].x.add[1]>,<[target_block].y.add[1]>,<[target_block].z>,<[target_block].x.sub[1]>,<[target_block].y.sub[1]>,<[target_block].z>]>
        - define blocks_to_break <list[]>
        - foreach <[mining_cuboid].blocks> as:block:
            - if 0 <= <[block].material.hardness> && <[block].material.hardness> <= <[target_block].material.hardness>:
                - define blocks_to_break:->:<[block]>
        - define remaining_durability <player.item_in_hand.max_durability.sub[<player.item_in_hand.durability>]>
        - if <[blocks_to_break].size> > <[remaining_durability]>:
            - define blocks_to_break <[blocks_to_break].random[<[remaining_durability].sub[1]>]>
        - modifyblock <[blocks_to_break]> air naturally:<player.item_in_hand> source:<player>
        - define current_durability <player.item_in_hand.durability>
        - if <[current_durability].add[<[blocks_to_break].size>]> >= <player.item_in_hand.max_durability>:
            - take iteminhand
        - inventory adjust slot:hand durability:<[current_durability].add[<[blocks_to_break].size>]>
        - flag <player> mining_cooldown:!