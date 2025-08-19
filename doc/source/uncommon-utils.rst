==============
uncommon-utils
==============

.. current-library:: uncommon-dylan
.. current-module:: uncommon-utils


Enums
-----

Two kinds of enums are provided: traditional integer enums (see :macro:`define enum`) and
class-based enums (see :macro:`define enum-class`).

Integer-based Enums
~~~~~~~~~~~~~~~~~~~

.. macro:: define enum
   :defining:

   Defines a set of named integer constants along with a way to lookup the name from the
   value and vise versa.

   :macrocall:
     .. parsed-literal:: 
        define enum `name` ()
          [ `clauses` ]
        end [ enum ]

   Example:

   .. code:: dylan

      define enum nato-alphabet ()
        $alpha; $bravo; $charlie;
      end;

   This is the simplest form of ``define enum`` and is roughly equivalent to the
   following Dylan code:

   .. code:: dylan

      define constant $alpha :: <int> = 1;
      define constant $bravo :: <int> = 2;
      define constant $charlie :: <int> = 3;
      define constant $nato-alphabet-values = vector($alpha, $bravo, $charlie);
      define constant $nato-alphabet-names = vector("$alpha", "$bravo", "$charlie");
      define function nato-alphabet-to-name ...implementation elided... end;
      define function name-to-nato-alphabet ...implementation elided... end;

   It is also possible to assign explicit values and names to all or some of the enum
   items. The following enum shows an example of all possible enum clause forms:

   .. code::

      define enum color ()
        $red;              // defines $red   :: <int> = 1  with name "$red"
        $green = 20;       // defines $green :: <int> = 20 with name "$green"
        $blue      "Blue"; // defines $blue  :: <int> = 21 with name "Blue"
        $cyan = 30 "Cyan"; // defines $cyan  :: <int> = 30 with name "Cyan"
      end;

Class-based Enums
~~~~~~~~~~~~~~~~~

Class-based enums provide a concise way to define a class and a set of constants bound to
an instance of that class, useful for cases where there is a well-defined, small set of
values in the type. For example: the items in a menu, North South East West, or planets
in the Solar System.

.. macro:: define enum-class
   :defining:

   Defines a set of named constants along with a sequence containing all the constant
   values.

   :macrocall:
     .. parsed-literal:: 
        define enum-class `name` ()
          [ `slots` ]
          [ `clauses` ]
        end [ enum-class ]

   Example: define a ``<planet>`` class and a constant for each planet in the Solar
   System.

   .. code:: dylan

      define enum-class <planet> (<object>)
        constant slot %name :: <string>, required-init-keyword: name:;
        constant slot %mass :: <float>,  required-init-keyword: mass:;
        $mercury (name: "Mercury", mass: 1.1);
        $venus   (name: "Venus",   mass: 3.3);
        $mars    (name: "Mars",    mass: 5.5);
        ...etc...
      end;

   This defines the constants ``$mercury :: <planet>``, ``$venus :: <planet>`` etc. and
   ``$planet-instances :: <seq>`` which contains each of the constants in the order they
   occur in the source.

   .. note:: The name of the class *must* start with ``<`` and end with ``>`` or it will
             not match the macro pattern.


Trie
----

An implementation of the `Trie data structure <https://en.wikipedia.org/wiki/Trie>`_.  In
Dylan terms, a :class:`<trie>` is a stretchy mutable explicit key collection in which the
key is a :const:`<seq>` leading to the graph node that contains the associated
value. Its canonical use case is to store a dictionary of words.

API Overview
~~~~~~~~~~~~

:class:`<trie>` is the class that implements the Trie data structure and its collection
protocol methods. It is abstract; calling :drm:`make` on :class:`<trie>` returns an
instance of :class:`<object-trie>`.

.. code:: dylan

   make(<trie>) => {instance of <object-trie>}

The concrete subclasses of :class:`<trie>` are also (usually indirect) subclasses of
:class:`<trie-node>`. This means that the empty sequence (e.g., ``#()``, ``#[]``, or
``""``) are the key that matches the value stored in the root of the Trie.

.. code:: dylan

   let t = make(<trie>);
   t[""] := 100;

A :class:`<trie>` is a stretchy, mutable, explicit key collection supporting the usual
collection operations such as :drm:`element`, :drm:`element-setter`, :drm:`size`, etc.

Although :class:`<trie>` does support :drm:`forward-iteration-protocol`, the
implementation is extremely inefficient, essentially converting the trie to a
:drm:`<table>` and calling :drm:`forward-iteration-protocol` on that.  Use
:func:`traverse` instead if performance (or iteration order) matters.

Several concrete subclasses are provided to support different kinds of key lookup.  These
classes are named based on the way *individual elements of the key* are compared.

* :class:`<object-trie>` is the default implementation, comparing the elements of the key
  using :drm:`==`.  Use this for :drm:`<string>` keys if you want a case-sensitive
  comparison, or for keys that are sequences of integers, for example.

* :class:`<ichar-trie>` *assumes* the keys are strings and compares the elements of the
  key case-insensitively.

