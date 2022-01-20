---
title: "Flattening arrays in PHP"
date: 2022-01-20T09:42:00+01:00
summary: |
    A short & easy way to flatten two-dimensional arrays, and a slightly more
    verbose one to handle arbitrarily nested arrays.
grimoire:
    - PHP
tags:
    - PHP
---

To sum things up; if you want to flatten a **two-dimensional** array with
numeric keys:

```php
array_merge(...$twoDimensionalArray);
```

If you want to flatten a **two-dimensional** associative array:

```php
array_merge(...array_values($twoDimensionalArray));
```

If you want a **general solution** to flatten an arbitrarily nested array and
you don't care about the keys:

```php
function flatten_array(array $array): array {
    $recursiveArrayIterator = new RecursiveArrayIterator(
        $array,
        RecursiveArrayIterator::CHILD_ARRAYS_ONLY
    );
    $iterator = new RecursiveIteratorIterator($recursiveArrayIterator);

    return iterator_to_array($iterator, false);
}
```

If you want a **general solution** to flatten an arbitrarily nested array and
you *do* care about the keys:

```php
function flatten_array_preserve_keys(array $array): array {
    $recursiveArrayIterator = new RecursiveArrayIterator(
        $array,
        RecursiveArrayIterator::CHILD_ARRAYS_ONLY
    );
    $iterator = new RecursiveIteratorIterator($recursiveArrayIterator);

    return iterator_to_array($iterator);
}
```

## Flattening a two-dimensional array

```php
array_merge(...$twoDimensionalArray);
```

[`array_merge`](https://www.php.net/manual/en/function.array-merge.php) takes a
variable list of arrays as arguments and merges them all into one array. By
using the splat operator (`...`), every element of the two-dimensional array
gets passed as an argument to `array_merge`.

This works fine for merging associative arrays as well, but beware that the
outer array is only allowed to have numeric keys:

```php
$twoDimensionalArray = [
    'x' => ['first', 'array'],
    'y' => ['second', 'array']
];

$flattenedArray = array_merge(...$twoDimensionalArray);
// Fatal error: Uncaught ArgumentCountError: array_merge() does not accept unknown named parameters
```

The solution is to use `array_values` in those cases:

```php
$twoDimensionalArray = [
    'x' => ['first', 'array'],
    'y' => ['second', 'array']
];

$flattenedArray = array_merge(...array_values($twoDimensionalArray));
```

On PHP version 7.3 or lower, you will see the following if the input array is
empty:

```php
$twoDimensionalArray = [];
array_merge(...$twoDimensionalArray);
// Warning:  array_merge() expects at least 1 parameter, 0 given.
```

You can solve this by passing a single empty array as an extra argument:

```php
array_merge([], ...$twoDimensionalArray);
```

## A general solution for arbitrarily nested arrays

```php
function flatten_array(array $array): array {
    $recursiveArrayIterator = new RecursiveArrayIterator(
        $array,
        RecursiveArrayIterator::CHILD_ARRAYS_ONLY
    );
    $iterator = new RecursiveIteratorIterator($recursiveArrayIterator);

    return iterator_to_array($iterator, false);
}
```

For arbitrarily nested arrays we make use of the built-in iterators
[`RecursiveArrayIterator`](https://www.php.net/manual/en/class.recursivearrayiterator.php)
and
[`RecursiveIteratorIterator`](https://www.php.net/manual/en/class.recursiveiteratoriterator.php).
It is important to note that we have to pass the flag `CHILD_ARRAYS_ONLY` to the
`ArrayIterator`, otherwise it would iterate over public properties of objects as
well, which you probably never want:

```php
class Person
{
    public function __construct(public $name) {}
}

$array = [
    new Person('Jake'),
    new Person('Charles')
];


flatten_array($array);
// Without CHILD_ARRAYS_ONLY:
//
// [
//     0 => 'Jake',
//     1 => 'Charles'
// ]
//
// With CHILD_ARRAYS_ONLY:
//
// [
//     0 => Person Object,
//     1 => Person Object
// ]
```

Lastly, you can play around with the second argument of
[`iterator_to_array`](https://www.php.net/manual/en/function.iterator-to-array.php),
which indicates whether or not keys should be preserved. If you pass `false`,
keys will not be preserved and the result will be a simple list. If you pass
`true` (which is the default), keys will be preserved, meaning duplicate entries
will be lost. Both approaches have their uses.

```php
$employees = [
    ['name' => 'Jake Peralta'],
    ['name' => 'Charles Boyle']
];

flatten_array($employees);
// [
//     0 => 'Jake Peralta',
//     1 => 'Charles Boyle,
// ]

flatten_array_preserve_keys($employees);
// [
//     'name' => 'Charles Boyle'
// ]
```
