package kafkapub

import (
	"github.com/TIBCOSoftware/flogo-lib/core/activity"
)

var jsonMetadata = `{
  "name": "tibco-kafkapub",
  "version": "0.0.1",
  "type": "flogo:activity",
  "ref": "github.com/TIBCOSoftware/flogo-contrib/activity/kafkapub",
  "description": "Publish a message to a kafka topic",
  "author": "Wendell Nichols <wnichols@tibco.com>",
  "inputs":[
    {
      "name": "BrokerUrls",
      "type": "string",
      "required": true
    },
    {
      "name": "Topic",
      "type": "string",
      "required": true
    },
    {
      "name": "Message",
      "type": "string",
      "required": true
    },
    {
      "name": "user",
      "type": "string",
      "required": false
    },
    {
      "name": "password",
      "type": "string",
      "required": false
    },
    {
      "name": "truststore",
      "type": "string",
      "required": false
    }
  ],
  "outputs": [
    {
      "name": "partition",
      "type": "int"
    },
    {
      "name": "offset",
      "type": "long"
    }
  ]
}`

// init create & register activity
func init() {
	md := activity.NewMetadata(jsonMetadata)
	activity.Register(NewActivity(md))
}
