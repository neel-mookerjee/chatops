package main

import (
	"fmt"
	"log"
	"os"
    "strings"
    "github.com/nlopes/slack"
    "os/exec"
)

// @chatbot run <step name> <EMR cluster ID> <s3://script location>

func main() {
	// hardcoding this is not recommended; read from K8 secret!!!!
	api := slack.New("test-23232323232323-MFqaVpeVmT9yku4I6jNFg9bd")
    fmt.Printf("api: %v\n", api)
	logger := log.New(os.Stdout, "slack-bot: ", log.Lshortfile|log.LstdFlags)
	slack.SetLogger(logger)
	api.SetDebug(true)

	rtm := api.NewRTM()
	go rtm.ManageConnection()

  helpstr := "*usage:* _@chatbot <command> <args>_"
  helpstr += "\n\n*options:*"
  helpstr += "\n\t_@chatbot run <arg1> <arg2> <arg3>_"
  helpstr += "\n\t_@chatbot help_"
  helpstr += "\n\n*examples:*"
  helpstr += "\n\t_@chatbot run val1 val2 val3"
	helpstr += "\n\t_@chatbot help_"
	helpstr += "\n\n*know more about chatbot:*"


	for msg := range rtm.IncomingEvents {
		switch ev := msg.Data.(type) {
		case *slack.HelloEvent:
			// Ignore hello

		case *slack.ConnectedEvent:
			//fmt.Println("Infos:", ev.Info)
			//fmt.Println("Connection counter:", ev.ConnectionCount)
			// Replace C2147483705 with your Channel ID
		//	rtm.SendMessage(rtm.NewOutgoingMessage("Hello world", "C983PRA3C"))

		case *slack.MessageEvent:
			if strings.HasPrefix(ev.Text, "<@U9H9BSGH4> ") {
                fmt.Printf("Command Received: %v\n", ev.Text)
                parts := strings.Fields(ev.Text)
                if len(parts) == 5 && parts[1] == "run" {
                    fmt.Printf("Executing command...")
                    out, err := exec.Command("bash", "/sample-script.sh", parts[2], parts[3], parts[4]).Output()
                    fmt.Printf("Output: %s\n", out)
                	if err != nil {
                        fmt.Printf("Error: %v", err)
                	}
                    rtm.SendMessage(rtm.NewOutgoingMessage(fmt.Sprintf("%s", out), ev.Channel))
                } else if len(parts) == 2 && parts[1] == "help" {
                    str := "Hola! I help you with the sample script run.\n\n"
                    str += helpstr
                    rtm.SendMessage(rtm.NewOutgoingMessage(fmt.Sprintf("%s", str), ev.Channel))
                } else {
                    str := "Sorry, I didn't get that.\n\n"
                    str += helpstr
                    rtm.SendMessage(rtm.NewOutgoingMessage(fmt.Sprintf("%s", str), ev.Channel))
                }
				//rtm.SendMessage(rtm.NewOutgoingMessage("Use /help command to know the options", ev.Channel))
			}
		case *slack.PresenceChangeEvent:
			//fmt.Printf("Presence Change: %v\n", ev)

		case *slack.LatencyReport:
			//fmt.Printf("Current latency: %v\n", ev.Value)

		case *slack.RTMError:
			//fmt.Printf("Error: %s\n", ev.Error())

		case *slack.InvalidAuthEvent:
			//fmt.Printf("Invalid credentials")
			return

		default:

			// Ignore other events..
			// fmt.Printf("Unexpected: %v\n", msg.Data)
		}
	}
}
