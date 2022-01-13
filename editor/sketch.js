const TILE_SIZE = 25;
var WORLD_SIZE = 10;
var WORLD_HEIGHT = 5;

var xAngle = 0;
var yAngle = 0;
var zAngle = 0;
var zLevel = 0;

const TILE_AIR = 0;
const TILE_CUBE = 1;
const TILE_SLOPE_FRONT = 2;
const TILE_SLOPE_RIGHT = 3;
const TILE_SLOPE_LEFT = 4;
const TILE_SLOPE_BACK = 5;
const TILE_MIRROR_FRONT = 6;
const TILE_MIRROR_RIGHT = 7;
const TILE_MIRROR_LEFT = 8;
const TILE_MIRROR_BACK = 9;
const TILE_PUNCH_FRONT = 10;
const TILE_PUNCH_RIGHT = 11;
const TILE_PUNCH_LEFT = 12;
const TILE_PUNCH_BACK = 13;
const TILE_ICE = 14;
const TILE_STARTING = 15;
const TILE_ENDING = 16;

var selectingTileTypeButtons = []
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

  for (let i = TILE_AIR; i <= TILE_ENDING; ++i) {
    var button = createButton(tileToString(i));
    button.position(3 * width / 4, i * 25 + height / 4);
    button.mouseClicked(() => selectedTileType = i);
    selectingTileTypeButtons.push(button);
  }
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

function drawPunch() {
  scale(0.3);
  rotateZ(PI/2);
  cone(40, 70);
}

function drawTile(tile) {
  push();
  if (tile == TILE_AIR) {
    // don't render air
  } else if (tile == TILE_CUBE) {
    box(TILE_SIZE);
  } else if (tile == TILE_SLOPE_RIGHT) {
    rotateZ(PI);
    drawSlope();
  } else if (tile == TILE_SLOPE_FRONT) {
    rotateZ(-PI / 2);
    drawSlope();
  } else if (tile == TILE_SLOPE_LEFT) {
    rotateZ(0);
    drawSlope();
  } else if (tile == TILE_SLOPE_BACK) {
    rotateZ(-3 * PI / 2);
    drawSlope();
  } else if (tile == TILE_MIRROR_FRONT) {
    rotateX(3 * PI / 2);
    rotateY(PI / 2);
    drawSlope();
  } else if (tile == TILE_MIRROR_RIGHT) {
    rotateX(PI / 2);
    rotateY(PI / 2);
    drawSlope();
  } else if (tile == TILE_MIRROR_LEFT) {
    rotateX(PI / 2);
    rotateY(-PI / 2);
    drawSlope();
  } else if (tile == TILE_MIRROR_BACK) {
    rotateX(PI / 2);
    rotateY(-4*PI/2);
    drawSlope();
  } else if (tile == TILE_PUNCH_FRONT) {
    rotateX(3 * PI / 2);
    rotateY(PI / 2);
    drawPunch();
  } else if (tile == TILE_PUNCH_RIGHT) {
    rotateX(PI / 2);
    rotateY(-2*PI/2);
    drawPunch();
  } else if (tile == TILE_PUNCH_LEFT) {
    rotateX(PI / 2);
    rotateY(-4*PI/2);
    drawPunch();
  } else if (tile == TILE_PUNCH_BACK) {
    rotateX(PI / 2);
    rotateY(PI / 2);
    drawPunch();
  } else if (tile == TILE_ICE) {
    fill(127, 127, 255);
    box(TILE_SIZE);
  } else if (tile == TILE_STARTING) {
    fill(0, 255, 0);
    box(TILE_SIZE);
  } else if (tile == TILE_ENDING) {
    fill(255, 0, 0);
    box(TILE_SIZE);
  } else {
    console.log("invalid tile type: " + tile)
  }
  pop();
}

function showZLevel() {
  select("#zLevel").html("ZLevel: " + zLevel);
}

function tileToString(tile) {
  var asString = "";
  if (tile == TILE_AIR)
    asString = "AIR";
  else if (tile == TILE_CUBE)
    asString = "CUBE";
  else if (tile == TILE_SLOPE_FRONT)
    asString = "SLOPE_FRONT";
  else if (tile == TILE_SLOPE_RIGHT)
    asString = "SLOPE_RIGHT";
  else if (tile == TILE_SLOPE_LEFT)
    asString = "SLOPE_LEFT";
  else if (tile == TILE_SLOPE_BACK)
    asString = "SLOPE_BACK";
  else if (tile == TILE_MIRROR_FRONT)
    asString = "TILE_MIRROR_FRONT"
  else if (tile == TILE_MIRROR_RIGHT)
    asString = "TILE_MIRROR_RIGHT"
  else if (tile == TILE_MIRROR_LEFT)
    asString = "TILE_MIRROR_LEFT"
  else if (tile == TILE_MIRROR_BACK)
    asString = "TILE_MIRROR_BACK"
  else if (tile == TILE_PUNCH_FRONT)
    asString = "TILE_PUNCH_FRONT"
  else if (tile == TILE_PUNCH_RIGHT)
    asString = "TILE_PUNCH_RIGHT"
  else if (tile == TILE_PUNCH_LEFT)
    asString = "TILE_PUNCH_LEFT"
  else if (tile == TILE_PUNCH_BACK)
    asString = "TILE_PUNCH_BACK"
  else if (tile == TILE_ICE)
    asString = "TILE_ICE"
  else if (tile == TILE_STARTING)
    asString = "TILE_STARTING"
  else if (tile == TILE_ENDING)
    asString = "TILE_ENDING"
  else
    console.log("asString invalid tileType: " + tile);
  return asString;
}

