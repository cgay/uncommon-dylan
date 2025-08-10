**************
uncommon-dylan
**************

The ``uncommon-dylan`` library is two things:

1. It is a collection of utilities that may potentially be useful to any Dylan
   library. That is, they are small utilities that you might reach for on occasion but
   were not provided by the ``dylan`` or ``common-dylan`` libraries, either because they
   weren't considered at all or because they weren't considered to be important enough to
   be in the core libraries. These utilities are exported by the ``uncommon-utils``
   module.

2. It provides alternative, shorter, names for some ``dylan`` and ``common-dylan`` module
   bindings, the prime example being ``<integer> => <int>``.  These shorter names are
   exported from the ``uncommon-brevity`` module.

   If both ``common-dylan`` and ``uncommon-brevity`` are used, then both the long name
   (ex: :drm:`<integer>`) and short name (ex: ``<int>``) will be available to your
   module.  If you want **only** the short names, you may use the ``uncommon-dylan``
   module instead; it exports everything from both modules but excludes the original long
   names.

Enjoy.

.. toctree::

   brevity
   uncommon-utils
