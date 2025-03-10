const fs = require("fs");
const color=208
const stars = []

let d=1
let lastHit=false
const solidTile=5

for(let y=0; y<32; y++){
    for(let x=0; x<128; x++){
        // Solid tile on edges
        if (x===0 || x===127 /*|| y===0 || y===14*/) {
            stars.push(solidTile)
            continue
        }
        let n=0
        if (!lastHit && Math.random()*100 > 60) {
            n=d
            d++
            if (d==5) {
                d=1
            }
            lastHit=true
        } else {
            lastHit=false
        }
        stars.push(n)
    }
}

//console.log(stars)

let data=[]
let c=0
for(let y=0; y<32; y++){
    for(let x=0; x<128; x++){
        // Solid tile on edges
        if (x===0) {
            data.push(stars[c], 50)
        } else if(x===127) {
            data.push(stars[c], 100)
        } else {
            data.push(stars[c],c===0 ? 0 : color)
        }
        
        // if (y===0) {
        //     data.push(stars[c], 150)
        // } else if(y===14) {
        //     data.push(stars[c], 180)
        // } 

        c++
    }
}

// const data=stars.reduce((p,c)=> {
//     p.push(c,c===0 ? 0 : color)
//     return p
// },[])

output = new Uint8Array(data);
fs.writeFileSync("build/FIELD.BIN", output, "binary");
