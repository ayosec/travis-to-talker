express = require "express"
crypto = require "crypto"
https = require "https"

app = express.createServer()
  .use(express.logger())
  .use(express.bodyParser())

TravisToken = process.env.TRAVIS_TOKEN

Talker =
  token:   process.env.TALKER_TOKEN
  roomId:  process.env.TALKER_ROOM_ID

app.post "/travis", (request, response) ->
  payload = JSON.parse(request.body.payload)
  dataToRoom =
    repository: payload.repository
    duration: payload.duration
    build_url: payload.build_url
    branch: payload.branch
    commit: payload.commit
    compare_url: payload.compare_url

  # Check for authorization
  if TravisToken
    expected = crypto.
      createHash("sha256").
      update("#{payload.repository.owner_name}/#{payload.repository.name}#{TravisToken}").
      digest("hex")

    if expected != request.headers.authorization
      response.send("Invalid authorization")
      return

  requestBody = JSON.stringify(message: "TRAVIS BUILD " + JSON.stringify(dataToRoom))
  talkerReq = https.request({
    host: "talkerapp.com"
    path: "/rooms/#{Talker.roomId}/messages.json"
    method: "POST"
    headers: {
      "X-Talker-Token": Talker.token
      "Accept": "application/json"
      "Content-Type": "application/json"
      "Content-length": requestBody.length
    }
  }, (res) ->
    res.on "data", (data) -> console.log("Data from talker: #{data}")
  )

  talkerReq.on "error", (error) -> console.log "Error on request to talker: #{error}"
  talkerReq.end(requestBody)

  response.send("Ok")


unless TravisToken
  console.log "WARNING: TRAVIS_TOKEN is missing. Requests will be open"

do ->
  port = process.env.PORT || 5000
  app.listen port, ->
    console.log "Listening on #{port}"
