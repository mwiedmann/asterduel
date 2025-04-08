const fs = require("fs");

const inputFile = process.argv[2];
const outputFile = process.argv[3];

const frameWidth = process.argv[4];
const frameHeight = process.argv[5];
const frameCountWidth = process.argv[6]; // how many frames per row in image for this frame size
const startingTile = process.argv[7];
const xTiles = process.argv[8];
const yTiles = process.argv[9];
const tileCount = process.argv[10] || xTiles * yTiles;
console.log('tileCount',tileCount)
const imageData = [...fs.readFileSync(inputFile)].slice(startingTile * frameWidth * frameHeight);

const flattenedTiles = [];

let ty, tx, y, x, start, pixelIdx;
let tilesDone=0

for (ty = 0; ty < yTiles && tilesDone<tileCount; ty++) {
  for (tx = 0; tx < xTiles && tilesDone<tileCount; tx++) {
    for (y = 0; y < frameHeight && tilesDone<tileCount; y++) {
      start =
        ty * frameCountWidth * frameWidth * frameHeight +
        tx * frameWidth +
        y * frameCountWidth * frameWidth;
      for (x = 0; x < frameWidth; x++) {
        pixelIdx = start + x;
        flattenedTiles.push(imageData[pixelIdx]);
      }
    }
    tilesDone++
  }
}

output = new Uint8Array([...flattenedTiles]);
fs.writeFileSync(outputFile, output, "binary");

console.log(`Generated file ${outputFile}`);
