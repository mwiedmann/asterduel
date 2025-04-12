const fs = require("fs");
const color=208
const overlay = []

let d=1
let lastHit=false
const solidTile=5
const baseStart=5
const baseTiles=[1,0,18,4,52]
const shieldStart=15
const shieldTiles=[18,7,8,4,11,3,52]
for(let y=0; y<32; y++){
    for(let x=0; x<64; x++){
        if (y === 0 || y === 15) {
            if (x>=baseStart && x<baseStart+baseTiles.length) {
                overlay.push(baseTiles[x-baseStart],0)
            } else if (x>=shieldStart && x<shieldStart+shieldTiles.length) {
                overlay.push(shieldTiles[x-shieldStart],0)
            } else {
                overlay.push(59,0)
            }
        } else {
            overlay.push(58,0)
        }
    }
}

//console.log(stars)

// let data=[]
// let c=0
// for(let y=0; y<32; y++){
//     for(let x=0; x<128; x++){
//         // Solid tile on edges
//         if (x===0) {
//             data.push(stars[c], 50)
//         } else if(x===127) {
//             data.push(stars[c], 100)
//         } else if (y===0) {
//             data.push(stars[c], 150)
//         } else if(y===14) {
//             data.push(stars[c], 180)
//         } else {
//             data.push(stars[c],c===0 ? 0 : color)
//         }

//         c++
//     }
// }

// const data=stars.reduce((p,c)=> {
//     p.push(c,c===0 ? 0 : color)
//     return p
// },[])

output = new Uint8Array(overlay);
fs.writeFileSync("build/OVERLAY.BIN", output, "binary");
