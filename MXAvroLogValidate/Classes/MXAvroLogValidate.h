#if __has_include(<MXAvroLogValidate/MXAvroLog.h>)

FOUNDATION_EXPORT double MXAvroLogValidateVersionNumber;
FOUNDATION_EXPORT const unsigned char MXAvroLogValidateVersionString[];

#import <MXAvroLogValidate/MXAvroLogValidator.h>
#import <MXAvroLogValidate/NSDictionary+MXAvro.h>

#else

#import "MXAvroLogValidator.h"
#import "NSDictionary+MXAvro.h"

#endif
