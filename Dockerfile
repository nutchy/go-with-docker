# This image runs the alpine Linux distribution which is small in size 
# and has Golang already installed which is perfect for our use case.
# There are tons of publicly available Docker image, have a look at https://hub.docker.com/_/golang
FROM golang:alpine AS builder

# Set necessary environmet variables needed for our image
ENV GO111MODULE=on \
  CGO_ENABLED=0 \
  GOOS=linux \
  GOARCH=amd64

# Move to working directory /build
WORKDIR /build

# Copy and download dependency using go mod
COPY go.mod .
COPY go.sum .
RUN go mod download

# Copy the code into the container
COPY . .

# Build the application
RUN go build -o main .

# Move to /dist directory as the place for resulting binary folder
WORKDIR /dist

# Copy binary from build to main folder
RUN cp /build/main .

# Export necessary port
EXPOSE 3000

# Build a small image
FROM scratch

COPY --from=builder /dist/main /
COPY ./database/data.json /database/data.json

# Command to run
ENTRYPOINT ["/main"]