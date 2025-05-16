
package main

import (
	tgbotapi "github.com/go-telegram-bot-api/telegram-bot-api/v5"
	"log"
)

func main() {
	// Initialize bot with your token
	bot, err := tgbotapi.NewBotAPI("7840497465:AAHfEoBzL1cGf1EyIhllm6SNbK5JUxS6a38")
	if err != nil {
		log.Panic(err)
	}

	bot.Debug = true
	log.Printf("Authorized on account %s", bot.Self.UserName)

	// Set up update configuration
	u := tgbotapi.NewUpdate(0)
	u.Timeout = 60

	// Get updates channel
	updates := bot.GetUpdatesChan(u)

	// Process incoming updates
	for update := range updates {
		if update.Message == nil {
			continue // ignore any non-Message updates
		}

		// Prepare a response message
		msg := tgbotapi.NewMessage(update.Message.Chat.ID, "Hello, I received your message!")
		msg.ReplyToMessageID = update.Message.MessageID

		// Send the message
		if _, err := bot.Send(msg); err != nil {
			log.Printf("Error sending message: %v", err)
		}
	}
}