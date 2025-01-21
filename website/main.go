package main

import (
    "encoding/json"
    "html/template"
    "io/ioutil"
    "log"
    "net/http"
    "os"
    "path/filepath"
    "sort"
    "math/rand"
    "time"
    "fmt"
    "github.com/git-lfs/git-lfs/v3/errors"  // Add git-lfs package import
)

type Article struct {
    ID          string `json:"id"`
    Title       string `json:"title"`
    Content     string `json:"content"`
    Author      string `json:"author"`
    PublishDate string `json:"publishDate"`
    ImageUrl    string `json:"imageUrl"`
}

func getArticles(count int) ([]Article, error) {
    var articles []Article
    
    files, err := ioutil.ReadDir("data/articles")
    if err != nil {
        return nil, fmt.Errorf("failed to read articles directory: %v", err)
    }

    sort.Slice(files, func(i, j int) bool {
        return files[i].ModTime().After(files[j].ModTime())
    })

    if len(files) > count {
        files = files[:count]
    }

    for _, file := range files {
        if filepath.Ext(file.Name()) != ".json" {
            continue
        }

        filePath := filepath.Join("data/articles", file.Name())
        content, err := ioutil.ReadFile(filePath)
        if err != nil {
            return nil, fmt.Errorf("failed to read file %s: %v", file.Name(), err)
        }

        if len(content) == 0 {
            log.Printf("Warning: Empty file found: %s", file.Name())
            continue
        }

        var article Article
        if err := json.Unmarshal(content, &article); err != nil {
            return nil, fmt.Errorf("failed to parse JSON from file %s: %v\nContent: %s", 
                file.Name(), err, string(content))
        }

        articles = append(articles, article)
    }

    return articles, nil
}

func main() {
    rand.Seed(time.Now().UnixNano())
    
    // Verify directories exist
    if _, err := os.Stat("data/articles"); os.IsNotExist(err) {
        log.Fatal("data/articles directory not found")
    }
    
    // Get current working directory
    cwd, err := os.Getwd()
    if (err != nil) {
        log.Fatal(err)
    }
    
    // Verify template files exist
    templatePath := cwd + "/templates"
    if _, err := os.Stat(templatePath + "/layout.html"); os.IsNotExist(err) {
        log.Fatal("templates/layout.html not found at: " + templatePath)
    }
    if _, err := os.Stat(templatePath + "/article-partial.html"); os.IsNotExist(err) {
        log.Fatal("templates/article-partial.html not found at: " + templatePath)
    }
    
    // Create images directory if it doesn't exist
    if _, err := os.Stat("static/images"); os.IsNotExist(err) {
        if err := os.MkdirAll("static/images", 0755); err != nil {
            log.Fatal("Failed to create images directory:", err)
        }
    }
    
    // Serve static files with logging
    fs := http.FileServer(http.Dir("static"))
    http.Handle("/static/", http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        log.Printf("Serving static file: %s", r.URL.Path)
        http.StripPrefix("/static/", fs).ServeHTTP(w, r)
    }))

    // Routes
    http.HandleFunc("/", handleHome)
    http.HandleFunc("/load-more", handleLoadMore)

    log.Println("Server starting on :8080...")
    log.Fatal(http.ListenAndServe(":8080", nil))
}

func handleHome(w http.ResponseWriter, r *http.Request) {
    articles, err := getArticles(5)
    if err != nil {
        http.Error(w, err.Error(), http.StatusInternalServerError)
        return
    }

    tmpl, err := template.ParseFiles(
        "templates/layout.html",
        "templates/article-partial.html",
    )
    if err != nil {
        http.Error(w, err.Error(), http.StatusInternalServerError)
        return
    }

    if err := tmpl.Execute(w, articles); err != nil {
        // Don't write header here since template.Execute might have already written it
        log.Printf("Template execution error: %v", err)
    }
}

func handleLoadMore(w http.ResponseWriter, r *http.Request) {
    articles, err := getArticles(1)
    if err != nil {
        http.Error(w, err.Error(), http.StatusInternalServerError)
        return
    }

    if len(articles) == 0 {
        http.Error(w, "No more articles", http.StatusNotFound)
        return
    }

    tmpl, err := template.ParseFiles("templates/article-partial.html")
    if err != nil {
        http.Error(w, err.Error(), http.StatusInternalServerError)
        return
    }

    if err := tmpl.ExecuteTemplate(w, "article-partial.html", articles[0]); err != nil {
        // Don't write header here since template execution might have already written it
        log.Printf("Template execution error: %v", err)
    }
}

// checkLFSError is a utility function that wraps errors with LFS context
func checkLFSError(err error, operation string) error {
    if err != nil {
        return errors.NewWrappedError(err, "LFS operation failed: %s", operation)
    }
    return nil
}
