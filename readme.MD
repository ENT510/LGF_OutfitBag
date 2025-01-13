![GitHub Downloads](https://img.shields.io/github/downloads/ENT510/LGF_OutfitBag/total?logo=github)
![GitHub Release](https://img.shields.io/github/v/release/ENT510/LGF_OutfitBag?logo=github)

# LGF Outfit Bag
OutfitBag using "LGF_SpriteTextUI" for the interaction, Allow player to share personal outfit.

![Outfit Bag System](https://cdn.discordapp.com/attachments/1167599712732467390/1328118121130758176/image.png?ex=678632a3&is=6784e123&hm=37324a5600500f7c428674cd50ab6ce78f1515b54d21822df04385299083b0f0)

- [ShowCase](https://www.youtube.com/watch?v=d0nCkqfrgCo)

## Features
- Synced Interaction.
- Add Outfit by Code: Players can enter a code to copy or generate an outfit.
- Save and Load Outfits: Save the current outfit or load a previously saved one.
- Bag Management: Bags are treated as props in the world with a model and maximum slot configuration.

# Item Structure
```lua
['outfitbag_10'] = {
    label = 'Outfit Bag',
    weight = 0,
    stack = false,
    close = true,
    consume = 0,
    client = {
        export = 'LGF_DoorSystem.placeBag'
    },
},
-- Add other Bag 
```
