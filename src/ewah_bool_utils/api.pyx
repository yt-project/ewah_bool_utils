from libc.stdint cimport uint32_t

from ewah_bool_utils.ewah_bool_wrap cimport (
    BoolArrayCollection,
)
from cython.operator cimport dereference, preincrement
from libc.stdint cimport uint64_t

from ewah_bool_utils.ewah_bool_array cimport ewah_bool_array, ewah_bool_iterator


cdef object bool_array_collection_new():
    return BoolArrayCollection()

cdef bint bool_array_collection_loads(object coll, bytes s) except -1:
    return (<BoolArrayCollection>coll)._loads(s)

cdef bytes bool_array_collection_dumps(object coll):
    return (<BoolArrayCollection>coll)._dumps()

cdef bytes bool_array_collection_check(object coll):
    return (<BoolArrayCollection>coll)._check()

cdef void bool_array_collection_get_ghost_zones(object coll, int ngz, int order1, int order2,
                               bint periodicity[3], object out_ewah,
                               bint coarse_ghosts=0) noexcept:
    (<BoolArrayCollection>coll)._get_ghost_zones(ngz, order1, order2, periodicity, <BoolArrayCollection> out_ewah, coarse_ghosts)


cdef uint64_t bool_array_collection_count_total(object coll) noexcept:
    return (<BoolArrayCollection>coll)._count_total()


cdef uint64_t bool_array_collection_coarse_indices(object coll, uint64_t[::1] out) except -1:
    """Write the set coarse indices into ``out``; returns the number written."""
    cdef ewah_bool_array *keys = <ewah_bool_array *> (<BoolArrayCollection>coll).ewah_keys
    cdef ewah_bool_iterator *it = new ewah_bool_iterator(keys[0].begin())
    cdef ewah_bool_iterator *end = new ewah_bool_iterator(keys[0].end())
    cdef uint64_t i = 0
    try:
        while it[0] != end[0]:
            if i >= <uint64_t>out.shape[0]:
                raise IndexError("output buffer too small")
            out[i] = dereference(it[0])
            preincrement(it[0])
            i += 1
    finally:
        del it
        del end
    return i