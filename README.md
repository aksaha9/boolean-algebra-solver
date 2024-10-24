# boolean-algebra-solver
A Dockerized Web assembly version of my own legacy Boolean algebra program created on legacy Pascal on 16 bit MS-DOS which solves boolean equations

# My Boolean Algebra App

This is a Dockerized version of my Boolean algebra program, BOOLEAN1.COM, which I created in 1991 using PASCAL on MS-DOS. It has been packaged to run as a web application using DOSBox and Emscripten.

The boolean algebra program essentially is able to accept an interactive input of a boolean equation like A.B + B.C and then display its truth tables or minterm canonical form . The top - (bar) sign for a boolean variable signifying not is replaced by a back quote ` so mentioning A` will mean "not A"

## Running instance on the web

This is the running instance available on the web to try out my boolean algebra equation solver application -

http://ashish-saha.astuteinnovator.com/

## Building 

To build the Docker image, run the following command:

```bash
docker build -t my-boolean-algebra-app .
```

## Running

To run the image, use the following command:

```bash
docker run -p 5001:8080 my-boolean-algebra-app
```

This will start a container from the image and forward port 5001 on the host machine to port 8080 in the container. You can then access the application in your web browser at http://localhost:5001
