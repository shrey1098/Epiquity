import { createCipheriv, createDecipheriv } from "crypto";
import generateApiKey from "generate-api-key";

const generateToken = () =>{
    var token = generateApiKey();
    return String(token)   
}

// in production mode key is stored in environment variable
const hashToken = (token)=>{
    const algorithm = "aes-256-cbc"; 
    // generate 16 bytes of random data
    const initVector = process.env.INIT_VECTOR || '0000000000000000';
    // protected data
    const message = token;
    const Securitykey = process.env.DEVELOPER_SECRET || 'a54762edb437be644d699ff7c5d6235c'
    // the cipher function
    const cipher = createCipheriv(algorithm, Securitykey, initVector);
    // encrypt the message
    // input encoding
    // output encoding
    let encryptedData = cipher.update(message, "utf-8", "hex");
    encryptedData += cipher.final("hex");
    return encryptedData
}

const decryptToken = (encryptedToken) =>{
    const algorithm = "aes-256-cbc";
    const SecurityKey = process.env.DEVELOPER_SECRET || 'a54762edb437be644d699ff7c5d6235c';
    const initVector = process.env.INIT_VECTOR || '0000000000000000';
    console.log("securityKey:"+ SecurityKey+ "initVector:"+ initVector)
    const decipher = createDecipheriv(algorithm, SecurityKey, initVector);
    let decryptedData = decipher.update(encryptedToken, "hex", "utf-8");
    decryptedData += decipher.final("utf8");
    return decryptedData
}

export {generateToken, hashToken, decryptToken}