"use strict";
const getNewsHandler = require("./handlers/getNews");
const postNewsHandler = require("./handlers/postNews");
const getNewsItemHandler = require("./handlers/getNewsItem");
const postNewsConsumer = require("./consumers/postNewsConsumer");

module.exports = {
  getNews: getNewsHandler,
  postNews: postNewsHandler,
  postNewsConsumer: postNewsConsumer,
  getNewsItem: getNewsItemHandler,
};
