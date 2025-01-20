# Build stage
FROM golang:1.21-alpine AS builder

WORKDIR /app

# Copy only necessary files for go mod
COPY go.mod ./

# Download dependencies
RUN go mod download

# Copy the rest of the source code
COPY . .

# Build the application for Linux
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o main .

# Final stage
FROM alpine:latest

WORKDIR /app

# Add CA certificates and timezone data
RUN apk --no-cache add ca-certificates tzdata && \
    adduser -D appuser

# Copy the binary and required directories
COPY --from=builder /app/main .
COPY static/ /app/static/
COPY templates/ /app/templates/
COPY data/ /app/data/

# Set proper permissions
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Set environment variables
ENV PORT=8080

# Expose port
EXPOSE 8080

# Run the binary
CMD ["./main"]
