const dynamo = require("../services/dynamo");
const sqs = require("../services/sqs");

module.exports = async (event) => {
  await Promise.all(
    event.Records.map(
      (record) =>
        new Promise(async (resolve, reject) => {
          const { messageId, body, receiptHandle } = record;
          console.log("Processing", { messageId, body });
          try {
            await dynamo.insert(process.env.NEWS_TABLE_NAME, JSON.parse(body));
            console.log("Success persisting item", { messageId });
            await sqs.removeItem(process.env.SQS_QUEUE_URL, receiptHandle);
            console.log("Success processing item", { messageId });
            resolve();
          } catch (e) {
            console.error("Error persisting item", { messageId, e });
            reject();
          }
        })
    )
  );
};
