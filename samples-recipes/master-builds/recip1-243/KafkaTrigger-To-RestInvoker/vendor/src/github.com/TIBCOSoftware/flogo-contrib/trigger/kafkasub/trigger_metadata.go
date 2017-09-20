package kafkasub

import (
	"github.com/TIBCOSoftware/flogo-lib/core/trigger"
)

var jsonMetadata = `{
  "name": "tibco-kafkasub",
  "type": "flogo:trigger",
  "ref": "github.com/TIBCOSoftware/flogo-contrib/trigger/kafkasub",
  "version": "0.0.1",
  "title": "Receive Kafka Messages",
  "author": "Wendell Nichols <wnichols@tibco.com>",
  "description": "Simple Kafka Trigger",
  "settings":[
    {
      "name": "BrokerUrl",
      "type": "string"
    },
    {
      "name": "user",
      "type": "string"
    },
    {
      "name": "password",
      "type": "string"
    },
    {
      "name": "truststore",
      "type": "string"
    }
  ],
  "outputs": [
    {
      "name": "message",
      "type": "string"
    }
  ],
  "handler": {
    "settings": [
      {
        "name": "Topic",
        "type": "string",
        "required":"true"
      },
      {
        "name": "partitions",
        "type": "string",
        "required": "false"
      },
      {
        "name": "group",
        "type": "string",
        "required":"false"
      },
      {
        "name": "offset",
        "type": "int",
        "required":"false"
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
