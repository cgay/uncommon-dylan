================
uncommon-brevity
================

.. current-library:: uncommon-dylan
.. current-module:: uncommon-brevity


.. constant:: $max-int

   Equivalent to :drm:`$maximum-integer`.

.. constant:: $min-int

   Equivalent to :drm:`$minimum-integer`.

.. constant:: <bool>

   Equivalent to :drm:`<boolean>`.

.. function:: bool?

   :signature: bool? (x) => (b)

   :parameter x: An instance of :drm:`<object>`.
   :value b: An instance of :const:`<bool>`.

.. constant:: <char>

   Equivalent to :drm:`<character>`.

.. constant:: <char?>

   Equivalent to ``false-or(<char>)``.

.. function:: char?

   :signature: char? (object) => (bool)

   :parameter object: An instance of :drm:`<object>`.
   :value bool: An instance of :const:`<bool>`.

.. constant:: <func>

   Equivalent to :drm:`<function>`.

.. constant:: <func?>

   Equivalent to ``false-or(<function>)``.

.. function:: func?

   :signature: func? (x) => (b)

   :parameter x: An instance of :drm:`<object>`.
   :value b: An instance of :const:`<bool>`.

.. constant:: <int>

   Equivalent to :drm:`<integer>`.

.. constant:: <int?>

   Equivalent to ``false-or(<int>)``.

.. function:: int?

   :signature: int? (x) => (b)

   :parameter x: An instance of :drm:`<object>`.
   :value b: An instance of :const:`<bool>`.

.. constant:: <seq>

   Equivalent to :drm:`<sequence>`.

.. constant:: <seq?>

   Equivalent to ``false-or(<seq>)``.

.. function:: seq?

   :signature: seq? (x) => (b)

   :parameter x: An instance of :drm:`<object>`.
   :value b: An instance of :const:`<bool>`.

.. constant:: <string?>

   Equivalent to ``false-or(<string>)``.

.. function:: string?

   :signature: string? (x) => (b)

   :parameter x: An instance of :drm:`<object>`.
   :value b: An instance of :const:`<bool>`.

.. constant:: <symbol?>

   Equivalent to ``false-or(<symbol>)``.

.. function:: symbol?

   :signature: symbol? (x) => (b)

   :parameter x: An instance of :drm:`<object>`.
   :value b: An instance of :const:`<bool>`.

.. constant:: <vector*>

   Equivalent to :drm:`<stretchy-vector>`.

.. constant:: <vector*?>

   Equivalent to ``false-or(<vector*>)``.

.. function:: vector*?

   :signature: vector*? (x) => (b)

   :parameter x: An instance of :drm:`<object>`.
   :value b: An instance of :const:`<bool>`.

.. constant:: concat

   Equivalent to :drm:`concatenate`.
