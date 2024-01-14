git clone https://github.com/rordenlab/dcm2niix.git
cd dcm2niix
mkdir build && cd build
module load cmake
cmake .. # if needed: "cmake .. -DUSE_STATIC_RUNTIME=OFF -DCMAKE_INSTALL_PREFIX=/scratch/PATHTOBINFOLDER"
make # and with option above "make install"