import mongoose from "mongoose";

const userSchema = mongoose.Schema({
    username: {type: String, required: true},
    password: {type: String, required: true},
    email: {type: String, required: true},
    googleId: {type: String, required: false},
    facebookId: {type: String, required: false},
    apiToken: {type: String, required: true},
    dateJoined: {type: Date, required: true},
    isAdmin: {type: Boolean, required: true, default: false},
    isVerified: {type: Boolean, required: true, default: false},
});

const userModel = mongoose.model("User", userSchema);

export {userModel as User};
