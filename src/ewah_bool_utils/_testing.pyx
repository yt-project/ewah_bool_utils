# Cython interface for ewah_bool_utils tests

cimport cython
cimport numpy as np
from libcpp.vector cimport vector

from .ewah_bool_array cimport ewah_bool_array
from ewah_bool_utils.capi cimport bool_array_collection as bac_api
import numpy as np


cdef np.uint64_t FLAG = ~(<np.uint64_t>0)

ctypedef fused dtype_t:
    np.float32_t
    np.float64_t

ctypedef fused int_t:
    np.int32_t
    np.int64_t


cdef class Index:
    cdef void* ewah_array

    def __cinit__(self):
        cdef ewah_bool_array *ewah_array = new ewah_bool_array()
        self.ewah_array = <void *> ewah_array

    cdef bint _get(self, np.uint64_t i1):
        cdef ewah_bool_array *ewah_array = <ewah_bool_array *> self.ewah_array
        return ewah_array[0].get(i1)

    def get(self, i1):
        return self._get(i1)

    cdef void _set(self, np.uint64_t i1):
        cdef ewah_bool_array *ewah_array = <ewah_bool_array *> self.ewah_array
        ewah_array[0].set(i1)

    def set(self, i1):
        return self._set(i1)

    @cython.boundscheck(False)
    @cython.wraparound(False)
    @cython.cdivision(True)
    @cython.initializedcheck(False)
    def select(self, dtype_t[:] np_array):
        cdef ewah_bool_array *ewah_array = <ewah_bool_array *> self.ewah_array
        cdef int i, j
        cdef np.ndarray[dtype_t, ndim=1] out

        out = np.empty(ewah_array[0].numberOfOnes())
        j = 0
        for i in range(ewah_array[0].sizeInBits()):
            if ewah_array[0].get(i):
                out[j] = np_array[i]
                j += 1

        return out

    @cython.boundscheck(False)
    @cython.wraparound(False)
    @cython.cdivision(True)
    @cython.initializedcheck(False)
    def set_from(self, int_t[:] ids):
        cdef ewah_bool_array *ewah_array = <ewah_bool_array *> self.ewah_array
        cdef np.uint64_t i
        cdef np.uint64_t last = 0

        for i in range(ids.shape[0]):
            if ids[i] < last:
                raise RuntimeError
            self._set(ids[i])

        print('Set from %s array and ended up with %s bytes' % (
            ids.size, ewah_array[0].sizeInBytes()))


cpdef np.uint64_t[:] ewah_set_and_unset(int_t[:] arr):
    cdef ewah_bool_array *ewah_arr
    cdef vector[size_t] vec

    ewah_arr = new ewah_bool_array()

    for i2 in range(arr.shape[0]):
        i1 = arr[i2]
        ewah_arr[0].set(i1)

    vec = ewah_arr[0].toArray()
    np_arr = np.array(vec, 'uint64')

    return np_arr

cpdef int find_ewah_collisions(int_t[:] arr1, int_t[:] arr2):
    cdef ewah_bool_array *ewah_arr1
    cdef ewah_bool_array *ewah_arr2
    cdef ewah_bool_array *ewah_arr_keys
    cdef int ncoll

    ewah_arr1 = new ewah_bool_array()
    ewah_arr2 = new ewah_bool_array()
    ewah_arr_keys = new ewah_bool_array()

    for i2 in range(arr1.shape[0]):
        i1 = arr1[i2]
        ewah_arr1[0].set(i1)

    for j2 in range(arr2.shape[0]):
        j1 = arr2[j2]
        ewah_arr2[0].set(j1)

    ewah_arr2[0].logicaland(ewah_arr1[0], ewah_arr_keys[0])
    ncoll = ewah_arr_keys[0].numberOfOnes()

    return ncoll

cpdef dtype_t[:] make_and_select_from_ewah_index(dtype_t[:] arr,
      int_t[:] np_idx):
      cdef Index idx = Index()

      idx.set_from(np_idx)
      out_arr = idx.select(arr)
      return out_arr


def bac_new() -> object:
    return bac_api.new()

def bac_count_total() -> int:
    coll = bac_api.new()
    return bac_api.count_total(coll)

def bac_check() -> bool:
    coll = bac_api.new()
    return bac_api.check(coll)

def bac_dumps() -> bytes:
    coll = bac_api.new()
    return bac_api.dumps(coll)

def bac_dumps_loads() -> bool:
    coll = bac_api.new()
    return bac_api.loads(coll, bac_api.dumps(coll))



cdef object _bac_from(indices):
    coll = bac_api.new()
    for i in indices:
        bac_api.set_coarse(coll, i)
    return coll


def bac_coarse_indices(coll) -> list:
    out = np.empty(bac_api.count_total(coll), dtype=np.uint64)
    n = bac_api.coarse_indices(coll, out)
    return out[:n].tolist()


def bac_set_get(indices) -> list:
    coll = bac_api.new()
    for i in indices:
        bac_api.set(coll, i)
    return [bac_api.get(coll, i) for i in indices]


def bac_set_coarse_count(indices) -> int:
    return bac_api.count_total(_bac_from(indices))


