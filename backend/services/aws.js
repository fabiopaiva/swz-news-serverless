const AWS = require("aws-sdk");
AWS.config.update({ region: "eu-central-1" });

module.exports = AWS;
