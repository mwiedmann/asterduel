const fs = require("fs");
const color=208
const stars = []

let d=1
let lastHit=false
const solidTile=5
const leftBarrierTile=6
const rightBarrierTile=7

const ship1YStart= 5

for(let y=0; y<32; y++){
    for(let x=0; x<128; x++){
        // Solid tile on edges
        if (x===0 && y===ship1YStart+1) {
            stars.push(8,0)
            continue
        } else if (x===0 && y===ship1YStart+2) {
            stars.push(7,0)
            continue
        } else if (x===0 && y===ship1YStart+3) {
            stars.push(6,0)
            continue
        } else if (x===0 && y===ship1YStart+4) {
            stars.push(5,0)
            continue
        } else if (x===1 && y===ship1YStart-1) {
            stars.push(14,0)
            continue
        } else if (x===1 && y===ship1YStart) {
            stars.push(14,0)
            continue
        } else if (x===1 && y===ship1YStart+1) {
            stars.push(13,0)
            continue
        } else if (x===1 && y===ship1YStart+2) {
            stars.push(12,0)
            continue
        } else if (x===1 && y===ship1YStart+3) {
            stars.push(11,0)
            continue
        } else if (x===1 && y===ship1YStart+4) {
            stars.push(10,0)
            continue
        } else if (x===1 && y===ship1YStart+5) {
            stars.push(9,0)
            continue
        } else if (x===1 && y===ship1YStart+6) {
            stars.push(9,0)
            continue
        } else if (x===2 && y===ship1YStart-1) {
            stars.push(20,0)
            continue
        } else if (x===2 && y===ship1YStart) {
            stars.push(20,0)
            continue
        } else if (x===2 && y===ship1YStart+1) {
            stars.push(19,0)
            continue
        } else if (x===2 && y===ship1YStart+2) {
            stars.push(18,0)
            continue
        } else if (x===2 && y===ship1YStart+3) {
            stars.push(17,0)
            continue
        } else if (x===2 && y===ship1YStart+4) {
            stars.push(16,0)
            continue
        } else if (x===2 && y===ship1YStart+5) {
            stars.push(15,0)
            continue
        } else if (x===2 && y===ship1YStart+6) {
            stars.push(15,0)
            continue
        } else if (x===3 && y===ship1YStart+2) {
            stars.push(22,0)
            continue
        } else if (x===3 && y===ship1YStart+3) {
            stars.push(21,0)
            continue
        } else if (x===4 && y===ship1YStart+2) {
            stars.push(24,0)
            continue
        } else if (x===4 && y===ship1YStart+3) {
            stars.push(23,0)
            continue
        } else if (x===40) { // barriers
            stars.push(leftBarrierTile,0)
            continue
        } else if (x===87) { // barriers
            stars.push(rightBarrierTile,0)
            continue
        } 
        let n=0
        if (!lastHit && Math.random()*100 > 10) {
            n=d
            d++
            if (d==5) {
                d=1
            }
            lastHit=true
        } else {
            lastHit=false
        }
        stars.push(n,0)
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
//         } else {
//             data.push(stars[c],c===0 ? 0 : color)
//         }
        
//         // if (y===0) {
//         //     data.push(stars[c], 150)
//         // } else if(y===14) {
//         //     data.push(stars[c], 180)
//         // } 

//         c++
//     }
// }

// const data=stars.reduce((p,c)=> {
//     p.push(c,c===0 ? 0 : color)
//     return p
// },[])

output = new Uint8Array(stars);
fs.writeFileSync("build/FIELD.BIN", output, "binary");
