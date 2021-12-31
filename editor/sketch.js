const TILE_SIZE = 25;
const WORLD_SIZE = 10;
const WORLD_HEIGHT = 5;

var xAngle = 0;
var yAngle = 0;
var zAngle = 0;
var zLevel = 0;

const TILE_AIR = 0;
const TILE_CUBE = 1;
const TILE_SLOPE_LEFT = 2;
const TILE_SLOPE_RIGHT = 3;
var selectedTileType = TILE_CUBE;

var selectedX = -1;
var selectedY = -1;

var world = new Array();
for (let x = 0; x < WORLD_SIZE; x++) {
  world.push(new Array());
  for (let y = 0; y < WORLD_SIZE; y++) {
    world[x].push(new Array());
    for (let z = 0; z < WORLD_HEIGHT; z++) {
      world[x][y].push(TILE_AIR);
    }
  }
}

for (let x = 0; x < WORLD_SIZE; x++) {
  for (let y = 0; y < WORLD_SIZE; y++) {
    for (let z = 0; z < WORLD_HEIGHT; z++) {
      world[x][y][z] = TILE_SLOPE_RIGHT;
    }
  }
}

function setup() {
  createCanvas(2 * 800, 800, WEBGL);
  xAngle = PI / 3.5;
  yAngle = 0;
  zAngle = PI / 4;
}

function drawSlope() {
  scale(TILE_SIZE);

  translate(-0.5, -0.5, -0.5);

  beginShape();
  vertex(0, 0, 0);
  vertex(0, 1, 0);
  vertex(1, 1, 0);
  vertex(1, 0, 0);
  vertex(0, 0, 0);
  endShape(CLOSE);

  beginShape();
  vertex(0, 0, 1);
  vertex(0, 1, 0);
  vertex(1, 1, 0);
  vertex(1, 0, 1);
  vertex(0, 0, 1);
  endShape(CLOSE);

  beginShape();
  vertex(0, 0, 0);
  vertex(1, 0, 0);
  vertex(1, 0, 1);
  vertex(0, 0, 1);
  vertex(0, 0, 0);
  endShape(CLOSE);

  beginShape();
  vertex(0, 0, 0);
  vertex(0, 1, 0);
  vertex(0, 0, 1);
  vertex(0, 0, 0);
  endShape(CLOSE);

  beginShape();
  vertex(1, 0, 0);
  vertex(1, 1, 0);
  vertex(1, 0, 1);
  vertex(1, 0, 0);
  endShape(CLOSE);
}

function drawTile(tile) {
  if (tile == TILE_AIR) {

  } else if (tile == TILE_CUBE) {
    box(TILE_SIZE);
  } else if (tile == TILE_SLOPE_LEFT) {
    drawSlope();
  } else if (tile == TILE_SLOPE_RIGHT) {
    rotateZ(-PI / 2);
    drawSlope();
  } else {
    console.log("invalid tile type: " + tile)
  }
}

function showZLevel() {
  select("#zLevel").html("ZLevel: " + zLevel);
}

function showTileType() {
  var asString = "";
  if (selectedTileType == TILE_AIR)
    asString = "AIR";
  else if (selectedTileType == TILE_CUBE)
    asString = "CUBE";
  else if (selectedTileType == TILE_SLOPE_LEFT)
    asString = "SLOPE_LEFT";
  else if (selectedTileType == TILE_SLOPE_RIGHT)
    asString = "SLOPE_RIGHT";
  else
    console.log("asString invalid tileType: " + selectedTileType);
  select("#tileType").html("TyleType: " + asString);
}

function view() {
  perspective();
  // w
  if (keyIsDown(87)) {
    xAngle -= 0.01;
  }
  // a
  if (keyIsDown(65)) {
    zAngle -= 0.01;
  }
  // s
  if (keyIsDown(83)) {
    xAngle += 0.01;
  }
  // d
  if (keyIsDown(68)) {
    zAngle += 0.01;
  }

  translate(0, -0.6 * WORLD_SIZE * TILE_SIZE, 0);
  rotateX(xAngle);
  rotateY(yAngle);
  rotateZ(zAngle);

  for (let z = 0; z < WORLD_HEIGHT; z++) {
    if (z >= zLevel + 1) {
      continue;
    }
    for (let x = 0; x < WORLD_SIZE; x++) {
      for (let y = 0; y < WORLD_SIZE; y++) {
        if (x == 0 && y == 0 && z == 0) {
          fill(255, 0, 0);
        } else {
          fill(255);
        }
        push();
        translate(x * TILE_SIZE, y * TILE_SIZE, z * TILE_SIZE);

        drawTile(world[x][y][z]);

        pop();
      }
    }
  }
}

function edit() {
  push();
  ortho();

  translate(-width / 2, -height / 2);

  selectedX = -1;
  selectedY = -1;

  for (let x = 0; x < WORLD_SIZE; x++) {
    for (let y = 0; y < WORLD_SIZE; y++) {
      const xPos = mouseX;
      const yPos = mouseY;
      const size = TILE_SIZE * 2;

      if (x * size < xPos && xPos < (x + 1) * size
        && y * size < yPos && yPos < (y + 1) * size) {
        fill(0, 255, 0);
        selectedX = x;
        selectedY = y;
      } else if (x == 0 && y == 0) {
        fill(255, 0, 0);
      } else {
        fill(255);
      }

      push();
      translate(x * size, y * size, 0);

      rect(0, 0, size, size)

      pop();
    }
  }
  pop();
}

function draw() {
  background(200);

  edit();
  view();

  showZLevel();
  showTileType();
}

function keyPressed() {
  if (key == 'q') {
    zLevel = max(zLevel - 1, 0);
  }

  if (key == 'e') {
    zLevel = min(zLevel + 1, WORLD_HEIGHT - 1);
  }
}

function keyReleased() {

}

function mouseClicked() {
  if (selectedX >= 0 && selectedY >= 0) {
    world[selectedX][selectedY][zLevel] = selectedTileType;
    console.log("Setting (" + selectedX + ", " + selectedY + ", " + zLevel + ") to " + selectedTileType);
  }
}
