# ================================
# Build image
# ================================
FROM passivelogic/swift:swift-dev-2022-05-23-a as build

# Install OS updates and, if needed, sqlite3
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y \
    && rm -rf /var/lib/apt/lists/*
    
# Set up a build area
WORKDIR /build

# First just resolve dependencies.
# This creates a cached layer that can be reused
# as long as your Package.swift/Package.resolved
# files do not change.
COPY ./Package.* ./
RUN swift package resolve

# Copy entire repo into container
COPY . .

# Build oauth server
RUN swift build --product FluentDBReproducer --static-swift-stdlib

# Switch to the staging area
WORKDIR /staging

# Copy main executable & resources to staging area
RUN cp "$(swift build --package-path /build --show-bin-path)/FluentDBReproducer" ./

# Copy any resources from the public directory and views directory if the directories exist
# Ensure that by default, neither the directory nor any of its contents are writable.
RUN [ -d /build/Public ] && { mv /build/Public ./Public && chmod -R a-w ./Public; } || true
RUN [ -d /build/Resources ] && { mv /build/Resources ./Resources && chmod -R a-w ./Resources; } || true

# ================================
# Run image
# ================================
FROM ubuntu:focal

# Make sure all system packages are up to date.
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true && \
    apt-get -q update && apt-get -q dist-upgrade -y && apt-get install --yes libxml2-dev && rm -r /var/lib/apt/lists/*

# Create a reproducer user and group with /app as its home directory
RUN useradd --user-group --create-home --system --skel /dev/null --home-dir /app reproducer

# Switch to the new home directory
WORKDIR /app

# Copy built executable and any staged resources from builder
COPY --from=build --chown=reproducer:reproducer /staging /app
#COPY --from=build --chown=reproducer:reproducer /artifacts/bin/HiveController_WebServerApp.resources /usr/bin/HiveController_WebServerApp.resources


# Ensure all further commands run as the reproducer user
USER reproducer:reproducer

# Let Docker bind to port 8088
EXPOSE 8088

ENTRYPOINT ["./FluentDBReproducer"]
CMD ["serve", "--env", "dev", "--hostname", "0.0.0.0", "--port", "8088"]
