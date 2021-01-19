const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Credentials': true,
};

const corsHeadersInjected = {
  headers: corsHeaders
};

module.exports = { corsHeaders, corsHeadersInjected };
