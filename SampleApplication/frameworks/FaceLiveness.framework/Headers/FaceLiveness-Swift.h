// Generated by Apple Swift version 5.1.3 (swiftlang-1100.0.282.1 clang-1100.0.33.15)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgcc-compat"

#if !defined(__has_include)
# define __has_include(x) 0
#endif
#if !defined(__has_attribute)
# define __has_attribute(x) 0
#endif
#if !defined(__has_feature)
# define __has_feature(x) 0
#endif
#if !defined(__has_warning)
# define __has_warning(x) 0
#endif

#if __has_include(<swift/objc-prologue.h>)
# include <swift/objc-prologue.h>
#endif

#pragma clang diagnostic ignored "-Wauto-import"
#include <Foundation/Foundation.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

#if !defined(SWIFT_TYPEDEFS)
# define SWIFT_TYPEDEFS 1
# if __has_include(<uchar.h>)
#  include <uchar.h>
# elif !defined(__cplusplus)
typedef uint_least16_t char16_t;
typedef uint_least32_t char32_t;
# endif
typedef float swift_float2  __attribute__((__ext_vector_type__(2)));
typedef float swift_float3  __attribute__((__ext_vector_type__(3)));
typedef float swift_float4  __attribute__((__ext_vector_type__(4)));
typedef double swift_double2  __attribute__((__ext_vector_type__(2)));
typedef double swift_double3  __attribute__((__ext_vector_type__(3)));
typedef double swift_double4  __attribute__((__ext_vector_type__(4)));
typedef int swift_int2  __attribute__((__ext_vector_type__(2)));
typedef int swift_int3  __attribute__((__ext_vector_type__(3)));
typedef int swift_int4  __attribute__((__ext_vector_type__(4)));
typedef unsigned int swift_uint2  __attribute__((__ext_vector_type__(2)));
typedef unsigned int swift_uint3  __attribute__((__ext_vector_type__(3)));
typedef unsigned int swift_uint4  __attribute__((__ext_vector_type__(4)));
#endif

#if !defined(SWIFT_PASTE)
# define SWIFT_PASTE_HELPER(x, y) x##y
# define SWIFT_PASTE(x, y) SWIFT_PASTE_HELPER(x, y)
#endif
#if !defined(SWIFT_METATYPE)
# define SWIFT_METATYPE(X) Class
#endif
#if !defined(SWIFT_CLASS_PROPERTY)
# if __has_feature(objc_class_property)
#  define SWIFT_CLASS_PROPERTY(...) __VA_ARGS__
# else
#  define SWIFT_CLASS_PROPERTY(...)
# endif
#endif

#if __has_attribute(objc_runtime_name)
# define SWIFT_RUNTIME_NAME(X) __attribute__((objc_runtime_name(X)))
#else
# define SWIFT_RUNTIME_NAME(X)
#endif
#if __has_attribute(swift_name)
# define SWIFT_COMPILE_NAME(X) __attribute__((swift_name(X)))
#else
# define SWIFT_COMPILE_NAME(X)
#endif
#if __has_attribute(objc_method_family)
# define SWIFT_METHOD_FAMILY(X) __attribute__((objc_method_family(X)))
#else
# define SWIFT_METHOD_FAMILY(X)
#endif
#if __has_attribute(noescape)
# define SWIFT_NOESCAPE __attribute__((noescape))
#else
# define SWIFT_NOESCAPE
#endif
#if __has_attribute(warn_unused_result)
# define SWIFT_WARN_UNUSED_RESULT __attribute__((warn_unused_result))
#else
# define SWIFT_WARN_UNUSED_RESULT
#endif
#if __has_attribute(noreturn)
# define SWIFT_NORETURN __attribute__((noreturn))
#else
# define SWIFT_NORETURN
#endif
#if !defined(SWIFT_CLASS_EXTRA)
# define SWIFT_CLASS_EXTRA
#endif
#if !defined(SWIFT_PROTOCOL_EXTRA)
# define SWIFT_PROTOCOL_EXTRA
#endif
#if !defined(SWIFT_ENUM_EXTRA)
# define SWIFT_ENUM_EXTRA
#endif
#if !defined(SWIFT_CLASS)
# if __has_attribute(objc_subclassing_restricted)
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_CLASS_EXTRA
#  define SWIFT_CLASS_NAMED(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# else
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
#  define SWIFT_CLASS_NAMED(SWIFT_NAME) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# endif
#endif
#if !defined(SWIFT_RESILIENT_CLASS)
# if __has_attribute(objc_class_stub)
#  define SWIFT_RESILIENT_CLASS(SWIFT_NAME) SWIFT_CLASS(SWIFT_NAME) __attribute__((objc_class_stub))
#  define SWIFT_RESILIENT_CLASS_NAMED(SWIFT_NAME) __attribute__((objc_class_stub)) SWIFT_CLASS_NAMED(SWIFT_NAME)
# else
#  define SWIFT_RESILIENT_CLASS(SWIFT_NAME) SWIFT_CLASS(SWIFT_NAME)
#  define SWIFT_RESILIENT_CLASS_NAMED(SWIFT_NAME) SWIFT_CLASS_NAMED(SWIFT_NAME)
# endif
#endif