* :class:`<string-trie>` is for keys that are sequences of strings, compared
  case-sensitively.

* :class:`<istring-trie>` is for keys that are sequences of strings, compared
  case-insensitively.


Trie Reference
~~~~~~~~~~~~~~

.. class:: <trie>
   :open:
   :abstract:

   A Trie is a kind of :drm:`<collection>` with keys that are sequences. Each element of
   the key leads to the next node in the Trie and the last node in that path has a value
   associated with it.

   :superclasses: :drm:`<mutable-explicit-key-collection>`, :drm:`<stretchy-collection>`

   :keyword node-class: An instance of :drm:`<class>`. The default is
      :class:`<object-trie-node>`.  When creating a node while adding a new element to a
      Trie, this determines what kind of node to create.

   Calling ``make(<trie>, ...)`` returns a direct instance of :class:`<object-trie>`,
   which compares key elements with :drm:`==` and has nodes that are (by default) direct
   instances of :class:`<object-trie-node>`. 

.. class:: <trie-node>
   :open:
   :abstract:

   :superclasses: :drm:`<object>`

   :keyword children: An instance of :drm:`<table>`.
   :keyword value: An instance of :drm:`<object>`.

   Each node in a :class:`<trie>` must be an instance of :class:`<trie-node>`.  Nodes
   that have a ``value`` comprise the elements of a collection; nodes with no value are
   just part of an existing key's node path.

.. class:: <object-trie>

   :superclasses: :class:`<trie-node>`, :class:`<trie>`

.. class:: <object-trie-node>

   :superclasses: :class:`<trie-node>`

   The class of Trie node that compares key elements with :drm:`==`.

.. class:: <ichar-trie>

   :superclasses: :class:`<ichar-trie-node>`, :class:`<trie>`

   :keyword node-class: An instance of :drm:`<object>`. The default is
                        :class:`<ichar-trie-node>`.

   The class of Trie that compares key elements as case-insensitive characters.  In other
   words, keys for this collection are instances of :drm:`<string>`.

.. class:: <ichar-trie-node>

   :superclasses: :class:`<trie-node>`

   The class of Trie node that compares key elements as case-insensitive characters. This
   is the default node class for :class:`<ichar-trie>`.

.. class:: <string-trie>

   :superclasses: :class:`<string-trie-node>`, :class:`<trie>`

   :keyword node-class: The :class:`<string-trie-node>` class.

.. class:: <string-trie-node>

   :superclasses: :class:`<trie-node>`

   :keyword children: An instance of :class:`<string-table>`.

.. class:: <istring-trie>

   :superclasses: :class:`<istring-trie-node>`, :class:`<trie>`

   :keyword node-class: The :class:`<istring-trie-node>` class.

.. class:: <istring-trie-node>

   :superclasses: :class:`<trie-node>`

   :keyword children: An instance of :const:`<istring-table>`.

.. class:: <trie-element-error>

   :superclasses: :drm:`<simple-error>`

   The class of error signaled by :meth:`element(<trie>, <object>)` and
   :meth:`element-setter(<object>, <trie>, <object>)`.

.. generic-function:: traverse
   :sealed:

   :signature: traverse (fn node #key keys?) => ()

   Applies the function *fn* to each node under (and including) *node* that has an
   associated value.

   :parameter fn: An instance of :const:`<func>`.
   :parameter node: An instance of :class:`<trie-node>`.
   :parameter #key keys?: An instance of :const:`<bool>`.

   Traverses the entire Trie rooted at *node*, executing ``fn(node, depth)`` for each
   node with a value. If ``keys?`` is true then executes ``fn(node, deptth, key)`` for
   each node with a value. The latter can be expensive because it requires creating a
   sequence for each path to a value node.  A node is passed to *fn* rather than the
   node's value so that extra data stored in node subclasses can be accessed.


API for subclasses
~~~~~~~~~~~~~~~~~~

The following definitions are primarily exported for use by subclassers.

.. generic-function:: child-node
   :open:

   :signature: child-node (node key) => (child)

   Retrieve an immediate child of *node* matching the given *key*.

   :parameter node: An instance of :class:`<trie-node>`.
   :parameter key: An instance of :drm:`<object>`.
   :value child: An instance of :const:`<trie-node?>`.

   Note that this is a local operation on *node*, and *key* is only one element in the
   key used to access a Trie element.  For example, if the Trie key is "foo", then the
   key passed to ``child-node`` is ``'f'`` or ``'o'``.

   It is only necessary to implement this method if *key* is not sufficient for looking
   up an element in the node's ``children`` data structure (usually an instance of
   :drm:`<table>`).  For example, there is a method for ``(<ichar-trie-node>, <char>)``
   so that it can lowercase the :const:`<char>` before lookup.

.. generic-function:: child-node-setter
   :open:

   :signature: child-node-setter (new-value node key) => (new-value)

   :parameter new-value: An instance of :drm:`<object>`.
   :parameter node: An instance of :class:`<trie-node>`.
   :parameter key: An instance of :drm:`<object>`.
   :value new-value: An instance of :drm:`<object>`.

   See the notes for :gf:`child-node`, which also apply to this method.

