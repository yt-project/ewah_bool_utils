from ewah_bool_utils.ewah_bool_wrap cimport (
    BoolArrayCollection,
)
from cython.operator cimport dereference, preincrement
from libc.stdint cimport uint32_t, uint64_t, uint8_t

from ewah_bool_utils.ewah_bool_array cimport (
    ewah_bool_array,
    ewah_bool_iterator,
    ewah_map,
    ewah_word_type,
)

cdef uint64_t FLAG = ~(<uint64_t>0)

if sizeof(ewah_word_type) != sizeof(uint32_t):
    raise ImportError("set_refined_words assumes 32-bit ewah words")

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

# following functions are new encapsulations of procedures in yt
# that relied on accessing ewah class attributes. With ewal_bool_utils 2.0,
# we should move these implementations to new methods on the base class
# and replace the functions here with forwarding calls like above.

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


cdef void set_refined_words(object coll, uint64_t i1,
                            const uint32_t[::1] words) except *:
    cdef BoolArrayCollection bac = <BoolArrayCollection>coll
    cdef ewah_map *ewah_coll = <ewah_map *> bac.ewah_coll
    cdef ewah_bool_array *ewah_refn = <ewah_bool_array *> bac.ewah_refn
    cdef ewah_bool_array *entry = &ewah_coll[0][i1]
    cdef Py_ssize_t i
    if entry[0].sizeInBits() != 0:
        raise ValueError(f"refined entry for coarse cell {i1} is not empty")
    for i in range(words.shape[0]):
        entry[0].addWord(words[i])
    ewah_refn[0].set(i1)
