from ewah_bool_utils.ewah_bool_wrap cimport (
    BoolArrayCollection,
)
from cython.operator cimport dereference, preincrement
from libc.stdint cimport uint64_t, uint8_t

from ewah_bool_utils.ewah_bool_array cimport ewah_bool_array, ewah_bool_iterator

cdef uint64_t FLAG = ~(<uint64_t>0)

cdef object new():
    return BoolArrayCollection()

cdef bint loads(object coll, bytes s) except -1:
    return (<BoolArrayCollection>coll)._loads(s)

cdef bytes dumps(object coll):
    return (<BoolArrayCollection>coll)._dumps()

cdef bint check(object coll):
    return (<BoolArrayCollection>coll)._check()

cdef void get_ghost_zones(object coll, int ngz, int order1, int order2,
                               bint periodicity[3], object out_ewah,
                               bint coarse_ghosts=0) noexcept:
    (<BoolArrayCollection>coll)._get_ghost_zones(ngz, order1, order2, periodicity, <BoolArrayCollection> out_ewah, coarse_ghosts)


cdef uint64_t count_total(object coll) noexcept:
    return (<BoolArrayCollection>coll)._count_total()

cdef void reset(object coll) noexcept:
    (<BoolArrayCollection>coll)._reset()


cdef void set(object coll, uint64_t i1, uint64_t i2=FLAG) noexcept:
    (<BoolArrayCollection>coll)._set(i1, i2)


cdef bint get(object coll, uint64_t i1, uint64_t i2=FLAG) noexcept:
    return (<BoolArrayCollection>coll)._get(i1, i2)


cdef void set_coarse(object coll, uint64_t i1) noexcept:
    (<BoolArrayCollection>coll)._set_coarse(i1)


cdef bint get_coarse(object coll, uint64_t i1) noexcept:
    return (<BoolArrayCollection>coll)._get_coarse(i1)


cdef bint isref(object coll, uint64_t i1) noexcept:
    return (<BoolArrayCollection>coll)._isref(i1)


cdef void select_contaminated(object coll, object mask, uint8_t[:] out,
                              object mask2=None) except *:
    (<BoolArrayCollection>coll)._select_contaminated(
        <BoolArrayCollection>mask, out, <BoolArrayCollection>mask2
    )


cdef void select_uncontaminated(object coll, object mask, uint8_t[:] out,
                                object mask2=None) except *:
    (<BoolArrayCollection>coll)._select_uncontaminated(
        <BoolArrayCollection>mask, out, <BoolArrayCollection>mask2
    )


cdef void append(object coll, object other) noexcept:
    (<BoolArrayCollection>coll)._append(<BoolArrayCollection>other)


cdef bint intersects(object coll, object other) noexcept:
    return (<BoolArrayCollection>coll)._intersects(<BoolArrayCollection>other)


cdef void logicaland(object coll, object other, object out) noexcept:
    (<BoolArrayCollection>coll)._logicaland(
        <BoolArrayCollection>other, <BoolArrayCollection>out
    )


cdef void logicalor(object coll, object other, object out) noexcept:
    (<BoolArrayCollection>coll)._logicalor(
        <BoolArrayCollection>other, <BoolArrayCollection>out
    )

cdef void set_refined(object coll, uint64_t i1, uint64_t i2) noexcept:
    (<BoolArrayCollection>coll)._set_refined(i1, i2)


cdef void set_map(object coll, uint64_t i1, uint64_t i2) noexcept:
    (<BoolArrayCollection>coll)._set_map(i1, i2)


cdef void set_refn(object coll, uint64_t i1) noexcept:
    (<BoolArrayCollection>coll)._set_refn(i1)


cdef void set_coarse_array(object coll, uint8_t[:] arr) noexcept:
    (<BoolArrayCollection>coll)._set_coarse_array(arr)


cdef void set_refined_array(object coll, uint64_t mi1, uint8_t[:] arr) noexcept:
    (<BoolArrayCollection>coll)._set_refined_array(mi1, arr)


cdef void get_coarse_array(object coll, uint64_t imax, uint8_t[:] arr) except *:
    (<BoolArrayCollection>coll)._get_coarse_array(imax, arr)


cdef bint contains(object coll, uint64_t i) noexcept:
    return (<BoolArrayCollection>coll)._contains(i)


cdef void ewah_coarse(object coll) noexcept:
    (<BoolArrayCollection>coll)._ewah_coarse()


cdef uint64_t count_refined(object coll) noexcept:
    return (<BoolArrayCollection>coll)._count_refined()


cdef uint64_t count_coarse(object coll) noexcept:
    return (<BoolArrayCollection>coll)._count_coarse()


cdef void logicalxor(object coll, object other, object out) noexcept:
    (<BoolArrayCollection>coll)._logicalxor(
        <BoolArrayCollection>other, <BoolArrayCollection>out
    )

cdef int richcmp(object coll, object other, int op) except -1:
    return (<BoolArrayCollection>coll)._richcmp(<BoolArrayCollection>other, op)


# following functions are new encapsulations of procedures in yt
# that relied on accessing ewah class attributes.

cdef uint64_t coarse_indices(object coll, uint64_t[::1] out) except -1:
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
