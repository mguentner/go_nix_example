package main

import (
	"flag"
	"html/template"
	"log"
	"math/rand"
	"net/http"
)

func generateEmoji(w http.ResponseWriter, req *http.Request) {
	const tpl = `
	<!DOCTYPE html>
	<html>
		<head>
			<meta charset="UTF-8">
			<title>{{.Emoji}}</title>
			<style>
				body {
					text-align: center;
					width: 100%;
					height: 100%;
					font-size: 75vh;
				}
			</style>
		</head>
		<body>
		   {{.Emoji}}
		</body>
	</html>`

	emojis := []string{
		"😊", "🎉", "🌟", "🏆", "🚀",
		"💻", "🎮", "📚", "💸", "🎈",
	}
	randomIndex := rand.Intn(len(emojis))
	emoji := emojis[randomIndex]
	t, err := template.New("webpage").Parse(tpl)
	if err != nil {
		log.Fatal(err)
	}
	err = t.Execute(w, struct{ Emoji string }{
		Emoji: emoji,
	})
	if err != nil {
		log.Fatal(err)
	}
}

func main() {
	listenAddress := flag.String("l", ":8090", "listen address")
	flag.Parse()
	log.Printf("Listening on %s", *listenAddress)
	http.HandleFunc("/", generateEmoji)
	http.ListenAndServe(*listenAddress, nil)
}
