window.Cubecraft =
  SKY_COLOR: [0.53, 0.81, 0.98, 1.0]
  VERTICAL_FOV: 60 * (Math.PI / 180)

  # Clipping regions
  NEAR_VIEW: 0.1
  FAR_VIEW: 300

  # Each voxel is 1 unit
  GRID_SIZE:
    x: 64
    y: 32
    z: 64

  KEY_CODES:
    LEFT_MOUSE: 1
    RIGHT_MOUSE: 3
    w: 87
    s: 83
    a: 65
    d: 68
    SPACE: 32
    SHIFT: 16

  # Controls the mouse movement speed
  MOUSE_DAMPER: 500

  # Light attributes
  LIGHT_DIRECTION: [-0.4, -0.4, -1.0]
  LIGHT_COLOR: [0.9, 0.9, 0.9]
  AMBIENT_COLOR: [0.4, 0.4, 0.4]

  gl: null
  canvas: null
  chunkManager: null
  aspect: null
  mouse_movement: { x: 0, y: 0 }
  keysPressed: {}
  pMatrix: mat4.create()

  init: ->
    @canvas = document.getElementById('viewport')
    @gl = WebGLHelpers.getWebGLContext(@canvas)

    # When all textures have loaded, etc...
    onReady = (glCubeHelper) =>
      @chunkManager = new ChunkManager(glCubeHelper, @GRID_SIZE.x, @GRID_SIZE.y, @GRID_SIZE.z)
      seed = Math.random()
      @chunkManager.createLandscape(seed)

      @initEvents()
      @initFpsStats()

      @gl.clearColor(@SKY_COLOR...)
      @gl.enable(@gl.DEPTH_TEST)

      @tick()

    new GLCubeHelper(@gl, @LIGHT_DIRECTION, @LIGHT_COLOR, @AMBIENT_COLOR, onReady)

  initFpsStats: ->
    @fpsStats = new Stats()  # FPS benchmarking tool by Mr. Doob
    @fpsStats.domElement.style.position = 'absolute'
    @fpsStats.domElement.style.left = '0px'
    @fpsStats.domElement.style.top = '0px'
    document.body.appendChild(@fpsStats.domElement)

  initEvents: ->
    resizeWindow = =>
      @canvas.width = window.innerWidth
      @canvas.height = window.innerHeight
      @aspect = window.innerWidth / window.innerHeight
      @gl.viewport(0, 0, @canvas.width, @canvas.height)
    resizeWindow()

    # Record the mouse's movements while captured
    mousemove = (e) =>
      @mouse_movement.x = e.webkitMovementX
      @mouse_movement.y = e.webkitMovementY

    # Enable mouse-capturing by the browser
    # http://www.chromium.org/developers/design-documents/mouse-lock
    pointerLockChange = =>
      if document.webkitPointerLockElement == @canvas
        document.addEventListener('mousemove', mousemove, false)
      else
        document.removeEventListener('mousemove', mousemove, false)
    document.addEventListener('webkitpointerlockchange', pointerLockChange, false)

    # Capture mouse events
    $(@canvas).mousedown (e) =>
      @canvas.webkitRequestPointerLock()

      switch e.which
        when @KEY_CODES.LEFT_MOUSE
          Cubecraft.chunkManager.addBlock(Player.pos, Player.look)
        when @KEY_CODES.RIGHT_MOUSE
          Cubecraft.chunkManager.removeBlock(Player.pos, Player.look)

    # Capture all keyboard events
    $(window).keydown (e) =>
      @keysPressed[e.keyCode] = true
    .keyup (e) =>
      @keysPressed[e.keyCode] = false
    .resize(resizeWindow)

  draw: ->
    # Clear the color and depth buffers
    @gl.clear(@gl.COLOR_BUFFER_BIT | @gl.DEPTH_BUFFER_BIT)

    # Create the perspective matrix
    mat4.perspective(@pMatrix, @VERTICAL_FOV, @aspect, @NEAR_VIEW, @FAR_VIEW)

    # Render parts of the terrain
    @chunkManager.updateAndDraw(Player.viewMatrix, @pMatrix)

  # To be called 60 fps
  tick: ->
    @fpsStats.begin()

    Player.update()
    @draw()

    @fpsStats.end()
    requestAnimationFrame => @tick()