.. generic-function:: find-node
   :sealed:

   :signature: find-node (node key) => (node)

   Finds the node under *node* with the given *key*.  This is similar to ``element(trie,
   key)`` except that instead of returning the value associated with the node it returns
   the node itself.

   :parameter node: An instance of :class:`<trie-node>`.
   :parameter key: An instance of :const:`<seq>`.
   :value node: An instance of :const:`<trie-node?>`.

.. generic-function:: node-value
   :open:

   :signature: node-value (node) => (value)

   Retrieves the value associated with *node*.  If *node* has no value,
   :const:`$unsupplied` is returned. (:drm:`#f` is a valid node value.)

   :parameter node: An instance of :class:`<trie-node>`.
   :value value: An instance of :drm:`<object>`.


Miscellaneous
-------------

.. constant:: <uint>

   Equivalent to ``limited(<int>, min: 0)``.

.. constant:: <uint?>

   Equivalent to ``false-or(<uint>)``.

   :seealso: <uint>

.. function:: uint?

   :signature: uint? (object) => (bool)

   :parameter object: An instance of :drm:`<object>`.
   :value bool: An instance of :const:`<bool>`.

.. constant:: copy-seq

   Equivalent to :drm:`copy-sequence`.  Renamed to match the :const:`<seq>` type.

.. constant:: <istring-table>

   Equivalent to :class:`<case-insensitive-string-table>`.

.. class:: <singleton-object>
   :open:
   :abstract:

   :superclasses: :drm:`<object>`

   Subclass this and calling :drm:`make` on your class will always return the same
   object *regardless of the initialization arguments*.


.. function:: ash<<

   :signature: ash<< (i count) => (_)

   :parameter i: An instance of :const:`<int>`.
   :parameter count: An instance of :const:`<uint>`.
   :value _: An instance of :const:`<int>`.

   Arithmetic shift left.  ``ash<<(i, n)`` is equivalent to ``ash(i, n)``, but makes the
   direction of the shift clearer.

.. function:: ash>>

   :signature: ash>> (i count) => (_)

   :parameter i: An instance of :const:`<int>`.
   :parameter count: An instance of :const:`<uint>`.
   :value _: An instance of :const:`<int>`.

   Arithmetic shift right.  ``ash>>(i, n)`` is equivalent to ``ash(i, -n)``, but makes the
   direction of the shift clearer.

.. macro:: begin1

   Like :drm:`begin`, but returns the value of the first body expression.  Inspired by
   Common Lisp's ``prog1`` special form.

.. function:: count

   :signature: count (collection predicate #key limit) => (count)

   :parameter collection: An instance of :drm:`<collection>`.
   :parameter predicate: An instance of :const:`<func>`.
   :parameter #key limit: An instance of :drm:`<object>`.
   :value count: An instance of :const:`<int>`.

   Count the number of elements in *collection* that match *predicate*, up to *limit*
   items.  *limit* is an efficiency hack: stop counting when limit is reached, the idea
   being that you might want to know if there's more than one.

.. macro:: iff
   :function:

   :description:

      A more concise replacement for :drm:`if` when the test/true/false expressions are
      short. Functions that contain a lot of if/else conditionals can grow in size
      quickly and this macro just provides a way to avoid the extra lines required for
      "else" and "end".

      Examples:

      .. code:: dylan

         iff(i < len, loop(i + 1))

         iff(i < len,
             loop(i + 1),
             result)

.. macro:: inc!
   :function:

   A more concise way to increment a *place*.

   :macrocall:
     .. parsed-literal:: inc!(`place`)

     .. parsed-literal:: inc!!(`place`, `by`)

   :parameter place: A Dylan variable name or, if a corresponding ``-setter`` exists, a
                     function call.
   :parameter by: An instance of :drm:`<object>`. Default value: 1.
   :value new-value: An instance of :drm:`<object>`.

   Examples:

   .. code:: dylan

      let my-dog-has-fleas = 1;
      inc!(my-dog-has-fleas, 10);  // my-dog-has-fleas is now 10

      // instead of slot-getter(object) := slot-getter(object) + 1;
      inc!(slot-getter(object));

.. macro:: dec!
   :function:

   A more concise way to decrement a *place*.

   :macrocall:
     .. parsed-literal:: dec!(`place`)

     .. parsed-literal:: dec!!(`place`, `by`)

   :parameter place: A Dylan variable name or, if a corresponding ``-setter`` exists, a
                     function call.
   :parameter by: An instance of :drm:`<object>`. Default value: 1.
   :value new-value: An instance of :drm:`<object>`.

   Examples:

   .. code:: dylan

      let my-dog-has-fleas = 0;
      dec!(my-dog-has-fleas, 10);  // my-dog-has-fleas is now -10

      // instead of slot-getter(object) := slot-getter(object) - 1;
      dec!(slot-getter(object));

.. macro:: with-restart

.. macro:: with-simple-restart
