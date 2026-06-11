#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The "img" asset catalog image resource.
static NSString * const ACImageNameImg AC_SWIFT_PRIVATE = @"img";

/// The "img2" asset catalog image resource.
static NSString * const ACImageNameImg2 AC_SWIFT_PRIVATE = @"img2";

#undef AC_SWIFT_PRIVATE
