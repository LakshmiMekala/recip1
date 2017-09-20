package rest

import (
	"github.com/TIBCOSoftware/flogo-lib/core/trigger"
)

var jsonMetadata = `{
  "name": "tibco-rest",
  "type": "flogo:trigger",
  "ref": "github.com/TIBCOSoftware/flogo-contrib/trigger/rest",
  "version": "0.0.1",
  "title": "Receive HTTP Message",
  "description": "Simple REST Trigger",
  "homepage": "https://github.com/TIBCOSoftware/flogo-contrib/tree/master/trigger/rest",
  "settings": [
    {
      "name": "port",
      "type": "integer",
      "required": true
    }
  ],
  "outputs": [
    {
      "name": "params",
      "type": "params"
    },
    {
      "name": "pathParams",
      "type": "params"
    },
    {
      "name": "queryParams",
      "type": "params"
    },
    {
      "name": "content",
      "type": "object"
    }
  ],
  "handler": {
    "settings": [
      {
        "name": "method",
        "type": "string",
        "required" : true,
        "allowed" : ["GET", "POST", "PUT", "PATCH", "DELETE"]
      },
      {
        "name": "path",
        "type": "string",
        "required" : true
      },
      {
        "name": "autoIdReply",
        "type": "boolean"
      },
      {
        "name": "useReplyHandler",
        "type": "boolean"
      }
    ]
  }
}
`

// init create & register trigger factory
func init() {
	md := trigger.NewMetadata(jsonMetadata)
	trigger.RegisterFactory(md.ID, NewFactory(md))
}
