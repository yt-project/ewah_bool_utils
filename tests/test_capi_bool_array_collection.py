import pytest

from ewah_bool_utils._testing import (
    bac_count_total,
    bac_dumps,
    bac_dumps_loads,
    bac_dumps_loads_indices,
    bac_ghost_zone_count,
    bac_logicalor,
    bac_new,
    bac_set_coarse_count,
    bac_set_refined_words,
    bac_set_refined_words_twice,
)
from ewah_bool_utils.ewah_bool_wrap import BoolArrayCollection


# minimal tests on empty collections
class TestEmptyBoolArrayCollections:
    def test_new(self):
        assert isinstance(bac_new(), BoolArrayCollection)

    def test_empty_is_empty(self):
        assert bac_count_total() == 0

    def test_dumps(self):
        assert isinstance(bac_dumps(), bytes)

    def test_serialization_roundtrip(self):
        assert bac_dumps_loads()  # always 1 on success


# minimal tests on populated collections
class TestPopulatedBoolArrayCollections:
    def test_set_coarse_count(self):
        assert bac_set_coarse_count([3, 17, 1000]) == 3

    def test_serialization_roundtrip(self):
        assert bac_dumps_loads_indices([3, 17, 1000]) == [3, 17, 1000]

    def test_logicalor(self):
        assert bac_logicalor([1, 2], [3]) == [1, 2, 3]

    def test_ghost_zones(self):
        # one cell, one layer of periodic ghosts: 3**3 - 1 neighbours
        assert bac_ghost_zone_count(0, 1, 2) == 26

    def test_set_refined_words(self):
        # two 32-bit words with bit 1 set: refined indices 1 and 33
        assert bac_set_refined_words(5, [0b10, 0b10], [0, 1, 32, 33]) == {
            "isref": True,
            "get": [False, True, False, True],
        }
        with pytest.raises(ValueError):
            bac_set_refined_words_twice(5, [0b10])
