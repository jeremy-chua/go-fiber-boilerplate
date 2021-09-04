# GoFiber Docker Boilerplate

![Reference](https://img.shields.io/github/release/gofiber/boilerplate.svg)

## Modifications


## Development

### Start the application 


```bash
go run app.go
```


## Production

```bash
docker build -t gofiber .
docker run -d -p 3000:3000 gofiber
```

Go to `http://localhost:3000`:


![Go Fiber Docker Boilerplate](./go_fiber_boilerplate.gif)