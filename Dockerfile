ARG NODE_VERSION=10.18.1
FROM mhart/alpine-node:${NODE_VERSION} as alpine-node

ARG RUNTIME_DEPS='libpng-dev libjpeg-turbo libwebp tiff openexr jasper openblas libx11-dev zlib ffmpeg'
ARG BUILD_DEPS='xz wget unzip cmake build-base python linux-headers libjpeg-turbo-dev libwebp-dev tiff-dev openexr-dev jasper-dev openblas-dev zlib-dev ffmpeg-dev'
ARG OPENCV_VERSION=4.2.0
ARG LIB_PREFIX='/usr/local'

ENV OPENCV_VERSION=${OPENCV_VERSION} \
    LIB_PREFIX=${LIB_PREFIX} \
    OPENCV4NODEJS_DISABLE_AUTOBUILD=1 \
    FFMPEG_PATH='/usr/bin/ffmpeg' \
    FFPROBE_PATH='/usr/bin/ffprobe'

RUN apk add -u --no-cache --virtual .build-dependencies $BUILD_DEPS \
    && wget -q https://github.com/Itseez/opencv/archive/${OPENCV_VERSION}.zip -O opencv.zip \
    && wget -q https://github.com/Itseez/opencv_contrib/archive/${OPENCV_VERSION}.zip -O opencv_contrib.zip \
    && mkdir /opencv \
    && mv opencv.zip opencv_contrib.zip /opencv \
    && cd /opencv \
    && unzip -qq opencv.zip \
    && mv opencv-${OPENCV_VERSION} opencv \
    && unzip -qq opencv_contrib.zip \
    && mv opencv_contrib-${OPENCV_VERSION} opencv_contrib \
    && ls -la \
    && mkdir opencv/build \
    && cd opencv/build \
    && opencv_cmake_flags="-D CMAKE_BUILD_TYPE=RELEASE \
	-D BUILD_DOCS=OFF \
	-D BUILD_TESTS=OFF \
	-D BUILD_PERF_TESTS=OFF \
	-D BUILD_JAVA=OFF \
	-D BUILD_opencv_apps=OFF \
	-D BUILD_opencv_aruco=OFF \
	-D BUILD_opencv_bgsegm=OFF \
	-D BUILD_opencv_bioinspired=OFF \
	-D BUILD_opencv_ccalib=OFF \
	-D BUILD_opencv_datasets=OFF \
	-D BUILD_opencv_dnn_objdetect=OFF \
	-D BUILD_opencv_dpm=OFF \
	-D BUILD_opencv_fuzzy=OFF \
	-D BUILD_opencv_hfs=OFF \
	-D BUILD_opencv_java_bindings_generator=OFF \
	-D BUILD_opencv_js=OFF \
    -D BUILD_opencv_img_hash=OFF \
    -D BUILD_opencv_line_descriptor=OFF \
    -D BUILD_opencv_optflow=OFF \
    -D BUILD_opencv_phase_unwrapping=OFF \
	-D BUILD_opencv_python3=OFF \
	-D BUILD_opencv_python_bindings_generator=OFF \
	-D BUILD_opencv_reg=OFF \
	-D BUILD_opencv_rgbd=OFF \
	-D BUILD_opencv_saliency=OFF \
	-D BUILD_opencv_shape=OFF \
	-D BUILD_opencv_stereo=OFF \
	-D BUILD_opencv_stitching=OFF \
	-D BUILD_opencv_structured_light=OFF \
	-D BUILD_opencv_superres=OFF \
	-D BUILD_opencv_surface_matching=OFF \
	-D BUILD_opencv_ts=OFF \
	-D BUILD_opencv_xobjdetect=OFF \
	-D BUILD_opencv_xphoto=OFF \
	-D CMAKE_INSTALL_PREFIX=$LIB_PREFIX \
    -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules"

RUN cd /opencv/opencv/build \
    && cmake $opencv_cmake_flags .. \
    && make -j $(nproc) \
    && cd /opencv/opencv/build \
    && make install \
    && cd / \
    && rm -rf /opencv \
    && apk add -u --no-cache $RUNTIME_DEPS \
    && rm -rf /var/cache/apk/* /usr/share/man /usr/local/share/man /tmp/*

# Install opencv4nodejs
RUN apk update && apk add -u --no-cache python make g++
RUN npm i opencv4nodejs@5.5.0
