# Love3D Engine
A 3D renderer written entirely in Lua.

## About
This is based on javid9x/OneLoneCoder's 3D renderer, which he wrote for his olcConsoleGameEngine and documented on his YouTube channel.
I followed along with his videos in 2019, then returned in 2023 to fix it up and get it fully working.
It is not very performant. It was mainly a learning exercise in graphics programming for me.

## Using
You will need the Love2D engine installed (love2d.org). `cd` to the repo directory. Create a directory called "objects". Place some .obj files in that directory. I recommend something like the Utah teapot. Modify the ObjFile in main.lua to load whatever obj file you want. Run `love .` inside the repo directory.
