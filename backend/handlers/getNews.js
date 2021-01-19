const { corsHeadersInjected } = require('../utils/cors');
const dynamo = require("../services/dynamo");

module.exports = async (_event) => {
  try {
    const data = await dynamo.scan(process.env.NEWS_TABLE_NAME);
    return {
      statusCode: 200,
      body: JSON.stringify({
        result: "success",
        data,
      }),
      ...corsHeadersInjected
    };
  } catch (e) {
    console.error(e);
    return {
      statusCode: 500,
      body: JSON.stringify({
        errors: [e.message],
      }),
      ...corsHeadersInjected
    };
  }
};
