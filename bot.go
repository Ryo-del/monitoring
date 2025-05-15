package main

import (
	"log"
	"os/exec"
	"time"

	tgbotapi "github.com/go-telegram-bot-api/telegram-bot-api/v5"
)

func main() {
	bot, err := tgbotapi.NewBotAPI("7747181762:AAEfarc6qwn455UFadykr-MP2jmnnbpu_Wc")
	if err != nil {
		log.Panic(err)
	}

	bot.Debug = true
	log.Printf("Бот запущен: @%s", bot.Self.UserName)

	chatID := int64(962449094)
	for {
		// Запускаем проверку
		cmd := exec.Command("/bin/bash", "./main.sh")
		output, err := cmd.CombinedOutput()
		if err != nil {
			log.Printf("Ошибка выполнения скрипта: %v", err)
			continue
		}

		msg := tgbotapi.NewMessage(chatID, string(output))
		bot.Send(msg)

		time.Sleep(5 * time.Second)
	}

}
