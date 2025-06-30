cmake_minimum_required(VERSION 3.10)
project(Colorizer LANGUAGES OBJCXX)


# Détection automatique d'OpenCV
find_package(OpenCV REQUIRED)
include_directories(${OpenCV_INCLUDE_DIRS})


set(NEURAL_FILES
    ${CMAKE_SOURCE_DIR}/neural/colorization_deploy_v2.prototxt
    ${CMAKE_SOURCE_DIR}/neural/colorization_release_v2.caffemodel
)

set_source_files_properties(${NEURAL_FILES} PROPERTIES
    MACOSX_PACKAGE_LOCATION "Resources/neural"
)

set(IMAGES_FILES
    ${CMAKE_SOURCE_DIR}/images/Love-Strong.jpg
)

set_source_files_properties(${IMAGES_FILES} PROPERTIES
    MACOSX_PACKAGE_LOCATION "Resources/images"
)


add_executable(Colorizer MACOSX_BUNDLE
    main.mm
    AppDelegate.mm
    AppDelegate.h
    OpenCVHelper.mm
    OpenCVHelper.h
    Image.mm
    Image.h
    ${NEURAL_FILES}
    ${IMAGES_FILES}
)

set_target_properties(Colorizer PROPERTIES
    MACOSX_BUNDLE TRUE
    MACOSX_BUNDLE_INFO_PLIST "${CMAKE_SOURCE_DIR}/Info.plist"
)

target_link_libraries(Colorizer "-framework Cocoa"  "-framework UniformTypeIdentifiers" ${OpenCV_LIBS})

# file(COPY ${CMAKE_SOURCE_DIR}/neural DESTINATION ${CMAKE_BINARY_DIR})
# file(COPY ${CMAKE_SOURCE_DIR}/images DESTINATION ${CMAKE_BINARY_DIR})

# set(RESOURCES_FOLDER "${CMAKE_BINARY_DIR}/Colorizer.app/Contents/Resources")
# file(COPY ${CMAKE_SOURCE_DIR}/neural DESTINATION ${RESOURCES_FOLDER})
# file(COPY ${CMAKE_SOURCE_DIR}/images DESTINATION ${RESOURCES_FOLDER})
