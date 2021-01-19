const { corsHeadersInjected } = require('../utils/cors');
const sqs = require("../services/sqs");

module.exports = async (event) => {
  // SQS configured limit = 256KB
  if (String(event.body).length > 256 * 1024) {
    return {
      statusCode: 400,
      body: JSON.stringify({
        errors: ["Message is too big"],
      }),
      ...corsHeadersInjected
    };
  }
  const { slug, title, date, description } = JSON.parse(event.body);
  if (!slug || !date) {
    return {
      statusCode: 400,
      body: JSON.stringify({
        errors: ["slug and date are required"],
      }),
      ...corsHeadersInjected
    };
  }

  try {
    const { MessageId } = await sqs.addItem(
      process.env.SQS_QUEUE_URL,
      JSON.stringify({
        id: event.requestContext.requestId,
        slug: slug.toLowerCase(),
        title,
        date,
        description,
      })
    );
    console.log("Item enqueued", { MessageId });
    return {
      statusCode: 200,
      body: JSON.stringify({
        message: "success",
        id: MessageId,
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
