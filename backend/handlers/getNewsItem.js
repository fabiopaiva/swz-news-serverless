const dynamo = require("../services/dynamo");

module.exports = async (event) => {
  const { slug } = event.pathParameters;
  try {
    const data = await dynamo.scanWithFilter(
      process.env.NEWS_TABLE_NAME,
      {
        filterExpression: "#s = :slug",
        expressionAttributeNames: {
          "#s": "slug"
        },
        expressionAttributeValues: dynamo.marshall({
          ":slug": slug.toLowerCase(),
        }),
      }
    );
    if (!data) {
      return {
        statusCode: 404,
        body: JSON.stringify({
          errors: ["Not found"]
        }),
      };
    }
    return {
      statusCode: 200,
      body: JSON.stringify({
        result: "success",
        data,
      }),
    };
  } catch (e) {
    console.error(e);
    return {
      statusCode: 500,
      body: JSON.stringify({
        errors: [e.message],
        m: dynamo.marshall({
          ":slug": slug.toLowerCase(),
        })
      }),
    };
  }
};
