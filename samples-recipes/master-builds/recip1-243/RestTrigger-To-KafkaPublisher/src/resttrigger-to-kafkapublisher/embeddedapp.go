// Do not change this file, it has been generated using flogo-cli
// If you change it and rebuild the application your changes might get lost
package main

import (
	"encoding/json"

	"github.com/TIBCOSoftware/flogo-lib/app"
)

// embedded flogo app descriptor file
const flogoJSON string = `{
	"name": "RestTrigger-To-KafkaPublisher",
	"type": "flogo:app",
	"version": "1.0.0",
	"description": "This is the first microgateway app",
	"properties": null,
	"triggers": [
		{
			"name": "rest_trigger4",
			"id": "rest_trigger4",
			"ref": "github.com/TIBCOSoftware/flogo-contrib/trigger/rest",
			"settings": {
				"port": "9096"
			},
			"outputs": null,
			"handlers": [
				{
					"actionId": "get_pet_handler4",
					"settings": {
						"autoIdReply": "false",
						"method": "PUT",
						"path": "/petEvent",
						"useReplyHandler": "false"
					},
					"outputs": null
				}
			],
			"endpoints": null
		}
	],
	"actions": [
		{
			"id": "get_pet_handler4",
			"ref": "github.com/TIBCOSoftware/flogo-contrib/action/flow",
			"data": {
				"flow": {
					"type": 1,
					"attributes": [],
					"rootTask": {
						"id": 1,
						"type": 1,
						"tasks": [
							{
								"id": 2,
								"name": "tibco-kafkapub",
								"description": "Publish a message to a kafka topic",
								"type": 1,
								"activityType": "tibco-kafkapub",
								"activityRef": "github.com/TIBCOSoftware/flogo-contrib/activity/kafkapub",
								"attributes": [
									{
										"name": "BrokerUrls",
										"value": "localhost:9092",
										"required": false,
										"type": "string"
									},
									{
										"name": "Topic",
										"value": "syslog",
										"required": false,
										"type": "string"
									},
									{
										"name": "Message",
										"value": "mary had a little lamb",
										"required": false,
										"type": "string"
									}
								],
								"inputMappings": [
									{
										"type": 1,
										"value": "{T.content}",
										"mapTo": "Message"
									}
								]
							},
							{
								"id": 3,
								"name": "Log Message (2)",
								"description": "Simple Log Activity",
								"type": 1,
								"activityType": "github-com-tibco-software-flogo-contrib-activity-log",
								"activityRef": "github.com/TIBCOSoftware/flogo-contrib/activity/log",
								"attributes": [
									{
										"name": "message",
										"value": "success",
										"required": false,
										"type": "string"
									},
									{
										"name": "flowInfo",
										"value": "true",
										"required": false,
										"type": "boolean"
									},
									{
										"name": "addToFlow",
										"value": "true",
										"required": false,
										"type": "boolean"
									}
								]
							},
							{
								"id": 5,
								"name": "Log Message (3)",
								"description": "Simple Log Activity",
								"type": 1,
								"activityType": "tibco-log",
								"activityRef": "github.com/TIBCOSoftware/flogo-contrib/activity/log",
								"attributes": [
									{
										"name": "message",
										"value": "",
										"required": false,
										"type": "string"
									},
									{
										"name": "flowInfo",
										"value": "true",
										"required": false,
										"type": "boolean"
									},
									{
										"name": "addToFlow",
										"value": "true",
										"required": false,
										"type": "boolean"
									}
								],
								"inputMappings": [
									{
										"type": 1,
										"value": "{T.content}",
										"mapTo": "message"
									}
								]
							}
						],
						"links": [
							{
								"id": 1,
								"from": 2,
								"to": 3,
								"type": 0
							},
							{
								"id": 2,
								"from": 3,
								"to": 5,
								"type": 0
							}
						],
						"attributes": []
					},
					"errorHandlerTask": {
						"id": 4,
						"type": 1,
						"tasks": [
							{
								"id": 6,
								"name": "Log Message (4)",
								"description": "Simple Log Activity",
								"type": 1,
								"activityType": "tibco-log",
								"activityRef": "github.com/TIBCOSoftware/flogo-contrib/activity/log",
								"attributes": [
									{
										"name": "message",
										"value": "Error processing request in gateway",
										"required": false,
										"type": "string"
									},
									{
										"name": "flowInfo",
										"value": "false",
										"required": false,
										"type": "boolean"
									},
									{
										"name": "addToFlow",
										"value": "false",
										"required": false,
										"type": "boolean"
									}
								]
							},
							{
								"id": 7,
								"name": "Log Message (5)",
								"description": "Simple Log Activity",
								"type": 1,
								"activityType": "tibco-log",
								"activityRef": "github.com/TIBCOSoftware/flogo-contrib/activity/log",
								"attributes": [
									{
										"name": "message",
										"value": "",
										"required": false,
										"type": "string"
									},
									{
										"name": "flowInfo",
										"value": "false",
										"required": false,
										"type": "boolean"
									},
									{
										"name": "addToFlow",
										"value": "false",
										"required": false,
										"type": "boolean"
									}
								],
								"inputMappings": [
									{
										"type": 1,
										"value": "{T.content}",
										"mapTo": "message"
									}
								]
							}
						],
						"links": [
							{
								"id": 3,
								"from": 6,
								"to": 7,
								"type": 0
							}
						],
						"attributes": []
					}
				}
			}
		}
	]
}`

func init () {
	cp = EmbeddedProvider()
}

// embeddedConfigProvider implementation of ConfigProvider
type embeddedProvider struct {
}

//EmbeddedProvider returns an app config from a compiled json file
func EmbeddedProvider() (app.ConfigProvider){
	return &embeddedProvider{}
}

// GetApp returns the app configuration
func (d *embeddedProvider) GetApp() (*app.Config, error){

	app := &app.Config{}
	err := json.Unmarshal([]byte(flogoJSON), app)
	if err != nil {
		return nil, err
	}
	return app, nil
}
