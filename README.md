# Cubecraft

[ustasb.com/cubecraft](http://ustasb.com/cubecraft) (Only tested in **Chrome!**)

A simple voxel engine I created for my CS 4300: Computer Graphics course.
It's not the prettiest code!

Texture Credit: John Smith Legacy v1.0.2 Minecraft Texture Pack - http://jslegacy.com

## Controls

- Fly through the world using WASD, Shift (fly down), Space (fly up) and your mouse.
- Left click to place a block.
- Right click to remove a block.

## Usage

1. `python -m SimpleHTTPServer`
2. Navigate to `http://localhost:8000`, using **Chrome**.

## Development

First, build the Docker image:

    docker build -t cubecraft .

Compile CoffeeScript with:

    ./recompile_assets.sh

To recompile assets when files change:

    fswatch -o src | xargs -n1 -I{} ./recompile_assets.sh
