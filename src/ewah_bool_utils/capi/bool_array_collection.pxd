from libc.stdint cimport uint8_t, uint64_t

cdef object new()
cdef bint loads(object coll, bytes s) except -1
cdef bytes dumps(object coll)
cdef bint check(object coll)
cdef uint64_t count_total(object coll) noexcept
cdef uint64_t coarse_indices(object coll, uint64_t[::1] out) except -1
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

# following are not used by yt api
cdef void set_refined(object coll, uint64_t i1, uint64_t i2) noexcept
cdef void set_map(object coll, uint64_t i1, uint64_t i2) noexcept
cdef void set_refn(object coll, uint64_t i1) noexcept
cdef void set_coarse_array(object coll, uint8_t[:] arr) noexcept
cdef void set_refined_array(object coll, uint64_t mi1, uint8_t[:] arr) noexcept
cdef void get_coarse_array(object coll, uint64_t imax, uint8_t[:] arr) except *

cdef bint contains(object coll, uint64_t i) noexcept
cdef void ewah_coarse(object coll) noexcept
cdef uint64_t count_refined(object coll) noexcept
cdef uint64_t count_coarse(object coll) noexcept

cdef void logicalxor(object coll, object other, object out) noexcept
cdef int richcmp(object coll, object other, int op) except -1
