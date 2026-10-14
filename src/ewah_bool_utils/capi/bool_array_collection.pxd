from libc.stdint cimport uint8_t, uint32_t, uint64_t

cdef object new()
cdef bint loads(object coll, bytes s) except -1
cdef bytes dumps(object coll)
cdef bint check(object coll)
cdef uint64_t count_total(object coll) noexcept
cdef void reset(object coll) noexcept

cdef void set(object coll, uint64_t i1, uint64_t i2=*) noexcept
cdef bint get(object coll, uint64_t i1, uint64_t i2=*) noexcept
cdef void set_coarse(object coll, uint64_t i1) noexcept
cdef bint get_coarse(object coll, uint64_t i1) noexcept
cdef bint isref(object coll, uint64_t i1) noexcept
cdef void select_contaminated(object coll, object mask, uint8_t[:] out,
                              object mask2=*) except *
cdef void select_uncontaminated(object coll, object mask, uint8_t[:] out,
                                object mask2=*) except *
cdef void get_ghost_zones(object coll, int ngz, int order1, int order2,
                          bint periodicity[3], object out_ewah,
                          bint coarse_ghosts=*) noexcept

cdef void append(object coll, object other) noexcept
cdef bint intersects(object coll, object other) noexcept
cdef void logicaland(object coll, object other, object out) noexcept
cdef void logicalor(object coll, object other, object out) noexcept

# following are new encapsulations of procedures in yt that relied on
# accessing ewah class attributes.
cdef uint64_t coarse_indices(object coll, uint64_t[::1] out) except -1
# Append raw bitmap words to the refined entry for coarse cell i1. Words are
# ewah_word_type (uint32_t), consumed in order from bit 0, and the refined
# entry for i1 must be empty. Marks i1 as refined but does not set its coarse
# key; call set_coarse for that.
cdef void set_refined_words(object coll, uint64_t i1,
                            const uint32_t[::1] words) except *
