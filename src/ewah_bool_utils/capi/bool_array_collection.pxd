from libc.stdint cimport uint32_t
from libc.stdint cimport uint64_t

cdef object new()
cdef bint loads(object coll, bytes s) except -1
cdef bytes dumps(object coll)
cdef bytes check(object coll)
cdef void get_ghost_zones(object coll, int ngz, int order1, int order2,
                               bint periodicity[3], object out_ewah,
                               bint coarse_ghosts=*) noexcept

cdef uint64_t count_total(object coll) noexcept
cdef uint64_t coarse_indices(object coll, uint64_t[::1] out) except -1