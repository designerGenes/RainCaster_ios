// Copyright 2015 Google Inc.

#import <GoogleCast/GCKDeviceProvider.h>

#import <GoogleCast/GCKDefines.h>
#import <GoogleCast/GCKDevice.h>

#import <Foundation/Foundation.h>

GCK_ASSUME_NONNULL_BEGIN

/**
 * Convenience methods for constructing GCKDevice objects and sending discovery notifications to the
 * framework.
 *
 * @since 3.0
 */
@interface GCKDeviceProvider (Protected)

/**
 * Notifies the discovery manager that discovery has started.
 */
- (void)notifyDidStartDiscovery;

/**
 * Notifies the discovery manager that a new device has been published.
 */
- (void)notifyDidPublishDevice:(GCKDevice *)device;

/**
 * Notifies the discovery manager that a previously-published device has been unpublished, because
 * it is no longer available.
 */
- (void)notifyDidUnpublishDevice:(GCKDevice *)device;

/**
 * Notifies the discovery manager that one or more of a previously-published device's display
 * attributes (such as friendly name or icons) have changed.
 */
- (void)notifyDidUpdateDevice:(GCKDevice *)device;

/**
 * Factory method for constructing new GCKDevice instances. The parameters correspond to
 * immutable properties of a GCKDevice.
 *
 * @param deviceID The unique ID identifying this device. This value must be unique among all
 * GCKDevice objects that are created by this provider.
 * @param ipAddress The IP address of the device, in numeric form (for example,
 * <code>@@"10.0.0.10"</code>). May not be <code>nil</code>.
 * @param servicePort The service port on which connections should be made to this device. May be
 * 0 if a service port is not applicable.
 */
- (GCKDevice *)createDeviceWithID:(NSString *)deviceID
                        ipAddress:(NSString *)ipAddress
                      servicePort:(uint16_t)servicePort;

@end

GCK_ASSUME_NONNULL_END
