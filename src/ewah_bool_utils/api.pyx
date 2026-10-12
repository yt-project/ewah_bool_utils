from libc.stdint cimport uint32_t

from ewah_bool_utils.ewah_bool_wrap cimport (
    BoolArrayCollection,    
)

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