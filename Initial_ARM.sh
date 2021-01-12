#!/usr/bin/env bash

# Es wird empfohlen root als Benutzer zu verwenden
Benutzer="root"


if [ "$(whoami)" != $Benutzer ]; then
        echo $(date -u) "Script muss als Benutzer $Benutzer ausgeführt werden!"
        exit 255
fi

echo $(date -u) "Test auf bestehende Installation.log"
                 test -f ~/Installation.log && rm ~/Installation.log

echo $(date -u) "Installation.log anlegen"
                 touch ~/Installation.log

####################################################################################################################
# JP4.4.1
#
#
echo $(date -u) "#####################################################################################################################################" | tee -a  ~/Installation.log
echo $(date -u) "# Zoneminder - Objekterkennung mit OpenCV (GPU), YOLO, cuDNN und CUDA auf NVIDIA Jetson - Plattform mit JP4.4.1     By WIEGEHTKI.DE #" | tee -a  ~/Installation.log
echo $(date -u) "# Zur freien Verwendung. Ohne Gewähr und nur auf Testsystemen anzuwenden                                                            #" | tee -a  ~/Installation.log
echo $(date -u) "#                                                                                                                                   #" | tee -a  ~/Installation.log
echo $(date -u) "# v1.0.1 (Rev a), 12.01.2021                                                                                                        #" | tee -a  ~/Installation.log
echo $(date -u) "#####################################################################################################################################" | tee -a  ~/Installation.log
echo $(date -u) "....................................................................................................................................." | tee -a  ~/Installation.log
echo $(date -u) "01 von 04: Linux - Check"    | tee -a  ~/Installation.log
                uname -m && cat /etc/*release | tee -a  ~/Installation.log

echo $(date -u) "....................................................................................................................................." | tee -a  ~/Installation.log
echo $(date -u) "02 von 04: System - Update & Upgrade"  | tee -a  ~/Installation.log
                apt -y update
                apt -y dist-upgrade

echo $(date -u) "....................................................................................................................................." | tee -a  ~/Installation.log
echo $(date -u) "03 von 04 Diverse Pakete installieren wie Compiler, Headers usw., welche für CUDA benötigt werden"  | tee -a  ~/Installation.log
                apt -y install gcc make nano letsencrypt
                apt -y install build-essential cmake pkg-config unzip yasm git checkinstall
                apt -y install libjpeg-dev libpng-dev libtiff-dev liblzma-doc
                apt -y install libavcodec-dev libavformat-dev libswscale-dev libavresample-dev
                apt -y install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev
                apt -y install libxvidcore-dev x264 libx264-dev libfaac-dev libmp3lame-dev libtheora-dev
                apt -y install libfaac-dev libmp3lame-dev libvorbis-dev
                apt -y install libopencore-amrnb-dev libopencore-amrwb-dev
                apt -y install libdc1394-22 libdc1394-22-dev libxine2-dev libv4l-dev v4l-utils libraw1394-doc
                cd /usr/include/linux
                ln -s -f ../libv4l1-videodev.h videodev.h
                cd ~
                #apt -y install install libgtk-3-dev
                apt -y install python3-testresources
                apt -y install libtbb-dev tbb-examples libtbb-doc
                apt -y install libatlas-base-dev gfortran 
                apt -y install libprotobuf-dev protobuf-compiler
                apt -y install libgoogle-glog-dev libgflags-dev
                apt -y install libgphoto2-dev libeigen3-dev libhdf5-dev doxygen
                apt -y install gcc-6

echo $(date -u) "....................................................................................................................................." | tee -a  ~/Installation.log
echo $(date -u) "04 von 04: Ende der Installation - Schritt 1"  | tee -a  ~/Installation.log
                cd ~

