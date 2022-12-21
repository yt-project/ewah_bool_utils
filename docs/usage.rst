=====
Usage
=====

Set from an integer numpy array::

    from ewah_bool_utils.ewah_bool_array cimport ewah_bool_array

    cdef ewah_bool_array *ewah_array

    ewah_array = new ewah_bool_array()

    for i2 in range(numpy_array.shape[0]):
    	i1 = numpy_array[i2]
    	ewah_array[0].set(i1)

Unset an EWAH array::

    from libcpp.vector cimport vector
    from ewah_bool_utils.ewah_bool_array cimport ewah_bool_array
    import numpy as np

    cdef vector[size_t] vec

    vec = ewah_array[0].toArray()
    numpy_array = np.array(vec, 'uint64')

Find the number of collisions between two EWAH arrays::

    from ewah_bool_utils.ewah_bool_array cimport ewah_bool_array

    cdef ewah_bool_array ewah_array_keys
    cdef int ncoll

    ewah_array2[0].logicaland(ewah_array1[0], ewah_array_keys[0])
    ncoll = ewah_array_keys[0].numberOfOnes()
