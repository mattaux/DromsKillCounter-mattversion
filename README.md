DTKC – Kill Counter (Extended)

This repository contains an extended version of the original DTKC kill counter addon for WoW WotLK 3.3.5.

The original addon did not include configuration commands.
This version adds slash commands and configurable behavior, while keeping the core logic intact.

What Was Added

Slash command interface (/dtkc)

Configurable kill counting window

Configurable display duration

Two counting modes: streak and burst

Independent show/hide control for:

Total kill counter

Multi-kill counter

No external libraries are used. All UI elements rely on Blizzard’s native API.

Counting Modes
STREAK

Each kill resets the timer window

The count continues as long as kills keep happening within the window

BURST

Uses a fixed time window

Only kills that occur inside that window are counted

Slash Commands
/dtkc window <seconds>


Sets the time window used for kill counting

/dtkc display <seconds>


Sets how long the counter remains visible

/dtkc mode <burst> | <streak>


Selects the counting mode

/dtkc total <show> | <hide>


Shows or hides the total kills counter

/dtkc multi <show> | <hide>


Shows or hides the multi-kill counter

Compatibility

World of Warcraft: Wrath of the Lich King (3.3.5)

Uses Blizzard FrameXML / UI API only