#if !defined(SWIFT_PROTOCOL)
# define SWIFT_PROTOCOL(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
# define SWIFT_PROTOCOL_NAMED(SWIFT_NAME) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
#endif

#if !defined(SWIFT_EXTENSION)
# define SWIFT_EXTENSION(M) SWIFT_PASTE(M##_Swift_, __LINE__)
#endif

#if !defined(OBJC_DESIGNATED_INITIALIZER)
# if __has_attribute(objc_designated_initializer)
#  define OBJC_DESIGNATED_INITIALIZER __attribute__((objc_designated_initializer))
# else
#  define OBJC_DESIGNATED_INITIALIZER
# endif
#endif
#if !defined(SWIFT_ENUM_ATTR)
# if defined(__has_attribute) && __has_attribute(enum_extensibility)
#  define SWIFT_ENUM_ATTR(_extensibility) __attribute__((enum_extensibility(_extensibility)))
# else
#  define SWIFT_ENUM_ATTR(_extensibility)
# endif
#endif
#if !defined(SWIFT_ENUM)
# define SWIFT_ENUM(_type, _name, _extensibility) enum _name : _type _name; enum SWIFT_ENUM_ATTR(_extensibility) SWIFT_ENUM_EXTRA _name : _type
# if __has_feature(generalized_swift_name)
#  define SWIFT_ENUM_NAMED(_type, _name, SWIFT_NAME, _extensibility) enum _name : _type _name SWIFT_COMPILE_NAME(SWIFT_NAME); enum SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_ENUM_ATTR(_extensibility) SWIFT_ENUM_EXTRA _name : _type
# else
#  define SWIFT_ENUM_NAMED(_type, _name, SWIFT_NAME, _extensibility) SWIFT_ENUM(_type, _name, _extensibility)
# endif
#endif
#if !defined(SWIFT_UNAVAILABLE)
# define SWIFT_UNAVAILABLE __attribute__((unavailable))
#endif
#if !defined(SWIFT_UNAVAILABLE_MSG)
# define SWIFT_UNAVAILABLE_MSG(msg) __attribute__((unavailable(msg)))
#endif
#if !defined(SWIFT_AVAILABILITY)
# define SWIFT_AVAILABILITY(plat, ...) __attribute__((availability(plat, __VA_ARGS__)))
#endif
#if !defined(SWIFT_WEAK_IMPORT)
# define SWIFT_WEAK_IMPORT __attribute__((weak_import))
#endif
#if !defined(SWIFT_DEPRECATED)
# define SWIFT_DEPRECATED __attribute__((deprecated))
#endif
#if !defined(SWIFT_DEPRECATED_MSG)
# define SWIFT_DEPRECATED_MSG(...) __attribute__((deprecated(__VA_ARGS__)))
#endif
#if __has_feature(attribute_diagnose_if_objc)
# define SWIFT_DEPRECATED_OBJC(Msg) __attribute__((diagnose_if(1, Msg, "warning")))
#else
# define SWIFT_DEPRECATED_OBJC(Msg) SWIFT_DEPRECATED_MSG(Msg)
#endif
#if !defined(IBSegueAction)
# define IBSegueAction
#endif
#if __has_feature(modules)
#if __has_warning("-Watimport-in-framework-header")
#pragma clang diagnostic ignored "-Watimport-in-framework-header"
#endif
@import CoreGraphics;
@import Foundation;
@import ObjectiveC;
@import QuartzCore;
@import UIKit;
#endif

