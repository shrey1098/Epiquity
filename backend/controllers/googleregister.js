import { User } from "../models/user.js";
import { hashToken, generateToken, decryptToken } from "../utils/tokenHandler.js";
import passport from "passport";
import {Strategy} from 'passport-google-oauth20';
const GoogleStrategy = Strategy;
const GOOGLE_CLIENT_ID = "780801164708-ci6iisi0elcono3845qpfraumaaalagn.apps.googleusercontent.com"
const GOOGLE_CLIENT_SECRET = "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"
passport.use(new GoogleStrategy({
    clientID: GOOGLE_CLIENT_ID,
    clientSecret: GOOGLE_CLIENT_SECRET,
    callbackURL: "http://ec2-13-126-202-203.ap-south-1.compute.amazonaws.com:3000/api/register/google/callback"
  },
  function(accessToken, refreshToken, profile, cb) {
      //console.log(cb)
      let apiKey = generateToken()
      let hashApiKey = hashToken(apiKey)
      User.findOne({ googleId: profile.id }, async function (err, user) {
        if (err) {
          return cb(err)
        }
        // Create new user
        if(!user) {
            const apiToken = generateToken();
            const hashedToken = hashToken(apiToken);
            const dateJoined = new Date();
            const user = new User({
                username: profile.name.givenName,
                password: hashedToken,
                email: profile._json.email,
                googleId: profile.id,
                apiToken:hashedToken,
                dateJoined: dateJoined,
                isVerified: true,
          })
          try{
            await user.save();
            return cb(err, {'apikey':apiKey, 'user':user})
          }catch(err){
            return cb(err)
          }
        }
        if(user){
          return cb(err, user)
        }
      });
    }
));

passport.serializeUser(function(user, cb){
    cb(null, user);
})
passport.deserializeUser(function (user, cb){
    cb(null, user);
})