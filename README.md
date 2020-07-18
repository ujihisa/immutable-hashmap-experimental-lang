## How to run

```
$ make
cc -Wall -g    ihel.c   -o ihel
$ ./ihel
```

## Author

Tatsuhiro Ujihisa <ujihisa@gmail.com>

## Licence

GPLv3 or any later versions

## Ihel

Literals
* `''` for String
* `{key: expr}` for Hashmap
* `x` for local variable lookup
* `(f expr)`, `(f expr expr)`, ... for function call

Statements
* `p` prefix
* `=` infix

Functions
* `set`

Basic features

```
p 'hello world'
# hello world
```

```
p {a: 'hello', b: 'world'}
# {a: 'hello', b: 'world'}

p {b: 'hello', a: 'world'}
# {a: 'world', b: 'hello'}

x = {c: 'hello', d: 'world'}
p x
# {c: 'hello', d: 'world'}
```

```
p {a: 'hello', b: 'world'}['a']
# hello

x = {a: 'b', b: 'world'}
p x['a']
# 'b'

p x[x['a']]
# 'world'
```

```
p (set {} 'a' 'A')
# {a: 'A'}

p (set (set {} 'a' 'A') 'b' 'B')
# {a: 'A', b: 'B'}
```

Characteristic features

```
x = {a: 'a', b: 'b', c: 'c'}
y = {d: x} # This does not copy the content of x, so it's memory efficient
p y
# {d: {a: 'a', b: 'b', c: 'c'}}

x = (set x 'a' 'A')
p x
# {a: 'A', b: 'b', c: 'c'}

p y # See, the x part is unchanged. It still refers original x value
# {d: {a: 'a', b: 'b', c: 'c'}}
```
