extern NSString *const MASDictionaryTransformerName;

/**
    @brief Converts shortcuts for storage in user defaults.

    User defaults can’t stored custom types directly, they have to
    be serialized to @p NSData or some other supported type like an
    @p NSDictionary. In Cocoa Bindings, the conversion can be done
    using value transformers like this one.

    There’s a built-in transformer (@p NSKeyedUnarchiveFromDataTransformerName)
    that converts any @p NSCoding types to @p NSData, but with shortcuts
    it makes sense to use a dictionary instead – the defaults look better
    when inspected with the @p defaults command-line utility and the
    format is compatible with an older sortcut library called Shortcut
    Recorder.
*/
@interface MASDictionaryTransformer : NSValueTransformer
@end
