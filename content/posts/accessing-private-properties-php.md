---
title: "Accessing private properties in PHP"
date: 2018-06-09T19:41:36+02:00
tags:
    - php
description: 'Finding a way around property visibility'
---

Private properties can only be accessed by the class that defines the
property... right? Actually, PHP has a few ways to circumvent this: reflection,
closures and array casting.

## Reflection: slow, but clean
PHP provides a [reflection API][reflection-php] to retrieve metadata of classes,
methods, interfaces, and so on. Of special interest to us is the
[`ReflectionProperty`][reflection-property] class. Among other things, it has
the wonderful method `setAccesible`.

In our code samples, we're going to try to retrieve and change the property
`$property` of the following class:

```php
<?php

namespace PhpPrivateAccess;

class MyClass
{
    private $property = 'Im private!';

    public function getProperty(): string
    {
        return $this->property;
    }

    public function setProperty(string $property): void
    {
        $this->property = $property;
    }
}

```

Using reflection, we can access the property using a clean API. Both reading the
property and changing it are possible after a call to `setAccessible`.

```php
<?php

use PhpPrivateAccess\MyClass;

$class = new MyClass();
$reflectionProperty = new \ReflectionProperty(MyClass::class, 'property');
$reflectionProperty->setAccessible(true);

// Once the property is made accessible, you can read it..
var_dump($reflectionProperty->getValue($class));
// => string(11) "Im private!"

// And even change it!
$reflectionProperty->setValue($class, 'Im changed');
var_dump($class->getProperty());
// => string(10) "Im changed"
```

## Closures: an interesting alternative
PHP uses a class to represent functions: [`Closure`][closures-php]. While
originally closures were just an implementation detail, they were officially
added to the spec in PHP 5.4. As it turns out, closures can be abused to both
read and write private properties. Marco Pivetta explains this in detail in [his
blog post][ocramius-closures].

The idea is to create a getter using a closure, and then bind it to the class
you want to access.

```php
<?php

use PhpPrivateAccess\MyClass;

$class = new MyClass();

// Create a closure from a callable and bind it to MyClass.
$closure = \Closure::bind(function (MyClass $class) {
    return $class->property;
}, null, MyClass::class);

var_dump($closure($class));
// => string(11) "Im private!"
```

While this is pretty cool, it gets even better. You can retrieve the private
property *by reference*. So not only will you be able to retrieve its value,
you'll be able to change it as well. Neat!

```php
<?php

use PhpPrivateAccess\MyClass;

$class = new MyClass();

// Create the closure by reference.
$closure = \Closure::bind(function &(MyClass $class) {
    return $class->property;
}, null, MyClass::class);

$value = &$closure($class);
$value = 'Im changed';

var_dump($class->getProperty());
// => string(10) "Im changed"
```

## Casting to array
As a last option, we'll abuse PHP's implementation of casting an object to an
array. When you cast an object to an array, *all* properties get exposed. Let's
see it in action:

```php
<?php

class Visibility
{
    public $public = 'public';
    protected $protected = 'protected';
    private $private = 'private';
}

// We'll use Symfony's var dumper for this, because `var_dump` doesn't
// print null characters (\x00).
dump((array) new Visibility());
// =>
// array:3 [
//   "public" => "public"
//   "\x00*\x00protected" => "protected"
//   "\x00Visibility\x00private" => "private"
// ]
```

As you can see, PHP uses a [null character][null-character] to separate the
visibility scope from the property name.

- For **public** properties, only the property name is used as the key.
- **Protected** properties get `*` as their visibility scope.
- **Private** properties are prefixed by a fully qualified class name.

While this is technically undefined behaviour, a [test case][array-cast-test]
has been created to ensure it doesn't get changed. Knowing this, we can create
a way to access any property we want.

```php
function get_property(object $object, string $property) {
    $array = (array) $object;
    $propertyLength = strlen($property);
    foreach ($array as $key => $value) {
        if (substr($key, -$propertyLength) === $property) {
            return $value;
        }
    }
}

$class = new PhpPrivateAccess\MyClass();
var_dump(get_property($class, 'property'));
// => string(11) "Im private!"
```

So, we can read properties using this method. But what about writing? One option
is to use `unserialize`. When you `serialize` an object, the string
representation is basically that of a serialized array, prefixed with the class
name. A comparison:

