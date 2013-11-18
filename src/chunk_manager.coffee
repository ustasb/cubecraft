class window.ChunkManager
  constructor: (@glCubeHelper, @xGridSize, @yGridSize, @zGridSize) ->
    @blocks = [[[]]] # A 3D array of blocks
    @blockList = []  # Easier to iterate over
    @_chunks = []

  updateAndDraw: (mvMatrix, pMatrix) ->
    for chunk in @_chunks
      chunk.update()
      chunk.render(mvMatrix, pMatrix)

  # Get a block from a given ray
  getClosestBlockHitByRay: (rpos, rview) ->
    hit = dist: Infinity

    for block in @blockList
      if block.isActive
        intersect = block.getSideIntersectedByRay(rpos, rview)
        if intersect?.dist < hit.dist
          hit = intersect
          hit.block = block

    hit

  addBlock: (rpos, rview) ->
    hit = @getClosestBlockHitByRay(rpos, rview)
    if hit.block
      surroundingBlocks = @getSurroundingBlocks(hit.block)
      sideToAddBlockTo = surroundingBlocks[hit.side]
      sideToAddBlockTo.setActive(true) if sideToAddBlockTo

  removeBlock: (rpos, rview) ->
      hit = @getClosestBlockHitByRay(rpos, rview)
      if hit.block
        hit.block.setActive(false)

        surroundingBlocks = @getSurroundingBlocks(hit.block)
        for side, block of surroundingBlocks
          if block and block.isActive
            block.chunker.needsUpdating = true

  getSurroundingBlocks: (block) ->
    x = block.x
    y = block.y
    z = block.z
    blocks = {}

    blocks['right'] = @blocks[x + 1]?[z][y] or null
    blocks['left'] = @blocks[x - 1]?[z][y] or null
    blocks['front'] = @blocks[x][z + 1]?[y] or null
    blocks['back'] = @blocks[x][z - 1]?[y] or null
    blocks['top'] = @blocks[x][z][y + 1] or null
    blocks['bottom'] = @blocks[x][z][y - 1] or null

    blocks

  getVisibleFaces: (b0) ->
    blocks = @getSurroundingBlocks(b0)
    visibleFaces = {}

    for side, block of blocks
      if not block or not block.isActive
        visibleFaces[side] = true

    visibleFaces

  createLandscape: (seed = 0.7) ->
    @blocks = []
    @blockList = []
    @_chunks = []

    noiseSize = 6
    for x in [0...@xGridSize]
      @blocks.push []

      chunk = new Chunk(@glCubeHelper, this)
      @_chunks.push(chunk)

      for z in [0...@zGridSize]
        @blocks[x].push []

        height = @yGridSize * PerlinNoise.noise(
          noiseSize * x / @xGridSize,
          seed,
          noiseSize * z / @zGridSize
        )
        # Lower the height a bit
        height = Math.round Math.pow(Math.log(height), 2.2)

        for y in [0...@yGridSize]
          active = y <= height
          block = new Block(x, y, z, active)
          @blocks[x][z].push(block)
          @blockList.push(block)
          chunk.addBlock(block)

class Chunk
  constructor: (@glCubeHelper, @manager) ->
    @_blocks = []
    @needsUpdating = true

  addBlock: (block) ->
    block.addChunker(this)
    @_blocks.push(block)

  # A mesh contains multiple cubes
  # and lots of data
  updateMeshData: () ->
    vertices = []
    vertIndices = []
    vertNormals = []
    textCoords = []

    indexCount = 0
    indexOffset = 0

    for block in @_blocks
      if block.isActive
        faces = @manager.getVisibleFaces(block)
        if Object.keys(faces).length > 0
          @glCubeHelper.addTextureCoords(textCoords, faces)
          @glCubeHelper.addVertexNormals(vertNormals, faces)
          indexCount += @glCubeHelper.addVertexIndices(vertIndices, indexOffset, faces)
          indexOffset += @glCubeHelper.addVerticesAtPos(vertices, block.x, block.y, block.z, Block.RENDER_SIZE, faces)

    @_vertBuffer = @glCubeHelper.getGLBufferFromArray(vertices)
    @_textCoordBuffer = @glCubeHelper.getGLBufferFromArray(textCoords)
    @_vertNormalBuffer = @glCubeHelper.getGLBufferFromArray(vertNormals)
    @_vertIndexBuffer = @glCubeHelper.getGLBufferFromArray(vertIndices, true)
    @_vertIndexBuffer.numItems = indexCount

  update: ->
    if @needsUpdating
      @needsUpdating = false
      @updateMeshData()

  render: (mvMatrix, pMatrix) ->
    @glCubeHelper.draw(mvMatrix, pMatrix, @_vertBuffer, @_vertIndexBuffer, @_textCoordBuffer, @_vertNormalBuffer)

