# CARDAMOM In Docker

## Introduction

This Docker setup allows you to easily run CARDAMOM in a containerized environment.

## Prerequisites

Make sure you have the following installed on your system:

- [Docker](https://www.docker.com/)

## Getting Started

1. **Build the Docker Image:**

   ```bash
   cd Docker/Dockerfile/
   docker build --platform linux/amd64 -t cardamom:latest .
   ```

2. **Run CARDAMOM Container:**

   ```bash
   docker run -t --rm cardamom:latest
   ```

3. **Run CARDAMOM_MDF.exe:**

   ```bash
    docker exec $(docker ps -q --filter "name=cardamom") C/projects/CARDAMOM_MDF/CARDAMOM_MDF.exe /path/to/input-file ./output_param_file.cbr
   ```
