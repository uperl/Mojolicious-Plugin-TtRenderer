package
  Foo;
use strict;
use warnings;
1;
__DATA__ 

@@ include.inc
Hello
@@ includes/sub/include.inc
Hallo

@@ layouts/layout.html.tt
w[%- content -%]d

