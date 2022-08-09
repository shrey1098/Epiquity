import { User } from "../models/user.js";
import { hashToken } from "../utils/tokenHandler.js";

const verifyToken = (req, res, next) => {
    const apiToken = req.query.apiToken;
    //console.log(apiToken);
    if (apiToken){
        const hToken = hashToken(apiToken)
        //console.log(hToken)
        User.findOne({apiToken: hToken}, function (err, user) {
            //console.log(user)
            if (err) {
                return res.status(404).send(err)
            }
            if (!user){
                return res.status(404).json({message:'user not found'})
            }
            else{
                res.locals._id = user._id
                res.locals.isAdmin = user.isAdmin
                next()
            }
        })
    }else{
        res.status(404).json({message:'apiToken not provided'})
    }
}

export {verifyToken}