import { User } from "../models/user.js";
import { hashToken, generateToken, decryptToken } from "../utils/tokenHandler.js";


const registerUserEmail = (req, res) => {
    const { username, password, email } = req.body;
    // passsword will already be hashed by the client, so we don't need to hash it again. Algorithm used is same as in utils.py/tokenHandler.js
    //check if email is already in use
    if (req.body.isAdmin){
        res.status(400).send({ message: "Not allowed" });
    }
    else{
        try{
            // check if email is valid
            if (!email.includes("@") && !email.includes(".")){
                res.status(400).send({ message: "Invalid email" });
            }
            else{
                User.findOne({ email: email }, (err, user) => {
                    if (err) {
                        res.status(500).json({ error: err });
                    } else if (user) {
                        res.status(400).json({ error: "Email already in use" });
                    } else {
                        const apiToken = generateToken();
                        const hashedToken = hashToken(apiToken);
                        const dateJoined = new Date();
                        const user = new User({
                            username,
                            password,
                            email,
                            apiToken:hashedToken,
                            dateJoined,
                        });
                        user.save()
                            .then(() => {
                                res.status(201).json({
                                    message: "User created successfully",
                                    apiToken: apiToken,
                                    username: username,
                                });
                            }).catch(err => {
                                res.status(500).json({
                                    error: err
                                });
                            }
                            );
                        }
                    }
                );
            }
            }
        catch{
            res.status(500).json({ error: err });
        }
    }
}




 
export { registerUserEmail } 