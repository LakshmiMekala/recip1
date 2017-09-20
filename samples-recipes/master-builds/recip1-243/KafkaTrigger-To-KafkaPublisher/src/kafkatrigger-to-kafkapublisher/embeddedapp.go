// Do not change this file, it has been generated using flogo-cli
// If you change it and rebuild the application your changes might get lost
package main

import (
	"encoding/json"

	"github.com/TIBCOSoftware/flogo-lib/app"
)

// embedded flogo app descriptor file
const flogoJSON string = `{
	"name": "KafkaTrigger-To-KafkaPublisher",
	"type": "flogo:app",
	"version": "1.0.0",
	"description": "This is the first microgateway app",
	"properties": null,
	"triggers": [
		{
			"name": "kafka_trigger1",
			"id": "kafka_trigger1",
			"ref": "github.com/TIBCOSoftware/flogo-contrib/trigger/kafkasub",
			"settings": {
				"BrokerUrl": "localhost:9092"
			},
			"outputs": null,
			"handlers": [
				{
					"actionId": "kafka_handler1",
					"settings": {
						"Topic": "publishpet"
					},
					"outputs": null
				}
			],
			"endpoints": null
		}
	],
	"actions": [
		{
			"id": "kafka_handler1",
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
										"value": "subscribepet",
										"required": false,
										"type": "string"
									},
									{
										"name": "Message",
										"value": "",
										"required": false,
										"type": "string"
									}
								],
								"inputMappings": [
									{
										"type": 1,
										"value": "{T.message}",
										"mapTo": "Message"
									}
								]
							}
						],
						"links": [],
						"attributes": []
					},
					"errorHandlerTask": {
						"id": 3,
						"type": 1,
						"tasks": [
							{
								"id": 4,
								"name": "Log Message (2)",
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
							}
						],
						"links": [],
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
