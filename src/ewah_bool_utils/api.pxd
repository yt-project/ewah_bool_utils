from libc.stdint cimport uint32_t

cdef object bool_array_collection_new()
cdef bint bool_array_collection_loads(object coll, bytes s) except -1
cdef bytes bool_array_collection_dumps(object coll)
cdef bytes bool_array_collection_check(object coll)
cdef void bool_array_collection_get_ghost_zones(object coll, int ngz, int order1, int order2,
                               bint periodicity[3], object out_ewah,
                               bint coarse_ghosts=*) noexcept