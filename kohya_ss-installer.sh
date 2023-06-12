#!/bin/bash

# Update the package repository
apt update

# Add deadsnakes PPA for installing Python 3.10
apt install -y software-properties-common
add-apt-repository -y ppa:deadsnakes/ppa
apt update

# Install required packages
apt install -y python3.10 python3.10-tk python3.10-distutils python3.10-dev

# Set Python 3.10 as the default Python interpreter
update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1

# Update pip
curl -sS https://bootstrap.pypa.io/get-pip.py | python3.10

# Add the pip script location to PATH
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
export PATH="$HOME/.local/bin:$PATH"

# Clone the repository
git clone https://github.com/kohya-ss/sd-scripts.git

# Install dependencies
cd sd-scripts
python3.10 -m pip install torch==1.13.1 torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu116
python3.10 -m pip install --use-pep517 --upgrade -r requirements.txt
# commenting out xformers because you should really just train in fp32 instead.
# Also, xformers tried to install pytorch 2 which is not what we want.
# python3.10 -m pip install xformers

# Check if the system has an NVIDIA A5000 GPU
if nvidia-smi --query-gpu=name --format=csv,noheader | grep -q "A5000"; then
  echo "NVIDIA A5000 GPU detected. Applying necessary fixes."

  # Install libjpeg and libpng
  sudo apt-get install -y libjpeg-dev libpng-dev

  # Reinstall torchvision
  python3.10 -m pip install --no-cache-dir --force-reinstall torchvision
  # commenting out xformers because you should really just train in fp32 instead.
  # Also, xformers tried to install pytorch 2 which is not what we want.
  python3.10 -m pip install xformers

  # Adjust TensorFlow, CUDA, and cuDNN installation if needed
fi

# Uninstall the system psutil package
sudo apt remove -y python3-psutil

# Install the psutil package for the local Python environment
python3.10 -m pip install --upgrade psutil

# Print a message to the user indicating the installation is complete
echo "Kohya SS has been installed. To launch the app, close this window and open terminal then run accelerate config."
echo "Accelerate config answers: this machine, no distributed training, NO, NO, NO, all, fp16."
echo "python3.10 (python3) has been installed as well."
# Exit the script
exit 0
