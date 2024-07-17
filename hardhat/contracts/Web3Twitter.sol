// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Web3Twitter is Ownable {
    using Counters for Counters.Counter;

    struct Tweet {
        address author;
        string content;
        uint256 likes;
        uint256 timestamp;
    }

    mapping(uint256 => Tweet) public tweets;
    mapping(address => uint256[]) public userTweets;
    mapping(address => mapping(address => bool)) public isFollowing;
    mapping(address => address[]) public followers;
    mapping(address => address[]) public following;
    mapping(address => mapping(uint256 => bool)) public hasLiked;

    Counters.Counter private _tweetIds;

    event TweetPosted(uint256 indexed tweetId, address indexed author, string content);
    event TweetLiked(uint256 indexed tweetId, address indexed liker);
    event UserFollowed(address indexed follower, address indexed followed);

    constructor() {}

    function postTweet(string memory _content) external {
        require(bytes(_content).length > 0 && bytes(_content).length <= 280, "Tweet must be between 1 and 280 characters");

        uint256 newTweetId = _tweetIds.current();
        _tweetIds.increment();

        tweets[newTweetId] = Tweet({
            author: msg.sender,
            content: _content,
            likes: 0,
            timestamp: block.timestamp
        });

        userTweets[msg.sender].push(newTweetId);

        emit TweetPosted(newTweetId, msg.sender, _content);
    }

    function likeTweet(uint256 _tweetId) external {
        require(_tweetId < _tweetIds.current(), "Tweet does not exist");
        require(!hasLiked[msg.sender][_tweetId], "You have already liked this tweet");

        tweets[_tweetId].likes++;
        hasLiked[msg.sender][_tweetId] = true;

        emit TweetLiked(_tweetId, msg.sender);
    }

    function followUser(address _userToFollow) external {
        require(_userToFollow != msg.sender, "You cannot follow yourself");
        require(!isFollowing[msg.sender][_userToFollow], "You are already following this user");

        isFollowing[msg.sender][_userToFollow] = true;
        following[msg.sender].push(_userToFollow);
        followers[_userToFollow].push(msg.sender);

        emit UserFollowed(msg.sender, _userToFollow);
    }

    function getTweet(uint256 _tweetId) external view returns (Tweet memory) {
        require(_tweetId < _tweetIds.current(), "Tweet does not exist");
        return tweets[_tweetId];
    }

    function getUserTweets(address _user) external view returns (uint256[] memory) {
        return userTweets[_user];
    }

    function getFollowers(address _user) external view returns (address[] memory) {
        return followers[_user];
    }

    function getFollowing(address _user) external view returns (address[] memory) {
        return following[_user];
    }
}