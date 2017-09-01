class window.GLCubeHelper
  @VERTEX_SIZE: 3
  @NORMAL_SIZE: 3
  @TEXTURE_COORD_SIZE: 2

  constructor: (@gl, @lightDirection, @lightColor, @ambientColor, onReady) ->
    vertexShader = WebGLHelpers.getShaderFromDOM(gl, 'cube-vertex')
    fragmentShader = WebGLHelpers.getShaderFromDOM(gl, 'cube-fragment')
    @program = WebGLHelpers.createProgram(gl, vertexShader, fragmentShader)

    vec3.normalize(@lightDirection, @lightDirection)
    vec3.scale(@lightDirection, @lightDirection, -1)

    # Get all attribute locations
    @program.vertexPosLocation = gl.getAttribLocation(@program, 'a_vertexPos')
    @program.vertexTextureLocation = gl.getAttribLocation(@program, 'a_textureCoord')
    @program.vertexNormalLocation = @gl.getAttribLocation(@program, 'a_vertexNormal')
    # Enable feeding data via array buffers
    gl.enableVertexAttribArray(@program.vertexPosLocation)
    gl.enableVertexAttribArray(@program.vertexTextureLocation)
    gl.enableVertexAttribArray(@program.vertexNormalLocation)

    # Get all uniform locations
    @program.mvMatrixLocation = gl.getUniformLocation(@program, 'u_mvMatrix')
    @program.pMatrixLocation = gl.getUniformLocation(@program, 'u_pMatrix')
    @program.nMatrixLocation = gl.getUniformLocation(@program, 'u_nMatrix')
    @program.samplerLocation = gl.getUniformLocation(@program, 'u_sampler')
    @program.ambientColorLocation = gl.getUniformLocation(@program, 'u_ambientColor')
    @program.lightingDirectionLocation = gl.getUniformLocation(@program, 'u_lightingDirection')
    @program.directionalColorLocation = gl.getUniformLocation(@program, 'u_directionalColor')

    WebGLHelpers.initTexture gl, 'img/textures/stonebricksmooth_carved.png', (glTexture) =>
      @texture = glTexture
      onReady(this)

  draw: (mvMatrix, pMatrix, vertexPosBuffer, indexBuffer, textureCoordBuffer, normalBuffer) ->
    @gl.useProgram(@program)

    # Upload uniform matrices to shaders
    @gl.uniformMatrix4fv(@program.mvMatrixLocation, false, mvMatrix)
    @gl.uniformMatrix4fv(@program.pMatrixLocation, false, pMatrix)

    # http://learningwebgl.com/blog/?p=684
    normalMatrix = mat3.create()
    mat3.fromMat4(normalMatrix, mvMatrix)
    mat3.invert(normalMatrix, normalMatrix)
    mat3.transpose(normalMatrix, normalMatrix)
    @gl.uniformMatrix3fv(@program.nMatrixLocation, false, normalMatrix)

    @gl.bindBuffer(@gl.ARRAY_BUFFER, vertexPosBuffer)
    @gl.vertexAttribPointer(@program.vertexPosLocation, GLCubeHelper.VERTEX_SIZE, @gl.FLOAT, false, 0, 0)

    @gl.bindBuffer(@gl.ARRAY_BUFFER, normalBuffer)
    @gl.vertexAttribPointer(@program.vertexNormalLocation, GLCubeHelper.NORMAL_SIZE, @gl.FLOAT, false, 0, 0)

    @gl.bindBuffer(@gl.ARRAY_BUFFER, textureCoordBuffer)
    @gl.vertexAttribPointer(@program.vertexTextureLocation, GLCubeHelper.TEXTURE_COORD_SIZE, @gl.FLOAT, false, 0, 0)

    # Upload light attributes
    @gl.uniform3fv(@program.lightingDirectionLocation, @lightDirection)
    @gl.uniform3f(@program.directionalColorLocation, @lightColor...)
    @gl.uniform3f(@program.ambientColorLocation, @ambientColor...)

    # Bind active texture
    @gl.activeTexture(@gl.TEXTURE0)
    @gl.bindTexture(@gl.TEXTURE_2D, @texture)
    @gl.uniform1i(@program.samplerUniform, 0)

    @gl.bindBuffer(@gl.ELEMENT_ARRAY_BUFFER, indexBuffer)
    @gl.drawElements(@gl.TRIANGLES, indexBuffer.numItems, @gl.UNSIGNED_SHORT, 0)

  getGLBufferFromArray: (array, indexBuffer = false) ->
    newBuffer = @gl.createBuffer()

    if indexBuffer
      @gl.bindBuffer(@gl.ELEMENT_ARRAY_BUFFER, newBuffer)
      @gl.bufferData(@gl.ELEMENT_ARRAY_BUFFER, new Uint16Array(array), @gl.STATIC_DRAW)
    else
      @gl.bindBuffer(@gl.ARRAY_BUFFER, newBuffer)
      @gl.bufferData(@gl.ARRAY_BUFFER, new Float32Array(array), @gl.STATIC_DRAW)

    newBuffer


  # Modifies the incoming array with new, shifted vertices for a cube
  addVerticesAtPos: (array, x, y, z, w = 1, faces = { all: true }) ->
    w /= 2  # The x, y, z positions are at the center of the cube
    addedVertices = 0

    if faces['front'] or faces['all']
      addedVertices += 4
      array.push(
        -w+x, -w+y,  w+z
         w+x, -w+y,  w+z
         w+x,  w+y,  w+z
        -w+x,  w+y,  w+z)

    if faces['back'] or faces['all']
      addedVertices += 4
      array.push(
        -w+x, -w+y, -w+z
        -w+x,  w+y, -w+z
         w+x,  w+y, -w+z
         w+x, -w+y, -w+z)

    if faces['top'] or faces['all']
      addedVertices += 4
      array.push(
        -w+x,  w+y, -w+z
        -w+x,  w+y,  w+z
         w+x,  w+y,  w+z
         w+x,  w+y, -w+z)

    if faces['bottom'] or faces['all']
      addedVertices += 4
      array.push(
        -w+x, -w+y, -w+z
         w+x, -w+y, -w+z
         w+x, -w+y,  w+z
        -w+x, -w+y,  w+z)

    if faces['right'] or faces['all']
      addedVertices += 4
      array.push(
         w+x, -w+y, -w+z
         w+x,  w+y, -w+z
         w+x,  w+y,  w+z
         w+x, -w+y,  w+z)

    if faces['left'] or faces['all']
      addedVertices += 4
      array.push(
        -w+x, -w+y, -w+z
        -w+x, -w+y,  w+z
        -w+x,  w+y,  w+z
        -w+x,  w+y, -w+z)

    addedVertices

  # Modifies the incoming array with new vertex normals for a cube
  addVertexNormals: (array, faces = { all: true }) ->
    addedNormals = 0

    if faces['front'] or faces['all']
      addedNormals += 4
      array.push(
       0.0,  0.0,  1.0
       0.0,  0.0,  1.0
       0.0,  0.0,  1.0
       0.0,  0.0,  1.0)

    if faces['back'] or faces['all']
      addedNormals += 4
      array.push(
        0.0,  0.0, -1.0
        0.0,  0.0, -1.0
        0.0,  0.0, -1.0
        0.0,  0.0, -1.0)

    if faces['top'] or faces['all']
      addedNormals += 4
      array.push(
        0.0,  1.0,  0.0
        0.0,  1.0,  0.0
        0.0,  1.0,  0.0
        0.0,  1.0,  0.0)

    if faces['bottom'] or faces['all']
      addedNormals += 4
      array.push(
        0.0, -1.0,  0.0
        0.0, -1.0,  0.0
        0.0, -1.0,  0.0
        0.0, -1.0,  0.0)

    if faces['right'] or faces['all']
      addedNormals += 4
      array.push(
        1.0,  0.0,  0.0
        1.0,  0.0,  0.0
        1.0,  0.0,  0.0
        1.0,  0.0,  0.0)

    if faces['left'] or faces['all']
      addedNormals += 4
      array.push(
        -1.0,  0.0,  0.0
        -1.0,  0.0,  0.0
        -1.0,  0.0,  0.0
        -1.0,  0.0,  0.0)

    addedNormals

  # Modifies the incoming array with new UV mappings for a cube
  addTextureCoords: (array, faces = { all: true })->

    if faces['front'] or faces['all']
      array.push(
        0.0, 0.0
        1.0, 0.0
        1.0, 1.0
        0.0, 1.0)

    # Back face
    if faces['back'] or faces['all']
      array.push(
        1.0, 0.0
        1.0, 1.0
        0.0, 1.0
        0.0, 0.0)

    # Top face
    if faces['top'] or faces['all']
      array.push(
        0.0, 1.0
        0.0, 0.0
        1.0, 0.0
        1.0, 1.0)

    # Bottom face
    if faces['bottom'] or faces['all']
      array.push(
        1.0, 1.0
        0.0, 1.0
        0.0, 0.0
        1.0, 0.0)

    if faces['right'] or faces['all']
      array.push(
        1.0, 0.0
        1.0, 1.0
        0.0, 1.0
        0.0, 0.0)

    if faces['left'] or faces['all']
      array.push(
        0.0, 0.0
        1.0, 0.0
        1.0, 1.0
        0.0, 1.0)

  # Each indice corresponds to a vertex. Allows for vertex reuse.
  # o is the offset
  addVertexIndices: (array, o = 0, faces = { all: true }) ->
    addedIndices = 0
    indices = [
      [o+0,  o+1,  o+2,  o+0,  o+2,  o+3]
      [o+4,  o+5,  o+6,  o+4,  o+6,  o+7]
      [o+8,  o+9,  o+10, o+8,  o+10, o+11]
      [o+12, o+13, o+14, o+12, o+14, o+15]
      [o+16, o+17, o+18, o+16, o+18, o+19]
      [o+20, o+21, o+22, o+20, o+22, o+23]
    ]

    if faces['front'] or faces['all']
      array.push indices[addedIndices / 6]...
      addedIndices += 6

    if faces['back'] or faces['all']
      array.push indices[addedIndices / 6]...
      addedIndices += 6

    if faces['top'] or faces['all']
      array.push indices[addedIndices / 6]...
      addedIndices += 6

    if faces['bottom'] or faces['all']
      array.push indices[addedIndices / 6]...
      addedIndices += 6

    if faces['right'] or faces['all']
      array.push indices[addedIndices / 6]...
      addedIndices += 6

    if faces['left'] or faces['all']
      array.push indices[addedIndices / 6]...
      addedIndices += 6

    addedIndices
