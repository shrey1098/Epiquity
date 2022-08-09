import express from 'express';
import { registerUserEmail } from '../controllers/register.js';
import passport from "passport";
import { decryptToken } from '../utils/tokenHandler.js';
import ('../controllers/googleregister.js');


const router = express.Router();

router.post('/email', (req, res) => {
// Usage: POST /api/register/email
// Body: {username, password, email}
// Response: {message, apiToken, username}
    registerUserEmail(req, res);
}
);
router.get('/email', (req, res) => {
// Usage: GET /api/register/email
// Response: {message, apiToken, username}
// render html page with form to register
    res.sendFile('/emailRegister.html', {root: './views'});
}
);
router.get('/google', passport.authenticate('google',
 {scope: ['openid','profile', 'email'], passReqToCallback:true})
 )

router.get('/google/callback', 
 passport.authenticate('google', { failureRedirect: '/google' }),
 (req, res)=> {
   if(req.user['apikey']){
     res.status(200).json({'apikey': req.user['apikey']})
   }
   else{
     // get api key of the existing user & decrypt it
     res.status(200).json({"apiToken": decryptToken(req.user['apiToken'])})
   }
 });


export { router as registerRouter };

