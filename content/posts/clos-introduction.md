---
title: "Classes in Lisp: an introduction to CLOS"
date: 2018-06-06T18:58:01+02:00
categories:
    - tutorials
tags:
    - Lisp
    - CLOS
description: 'An introduction to the Common Lisp Object System'
summary: >
  If you're coming from the more mainstream OO languages, the Common Lisp Object
  System (*CLOS*) might seem a bit alien. This introduction is intended to get
  you up to speed with the basic principles of object orientation in Lisp.
---

If you're coming from the more mainstream OO languages, the Common Lisp Object
System (*CLOS*) might seem a bit alien. This introduction is intended to get
you up to speed with the basic principles of object orientation in Lisp.

## Object structure

To see how CLOS differs from your regular OO language, we'll start with a
familiar example and work our way towards the Lisp equivalent. Let's take a
look at this highly sophisticated `Player` class:

```java
public class Player {

  private String name;
  private Integer hitpoints = 100;

  public Player(String name) {
    this.name = name;
  }

  public String getName() {
    return name;
  }

  public String getHitpoints() {
    return hitpoints;
  }

  public void receiveDamage(Integer damage) {
    hitpoints -= damage;
  }
}
```

In Java, and many other languages, methods and properties are put together in
the class definition. Lisp takes a different approach, separating the structure
(properties) from the functionality (methods) of a class.

### Defining a class
We'll define a class using the [`defclass`][defclass-hs] macro. This describes
the structure of the class. In essence, it is just a list of properties with
some info about how these properties are accessed and initialized. In Lisp,
properties are called *slots*.

```
(defclass class-name ({superclass-name}*)
  ({slot-specifier}*)
  [[class-option]])
```

- `{superclass-name}*` contains the parents of this class. Multiple parents are
allowed, we'll get to that later!
- `{slot-specifier}*` contains the list of slots (properties) the class has.
- `[[class option]]` is used for some additional info and behaviour. For
example, you can add a docstring using `:documentation`.

Taking our `Player` example, this is how it would look like in Lisp:

```lisp
(defclass player ()
  ((name
    :initarg :name
    :accessor name)
   (hitpoints
    :initform 100
    :accessor hitpoints))
  (:documentation "A docstring just to show how a class-option looks like"))
```

### Slots
The slot specifiers describe the slots: how they're accessed, their initial
value, and so on. This is done using slot options. These are the ones most
often used:

- `:initarg` allows the slot to be set when constructing a new instance, using
the key provided.
- `:initform` provides a default value for the slot when no `:initarg` is used.
- `:accessor` combines `:reader` and `:writer`. In essence, it is both a getter
and a setter. Multiple accessors can be defined for the same slot.

Other slot options exist (`:type`, `:documentation`, ...). Take a look at the
[HyperSpec][defclass-hs] for some more information.

### Object instantiation
You can make an instance of a class using [`make-instance`][make-instance-hs].
This is where the `:initarg`s come into play.

```lisp
(defvar *p* (make-instance 'player :name "AzureDiamond"))
```

This will create a player named *"AzureDiamond"*, with 100 hitpoints. Both slots
of the class are defined with an `:accessor`. This accessor allows the value
of the slot to be retrieved. It is also *setf*able, and thus acts as a setter
as well.

```
CL-USER> (name *p*)
"AzureDiamond"

CL-USER> (hitpoints *p*)
100

CL-USER> (setf (hitpoints *p*) 90)
90

CL-USER> (hitpoints *p*)
90
```


Slot values can be retrieved using `slot-value` as well. It is, however,
considered best practice to define an accessor instead.

CLOS doesn't provide encapsulation; slots cannot be defined as protected or
private. Instead, the programmer decides which accessors are exported in the
package definition. Keep in mind that `slot-value` could still be used.

Some people like to wrap `make-instance` to define a constructor of some sorts.
This allows you to define required parameters. This is just a side note however,
and not mandatory at all.

```lisp
(defun make-player (name)
  (make-instance 'player :name name))
```

A useful macro worth mentioning is [`with-accessors`][with-accessors-hs]. You'll
often find yourself writing code like this:

```lisp
;; Don't allow negative hitpoints.
(when (minusp (hitpoints player))
  (setf (hitpoints player) 0))
```

`with-accessors` prevents the duplication of the accessor calls. The gain isn't
that apparent in such a small example, but it is nice knowing this macro exists
for when your're writing more complex code.

```lisp
;; Don't allow negative hitpoints.
(with-accessors ((hitpoints hitpoints)) player
  (when (minusp hitpoints)
    (setf hitpoints 0)))
```

## Object behaviour

Object behaviour is implemented using methods. Methods are concrete
implementations of generic functions. Think of a generic function like a
blueprint or an interface.

The Lisp version of `receiveDamage` could look like this:

```lisp
(defgeneric receive-damage (player damage)
  (:documentation "Applies damage to the player."))

(defmethod receive-damage ((player player) damage)
  (decf (hitpoints player) damage))

;; Usage
CL-USER> (receive-damage *p* 10)
80
```

