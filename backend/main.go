package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"github.com/gorilla/mux"
)


type Item struct {
	Type string `json:"type"`
	Count string `json:"count"`
	Time string `json:"time"`
}

var items [] Item

func GetItems(w http.ResponseWriter, req *http.Request) {
	w.WriteHeader(200)
	w.Header().Set("Content-Type", "application/json; charset=UTF-8")
	json.NewEncoder(w).Encode(items)
}

func AddItem(w http.ResponseWriter, req *http.Request) {
	var item Item
	_ = json.NewDecoder(req.Body).Decode(&item)
	w.WriteHeader(201)
	items = append(items, item)
	fmt.Println("Adding Item time: ")
	fmt.Println(item)
}

// run
func main() {

	// Get handle function:
	router := mux.NewRouter()
	router.HandleFunc("/items/", GetItems).Methods("GET")
	router.HandleFunc("/item/", AddItem).Methods("PUT")

	// start api on 9090
	log.Fatal(http.ListenAndServe(":9090", router))
}
