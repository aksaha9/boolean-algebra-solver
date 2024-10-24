# Stage 1: Build and package DOSBox and your program
FROM ubuntu:20.04 AS builder

# Install dependencies, including tzdata with pre-seeded answer
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        git \
        wget \
        build-essential \
        python3 \
        python3-pip \
        tzdata \
        curl \
        && echo "Europe/London" > /etc/timezone \
        && dpkg-reconfigure -f noninteractive tzdata \
        && apt-get clean 

# Install Node.js and npm
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean

# Install Emscripten from GitHub (replace with the latest release tag if needed)
RUN git clone https://github.com/emscripten-core/emsdk.git && \
    cd emsdk && \
    ./emsdk install 3.1.65 && \
    ./emsdk activate 3.1.65

# Get the Emscripten version and store it in a file
RUN bash -c "source /emsdk/emsdk_env.sh && \
             emcc --version > /tmp/emscripten_version.txt" 
    
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    automake \
    python

# Clone the em-dosbox repository
RUN git clone https://github.com/dreamlayers/em-dosbox.git

# Comment out the --memory-init-file 0 line in src/Makefile.am using sed
RUN sed -i 's/dosbox_LDFLAGS+=--memory-init-file 0/#dosbox_LDFLAGS+=--memory-init-file 0/g' em-dosbox/src/Makefile.am

# Compile DOSBox to JavaScript (Emscripten)
# Use bash explicitly for the RUN instruction and source the environment within it
RUN bash -c "source /emsdk/emsdk_env.sh && \
             cd em-dosbox && \
             ./autogen.sh && \
             emconfigure ./configure && \
             make"


# Package my dos program BOOLEAN1.COM
COPY binary/BOOLEAN1.COM /em-dosbox/src
COPY packager.py /em-dosbox/src
RUN bash -c "pip3 install configparser"
RUN bash -c "source /emsdk/emsdk_env.sh && \
            cd em-dosbox/src && \
            ./packager.py boolalg BOOLEAN1.COM"

# Stage 2: Final image with only the necessary files
#FROM node:18-alpine 
# CVE-2024-6119⁠ Fix
#FROM node:slim
FROM node:20-slim

# Create the app directory
WORKDIR /app

# Copy the index.html file
# This index.html files serves as the landing page for the users
# of the web application. It provides an introduction to the 
# boolean algebra program that I had created in 1991 using PASCAL
# on MS-DOS and now packaged it to run as a web application using 
# DOSBox and Emscripten.
# Boolean Algebra Software
# -------------------------
# This software was created by me in 1991 using PASCAL on MS-DOS.
# It is a simple program that allows you to enter a boolean expression
# and it will evaluate the expression and display the truth table and
# minterm canonical form of the input expression.
# The program is called BOOLEAN1.COM and it is packaged to run as a
# web application using DOSBox and Emscripten.
# The program is available in the DOSBox emulator below.
# ----------------------------------------------
COPY index.html .
# Copy the generated files from the builder stage
COPY --from=builder /em-dosbox/src/boolalg.html .
COPY --from=builder /em-dosbox/src/boolalg.data .
COPY --from=builder /em-dosbox/src/dosbox.html .
COPY --from=builder /em-dosbox/src/dosbox.js .
COPY --from=builder /em-dosbox/src/dosbox.wasm .

# Copy the Emscripten version file
COPY --from=builder /tmp/emscripten_version.txt /tmp/emscripten_version.txt

# Install http-server
RUN npm install -g http-server

# Expose the web server port
EXPOSE 8080

# Start the web server
CMD ["http-server"]