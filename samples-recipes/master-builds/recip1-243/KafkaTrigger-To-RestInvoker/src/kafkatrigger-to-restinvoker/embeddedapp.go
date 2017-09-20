// Do not change this file, it has been generated using flogo-cli
// If you change it and rebuild the application your changes might get lost
package main

import (
	"encoding/json"

	"github.com/TIBCOSoftware/flogo-lib/app"
)

// embedded flogo app descriptor file
const flogoJSON string = `{
	"name": "KafkaTrigger-To-RestInvoker",
	"type": "flogo:app",
	"version": "1.0.0",
	"description": "This is the first microgateway app",
	"properties": null,
	"triggers": [
		{
			"name": "kafka_trigger",
			"id": "kafka_trigger",
			"ref": "github.com/TIBCOSoftware/flogo-contrib/trigger/kafkasub",
			"settings": {
				"BrokerUrl": "localhost:9092"
			},
			"outputs": null,
			"handlers": [
				{
					"actionId": "kafka_handler",
					"settings": {
						"Topic": "syslog"
					},
					"outputs": null
				}
			],
			"endpoints": null
		}
	],
	"actions": [
		{
			"id": "kafka_handler",
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
								"name": "Invoke REST Service",
								"description": "Simple REST Activity",
								"type": 1,
								"activityType": "github-com-tibco-software-flogo-contrib-activity-rest",
								"activityRef": "github.com/TIBCOSoftware/flogo-contrib/activity/rest",
								"attributes": [
									{
										"name": "method",
										"value": "PUT",
										"required": true,
										"type": "string"
									},
									{
										"name": "uri",
										"value": "http://petstore.swagger.io/v2/pet",
										"required": true,
										"type": "string"
									},
									{
										"name": "pathParams",
										"value": null,
										"required": false,
										"type": "params"
									},
									{
										"name": "queryParams",
										"value": null,
										"required": false,
										"type": "params"
									},
									{
										"name": "content",
										"value": null,
										"required": false,
										"type": "any"
									}
								],
								"inputMappings": [
									{
										"type": 1,
										"value": "{T.message}",
										"mapTo": "content"
									}
								]
							},
							{
								"id": 3,
								"name": "Log Message",
								"description": "Simple Log Activity",
								"type": 1,
								"activityType": "github-com-tibco-software-flogo-contrib-activity-log",
								"activityRef": "github.com/TIBCOSoftware/flogo-contrib/activity/log",
								"attributes": [
									{
										"name": "message",
										"value": "Success",
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
								"id": 7,
								"name": "Log Message (4)",
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
										"value": "{A2.result}",
										"mapTo": "message"
									}
								]
							},
							{
								"id": 4,
								"name": "Log Message (2)",
								"description": "Simple Log Activity",
								"type": 1,
								"activityType": "github-com-tibco-software-flogo-contrib-activity-log",
								"activityRef": "github.com/TIBCOSoftware/flogo-contrib/activity/log",
								"attributes": [
									{
										"name": "message",
										"value": "Failure",
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
								"id": 8,
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
										"value": "{A2.result}",
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
								"type": 1,
								"value": "${A2.result}.id\u003e=0"
							},
							{
								"id": 2,
								"from": 3,
								"to": 7,
								"type": 0
							},
							{
								"id": 3,
								"from": 2,
								"to": 4,
								"type": 1,
								"value": "${A2.result}.code==1"
							},
							{
								"id": 4,
								"from": 4,
								"to": 8,
								"type": 0
							}
						],
						"attributes": []
					},
					"errorHandlerTask": {
						"id": 5,
						"type": 1,
						"tasks": [
							{
								"id": 6,
								"name": "Log Message (3)",
								"description": "Simple Log Activity",
								"type": 1,
								"activityType": "github-com-tibco-software-flogo-contrib-activity-log",
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
								"id": 9,
								"name": "Log Message (6)",
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
										"value": "{A2.result}",
										"mapTo": "message"
									}
								]
							}
						],
						"links": [
							{
								"id": 5,
								"from": 6,
								"to": 9,
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