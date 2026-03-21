<div align="middle">

<img src="./git_assets/icon.png" align=""></img>

**Version:** 0.0.1

Tesseract is a (work in progress) advanced modding platform for Godot 4 that gives both modders & game developers the tools they need to easily implement seamless mods.

</div>

---

# Features
Not all of the listed features are complete or implemented at all.

- Load mods from PCK, ZIP (TMOD), or folder.
  - Seamlessly drag DLC/mod content out of Godot & into any game's designated mods folder.
  - Export mods as TMOD ZIP files for compression, encryption, & ease of sharing.
- Dependency free mods.
  - Load & export mods without bundling unnecessary files (unavailable for PCK loader).
- Extensive sandboxing.
  - Choose which folders mods are allowed to overwrite.
  - Regulate or block script usage.
  - Force mods to load into a dedicated folder.
- Mod metadata.
  - Name, author, version, description, etc.
  - Specify compatible game versions.
- Customizable game API.
  - Send & recieve signals from mods.
  - Specify assets for mods to use.


# Install & use mods
For the end user, installing mods should be as simple & seamless as possible. The user only has 2 things they need to do, or if your game has built-in mod management (importing, reordering & toggling) 0 things!

1. Throw the TMOD file or mod folder into the game's dedicated mods folder (usually at `user://MODS`).
2. Rename the file/folder to start with the load order for that mod. For example to load any mod *before* all other mods the name should start with the number "1".
   It works like this because mods are loaded alphabetically based on their file/folder name.


# Create your first mod
If you are familiar with Godot 4.0 then creating a Tesseract mod will be a breeze.
To get started open a brand new project in Godot 4 with Tesseract installed. Developers may provide a dedicated Godot project for modders, use that if possible.

Create a new folder anywhere in your project to hold all the files for your mod, this will be referenced as the root directory of your mod.

## Create a config file
For (most) games that support Tesseract, mods require a configuration file that specifies a unique name, a type, version, & optionally an author.
Depending on the game, they may have you specify additional parameters for your mod.

Here is what a basic config file looks like:
```ini
[TesseractMod]
; Unique name of the mod.
name="My Mod"
; Author of the mod.
author="John Doe"
; String representation of the mod version.
version_string="1.0.0"
; Version of the mod.
version_number=1
; All game API versions this mod is expected to work for.
game_versions=[1]
description_short="Short description of this mod."
description_long="Long description of this mod, should include a list of all changes made."
```

Your config file should be located in the *root directory of your mod* & have the exact name `MOD.cfg`.

## Create an init script
This step is completely optional & depends on whether or not the game you are developing for supports scripts inside mods.
You only need to do this if you want to connect to the game's API signals &/or if you want to run custom logic during mod initialization.

Here is what a basic init script looks like:
```gdscript
extends TesseractMod


func init() -> void:
	print('%s mod successfuly activated!!' % name)


func recieve_signal(_signal_name:String, ..._args) -> void:
	pass
```

