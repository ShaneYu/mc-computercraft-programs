# Minecraft ComputerCraft - Programs & Libraries

A collection of my programs and libraries for [Minecraft](https://www.minecraft.net/) ComputerCraft ([CC: Tweaked](https://github.com/cc-tweaked/CC-Tweaked))


## Getting started

The easiest way to get started is by using my installer program. The installer will allow you to select which libraries and programs to download and/or update.

If you have no run the installer previously on on the current device (turtle or computer), run the following command:

```
pastebin run 7pQePxw4
```

Otherwise, if you have run the installer previously on the current device, run the following command instead:

```
shadownet install
```

_The installer will only show the libraries and programs relevant to the device you are running it on, I.E. turtle programs will not be shown when running the installer on a computer device._


### Libraries

- `shadownet/core/middleclass.lua` - A simple OOP library for Lua. It has inheritance, metamethods (operators), class variables and weak mixin support
- `shadownet/core/surface.lua` - A powerful graphics API made for lua-based
- `shadownet/core/fonts.lua` - Various 8bit fonts for rendering larger text
- `shadownet/core/i18n/` - A very complete i18n lib for Lua
- `shadownet/core/mixins/stateful.lua` - Stateful classes for Lua (used with middleclass)
- `shadownet/gui/...` - A OOP GUI framework built on Surface 2


### Programs

All programs listed below can be installed via the ShadowNet installer, type `shadownet install` to bring it up.

Simply select the programs you with to install, delete or update and also toggle on which program you wish to autostart when the computer boots up.

#### Sheap Shearer (turtle)

Sheep Shearer is a turtle program that shears sheep continuously in a circle around them and dumps the wool off into an inventory above it.

When you first startup the program it will ask you if you'd like it to build the sheep searing structure for you. If you answer yes it will inform you what materials it requires, what slots to place them in and also some fuel for it to build.

Fuel is only needed to build the structure; as the turtle does not move and only turns around on the spot, it doesn't need fuel to function normally once the structure is built.


### API Documentation

- [Using the ShadowNet GUI Framework](GUI.md)
- [Using middle class for OOP](https://github.com/kikito/middleclass/wiki)
- [Using states with classes](https://github.com/kikito/stateful.lua/blob/master/README.md)
- [Using i18n to make your applications mult-lingual](https://github.com/kikito/i18n.lua/blob/master/README.md)
- [Using Surface 2 outside of the GUI framework](https://github.com/CrazedProgrammer/Surface2/wiki/Concepts)

## Credits

- [Enrique García Cota (kikito)](https://github.com/kikito)
  - [middleclass](https://github.com/kikito/middleclass) - Object-orientation for Lua
  - [stateful](https://github.com/kikito/stateful.lua) - Stateful classes for Lua
  - [i18n](https://github.com/kikito/i18n.lua) - A very complete i18n lib for Lua
- [CrazedProgrammer](https://github.com/CrazedProgrammer)
  - [surface v2](https://github.com/CrazedProgrammer/Surface2) - A powerful graphics API made for lua-based environments
