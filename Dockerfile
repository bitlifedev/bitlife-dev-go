FROM --platform=$BUILDPLATFORM golang:1.17-alpine AS build

# Set destination for COPY
WORKDIR /src

# Download Go modules
COPY go.mod .
COPY go.sum .
RUN go mod download

# Copy the source code. Note the slash at the end, as explained in
# https://docs.docker.com/engine/reference/builder/#copy
COPY . .

ARG TARGETOS
ARG TARGETARCH

# Build
#RUN go build -o /docker-gs-ping
RUN --mount=target=. \
    --mount=type=cache,target=/root/.cache/go-build \
    --mount=type=cache,target=/go/pkg \
    GOOS=$TARGETOS GOARCH=$TARGETARCH go build -o /out/myapp .

FROM alpine
COPY --from=build /out/myapp /bin


# This is for documentation purposes only.
# To actually open the port, runtime parameters
# must be supplied to the docker command.
#EXPOSE 8080

# (Optional) environment variable that our dockerised
# application can make use of. The value of environment
# variables can also be set via parameters supplied
# to the docker command on the command line.
#ENV HTTP_PORT=8081

# Run
CMD [ "/bin/myapp" ]