function showTileType() {
  let asString = tileToString(selectedTileType);
  select("#tileType").html("TyleType: " + asString);
}

function view() {
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

  perspective();

  translate(0, -0.6 * WORLD_SIZE * TILE_SIZE, 0);
  rotateX(xAngle);
  rotateY(yAngle);
  rotateZ(zAngle);
  textSize(20);

  for (let z = 0; z < WORLD_HEIGHT; z++) {
    for (let x = 0; x < WORLD_SIZE; x++) {
      for (let y = 0; y < WORLD_SIZE; y++) {
        if (x == selectedX && y == selectedY && z == zLevel) {
          fill(252, 171, 251, 125);
        } else {
          fill(255);
        }
        push();
        translate(x * TILE_SIZE, y * TILE_SIZE, z * TILE_SIZE);

        drawTile(world[x][y][z]);

        if (x == selectedX && y == selectedY && z == zLevel) {
          if (selectedTileType == TILE_AIR) {
            box(TILE_SIZE);
          } else {
            drawTile(selectedTileType);
          }
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
        fill(252, 171, 251);
        selectedX = x;
        selectedY = y;
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

function getTileSymbols() {
  let out = [];
  for (let i = 0; i <= 16; ++i) {
    out.push(i);
  }
  return out;
}

function getProbabilities(symbols, data) {
  return []; // TODO
}

function zip(xs, ys) {
  return xs.map((x, i) => [x, ys[i]]);
}

function popNextNode(q1, q2) {
  let x = [Infinity, Infinity];
  let y = [Infinity, Infinity];

  if (q1.length > 0) {
    x = q1[0];
  }
  if (q2.length > 0) {
    y = q2[0];
  }

  if (x[1] < y[1]) {
    return [x, q1.slice(1), q2];
  } else {
    return [y, q1, q2.slice(1)];
  }
}

function huffmanCode(symbols, probs) {
  let nodes = zip(symbols, probs);
  nodes.sort((a, b) => a[1] - b[1]);
  let q1 = []
  let q2 = []
  for (let i = 0; i < nodes.length; ++i) {
    q1.push(nodes[i]);
  }
  
  while (q1.length + q2.length > 1) {
    let x, q1_prime, q2_prime, y, q1_prime_prime, q2_prime_prime
    [x, q1_prime, q2_prime] = popNextNode(q1, q2);
    [y, q1_prime_prime, q2_prime_prime] = popNextNode(q1_prime, q2_prime);
    let n;

    if (Array.isArray(x[0])) {
      n = [[y[0], x[0]], x[1] + y[1]]
    } else {
      n = [[x[0], y[0]], x[1] + y[1]]
    }

    q1 = q1_prime_prime;
    q2 = q2_prime_prime;

    q2.push(n);
  }

  let root = popNextNode(q1, q2)[0][0];
  return root;
}

function flattenCodec(codec, output=[]) {
  output.push(codec[0]);
  if (Array.isArray(codec[1]))
    output = output.concat(flattenCodec(codec[1]));
  else
    output.push(codec[1]);
  return output;
}

function exportWorld() {
  let codec = huffmanCode(['a', 'b', 'c', 'd'], [0.40, 0.3, 0.4, 0.05]);
  console.log(codec);
  console.log(flattenCodec(codec));

  var output = "";
  output += "import ../../components/worldtilecomponent<br/><br/>"
  output += `const worldXSize: int8 = ${WORLD_SIZE}<br/>`
  output += `const worldYSize: int8 = ${WORLD_SIZE}<br/>`
  output += `const worldZSize: int8 = ${WORLD_HEIGHT}<br/>`
  output += `const worldData: array[${WORLD_SIZE * WORLD_SIZE * WORLD_HEIGHT}, uint8] = [`

  var firstTile = true;

  for (let z = 0; z < WORLD_HEIGHT; z++) {
    for (let x = 0; x < WORLD_SIZE; x++) {
      for (let y = 0; y < WORLD_SIZE; y++) {
        output += world[x][y][z]
        if (firstTile) {
          output += "'u8";
          firstTile = false;
        }
        let isLast = z == WORLD_HEIGHT - 1 && x == WORLD_SIZE - 1 && y == WORLD_SIZE - 1
        if (!isLast) {
          output += ", "
        }
      }
    }
  }
  output += "]<br/><br/>"
  output += "makeLevel(TODO_INSERT_LEVEL_NAME)<br/><br/>"

  select("#exported").html(output);
}

function saveLevel() {
  select('#saveLevel').html(JSON.stringify({ world, WORLD_SIZE, WORLD_HEIGHT }))
}

function levelLoad() {
  var code = select('#levelLoad').value();
  var loaded = JSON.parse(code);
  world = loaded["world"];
  WORLD_SIZE = loaded["WORLD_SIZE"];
  WORLD_HEIGHT = loard["WORLD_HEIGHT"];
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

  if (key == 'r') {
    xAngle = PI / 3.5;
    yAngle = 0;
    zAngle = PI / 4;
  }

  if (key == 'f') {
    isFilling = true;
  }

  if ('0' <= key && key <= '9') {
    selectedTileType = keyCode - 48;
  }

  if (key == 'o') {
    exportWorld();
    saveLevel();
  }

  if (key == 'l') {
    levelLoad();
  }
}

function mouseClicked() {
  if (isFilling) {
    if (selectedX >= 0 && selectedY >= 0) {
      if (fillStart.length == 0) {
        fillStart = [selectedX, selectedY, zLevel];
      } else {
        fillEnd = [selectedX, selectedY, zLevel]

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