#pragma clang diagnostic ignored "-Wproperty-attribute-mismatch"
#pragma clang diagnostic ignored "-Wduplicate-method-arg"
#if __has_warning("-Wpragma-clang-attribute")
# pragma clang diagnostic ignored "-Wpragma-clang-attribute"
#endif
#pragma clang diagnostic ignored "-Wunknown-pragmas"
#pragma clang diagnostic ignored "-Wnullability"

#if __has_attribute(external_source_symbol)
# pragma push_macro("any")
# undef any
# pragma clang attribute push(__attribute__((external_source_symbol(language="Swift", defined_in="FaceLiveness",generated_declaration))), apply_to=any(function,enum,objc_interface,objc_category,objc_protocol))
# pragma pop_macro("any")
#endif

/// AutocaptureFeedback - Feedback from the autocapture algorithm. Part of FeedbackResult
typedef SWIFT_ENUM(NSInteger, AutocaptureFeedback, open) {
/// <summary>
/// AutoCapture is off and unconfigured.
/// </summary>
  AutocaptureFeedbackOFF = 0,
/// <summary>
/// AutoCapture is off and unconfigured.
/// </summary>
  AutocaptureFeedbackCOMPLIANT_IMAGE = 1,
/// <summary>
/// AutoCapture is off and unconfigured.
/// </summary>
  AutocaptureFeedbackNO_FACE_DETECTED = 2,
/// <summary>
/// AutoCapture is off and unconfigured.
/// </summary>
  AutocaptureFeedbackMULTIPLE_FACES_DETECTED = 3,
/// <summary>
/// AutoCapture is off and unconfigured.
/// </summary>
  AutocaptureFeedbackINVALID_POSE = 4,
/// <summary>
/// AutoCapture is off and unconfigured.
/// </summary>
  AutocaptureFeedbackFACE_TOO_FAR = 5,
/// <summary>
/// AutoCapture is off and unconfigured.
/// </summary>
  AutocaptureFeedbackFACE_TOO_CLOSE = 6,
/// <summary>
/// AutoCapture is off and unconfigured.
/// </summary>
  AutocaptureFeedbackFACE_ON_LEFT = 7,
/// <summary>
/// AutoCapture is off and unconfigured.
/// </summary>
  AutocaptureFeedbackFACE_ON_RIGHT = 8,
/// <summary>
/// AutoCapture is off and unconfigured.
/// </summary>
  AutocaptureFeedbackFACE_TOO_HIGH = 9,
/// <summary>
/// AutoCapture is off and unconfigured.
/// </summary>
  AutocaptureFeedbackFACE_TOO_LOW = 10,
/// <summary>
/// AutoCapture is off and unconfigured.
/// </summary>
  AutocaptureFeedbackINSUFFICIENT_LIGHTING = 11,
/// <summary>
/// AutoCapture is off and unconfigured.
/// </summary>
  AutocaptureFeedbackLIGHT_TOO_BRIGHT = 12,
/// <summary>
/// AutoCapture is off and unconfigured.
/// </summary>
  AutocaptureFeedbackTOO_MUCH_BLUR = 13,
/// <summary>
/// AutoCapture is off and unconfigured.
/// </summary>
  AutocaptureFeedbackSMILE_PRESENT = 14,
/// <summary>
/// AutoCapture is off and unconfigured.
/// </summary>
  AutocaptureFeedbackFOREHEAD_COVERING = 15,
/// <summary>
/// AutoCapture is off and unconfigured.
/// </summary>
  AutocaptureFeedbackBACKGROUND_TOO_BRIGHT = 16,
/// <summary>
/// AutoCapture is off and unconfigured.
/// </summary>
  AutocaptureFeedbackBACKGROUND_TOO_DARK = 17,
/// <summary>
/// AutoCapture is off and unconfigured.
/// </summary>
  AutocaptureFeedbackLEFT_EYE_CLOSED = 18,
/// <summary>
/// AutoCapture is off and unconfigured.
/// </summary>
  AutocaptureFeedbackRIGHT_EYE_CLOSED = 19,
/// <summary>
/// AutoCapture is off and unconfigured.
/// </summary>
  AutocaptureFeedbackLEFT_EYE_OBSTRUCTED = 20,
/// <summary>
/// AutoCapture is off and unconfigured.
/// </summary>
  AutocaptureFeedbackRIGHT_EYE_OBSTRUCTED = 21,
/// <summary>
/// AutoCapture is off and unconfigured.
/// </summary>
  AutocaptureFeedbackHEAVY_FRAMES = 22,
/// <summary>
/// AutoCapture is off and unconfigured.
/// </summary>
  AutocaptureFeedbackGLARE = 23,
/// <summary>
/// AutoCapture is off and unconfigured.
/// </summary>
  AutocaptureFeedbackDARK_GLASSES = 24,
/// <summary>
/// AutoCapture is off and unconfigured.
/// </summary>
  AutocaptureFeedbackFACIAL_SHADOWING = 25,
/// <summary>
/// AutoCapture is off and unconfigured.
/// </summary>
  AutocaptureFeedbackUNNATURAL_LIGHTING_COLOR = 26,
/// <summary>
/// AutoCapture is off and unconfigured.
/// </summary>
  AutocaptureFeedbackUNKNOWN = 27,
};