`defgeneric` is optional. When a `defmethod` is encountered for which a
generic doesn't exist yet, it will be created implicitly.

Methods look a lot like regular functions. The big difference between the two is
that methods specialize their behaviour based on their arguments. This means
that when multiple methods are defined for a generic, the one that best matches
the given argument will be called.


```lisp
(defgeneric echo (x))

(defmethod echo ((x))
  (format t "Argument: ~A" x))

CL-USER> (echo 5)
Argument: 5

(defmethod echo ((x integer))
  (format t "Argument is an integer: ~A" x))

;; Because an integer is passed, the more specific method
;; will be called.
CL-USER> (echo 5)
Argument is an integer: 5

```

Lots of interesting things can be done with methods, such as
[method combination][method-combination], but this goes beyond the scope of a
simple introduction.

## Inheritance

When defining a class using `defclass`, you can specify a list of parent classes
as well. Let's say we will allow our players to be a mighty `Wizard`:

```lisp
(defclass wizard (player)
  ((mana
    :initform 100
    :accessor mana)))
```

This wizard class now inherits all slots of the parent class. Methods applying
to player objects will work for wizards as well. Let's see it in action:

```txt
CL-USER> (defvar *w* (make-instance 'wizard :name "Gandalf"))
#<WIZARD {100297CD03}>

;; Slots are inherited from the parent.
CL-USER> (describe *w*)
#<WIZARD {100297CD03}>
  [standard-object]

Slots with :INSTANCE allocation:
  NAME                           = "Gandalf"
  HITPOINTS                      = 100
  MANA                           = 100

;; So are the methods.
CL-USER> (hitpoints *w*)
100
```

This works as expected; slots and methods that apply to the parent class are
inherited by the child.

We can implement `receive-damage` for our wizard class as well. When we use
this method, the method whose arguments best match the given one will be called.

```lisp
(defmethod receive-damage ((wizard wizard) damage)
  ;; Wizards take extra damage!
  (decf (hitpoints wizard) (* 1.5 damage)))

CL-USER> (receive-damage (make-instance 'wizard) 10)
85.0

CL-USER> (receive-damage (make-instance 'player) 10)
90
```

### Multiple inheritance

Another intersting and useful feature of CLOS is that is supports multiple
inheritance. A class is allowed to have multiple parent classes.

We'll use an example to make things clear. We want players to be able to be a
*battlemage*, a crossover between a wizard and a warrior.

```lisp
(defclass warrior (player) ())

(defmethod receive-damage ((warrior warrior) damage)
  ;; Warriors receive reduced damage.
  (decf (hitpoints warrior) (* 0.5 damage)))

;; A battlemage is a hybrid between a wizard and a
;; warrior.
(defclass battlemage (wizard warrior))
```

Multiple inheritance suffers from the
*[Deadly Diamond of Death][diamond-of-death]* problem. Common Lisp provides
sensible defaults to tackle this, as well as giving the developer full control
on how conflicts should be handled.

> The "diamond problem" is an ambiguity that arises when two classes B and C
> inherit from A, and class D inherits from both B and C. If there is a method
> in A that B and C have overridden, and D does not override it, then which
> version of the method does D inherit: that of B, or that of C?

Lisp looks at the order in which the parent classes are listed to decide which
one has priority. So for our example, the wizard class takes priority.

```Lisp
;; Both warrior and wizard define a receive-damage method,
;; but because the wizard is listed first as a parent class
;; of the battlemage, this method will be called.
CL-USER> (receive-damage (make-instance 'battlemage) 10)
85.0
```

It can still occur that there is a 'tie' between which method should be called.
CLOS has well-defined rules for what should happen in these cases. However, it
is considered best practice to manually define the order if such a tie can
occur. This goes beyond this introduction though.

## Further reading

While I hope this little guide helped you get started with CLOS, you'll want to
go more in-depth eventually. I've used the following sources to write this post,
I recommend you check them out as well!

- [A brief guide to CLOS](http://www.aiai.ed.ac.uk/~jeff/clos-guide.html)
- [Object Reorientation: classes](http://www.gigamonkeys.com/book/object-reorientation-classes.html)
- [Object Reorientation: generic functions](http://www.gigamonkeys.com/book/object-reorientation-generic-functions.html)
- [Wikipedia](https://en.wikipedia.org/wiki/Common_Lisp_Object_System)

[multiple-inheritance]: https://en.wikipedia.org/wiki/Multiple_inheritance
[multiple-dispatch]: https://en.wikipedia.org/wiki/Multiple_dispatch
[diamond-of-death]: https://en.wikipedia.org/wiki/Multiple_inheritance#The_diamond_problem
[defclass-hs]: http://clhs.lisp.se/Body/m_defcla.htm
[make-instance-hs]: http://www.lispworks.com/documentation/lw60/CLHS/Body/f_mk_ins.htm
[with-accessors-hs]: http://www.lispworks.com/documentation/lw51/CLHS/Body/m_w_acce.htm
[method-combination]: http://www.gigamonkeys.com/book/object-reorientation-generic-functions.html#method-combination
