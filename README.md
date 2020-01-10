# Swifty RA ☀️

Relational Algebra* in Swift.

This is just a pet project to see how two worlds of dynamic data representation and strong type system can be combined together using Swift. And a playground to try out different Swift tools to build embeded DSLs.
This project is not intended for any production usage, at least for now.

## TODO
- provide verbose errors & user-friendly description (especially if complex query processing fails)
- rewrite eager to lazy query processing (custom iterators?)
- tests and refactoring (value operations, functions, query processing, tuples, non-empty collections etc)
- suport more value types
- support indexing and primary keys
- think of foreign keys
- optimize query tree
- serialize/deserialize to/from Relation

*there is a notion of non-required value which means it can be NULL, whereas Relational Algebra doesn't support such.
