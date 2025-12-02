FROM px4io/px4-dev-nuttx-jammy

RUN apt update && apt install -y software-properties-common \
    && add-apt-repository universe

RUN apt install -y \
    vim \
    python3-pip python3-venv \
    curl lsb-release gnupg wget

RUN echo 'Acquire::http::Proxy "http://127.0.0.1:7890";' > /etc/apt/apt.conf.d/proxy.conf \
    && echo 'Acquire::https::Proxy "http://127.0.0.1:7890";' >> /etc/apt/apt.conf.d/proxy.conf

RUN DEBIAN_FRONTEND=noninteractive apt-get -y --quiet --no-install-recommends install \
    bc \
    ;
RUN echo "Gazebo (Harmonic) will be installed" && \
    echo "Earlier versions will be removed" && \
    # Add Gazebo binary repository
    wget https://packages.osrfoundation.org/gazebo.gpg -O /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null && \
    apt-get update -y --quiet

ENV gazebo_packages="gz-harmonic libunwind-dev"


RUN	DEBIAN_FRONTEND=noninteractive apt-get -y --quiet --no-install-recommends install \
    dmidecode \
    $gazebo_packages \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-ugly \
    gstreamer1.0-libav \
    libeigen3-dev \
    libgstreamer-plugins-base1.0-dev \
    libimage-exiftool-perl \
    libopencv-dev \
    libxml2-utils \
    pkg-config \
    protobuf-compiler \
    ;

RUN apt install -y locales \
    && locale-gen en_US.UTF-8 \
    &&  locale-gen zh_CN.UTF-8 \
    &&  update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

RUN export ROS_APT_SOURCE_VERSION=$(curl -s https://api.github.com/repos/ros-infrastructure/ros-apt-source/releases/latest | grep -F "tag_name" | awk -F\" '{print $4}') \
    && curl -L -o /tmp/ros2-apt-source.deb "https://github.com/ros-infrastructure/ros-apt-source/releases/download/${ROS_APT_SOURCE_VERSION}/ros2-apt-source_${ROS_APT_SOURCE_VERSION}.$(. /etc/os-release && echo ${UBUNTU_CODENAME:-${VERSION_CODENAME}})_all.deb" \
    && dpkg -i /tmp/ros2-apt-source.deb

RUN --mount=type=cache,target=/var/lib/apt/lists,id=apt_cache,sharing=locked \
    apt update && \
    apt install -y ros-humble-ros-base ros-dev-tools

RUN git clone https://github.com/WarriorHanamy/px4v1.16.git --depth=1 --recursive
WORKDIR /px4v1.16

ENV PATH="/px4v1.16/Tools:$PATH"
RUN make px4_sitl_default
#WORKDIR /plugins
#RUN . /opt/ros/humble/setup.sh \
#    && colcon build --symlink-install

#WORKDIR /px4-vtol
