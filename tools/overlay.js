const fs = require("fs");
const color=208
const overlay = []

let d=1
let lastHit=false
const solidTile=5

for(let y=0; y<32; y++){
    for(let x=0; x<64; x++){
        if (y === 0 || y === 15) {
            overlay.push(solidTile,50)
        } else {
            overlay.push(0,0)
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