def bac_set_refined(i1, i2) -> dict:
    coll = bac_api.new()
    bac_api.set(coll, i1, i2)
    return {
        "get_coarse": bac_api.get_coarse(coll, i1),
        "get": bac_api.get(coll, i1, i2),
        "get_other": bac_api.get(coll, i1, i2 + 1),
        "isref": bac_api.isref(coll, i1),
    }


def bac_reset(indices) -> int:
    coll = _bac_from(indices)
    bac_api.reset(coll)
    return bac_api.count_total(coll)


def bac_dumps_loads_indices(indices) -> list:
    coll = bac_api.new()
    bac_api.loads(coll, bac_api.dumps(_bac_from(indices)))
    return bac_coarse_indices(coll)


def bac_append(a, b) -> list:
    coll = _bac_from(a)
    bac_api.append(coll, _bac_from(b))
    return bac_coarse_indices(coll)


def bac_intersects(a, b) -> bool:
    return bac_api.intersects(_bac_from(a), _bac_from(b))


def bac_logicaland(a, b) -> list:
    out = bac_api.new()
    bac_api.logicaland(_bac_from(a), _bac_from(b), out)
    return bac_coarse_indices(out)


def bac_logicalor(a, b) -> list:
    out = bac_api.new()
    bac_api.logicalor(_bac_from(a), _bac_from(b), out)
    return bac_coarse_indices(out)


def bac_select(coarse, refined, mask, n, contaminated) -> list:
    """Coarse cells plus one refined cell, selected against a coarse mask."""
    coll = _bac_from(coarse)
    bac_api.set(coll, refined, 0)
    cdef np.uint8_t[:] out = np.zeros(n, dtype=np.uint8)
    if contaminated:
        bac_api.select_contaminated(coll, _bac_from(mask), out)
    else:
        bac_api.select_uncontaminated(coll, _bac_from(mask), out)
    return np.asarray(out).tolist()


def bac_ghost_zone_count(i1, ngz, order1) -> int:
    """Coarse ghost zones of a single set cell on a periodic grid."""
    cdef bint periodicity[3]
    periodicity[0] = periodicity[1] = periodicity[2] = 1
    coll = _bac_from([i1])
    out = bac_api.new()
    bac_api.get_ghost_zones(coll, ngz, order1, 1, periodicity, out, 1)
    return bac_api.count_total(out)


def bac_set_pieces(i1, i2) -> dict:
    """set_coarse + set_refn + set_map should equal a refined set()."""
    coll = bac_api.new()
    bac_api.set_coarse(coll, i1)
    bac_api.set_refn(coll, i1)
    bac_api.set_map(coll, i1, i2)
    other = bac_api.new()
    bac_api.set(other, i1, i2)
    return {
        "get": bac_api.get(coll, i1, i2),
        "isref": bac_api.isref(coll, i1),
        "eq": bac_api.richcmp(coll, other, 2),
        "ne": bac_api.richcmp(coll, other, 3),
    }


def bac_set_refined_only(i1, i2) -> dict:
    coll = bac_api.new()
    bac_api.set_refined(coll, i1, i2)
    return {
        "contains": bac_api.contains(coll, i1),
        "isref": bac_api.isref(coll, i1),
        "count_refined": bac_api.count_refined(coll),
    }


def bac_counts(coarse, refined) -> dict:
    coll = _bac_from(coarse)
    for i1, i2 in refined:
        bac_api.set(coll, i1, i2)
    bac_api.ewah_coarse(coll)
    return {
        "total": bac_api.count_total(coll),
        "refined": bac_api.count_refined(coll),
        "coarse": bac_api.count_coarse(coll),
    }


def bac_contains(indices, probe) -> bool:
    return bac_api.contains(_bac_from(indices), probe)


def bac_coarse_array_roundtrip(flags) -> list:
    coll = bac_api.new()
    cdef np.uint8_t[:] arr = np.array(flags, dtype=np.uint8)
    bac_api.set_coarse_array(coll, arr)
    cdef np.uint8_t[:] out = np.zeros(len(flags), dtype=np.uint8)
    bac_api.get_coarse_array(coll, len(flags), out)
    return np.asarray(out).tolist()


def bac_get_coarse_array(indices, imax) -> list:
    cdef np.uint8_t[:] out = np.zeros(imax, dtype=np.uint8)
    bac_api.get_coarse_array(_bac_from(indices), imax, out)
    return np.asarray(out).tolist()


def bac_set_refined_array(mi1, flags) -> dict:
    coll = _bac_from([mi1])
    cdef np.uint8_t[:] arr = np.array(flags, dtype=np.uint8)
    bac_api.set_refined_array(coll, mi1, arr)
    return {
        "isref": bac_api.isref(coll, mi1),
        "get": [bac_api.get(coll, mi1, i2) for i2 in range(len(flags))],
    }


def bac_logicalxor(a, b) -> list:
    out = bac_api.new()
    bac_api.logicalxor(_bac_from(a), _bac_from(b), out)
    return bac_coarse_indices(out)


def bac_richcmp(a, b, op) -> int:
    return bac_api.richcmp(_bac_from(a), _bac_from(b), op)
