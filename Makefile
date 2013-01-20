CC = gcc
CFLAGS =
AR = ar rc

BUILD = build
LIBSRCS = helper.c
LIBNAME = libutil.a

CH01SRCS = 0101.c
CH02SRCS = 0201.c

BUILD_O = $(BUILD)/o

all :lib

lib : $(LIBNAME)

clean :
	rm -rf $(BUILD)

$(BUILD) : $(BUILD_O)

$(BUILD_O) :
	mkdir -p $@

LIB_O :=

define BUILD_temp
  TAR :=  $(BUILD_O)/$(notdir $(basename $(1)))
  LIB_O := $(LIB_O) $$(TAR).o
  $$(TAR).o : | $(BUILD_O)
  -include $$(TAR).d
  $$(TAR).o : lib/$(1)
	$(CC) $(CFLAGS) -c -I lib -I. -o $$@ -MMD $$<
endef

$(foreach s,$(LIBSRCS),$(eval $(call BUILD_temp,$(s))))

$(LIBNAME) :  $(LIB_O)
	cd $(BUILD) && $(AR) $(LIBNAME) $(addprefix ../,$^)

TEST :=

define TEST_temp
  TAR :=  $(BUILD)/$(notdir $(basename $(1)))
  TEST := $(TEST) $$(TAR)
  $$(TAR) : | $(BUILD)
  $$(TAR) : $(LIBNAME)
  $$(TAR) : ch01/$(1) 
	cd $(BUILD) && $(CC) $(CFLAGS) -I.. -L. -o $$(notdir $$@) ../$$< -lutil
endef

$(foreach s,$(CH01SRCS),$(eval $(call TEST_temp,$(s))))

test: $(TEST)

TEST2 :=

define TEST2_temp
  TAR :=  $(BUILD)/$(notdir $(basename $(1)))
  TEST2 := $(TEST2) $$(TAR)
  $$(TAR) : | $(BUILD)
  $$(TAR) : $(LIBNAME)
  $$(TAR) : ch02/$(1) 
	cd $(BUILD) && $(CC) $(CFLAGS) -I.. -L. -o $$(notdir $$@) ../$$< -lutil
endef

$(foreach s,$(CH02SRCS),$(eval $(call TEST2_temp,$(s))))

test2: $(TEST2)
