#include <CoreAudio/AudioServerPlugIn.h>
#include <CoreFoundation/CoreFoundation.h>
#include <dlfcn.h>
#include <stdio.h>
#include <stdlib.h>

static void check(int condition, const char *message) {
    if (!condition) {
        fprintf(stderr, "FAIL: %s\n", message);
        exit(1);
    }
    printf("PASS: %s\n", message);
}

static void read_property(AudioServerPlugInDriverRef driver, AudioObjectID object,
                          AudioObjectPropertySelector selector, UInt32 size, void *value) {
    AudioObjectPropertyAddress address = {
        selector, kAudioObjectPropertyScopeGlobal, kAudioObjectPropertyElementMain
    };
    UInt32 actual = 0;
    OSStatus status = (*driver)->GetPropertyData(
        driver, object, 0, &address, 0, NULL, size, &actual, value);
    if (status != noErr || actual != size)
        fprintf(stderr, "object=%u selector=0x%x status=%d size=%u/%u\n",
                object, selector, (int)status, actual, size);
    check(status == noErr && actual == size, "HAL property readable with expected size");
}

static void check_string(AudioServerPlugInDriverRef driver, AudioObjectID object,
                         AudioObjectPropertySelector selector, CFStringRef expected) {
    CFStringRef value = NULL;
    read_property(driver, object, selector, sizeof(value), &value);
    check(value && CFEqual(value, expected), "HAL identity matches existing vRemote device");
    CFRelease(value);
}

int main(int argc, char **argv) {
    check(argc == 2, "driver binary path provided");
    // Load only in this process; never register or install a system audio device.
    void *handle = dlopen(argv[1], RTLD_NOW | RTLD_LOCAL);
    if (!handle) fprintf(stderr, "%s\n", dlerror());
    check(handle != NULL, "driver loads without missing symbols");
    void *(*create)(CFAllocatorRef, CFUUIDRef) = dlsym(handle, "BlackHole_Create");
    check(create != NULL, "CoreAudio factory is exported");
    AudioServerPlugInDriverRef driver = create(NULL, kAudioServerPlugInTypeUUID);
    check(driver != NULL, "CoreAudio driver interface created");
    check_string(driver, 3, kAudioObjectPropertyName, CFSTR("vRemoteDr 2ch"));
    check_string(driver, 3, kAudioDevicePropertyDeviceUID, CFSTR("vRemoteDr2ch_UID"));
    check_string(driver, 3, kAudioDevicePropertyModelUID, CFSTR("vRemoteDr2ch_ModelUID"));
    UInt32 transport = 0;
    read_property(driver, 2, kAudioBoxPropertyTransportType, sizeof(transport), &transport);
    check(transport == kAudioDeviceTransportTypeVirtual, "Box remains virtual");
    read_property(driver, 3, kAudioDevicePropertyTransportType, sizeof(transport), &transport);
    check(transport == kAudioDeviceTransportTypeUSB, "Device advertises USB transport");
    AudioStreamBasicDescription format = {0};
    read_property(driver, 7, kAudioStreamPropertyVirtualFormat, sizeof(format), &format);
    check(format.mChannelsPerFrame == 2 && format.mFormatID == kAudioFormatLinearPCM
          && format.mBitsPerChannel == 32 && (format.mFormatFlags & kAudioFormatFlagIsFloat),
          "output stream is two-channel 32-bit float PCM");
    dlclose(handle);
    return 0;
}
