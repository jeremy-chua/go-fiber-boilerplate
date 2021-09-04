ARG GO_VERSION=1.17
ARG BUILDER_WORKSPACE=workspace
ARG APP_NAME=app
ARG USERNAME=user
ARG USER_UID=1000
ARG USER_GID=${USER_UID}
ARG EXPOSE_PORTS=3000

# Building the binary of the App
FROM golang:${GO_VERSION} AS builder

ARG BUILDER_WORKSPACE
ARG APP_NAME

# Copy all the Code and stuff to compile everything
WORKDIR /${BUILDER_WORKSPACE}
COPY . .

# Downloads all the dependencies in advance (could be left out, but it's more clear this way)
RUN go mod download

# Builds the application as a staticly linked one, to allow it to run on alpine
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -installsuffix cgo -o ${APP_NAME} .

########################
# Deploy
########################

# Moving the binary to the 'final Image' to make it smaller
FROM alpine:latest

ARG BUILDER_WORKSPACE
ARG APP_NAME
ARG USERNAME
ARG USER_UID
ARG USER_GID
ARG EXPOSE_PORTS

# create folder for deployment
RUN mkdir /app
WORKDIR /app

# Update
RUN apk update && apk upgrade

# Create non-root user
RUN addgroup --gid ${USER_GID} -S ${USERNAME} && \
    adduser -S -D -H -u ${USER_UID} ${USERNAME} -G ${USERNAME} && \
    chown -R ${USERNAME} /app

USER ${USERNAME}

# Create the `public` dir and copy all the assets into it
RUN mkdir ./static
COPY --chown=${USERNAME} ./static ./static
COPY --chown=${USERNAME} --from=builder /${BUILDER_WORKSPACE}/${APP_NAME} .

EXPOSE ${EXPOSE_PORTS}

CMD ["./${APP_NAME}"]