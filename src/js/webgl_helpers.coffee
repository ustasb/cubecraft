window.WebGLHelpers =
  # Prepares a WebGL texture
  handleLoadedTexture: (gl, glTexture, image) ->
    gl.bindTexture(gl.TEXTURE_2D, glTexture)
    gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, true)
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, image)
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST)
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST_MIPMAP_LINEAR)
    gl.generateMipmap(gl.TEXTURE_2D)
    gl.bindTexture(gl.TEXTURE_2D, null)

  initTexture: (gl, texturePath, onLoad) ->
    glTexture = gl.createTexture()
    image = new Image()
    image.onload = =>
      @handleLoadedTexture(gl, glTexture, image)
      onLoad(glTexture)
    image.src = texturePath

  # Returns a WebGL context
  getWebGLContext: (canvas) ->
    contextNames = ['experimental-webgl', 'webgl']

    for name in contextNames
      gl = canvas.getContext(name)
      break if gl

    if !gl
      alert 'Could not create a WebGL context!'
      return null

    gl

  # Returns a WebGL shader from an HTML element.
  getShaderFromDOM: (gl, elementID) ->
    el = document.getElementById(elementID)

    if !el
      alert "Element ##{elementID} could not be found!"
      return null

    shaderSource = el.textContent

    if el.type == 'shader-x/vertex'
      shader = gl.createShader(gl.VERTEX_SHADER)
    else if el.type == 'shader-x/fragment'
      shader = gl.createShader(gl.FRAGMENT_SHADER)

    gl.shaderSource(shader, shaderSource)
    gl.compileShader(shader)

    if !gl.getShaderParameter(shader, gl.COMPILE_STATUS)
      alert gl.getShaderInfoLog(shader)
      return null

    shader

  # Returns a WebGL program from a vertex and fragment shader.
  createProgram: (gl, vertexShader, fragmentShader) ->
    program = gl.createProgram()

    gl.attachShader(program, vertexShader)
    gl.attachShader(program, fragmentShader)
    gl.linkProgram(program)

    if !gl.getProgramParameter(program, gl.LINK_STATUS)
      alert gl.getProgramInfoLog(program)
      return null

    program
