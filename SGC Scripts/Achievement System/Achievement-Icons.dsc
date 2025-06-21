## This is the Icon Portion of the Achievement System
#- This contains all Icons Used
# Icons
SGC_Achievement_Unknown_Achievement_Icon:
    type: item
    material: book
    display name: <empty>
    lore:
        - <gray>Description

SGC_Achievement_Remove_Tracker_Icon:
    type: item
    material: writable_book
    display name: <red>Stop Tracking
    lore:
        - <gray>Click to remove your currently tracked achievement

SGC_Achievement_Quiet_Icon:
  type: item
  mechanisms:
    skull_skin: eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvN2RkYjFlM2VjMzg2ZjhkMTg0YzI5ZmMwNGI4ZjZiNzZiMTg3OTVjMzI1YzQyOWM0OGIzNDgzNDMzMDA2N2FjZSJ9fX0=
  material: player_head
  display name: <dark_purple>Toggle Achievement Messages

SGC_Ach_Quiet_Icon_Toggle:
  type: data
  OFF: eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvNGVhNmU2YzRmMjkyZmNjODJiZWZlOTEyYjM5MjE3ODQ3MzA4MDZiZGM0YjA0OTE2MzhlNDYzODExMDg4MjdlYiJ9fX0=

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
    - define lore <[data-object].get[DESCRIPTION]>
    - if <[lore].object_type> == List:
        - define lore <[lore].set[<gray><[lore].first>].at[1]>
    - adjust def:icon lore:<[lore]>
    - determine <[icon]>