# this type is a mostly Stdlib::Host however we add support for wildcard domains
type Cfssl::Common_name = Variant[Cfssl::Wildcard, Stdlib::Host]
