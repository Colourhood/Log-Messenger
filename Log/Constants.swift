//
//  FileTypes.swift
//  Log
//
//  Created by Andrei Villasana on 9/20/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import Foundation

struct Constants {

    static let allDirectories = [Images];

    // # Mark - File Types
    static let JSON = "json";
    static let Text = "txt";
    static let PDF = "pdf";
    static let PNG = "png";
    static let JPEG = "jpeg";
    static let JPG = "jpg";
    static let TIFF = "tiff";

    // # Mark - MIME Content Types
    static let MPNG = "image/png";
    static let MJPEG = "image/jpeg";
    static let MJPG = "image/jpg";

    // # Mark - Directory Name
    static let Images = "Images";

    // # Mark - Filenames
    static let profilePicture = "profilePicture";

    // # Mark - SocketIO Events
    static let joinRoom = "join room";
    static let leaveRoom = "leave room";

    static let sendMessage = "send message";
    static let startTyping = "start typing";
    static let stopTyping = "stop typing";
}
