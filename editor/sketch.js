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

var showText = false;
var selectedX = -1;
var selectedY = -1;

var isFilling = false;
var fillStart = []
var fillEnd = []

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

// for (let x = 0; x < WORLD_SIZE; x++) {
//   for (let y = 0; y < WORLD_SIZE; y++) {
//     for (let z = 0; z < WORLD_HEIGHT; z++) {
//       if (x == 0)
//         world[x][y][z] = TILE_CUBE;
//     }
//   }
// }

let font;

function preload() {
  font = loadFont("assets/Inconsolata-Black.ttf");
}

function setup() {
  var canvas = createCanvas(2 * 800, 800, WEBGL);
  canvas.parent('sketch-holder');

  xAngle = PI / 3.5;
  yAngle = 0;
  zAngle = PI / 4;

  textFont(font);
}

function drawSlope() {
  let zero = () => vertex(0, 0, 0);
  let one = () => vertex(0, 1, 0);
  let two = () => vertex(1, 0, 0);
  let three = () => vertex(1, 1, 0);
  let four = () => vertex(0, 0, 1);
  let five = () => vertex(0, 1, 1);
  let six = () => vertex(1, 0, 1);
  let seven = () => vertex(1, 1, 1);

  push();
  scale(TILE_SIZE);

  translate(-0.5, -0.5, -0.5);

  beginShape(TRIANGLES);

  zero(); six(); seven();
  zero(); one(); seven();
  three(); six(); seven();
  two(); three(); six();
  one(); three(); seven();
  zero(); two(); six();

  endShape(TRIANGLES);
  pop();
}

function drawTile(tile) {
  push();
  if (tile == TILE_AIR) {

  } else if (tile == TILE_CUBE) {
    box(TILE_SIZE);
  } else if (tile == TILE_SLOPE_RIGHT) {
    rotateZ(PI);
    drawSlope();
  } else if (tile == TILE_SLOPE_LEFT) {
    rotateZ(-PI / 2);
    drawSlope();
  } else {
    console.log("invalid tile type: " + tile)
  }
  pop();
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
  textSize(20);

  for (let z = 0; z < WORLD_HEIGHT; z++) {
    for (let x = 0; x < WORLD_SIZE; x++) {
      for (let y = 0; y < WORLD_SIZE; y++) {
        if (x == selectedX && y == selectedY && z == zLevel) {
          fill(0, 255, 0, 125);
        } else if (x == 0 && y == 0 && z == 0) {
          fill(255, 0, 0);
        } else {
          fill(255);
        }
        push();
        translate(x * TILE_SIZE, y * TILE_SIZE, z * TILE_SIZE);

        drawTile(world[x][y][z]);

        if (x == selectedX && y == selectedY && z == zLevel) {
          drawTile(selectedTileType);
        }

        if (showText && z == zLevel) {
          translate(0, 0, TILE_SIZE);
          fill(0);
          text(y + x * WORLD_SIZE, -TILE_SIZE / 2, TILE_SIZE / 4)
          fill(255);
        }

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
  textSize(24);

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

      if (showText) {
        fill(0);
        text(y + x * WORLD_SIZE + zLevel * WORLD_SIZE * WORLD_SIZE, (x + 0.25) * size, (y + 0.75) * size)
        fill(255);
      }
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

function exportWorld() {
  var output = `const worldData: array[${WORLD_SIZE*WORLD_SIZE*WORLD_HEIGHT}, uint8] = [`
  var firstTile = true;

  for (let z = 0; z < WORLD_HEIGHT; z++) {
    for (let x = 0; x < WORLD_SIZE; x++) {
      for (let y = 0; y < WORLD_SIZE; y++) {
        output += world[x][y][z]
        if (firstTile) {
          output += "'u8";
          firstTile = false;
        }
        let isLast = z == WORLD_HEIGHT - 1&& x == WORLD_SIZE - 1 && y == WORLD_SIZE - 1
        if (!isLast) {
          output += ", "
        } 
      }
    }
  }
  output += "]<br/>"
  output += `const worldXSize: int = ${WORLD_SIZE}<br/>`
  output += `const worldYSize: int = ${WORLD_SIZE}<br/>`
  output += `const worldZSize: int = ${WORLD_HEIGHT}<br/>`

  select("#exported").html(output);
}

function keyPressed() {
  if (key == 'q') {
    zLevel = max(zLevel - 1, 0);
  }

  if (key == 'e') {
    zLevel = min(zLevel + 1, WORLD_HEIGHT - 1);
  }

  if (key == 't') {
    showText = !showText;
  }

  if (key == 'f') {
    isFilling = true;
  }

  if ('0' <= key && key <= '9') {
    selectedTileType = keyCode - 48;
  }

  if (key == 'o') {
    exportWorld();
  }
}

function keyReleased() {

}

function mouseClicked() {
  if (isFilling) {
    if (selectedX >= 0 && selectedY >= 0) {
      if (fillStart.length == 0) {
        fillStart = [selectedX, selectedY, zLevel];
        console.log('START ' + fillStart);
      } else {
        fillEnd = [selectedX, selectedY, zLevel]
        console.log('END ' + fillEnd);

        let xMin = min(fillStart[0], fillEnd[0]);
        let yMin = min(fillStart[1], fillEnd[1]);
        let zMin = min(fillStart[2], fillEnd[2]);
        let xMax = max(fillStart[0], fillEnd[0]);
        let yMax = max(fillStart[1], fillEnd[1]);
        let zMax = max(fillStart[2], fillEnd[2]);
        for (let x = xMin; x <= xMax; x++) {
          for (let y = yMin; y <= yMax; y++) {
            for (let z = zMin; z <= zMax; z++) {
              world[x][y][z] = selectedTileType;
            }
          }

        }

        fillStart = [];
        fillEnd = [];
        isFilling = false;
      }
    }
  }
  else if (selectedX >= 0 && selectedY >= 0) {
    world[selectedX][selectedY][zLevel] = selectedTileType;
  }
}
