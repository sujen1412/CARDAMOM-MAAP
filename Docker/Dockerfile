# Use a base image with Conda
FROM --platform=linux/amd64 continuumio/miniconda3:latest

WORKDIR /app

# Install Git
RUN apt-get update && \
    apt-get install -y git

# Clone the Git repository into the container
RUN git clone https://github.com/CARDAMOM-framework/CARDAMOM_v2.3.git .

# Create and activate a Conda environment
RUN conda create --name myenv python=3.10 -y

# Install required Conda packages
RUN conda install conda-forge::gcc conda-forge::netcdf4 conda-forge::hdf5 -y

# Run the CARDAMOM_COMPILE.sh
CMD ["bash", "BASH/CARDAMOM_COMPILE.sh"]
