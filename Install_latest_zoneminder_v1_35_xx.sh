#!/usr/bin/env bash

                #Es wird empfohlen root als Benutzer zu verwenden
                Benutzer="root"
                export DEBCONF_NONINTERACTIVE_SEEN="true"
                export DEBIAN_FRONTEND="noninteractive"
                export PHP_VERS="7.4"
                export OPENCV_VER="4.5.1"
                export PYTHON_VER="3.6"
                export OPENCV_URL=https://github.com/opencv/opencv/archive/$OPENCV_VER.zip
                export OPENCV_CONTRIB_URL=https://github.com/opencv/opencv_contrib/archive/$OPENCV_VER.zip
                export TZ="Europe/Berlin"
                export SHMEM="50%"
                export MULTI_PORT_START="0"
                export MULTI_PORT_END="0"
 
                #Vorbelegung CompilerFlags und Warnungen zu unterdrücken die durch automatisch generierten Code schnell mal entstehen können und keine wirkliche Relevanz haben
                export CFLAGS=$CFLAGS" -w"
                export CPPFLAGS=$CPPFLAGS" -w"
                export CXXFLAGS=$CXXFLAGS" -w"

                if [ "$(whoami)" != $Benutzer ]; then
                        echo $(date -u) "Script muss als Benutzer $Benutzer ausgeführt werden!"
                        exit 255
                fi

                echo $(date -u) "Test auf bestehende FinalInstall.log"
                      test -f ~/Installation.log && rm ~/Installation.log

                echo $(date -u) "FinalInstall.log anlegen"
                      touch ~/Installation.log

                #Highspeed - Modus setzen
                grep -q Jetson-AGX /proc/device-tree/model && sudo nvpmodel -m 3
                grep -q Xavier /proc/device-tree/model && sudo nvpmodel -m 2
                grep -q Nano /proc/device-tree/model   && sudo nvpmodel -m 0
                sudo jetson_clocks

echo $(date -u) "#################################################################################################################" | tee -a  ~/Installation.log
echo $(date -u) "# Zoneminder - Objekterkennung mit OpenCV, CUDA, cuDNN und YOLO auf Ubuntu 18.04 LTS            By WIEGEHTKI.DE #" | tee -a  ~/Installation.log
echo $(date -u) "# Zur freien Verwendung. Ohne Gewähr und nur auf Testsystemen anzuwenden                                        #" | tee -a  ~/Installation.log
echo $(date -u) "#                                                                                                               #" | tee -a  ~/Installation.log
echo $(date -u) "# V2.0.0 (Rev b), 23.01.2021                                                                                    #" | tee -a  ~/Installation.log
echo $(date -u) "#################################################################################################################" | tee -a  ~/Installation.log