```php
<?php

$class = new PhpPrivateAccess\MyClass();
var_dump(serialize((array) $class));
// => string(67) "a:1:{s:34:"PhpPrivateAccess\MyClassproperty";s:11:"Im private!";}"

var_dump(serialize($class));
// => string(97) "O:24:"PhpPrivateAccess\MyClass":1:{s:34:"PhpPrivateAccess\MyClassproperty";s:11:"Im private!";}"
```

Knowing this, we can fabricate a string to pass to `unserialize`. The result
will be an new object with our new value for its property.

```php
<?php

$class = new PhpPrivateAccess\MyClass();

$array = (array) $class;
$className = get_class($class);
$array["\0{$className}\0property"] = 'changed';

$classLength = strlen($className);
$serializedArray = serialize($array);
$serializedArray = substr($serializedArray, 1);

$serializedClass = "O:{$classLength}:\"{$className}\"{$serializedArray}";
$result = unserialize($serializedClass);
var_dump($result->getProperty());
// => string(10) "Im changed"
```

This is far from ideal however. `unserialize` is [slow](#performance), and the
resulting object is a new instance. This makes it pretty useless. On top of
that, the code needed to achieve this looks really ugly.

We can do better than this. You probably know about
[`arrray_walk`][array-walk-php]. It walks over each element of an array, and
applies a callback to it. This array is passed by reference. That's cool and
all, but how is this going to solve our problem? Well, apparently you can pass
an object to `array_walk` without PHP complaining. It will implicitly get cast
to an array, **but**, the values can be retrieved by reference. Interesting! We
now know enough to set properties as well.


```php
<?php

function set_property(object $object, string $property, $newValue): void {
    array_walk($object, function (&$value, $key) use ($newValue, $property) {
        // Analogous to `get_property`.
        if (substr($key, -strlen($property)) === $property) {
            $value = $newValue;
        }
    });
}

$class = new PhpPrivateAccess\MyClass();
set_property($class, 'property', 'Im changed!');

var_dump($class->getProperty());
// => string(11) "Im changed!"
```

One note here: we're abusing undefined behaviour. There is no guarantee this
will continue to work in future PHP versions.

## Performance

So, we've got a couple of ways to access and even mutate private properties. But
what about performance? I've put together some [benchmarking
code][benchmark-repo] to test this. While not 100% accurate, it gives us an
indication about the relative performance. The results for 1 million iterations:

```text
PHP version: PHP 7.2.4-1+b1
Host: Linux Whirlpool 4.14.0-3-amd64 #1 SMP Debian 4.14.17-1 (2018-02-14) x86_64
Iterations: 1000000

+------------|-------+
| Method     | Time  |
+------------|-------+
| Reading            |
+------------|-------+
| Getter     | 92ms  |
| Array cast | 214ms |
| Reflection | 407ms |
| Closures   | 428ms |
+------------|-------+
| Writing            |
+------------|-------+
| Setter     | 91ms  |
| Array walk | 335ms |
| Reflection | 407ms |
| Closures   | 429ms |
| Unserialze | 973ms |
+------------|-------+
```

This shows us a couple of things:

- Array casting is the fastest way to read private properties, and
  `array_walk` comes out as the fastest way to write to them.
- Reflection is ~4.5 times slower than using a simple getter or setter.
- `unserialize` is *slow*, about 10 times slower than using a setter.

## Conclusion

If you're concerned about **speed**, cast your object to an array to read it,
and use `array_walk` to write to it. It's really fast! However, if you're
writing **production code**, consider if you *really* want to do this.
Properties are private for a reason! If you have a valid use case, go for
reflection. Your code will be more readable and thus easier to maintain. Plus,
its behaviour is well-defined and documented. The performance gain isn't worth
sacrificing this for.



[reflection-php]: https://secure.php.net/manual/en/book.reflection.php
[reflection-property]: https://secure.php.net/manual/en/class.reflectionproperty.php
[closures-php]: https://secure.php.net/manual/en/class.closure.php
[ocramius-closures]: https://ocramius.github.io/blog/accessing-private-php-class-members-without-reflection/
[null-character]: https://en.wikipedia.org/wiki/Null_character
[array-cast-test]: https://github.com/php/php-src/blob/master/tests/classes/array_conversion_keys.phpt
[array-walk-php]: https://secure.php.net/manual/en/function.array-walk.php
[benchmark-repo]: https://github.com/mark-gerarts/php-private-access-bench