@class NSCoder;
enum StaticPropertyTag : NSInteger;
enum PropertyTag : NSInteger;
@class FeedbackResult;
enum WorkflowState : NSInteger;
@class UIImage;
@class NSError;
enum LivenessDecision : NSInteger;

/// FaceLiveness - A custom view for facial analysis. The component performs and manages
/// all necessary funcitons including camera operations, previewing, and
/// workflow operations.
SWIFT_CLASS("_TtC12FaceLiveness12FaceLiveness")
@interface FaceLiveness : UIView
- (nullable instancetype)initWithCoder:(NSCoder * _Nonnull)aDecoder OBJC_DESIGNATED_INITIALIZER;
- (nonnull instancetype)initWithFrame:(CGRect)frame OBJC_DESIGNATED_INITIALIZER;
- (void)layoutSubviews;
- (NSString * _Nonnull)getVersion SWIFT_WARN_UNUSED_RESULT;
+ (BOOL)setStaticPropertyStringWithName:(enum StaticPropertyTag)name value:(NSString * _Nonnull)value error:(NSError * _Nullable * _Nullable)error;
- (BOOL)setStringPropertyWithName:(enum PropertyTag)name name:(NSString * _Nonnull)value value:(NSError * _Nullable * _Nullable)error;
- (BOOL)setBoolPropertyWithName:(enum PropertyTag)name name:(BOOL)value value:(NSError * _Nullable * _Nullable)error;
- (BOOL)setDoublePropertyWithName:(enum PropertyTag)name name:(double)value value:(NSError * _Nullable * _Nullable)error;
- (BOOL)selectWorkflowWithWorkflow:(NSString * _Nonnull)workflow error:(NSError * _Nullable * _Nullable)error;
- (BOOL)selectWorkflowWithWorkflow:(NSString * _Nonnull)workflow overrideParametersJson:(NSString * _Nullable)overrideJson error:(NSError * _Nullable * _Nullable)error;
- (void)setDevicePositionCallbackWithCallback:(void (^ _Nonnull)(CGFloat, BOOL))callback;
- (void)setFeedbackCallbackWithCallback:(void (^ _Nonnull)(FeedbackResult * _Nonnull))callback;
- (void)setWorkflowStateCallbackWithCallback:(void (^ _Nonnull)(enum WorkflowState, NSString * _Nonnull))callback;
- (NSArray<NSNumber *> * _Nullable)getRegionOfInterestAndReturnError:(NSError * _Nullable * _Nullable)error SWIFT_WARN_UNUSED_RESULT;
- (BOOL)startAndReturnError:(NSError * _Nullable * _Nullable)error;
- (BOOL)stopAndReturnError:(NSError * _Nullable * _Nullable)error;
- (NSDictionary<NSString *, id> * _Nullable)getServerPackageAndReturnError:(NSError * _Nullable * _Nullable)error SWIFT_WARN_UNUSED_RESULT;
- (UIImage * _Nullable)getCapturedImageAndReturnError:(NSError * _Nullable * _Nullable)error SWIFT_WARN_UNUSED_RESULT;
- (enum LivenessDecision)getLivenessDecision:(NSError * _Nullable * _Nullable)error SWIFT_WARN_UNUSED_RESULT;
@end

