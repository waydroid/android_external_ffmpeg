LOCAL_PATH := $(call my-dir)
SRC_PATH := $(FFMPEG_DIR)

FFMPEG_MULTILIB := 32
include $(LOCAL_PATH)/../android/build.mk

ifeq ($(CONFIG_VAAPI),yes)
  LOCAL_SHARED_LIBRARIES += libva
endif

LOCAL_MULTILIB := $(FFMPEG_MULTILIB)
include $(BUILD_SHARED_LIBRARY)

FFMPEG_MULTILIB := 64
include $(LOCAL_PATH)/../android/build.mk

ifeq ($(CONFIG_VAAPI),yes)
  LOCAL_SHARED_LIBRARIES += libva
endif

LOCAL_MULTILIB := $(FFMPEG_MULTILIB)
include $(BUILD_SHARED_LIBRARY)
