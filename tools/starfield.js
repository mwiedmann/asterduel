const fs = require("fs");
const color=208
const stars = []

let d=1
let lastHit=false

const shipYStart= 5
const ship2XStart=127
const ship2TileOffset=21
const leftBarrierTile=47
const rightBarrierTile=48

const checkBase1 = (stars,x,y) => {
    if (x===0 && y===shipYStart+1) {
        stars.push(8,0)
        return true
    } else if (x===0 && y===shipYStart+2) {
        stars.push(7,0)
        return true
    } else if (x===0 && y===shipYStart+3) {
        stars.push(6,0)
        return true
    } else if (x===0 && y===shipYStart+4) {
        stars.push(5,0)
        return true
    } else if (x===1 && y===shipYStart-1) {
        stars.push(14,0)
        return true
    } else if (x===1 && y===shipYStart) {
        stars.push(14,0)
        return true
    } else if (x===1 && y===shipYStart+1) {
        stars.push(13,0)
        return true
    } else if (x===1 && y===shipYStart+2) {
        stars.push(12,0)
        return true
    } else if (x===1 && y===shipYStart+3) {
        stars.push(11,0)
        return true
    } else if (x===1 && y===shipYStart+4) {
        stars.push(10,0)
        return true
    } else if (x===1 && y===shipYStart+5) {
        stars.push(9,0)
        return true
    } else if (x===1 && y===shipYStart+6) {
        stars.push(9,0)
        return true
    } else if (x===2 && y===shipYStart-1) {
        stars.push(20,0)
        return true
    } else if (x===2 && y===shipYStart) {
        stars.push(20,0)
        return true
    } else if (x===2 && y===shipYStart+1) {
        stars.push(19,0)
        return true
    } else if (x===2 && y===shipYStart+2) {
        stars.push(18,0)
        return true
    } else if (x===2 && y===shipYStart+3) {
        stars.push(17,0)
        return true
    } else if (x===2 && y===shipYStart+4) {
        stars.push(16,0)
        return true
    } else if (x===2 && y===shipYStart+5) {
        stars.push(15,0)
        return true
    } else if (x===2 && y===shipYStart+6) {
        stars.push(15,0)
        return true
    } else if (x===3 && y===shipYStart+2) {
        stars.push(22,0)
        return true
    } else if (x===3 && y===shipYStart+3) {
        stars.push(21,0)
        return true
    } else if (x===4 && y===shipYStart+2) {
        stars.push(24,0)
        return true
    } else if (x===4 && y===shipYStart+3) {
        stars.push(23,0)
        return true
    } else if (x<=1) {
        stars.push(25,0)
        return true
    } 

    return false
}

const checkBase2 = (stars,x,y) => {
    if (x===ship2XStart && y===shipYStart+1) {
        stars.push(ship2TileOffset+8,0)
        return true
    } else if (x===ship2XStart && y===shipYStart+2) {
        stars.push(ship2TileOffset+7,0)
        return true
    } else if (x===ship2XStart && y===shipYStart+3) {
        stars.push(ship2TileOffset+6,0)
        return true
    } else if (x===ship2XStart && y===shipYStart+4) {
        stars.push(ship2TileOffset+5,0)
        return true
    } else if (x===ship2XStart-1 && y===shipYStart-1) {
        stars.push(ship2TileOffset+14,0)
        return true
    } else if (x===ship2XStart-1 && y===shipYStart) {
        stars.push(ship2TileOffset+14,0)
        return true
    } else if (x===ship2XStart-1 && y===shipYStart+1) {
        stars.push(ship2TileOffset+13,0)
        return true
    } else if (x===ship2XStart-1 && y===shipYStart+2) {
        stars.push(ship2TileOffset+12,0)
        return true
    } else if (x===ship2XStart-1 && y===shipYStart+3) {
        stars.push(ship2TileOffset+11,0)
        return true
    } else if (x===ship2XStart-1 && y===shipYStart+4) {
        stars.push(ship2TileOffset+10,0)
        return true
    } else if (x===ship2XStart-1 && y===shipYStart+5) {
        stars.push(ship2TileOffset+9,0)
        return true
    } else if (x===ship2XStart-1 && y===shipYStart+6) {
        stars.push(ship2TileOffset+9,0)
        return true
    } else if (x===ship2XStart-2 && y===shipYStart-1) {
        stars.push(ship2TileOffset+20,0)
        return true
    } else if (x===ship2XStart-2 && y===shipYStart) {
        stars.push(ship2TileOffset+20,0)
        return true
    } else if (x===ship2XStart-2 && y===shipYStart+1) {
        stars.push(ship2TileOffset+19,0)
        return true
    } else if (x===ship2XStart-2 && y===shipYStart+2) {
        stars.push(ship2TileOffset+18,0)
        return true
    } else if (x===ship2XStart-2 && y===shipYStart+3) {
        stars.push(ship2TileOffset+17,0)
        return true
    } else if (x===ship2XStart-2 && y===shipYStart+4) {
        stars.push(ship2TileOffset+16,0)
        return true
    } else if (x===ship2XStart-2 && y===shipYStart+5) {
        stars.push(ship2TileOffset+15,0)
        return true
    } else if (x===ship2XStart-2 && y===shipYStart+6) {
        stars.push(ship2TileOffset+15,0)
        return true
    } else if (x===ship2XStart-3 && y===shipYStart+2) {
        stars.push(ship2TileOffset+22,0)
        return true
    } else if (x===ship2XStart-3 && y===shipYStart+3) {
        stars.push(ship2TileOffset+21,0)
        return true
    } else if (x===ship2XStart-4 && y===shipYStart+2) {
        stars.push(ship2TileOffset+24,0)
        return true
    } else if (x===ship2XStart-4 && y===shipYStart+3) {
        stars.push(ship2TileOffset+23,0)
        return true
    } else if (x>=ship2XStart-1) {
        stars.push(ship2TileOffset+25,0)
        return true
    } 

    return false
}

for(let y=0; y<32; y++){
    for(let x=0; x<128; x++){
        if (checkBase1(stars,x,y)) {
            continue
        } else if (checkBase2(stars,x,y)) {
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
