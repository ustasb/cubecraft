# Cubecraft

- [brianustas.com/cubecraft/](http://brianustas.com/cubecraft/) (tested in Chrome)
- Initial release: 12/02/13
- Author: [Brian Ustas](http://brianustas.com)

A simple voxel engine written with raw WebGL that I created for my CS 4300: Computer Graphics course.

It's not the prettiest code!

Texture Credit: John Smith Legacy v1.0.2 Minecraft Texture Pack - http://jslegacy.com

## Controls

- Fly through the world using WASD, Shift (fly down), Space (fly up) and your mouse.
- Left click to place a block.
- Right click to remove a block.

## Usage

First build the Docker image:

    docker build -t cubecraft .

Compile SASS and CoffeeScript with:

    rake docker_build_dist

    # To recompile assets when files change (uses fswatch):

    rake docker_build_dist_and_watch

Serve assets via a local server:

    cd src && python -m SimpleHTTPServer

Navigate to `http://localhost:8000` in your browser.

## Production

To build the `public/` folder:

    rake docker_build_public

Open `public/index.html`.