echo $(date -u) "................................................................................................................." | tee -a  ~/Installation.log
echo $(date -u) "01 von 11: Linux - Check"    | tee -a  ~/Installation.log
                uname -m && cat /etc/*release | tee -a  ~/Installation.log

echo $(date -u) "................................................................................................................." | tee -a  ~/Installation.log
echo $(date -u) "02 von 11: System - Update & Upgrade"  | tee -a  ~/Installation.log
                apt -y update
                apt -y dist-upgrade

echo $(date -u) "................................................................................................................." | tee -a  ~/Installation.log
echo $(date -u) "03 von 11 Diverse Pakete installieren wie Compiler, Headers usw., welche für CUDA benötigt werden"  | tee -a  ~/Installation.log
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
                apt -y install python3-testresources
                #pt -y install libtbb-dev 
                #tbb-examples libtbb-doc
                apt -y install libatlas-base-dev gfortran 
                apt -y install libprotobuf-dev protobuf-compiler
                apt -y install libgoogle-glog-dev libgflags-dev
                apt -y install libgphoto2-dev libeigen3-dev libhdf5-dev doxygen
                #apt -y install gcc-6
                cd ~

echo $(date -u) "................................................................................................................." | tee -a  ~/Installation.log
echo $(date -u) "04 von 11: Systemupdate und Apache, MySQL und PHP installieren"  | tee -a  ~/Installation.log
                #apt -y upgrade
                #apt -y dist-upgrade

                apt -y install tasksel
                     
                add-apt-repository -y ppa:iconnor/zoneminder-master
                apt -y update
                apt -y upgrade
                apt -y dist-upgrade
                
                tasksel install lamp-server
                apt -y install python3-pip cmake
                pip3 install --upgrade pip
                apt -y install libopenblas-dev liblapack-dev libblas-dev

                #Mysql
                  
                if [ -f /etc/mysql/mysql.conf.d/mysqld.cnf ]; then
                    rm /etc/mysql/my.cnf
                    cp /etc/mysql/mysql.conf.d/mysqld.cnf /etc/mysql/my.cnf
                fi
                
                echo "default-time-zone='+01:00'" >> /etc/mysql/my.cnf
                echo "sql_mode        = NO_ENGINE_SUBSTITUTION" >> /etc/mysql/my.cnf
                mysql_tzinfo_to_sql /usr/share/zoneinfo/Europe/ | sudo mysql -u root mysql
                sudo mysql -e "SET GLOBAL time_zone = 'Berlin';"

                systemctl restart mysql

echo $(date -u) "................................................................................................................." | tee -a  ~/Installation.log
echo $(date -u) "05 von 11: Apache konfigurieren, SSL-Zertifikate generieren und Zoneminder installieren"  | tee -a  ~/Installation.log
                apt -y install zoneminder
                sudo apt -y install ntp ntp-doc
                apt -y install ssmtp mailutils net-tools wget sudo make
                apt -y install php$PHP_VERS php$PHP_VERS-fpm libapache2-mod-php$PHP_VERS php$PHP_VERS-mysql php$PHP_VERS-gd
                apt -y install libcrypt-mysql-perl libyaml-perl libjson-perl libavutil-dev ffmpeg && \
                apt -y install --no-install-recommends libvlc-dev libvlccore-dev vlc

                mysql -uroot --skip-password < /usr/share/zoneminder/db/zm_create.sql
                #mysql -uroot --skip-password -e "grant lock tables,alter,drop,select,insert,update,delete,create,index,alter routine,create routine, trigger,execute on zm.* to 'zmuser'@localhost identified by 'zmpass';"
                #mysql -uroot --skip-password < ~/zoneminder/sql/mod.sql
                mysqladmin -uroot --skip-password reload
                #mysql -u zmuser -pzmpass  -D zm  < /usr/share/zoneminder/db/zm_update-1.35.16.sql

                chown root:www-data /etc/zm/zm.conf
                chown -R www-data:www-data /usr/share/zoneminder/

                a2enmod cgi
                a2enmod rewrite
                a2enconf zoneminder
                a2enmod expires
                a2enmod headers

                if [ -f /etc/php/$PHP_VERS/cli/php.ini ]; then
                    sed -i "s|^;date.timezone =.*|date.timezone = ${TZ}|" /etc/php/$PHP_VERS/cli/php.ini
                fi
                if [ -f /etc/php/$PHP_VERS/apache2/php.ini ]; then
                    sed -i "s|^;date.timezone =.*|date.timezone = ${TZ}|" /etc/php/$PHP_VERS/apache2/php.ini
                fi
                if [ -f /etc/php/$PHP_VERS/fpm/php.ini ]; then
                    sed -i "s|^;date.timezone =.*|date.timezone = ${TZ}|" /etc/php/$PHP_VERS/fpm/php.ini
                fi
                
                if [[ $(cat /etc/timezone) != "$TZ" ]] ; then
                    echo "Setzen der Zeitzone auf: $TZ"
                    echo $TZ > /etc/timezone
                    ln -fs /usr/share/zoneinfo/$TZ /etc/localtime
                    dpkg-reconfigure tzdata -f noninteractive
                    echo "Datum: `date`"
                fi
                
                mkdir /etc/apache2/ssl/
                mkdir /etc/zm/apache2/
                mkdir /etc/zm/apache2/ssl/
                mv /root/zoneminder/apache/default-ssl.conf    /etc/apache2/sites-enabled/default-ssl.conf
                cp /etc/apache2/ports.conf                     /etc/apache2/ports.conf.default
                cp /etc/apache2/sites-enabled/default-ssl.conf /etc/apache2/sites-enabled/default-ssl.conf.default

                echo "localhost" >> /etc/apache2/ssl/ServerName
                export SERVER=`cat /etc/apache2/ssl/ServerName`
                # Test wegen doppelten Einträgen UW 9.1.2021
                (echo "ServerName" $SERVER && cat /etc/apache2/apache2.conf) > /etc/apache2/apache2.conf.old && mv  /etc/apache2/apache2.conf.old /etc/apache2/apache2.conf

                if [[ -f /etc/apache2/ssl/cert.key && -f /etc/apache2/ssl/cert.crt ]]; then
                    echo "Bestehendes Zertifikat gefunden in \"/etc/apache2/ssl/cert.key\""  | tee -a  ~/Installation.log
                else
                    echo "Es werden self-signed keys in /etc/apache2/ssl/ generiert, bitte mit den eigenen Zertifikaten bei Bedarf ersetzen"  | tee -a  ~/Installation.log
                    mkdir -p /config/keys
                    dd if=/dev/urandom of=~/.rnd bs=256 count=1
                    chmod 600 ~/.rnd
                    openssl req -x509 -nodes -days 4096 -newkey rsa:2048 -out /etc/apache2/ssl/cert.crt -keyout /etc/apache2/ssl/cert.key -subj "/C=DE/ST=HE/L=Frankfurt/O=Zoneminder/OU=Zoneminder/CN=localhost"
                fi

                #chown root:root /config/keys
                chmod 777 /etc/apache2/ssl
                a2enmod proxy_fcgi setenvif
                a2enconf php$PHP_VERS-fpm
                systemctl reload apache2
                adduser www-data video

                echo "extension=apcu.so"   > /etc/php/$PHP_VERS/mods-available/apcu.ini
                echo "extension=mcrypt.so" > /etc/php/$PHP_VERS/mods-available/mcrypt.ini
                
                systemctl enable zoneminder
                systemctl start zoneminder

echo $(date -u) "................................................................................................................." | tee -a  ~/Installation.log
echo $(date -u) "06 von 11: zmeventnotification installieren"  | tee -a  ~/Installation.log
                sudo apt -y install python3-matplotlib libgeos-dev
                python3 -m pip install numpy scipy ipython pandas sympy nose cython
                python3 -m pip install future

                cp -r ~/zoneminder/Anzupassen/. /etc/zm/.
                cp -r ~/zoneminder/zmeventnotification/EventServer.zip ~/.
                unzip EventServer
                cd ~/EventServer
                chmod -R +x *
                ./install.sh --install-hook --install-es --no-install-config --no-interactive
                cd ~
                cp EventServer/zmeventnotification.ini /etc/zm/. -r
                chmod +x /var/lib/zmeventnotification/bin/*


                yes | perl -MCPAN -e "install Crypt::MySQL"
                yes | perl -MCPAN -e "install Config::IniFiles"
                yes | perl -MCPAN -e "install Crypt::Eksblowfish::Bcrypt"

                apt -y install libyaml-perl
                apt -y install make
                yes | perl -MCPAN -e "install Net::WebSocket::Server"

                apt -y install libjson-perl
                yes | perl -MCPAN -e "install LWP::Protocol::https"
                yes | perl -MCPAN -e "install Net::MQTT::Simple"

echo $(date -u) "................................................................................................................." | tee -a  ~/Installation.log
echo $(date -u) "07 von 11: Gesichtserkennung und cuDNN installieren"  | tee -a  ~/Installation.log
                # Face recognition, umschalten auf CUDA. Bisherigen (CPU-) dlib de-installieren
                sudo -H pip3 uninstall dlib
                sudo -H pip3 uninstall face-recognition
                rm /usr/bin/python
                ln -sf python$PYTHON_VER /usr/bin/python
                apt -y install libopenblas-dev liblapack-dev libblas-dev # this is the important part
                cd ~/zoneminder/dlib
                python ./setup.py install 
                python3 -m pip install face_recognition
                cd ~

echo $(date -u) "................................................................................................................." | tee -a  ~/Installation.log
echo $(date -u) "08 von 11: Gesichtserkennung und cuDNN installieren"  | tee -a  ~/Installation.log
                #opencv compilieren
                apt -y install python-dev python3-dev
                apt -y install python-pip
                python2 -m pip  install numpy

                cd ~
                wget  -O opencv.zip $OPENCV_URL
                wget  -O opencv_contrib.zip $OPENCV_CONTRIB_URL
                unzip opencv.zip
                unzip opencv_contrib.zip
                mv $(ls -d opencv-*) opencv
                mv opencv_contrib-$OPENCV_VER opencv_contrib
                #rm *.zip

                cd ~/opencv
                rm -rf build
                mkdir build
                cd build

                #Wichtig: Je nach Karte wählen - CUDA_ARCH_BIN = https://en.wikipedia.org/wiki/CUDA 
                cmake -D CMAKE_BUILD_TYPE=RELEASE \
                      -D CMAKE_INSTALL_PREFIX=/usr/local \
                      -D INSTALL_PYTHON_EXAMPLES=OFF \
                      -D INSTALL_C_EXAMPLES=OFF \
                      -D OPENCV_ENABLE_NONFREE=ON \
                      -D WITH_CUDA=ON \
                      -D WITH_CUDNN=ON \
                      -D OPENCV_DNN_CUDA=ON \
                      -D ENABLE_FAST_MATH=1 \
                      -D CUDA_FAST_MATH=1 \
                      -D CUDA_ARCH_PTX="" \
                      -D CUDA_ARCH_BIN="5.3,6.2,7.2" \
                      -D WITH_CUBLAS=1 \
                      -D OPENCV_EXTRA_MODULES_PATH=~/opencv_contrib/modules \
                      -D HAVE_opencv_python3=ON \
                      -D PYTHON_EXECUTABLE=/usr/bin/python3 \
                      -D PYTHON2_EXECUTABLE=/usr/bin/python2 \
                      -D PYTHON_DEFAULT_EXECUTABLE=$(which python3) \
                      -D PYTHON_INCLUDE_DIR=$(python -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())")  \
                      -D PYTHON_LIBRARY=$(python -c "import distutils.sysconfig as sysconfig; print(sysconfig.get_config_var('LIBDIR'))") \
                      -D BUILD_EXAMPLES=OFF ..

                make -j$(nproc)
                make install

                echo "Test auf CUDA enabled Devices, muss größer 0 sein:" | tee -a  ~/Installation.log
                echo "import cv2" | tee -a  ~/Installation.log
                echo "count = cv2.cuda.getCudaEnabledDeviceCount()" | tee -a  ~/Installation.log
                echo "print(count)" | tee -a  ~/Installation.log

                chown root:www-data /etc/zm/conf.d/*.conf
                chmod 640 /etc/zm/conf.d/*.conf

echo $(date -u) "................................................................................................................." | tee -a  ~/Installation.log
echo $(date -u) "09 von 11: Anpassungen Zoneminder"  | tee -a  ~/Installation.log
                cp -r ~/zoneminder/Bugfixes/face_train.py /usr/local/lib/python$PYTHON_VER/dist-packages/pyzm/ml/face_train.py
                echo "Installation beendet, bitte Rechner neu starten (reboot)"
                echo ""

                cp -r ~/zoneminder/Anzupassen/. /etc/zm/.
                # Fix memory issue
                echo "Setzen shared memory auf :" $SHMEM "von `awk '/MemTotal/ {print $2}' /proc/meminfo` bytes"  | tee -a  ~/Installation.log
                umount /dev/shm
                mount -t tmpfs -o rw,nosuid,nodev,noexec,relatime,size=${SHMEM} tmpfs /dev/shm

                if [ $((MULTI_PORT_START)) -gt 0 ] && [ $((MULTI_PORT_END)) -gt $((MULTI_PORT_START)) ]; then

                         echo "Einstellung ES-Multiport-Bereich von ${MULTI_PORT_START} bis ${MULTI_PORT_END}."  | tee -a  ~/Installation.log

                         ORIG_VHOST="_default_:443"
                         NEW_VHOST=${ORIG_VHOST}
                         PORT=${MULTI_PORT_START}
                         while [[ ${PORT} -le ${MULTI_PORT_END} ]]; do
                             egrep -sq "Listen ${PORT}" /etc/apache2/ports.conf || echo "Listen ${PORT}" >> /etc/apache2/ports.conf
                             NEW_VHOST="${NEW_VHOST} _default_:${PORT}"
                             PORT=$(($PORT + 1))
                         done
                         perl -pi -e "s/${ORIG_VHOST}/${NEW_VHOST}/ if (/<VirtualHost/);" /etc/apache2/sites-enabled/default-ssl.conf
                else
                         if [ $((MULTI_PORT_START)) -ne 0 ];then
                             echo "Multi-port error start ${MULTI_PORT_START}, end ${MULTI_PORT_END}."  | tee -a  ~/Installation.log
                         fi
                fi
                
                chown -R root:www-data /etc/apache2/ssl/*
                a2enmod ssl

echo $(date -u) "................................................................................................................." | tee -a  ~/Installation.log
echo $(date -u) "10 von 11: Libraries und FFMPeg für CUDA installieren"  | tee -a  ~/Installation.log
                installLibs(){
                echo "Notwendige Pakete installieren"
                sudo apt-get update
                sudo apt-get -y --force-yes install autoconf automake build-essential libass-dev libfreetype6-dev libgpac-dev \
                     libsdl1.2-dev libtheora-dev libtool libva-dev libvdpau-dev libvorbis-dev libxcb1-dev libxcb-shm0-dev \
                     libxcb-xfixes0-dev pkg-config texi2html zlib1g-dev libopus-dev
                }
                  
               #Install nvidia SDK
               installSDK(){
               echo "Installieren NVIDIA Codecs."
               cd ~/ffmpeg_sources
               cd ~/ffmpeg_sources
               git clone https://git.videolan.org/git/ffmpeg/nv-codec-headers.git
               cd nv-codec-headers
               make
               sudo make install
               }
               
               #nasm
               compileNasm(){
               echo "Kompilieren von nasm"
               cd ~/ffmpeg_sources
               wget https://www.nasm.us/pub/nasm/releasebuilds/2.15.05/nasm-2.15.05.tar.gz
               tar xzvf nasm-2.15.05.tar.gz
               cd nasm-2.15.05
               ./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin"
               make -j$(nproc)
               make -j$(nproc) install
               make -j$(nproc) distclean
               }
               
               #libx264
               compileLibX264(){
               echo "Kompilieren von libx264"
               cd ~/ffmpeg_sources
               wget https://download.videolan.org/pub/x264/snapshots/x264-snapshot-20191217-2245-stable.tar.bz2 
               tar xjvf x264-snapshot-20191217-2245-stable.tar.bz2
               cd x264-snapshot-20191217-2245-stable
               PATH="$HOME/bin:$PATH" ./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" --enable-static
               PATH="$HOME/bin:$PATH" make -j$(nproc)
               make -j$(nproc) install
               make -j$(nproc) distclean
               }
               
               #libfdk-acc
               compileLibfdkcc(){
               echo "Kompilieren von libfdk-cc"
               sudo apt-get install unzip
               cd ~/ffmpeg_sources
               wget -O fdk-aac.zip https://github.com/mstorsjo/fdk-aac/zipball/master
               unzip fdk-aac.zip
               cd mstorsjo-fdk-aac*
               autoreconf -fiv
               ./configure --prefix="$HOME/ffmpeg_build" --disable-shared
               make -j$(nproc)
               make -j$(nproc) install
               make -j$(nproc) distclean
               }
               
               #libmp3lame
               compileLibMP3Lame(){
               echo "Kompilieren von libmp3lame"
               sudo apt-get install nasm
               cd ~/ffmpeg_sources
               wget http://downloads.sourceforge.net/project/lame/lame/3.100/lame-3.100.tar.gz
               tar xzvf lame-3.100.tar.gz
               cd lame-3.100
               ./configure --prefix="$HOME/ffmpeg_build" --enable-nasm --disable-shared
               make -j$(nproc)
               make -j$(nproc) install
               make -j$(nproc) distclean
               }
               
               #libopus
               compileLibOpus(){
               echo "Kompilieren von libopus"
               cd ~/ffmpeg_sources
               wget http://downloads.xiph.org/releases/opus/opus-1.3.1.tar.gz
               tar xzvf opus-1.3.1.tar.gz
               cd opus-1.3.1
               ./configure --prefix="$HOME/ffmpeg_build" --disable-shared
               make -j$(nproc)
               make -j$(nproc) install
               make -j$(nproc) distclean
               }

               #libx265
               compileLibX265(){
               echo "Kompilieren von libx265"               
               cd ~
               git clone https://bitbucket.org/multicoreware/x265_git
               cd x265_git/build/linux
               cmake -G "Unix Makefiles" ../../source
               make install
               }

               #libvpx
               compileLibPvx(){
               echo "Kompilieren von libvpx"
               cd ~/ffmpeg_sources
               git clone https://chromium.googlesource.com/webm/libvpx
               cd libvpx
               PATH="$HOME/bin:$PATH" ./configure --prefix="$HOME/ffmpeg_build" --disable-examples --enable-runtime-cpu-detect --enable-vp9 --enable-vp8 \
               --enable-postproc --enable-vp9-postproc --enable-multi-res-encoding --enable-webm-io --enable-better-hw-compatibility --enable-vp9-highbitdepth --enable-onthefly-bitpacking --enable-realtime-only \
               --cpu=native --as=nasm
               PATH="$HOME/bin:$PATH" make -j$(nproc)
               make -j$(nproc) install
               make -j$(nproc) clean
               }
               
               #ffmpeg
               compileFfmpeg(){
               echo "Kompilieren von ffmpeg"
               cd ~/ffmpeg_sources
               git clone https://github.com/FFmpeg/FFmpeg -b master
               cd FFmpeg

               PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure \
                 --prefix="$HOME/ffmpeg_build" \
                 --extra-cflags="-I$HOME/ffmpeg_build/include" \
                 --extra-ldflags="-L$HOME/ffmpeg_build/lib" \
                 --bindir="$HOME/bin" \
                 --enable-cuda-nvcc \
                 --enable-cuvid \
                 --enable-libnpp \
                 --extra-cflags="-I/usr/local/cuda/include/" \
                 --extra-ldflags=-L/usr/local/cuda/lib64/ \
                 --enable-gpl \
                 --enable-libass \
                 --enable-libfdk-aac \
                 --enable-vaapi \
                 --enable-libfreetype \
                 --enable-libmp3lame \
                 --enable-libopus \
                 --enable-libtheora \
                 --enable-libvorbis \
                 --enable-libvpx \
                 --enable-libx264 \
                 --enable-libx265 \
                 --enable-nonfree \
                 --enable-nvenc \
                 --pkg-config-flags="--static"
                 
               PATH="$HOME/bin:$PATH" make -j$(nproc)
               make -j$(nproc) install
               make -j$(nproc) distclean
               hash -r
               }
               
               #The process
               export PATH=/usr/local/cuda/bin${PATH:+:${PATH}}
               export LD_LIBRARY_PATH=/usr/local/cuda/lib64\${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
               
               #Monitoring jtop installieren
               sudo -H pip install -U jetson-stats
               #apt -y install atop
               #pip install nvidia-ml-py3
               
               cd ~
               mkdir ffmpeg_sources
               installLibs
               InstallCUDASDK
               installSDK
               compileNasm
               compileLibX264
               compileLibX265
               compileLibfdkcc
               compileLibMP3Lame
               compileLibOpus
               compileLibPvx
               compileFfmpeg
               cp ~/bin/ffmpeg  /usr/bin/ -r
               echo "Libraries und ffmpeg kompiliert!"
               
echo $(date -u) "................................................................................................................." | tee -a  ~/Installation.log
echo $(date -u) "11 von 11: Bugfixes kopieren und Ende"  | tee -a  ~/Installation.log
                #Bugfixes
                python3 -m pip install protobuf==3.3.0
                python3 -m pip install numpy==1.16.1
                chown -R  www-data:www-data /etc/apache2/ssl
                yes | perl -MCPAN -e "upgrade IO::Socket::SSL"
                cd ~
                zmupdate.pl -f
                echo ""
                echo "Installation abgeschlossen, bitte Log prüfen, hosts - Datei aktualisieren (siehe Video auf WIEGEHTKI.DE) und Jetson neu starten (reboot)"

                #Test:
                #https://zm.wiegehtki.de/zm/api/host/getVersion.json
                #https://zm.wiegehtki.de/zm/?view=image&eid=<EVENTID_EINSETZEN>&fid=snapshot
                #https://zm.wiegehtki.de/zm/?view=image&eid=<EVENTID_EINSETZEN>&fid=alarm

                ##### Verzeichnis für Gesichtstraining
                #/var/lib/zmeventnotification/known_faces

                #sudo -u www-data /var/lib/zmeventnotification/bin/zm_train_faces.py
                #sudo -u www-data /var/lib/zmeventnotification/bin/zm_detect.py --config /etc/zm/objectconfig.ini  --eventid 1 --monitorid 1 --debug
                #chown -R www-data:www-data /var/lib/zmeventnotification/known_faces
                #echo "<DEINE_IP>  <DEINE_DOMAIN>" >> /etc/hosts

                ##### Link für Reolink Kameras, getestet mit RL410 #####
                #rtmp://<KAMERA_IP>/bcs/channel0_main.bcs?channel=0&stream=0&user=admin&password=<Dein Passwort>