/// FaceLivenessError - Errors thrown by LivenessComponenet
typedef SWIFT_ENUM(NSInteger, FaceLivenessError, open) {
  FaceLivenessErrorNoError = 0,
  FaceLivenessErrorWorkflowInProgress = 1,
  FaceLivenessErrorWorkflowInvalid = 2,
  FaceLivenessErrorWorkflowNotSelected = 3,
  FaceLivenessErrorWorkflowNoneAvailable = 4,
  FaceLivenessErrorWorkflowInconsistent = 5,
  FaceLivenessErrorWorkflowUnableToInitialize = 6,
  FaceLivenessErrorServerPackageNotAvailable = 7,
  FaceLivenessErrorCameraInvalid = 8,
  FaceLivenessErrorAudioUnableToInitialize = 9,
  FaceLivenessErrorRegionOfInterestNotAvailable = 10,
  FaceLivenessErrorImageNotAvailable = 11,
  FaceLivenessErrorClassifierDataFileNotFound = 12,
  FaceLivenessErrorEmptyUsernameNotAllowed = 13,
  FaceLivenessErrorImageCallbackNotSet = 14,
  FaceLivenessErrorFeedbackCallbackNotSet = 15,
  FaceLivenessErrorWorkflowStateCallbackNotSet = 16,
  FaceLivenessErrorPropertyInvalid = 17,
  FaceLivenessErrorFaceModelInvalid = 18,
  FaceLivenessErrorFaceModelNotSupportWorkflow = 19,
  FaceLivenessErrorMethodNotAvailable = 20,
  FaceLivenessErrorFunctionNotAvailableInProduct = 21,
};
static NSString * _Nonnull const FaceLivenessErrorDomain = @"FaceLiveness.FaceLivenessError";


/// Provides information such as facial positioning.
SWIFT_CLASS("_TtC12FaceLiveness14FeedbackResult")
@interface FeedbackResult : NSObject
@property (nonatomic) enum AutocaptureFeedback autocaptureFeedback;
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_UNAVAILABLE_MSG("-init is unavailable");
@end



typedef SWIFT_ENUM(NSInteger, LivenessDecision, open) {
  LivenessDecisionERROR = 0,
  LivenessDecisionLIVE = 1,
  LivenessDecisionSPOOF = 2,
};

/// PropertyTag - Property settings
typedef SWIFT_ENUM(NSInteger, PropertyTag, open) {
  PropertyTagUsername = 0,
  PropertyTagConstructImage = 1,
  PropertyTagCaptureTimeout = 2,
  PropertyTagCaptureOnDevice = 3,
};

typedef SWIFT_ENUM(NSInteger, StaticPropertyTag, open) {
  StaticPropertyTagFaceModel = 0,
};





/// WorkflowState - State information of workflow progress.
typedef SWIFT_ENUM(NSInteger, WorkflowState, open) {
  WorkflowStateWorkflowPreparing = 0,
  WorkflowStateWorkflowDeviceInPosition = 1,
  WorkflowStateWorkflowHoldSteady = 2,
  WorkflowStateWorkflowCapturing = 3,
  WorkflowStateWorkflowEvent = 4,
  WorkflowStateWorkflowShowUI = 5,
  WorkflowStateWorkflowHideUI = 6,
  WorkflowStateWorkflowPostProcessing = 7,
  WorkflowStateWorkflowComplete = 8,
  WorkflowStateWorkflowAborted = 9,
  WorkflowStateWorkflowTimedOut = 10,
};

#if __has_attribute(external_source_symbol)
# pragma clang attribute pop
#endif
#pragma clang diagnostic pop
