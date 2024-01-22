#
# Copyright (C) 2013-2017 The Android-x86 Open Source Project
#
# Licensed under the GNU General Public License Version 2 or later.
# You may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.gnu.org/licenses/gpl.html
#

ifndef FFDROID_DIR
FFDROID_DIR := $(FFMPEG_DIR)android
endif

include $(CLEAR_VARS)
include $(FFDROID_DIR)/ffmpeg.mk

FFMPEG_ARCH_DIR := $(FFMPEG_ARCH)
ifeq ($(FFMPEG_ARCH),x86_64)
    FFMPEG_ARCH_DIR := x86
endif

$(foreach V,$(FF_VARS),$(eval $(call RESET,$(V))))
#$(warning INCLUDING $(wildcard $(LOCAL_PATH)/$(FFMPEG_ARCH)/Makefile) for $(FFMPEG_2ND_ARCH) - $(NEON-OBJS) - $(FF_VARS))

SUBDIR := $(FFDROID_DIR)/include/
include $(FFDROID_DIR)/config.mak
include $(LOCAL_PATH)/Makefile $(wildcard $(LOCAL_PATH)/$(FFMPEG_ARCH_DIR)/Makefile)
include $(FFMPEG_DIR)ffbuild/arch.mak

# remove duplicate objects
OBJS := $(sort $(OBJS) $(OBJS-yes))

ASM_SUFFIX := $(if $(filter x86,$(FFMPEG_ARCH_DIR)),asm,S)
ALL_S_FILES := $(subst $(LOCAL_PATH)/,,$(wildcard $(LOCAL_PATH)/$(FFMPEG_ARCH_DIR)/*.$(ASM_SUFFIX)))
ALL_S_FILES := $(if $(filter S,$(ASM_SUFFIX)),$(ALL_S_FILES),$(filter $(patsubst %.o,%.asm,$(X86ASM-OBJS) $(X86ASM-OBJS-yes)),$(ALL_S_FILES)))

ifneq ($(ALL_S_FILES),)
S_OBJS := $(ALL_S_FILES:%.$(ASM_SUFFIX)=%.o)
C_OBJS := $(filter-out $(S_OBJS),$(OBJS))
S_OBJS := $(filter $(S_OBJS),$(OBJS))
else
C_OBJS := $(OBJS)
S_OBJS :=
endif

C_FILES := $(C_OBJS:%.o=%.c)
S_FILES := $(S_OBJS:%.o=%.$(ASM_SUFFIX))

LOCAL_MODULE := lib$(NAME)
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := SHARED_LIBRARIES
LOCAL_ARM_MODE := arm
LOCAL_PROPRIETARY_MODULE := true

LOCAL_SRC_FILES := $(C_FILES) $(S_FILES)

LOCAL_C_INCLUDES := $(SUBDIR) $(FFMPEG_DIR)

LOCAL_EXPORT_C_INCLUDE_DIRS := $(LOCAL_C_INCLUDES)

# Base flags
LOCAL_CFLAGS += \
	-O3 -std=c99 -fno-math-errno -fno-signed-zeros -fomit-frame-pointer -fPIC
# Warnings disabled by FFMPEG
LOCAL_CFLAGS += \
	-Wno-parentheses -Wno-switch -Wno-format-zero-length -Wno-pointer-sign \
	-Wno-unused-const-variable -Wno-bool-operation -Wno-deprecated-declarations \
	-Wno-unused-variable
# Additional flags required for AOSP/clang
LOCAL_CFLAGS += \
	-Wno-unused-parameter -Wno-missing-field-initializers \
	-Wno-incompatible-pointer-types-discards-qualifiers -Wno-sometimes-uninitialized \
	-Wno-unneeded-internal-declaration -Wno-initializer-overrides -Wno-string-plus-int \
	-Wno-absolute-value -Wno-constant-conversion

LOCAL_ASFLAGS_x86 := -Pconfig-x86.asm
LOCAL_ASFLAGS_x86_64 := -Pconfig-x86_64.asm

LOCAL_LDFLAGS := -Wl,--no-fatal-warnings -Wl,-Bsymbolic
LOCAL_LDFLAGS_x86 := -Wl,-z,notext

LOCAL_CLANG_CFLAGS += -Wno-unknown-attributes
LOCAL_CLANG_ASFLAGS += $(if $(filter x86,$(FFMPEG_ARCH_DIR)),,-no-integrated-as)

LOCAL_SHARED_LIBRARIES := $($(NAME)_FFLIBS:%=lib%)
