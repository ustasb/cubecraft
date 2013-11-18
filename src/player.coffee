# Represents the camera
window.Player =
  SPEED: 0.2

  look: [0, -0.2, 1]
  pos: [25, 15, 0]
  up: [0, 1, 0]

  # World -> Camera
  viewMatrix: mat4.create()

  update: ->
    vec3.normalize(@look, @look)
    forward = vec3.clone(@look)

    strafe = vec3.cross([], @up, @look)
    vec3.normalize(strafe, strafe)

    rotateMatrix = mat4.create()
    # Yaw
    mat4.rotate(rotateMatrix, rotateMatrix, -Cubecraft.mouse_movement.x / Cubecraft.MOUSE_DAMPER, @up)
    # Pitch
    mat4.rotate(rotateMatrix, rotateMatrix, Cubecraft.mouse_movement.y / Cubecraft.MOUSE_DAMPER, strafe)
    vec3.transformMat4(@look, @look, rotateMatrix)

    Cubecraft.mouse_movement.x = 0
    Cubecraft.mouse_movement.y = 0

    # Forward
    if Cubecraft.keysPressed[Cubecraft.KEY_CODES.w]
      vec3.scale(forward, forward, @SPEED)
      vec3.add(@pos, @pos, forward)
    # Backwards
    else if Cubecraft.keysPressed[Cubecraft.KEY_CODES.s]
      vec3.scale(forward, forward, -@SPEED)
      vec3.add(@pos, @pos, forward)

    # Strafe left
    if Cubecraft.keysPressed[Cubecraft.KEY_CODES.a]
      vec3.scale(strafe, strafe, @SPEED)
      vec3.add(@pos, @pos, strafe)
    # Strafe right
    else if Cubecraft.keysPressed[Cubecraft.KEY_CODES.d]
      vec3.scale(strafe, strafe, -@SPEED)
      vec3.add(@pos, @pos, strafe)

    # Jet Pack
    if Cubecraft.keysPressed[Cubecraft.KEY_CODES.SPACE]
      vec3.add(@pos, @pos, vec3.scale([], @up, @SPEED))
    # Fall with aggression...
    else if Cubecraft.keysPressed[Cubecraft.KEY_CODES.SHIFT]
      vec3.add(@pos, @pos, vec3.scale([], @up, -@SPEED))

    # Update the view matrix
    lookPoint = vec3.add([], @pos, @look)
    mat4.lookAt(@viewMatrix, @pos, lookPoint, @up)