class Block
  @RENDER_SIZE: 1

  constructor: (@x, @y, @z, @isActive = true) ->
    d = Block.RENDER_SIZE / 2  # x, y, z are at the center of the block
    @min = [x - d, y - d, z - d]
    @max = [x + d, y + d, z + d]

  addChunker: (@chunker) ->

  setActive: (newState) ->
    if @isActive != newState
      @isActive = newState
      @chunker.needsUpdating = true

  getSideIntersectedByRay: do ->
    sideNormals =
      top: [0, 1, 0]
      bottom: [0, -1, 0]
      right: [1, 0, 0]
      left: [-1, 0, 0]
      front: [0, 0, 1]
      back: [0, 0, -1]

    getPointOnPlane = (pnormal, poffset, rpos, rview) ->
      vec3.normalize(rview, rview)

      vd = vec3.dot(pnormal, rview)
      if Math.abs(vd) < 0.01
        # Parallel to the plane--no intersection
        return false

      v0 = -(vec3.dot(pnormal, rpos) - poffset)
      t = v0 / vd
      if t < 0
        # Intersection is behind the ray origin--ignore it
        return false

      intersectPos = vec3.add([], rpos, vec3.scale([], rview, t))
      { pos: intersectPos, t: t }

    (pos, view) ->

      # TOP
      offset = @max[1]
      if pos[1] > offset
        p = getPointOnPlane(sideNormals.top, offset, pos, view)
        if p and
           p.pos[0] < @max[0] and p.pos[0] > @min[0] and
           p.pos[2] < @max[2] and p.pos[2] > @min[2]
             return { side: 'top', dist: p.t }

      # BOTTOM
      offset = @min[1]
      if pos[1] < offset
        offset *= -1
        p = getPointOnPlane(sideNormals.bottom, offset, pos, view)
        if p and
           p.pos[0] < @max[0] and p.pos[0] > @min[0] and
           p.pos[2] < @max[2] and p.pos[2] > @min[2]
             return { side: 'bottom', dist: p.t }

      # RIGHT
      offset = @max[0]
      if pos[0] > offset
        p = getPointOnPlane(sideNormals.right, offset, pos, view)
        if p and
           p.pos[1] < @max[1] and p.pos[1] > @min[1] and
           p.pos[2] < @max[2] and p.pos[2] > @min[2]
             return { side: 'right', dist: p.t }

      # LEFT
      offset = @min[0]
      if pos[0] < offset
        offset *= -1
        p = getPointOnPlane(sideNormals.left, offset, pos, view)
        if p and
           p.pos[1] < @max[1] and p.pos[1] > @min[1] and
           p.pos[2] < @max[2] and p.pos[2] > @min[2]
             return { side: 'left', dist: p.t }

      # FRONT
      offset = @max[2]
      if pos[2] > offset
        p = getPointOnPlane(sideNormals.front, offset, pos, view)
        if p and
           p.pos[1] < @max[1] and p.pos[1] > @min[1] and
           p.pos[0] < @max[0] and p.pos[0] > @min[0]
             return { side: 'front', dist: p.t }


      # BACK
      offset = @min[2]
      if pos[2] < offset
        offset *= -1
        p = getPointOnPlane(sideNormals.back, offset, pos, view)
        if p and
           p.pos[1] < @max[1] and p.pos[1] > @min[1] and
           p.pos[0] < @max[0] and p.pos[0] > @min[0]
             return { side: 'back', dist: p.t }

      return false
