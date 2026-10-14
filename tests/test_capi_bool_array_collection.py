import pytest

from ewah_bool_utils._testing import (
    bac_append,
    bac_check,
    bac_coarse_array_roundtrip,
    bac_contains,
    bac_count_total,
    bac_counts,
    bac_dumps,
    bac_dumps_loads,
    bac_dumps_loads_indices,
    bac_get_coarse_array,
    bac_ghost_zone_count,
    bac_intersects,
    bac_logicaland,
    bac_logicalor,
    bac_logicalxor,
    bac_new,
    bac_reset,
    bac_richcmp,
    bac_select,
    bac_set_coarse_count,
    bac_set_get,
    bac_set_pieces,
    bac_set_refined,
    bac_set_refined_array,
    bac_set_refined_only,
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

    def test_check(self):
        assert bac_check()


# minimal tests on populated collections
class TestPopulatedBoolArrayCollections:
    def test_set_get(self):
        assert bac_set_get([3, 17, 1000]) == [True, True, True]

    def test_set_coarse_count(self):
        assert bac_set_coarse_count([3, 17, 1000]) == 3

    def test_set_refined(self):
        assert bac_set_refined(5, 2) == {
            "get_coarse": True,
            "get": True,
            "get_other": False,
            "isref": True,
        }

    def test_reset(self):
        assert bac_reset([3, 17]) == 0

    def test_serialization_roundtrip(self):
        assert bac_dumps_loads_indices([3, 17, 1000]) == [3, 17, 1000]

    def test_append(self):
        assert bac_append([1, 2], [2, 3]) == [1, 2, 3]

    def test_intersects(self):
        assert bac_intersects([1, 2], [2, 3])
        assert not bac_intersects([1], [2])

    def test_logicaland(self):
        assert bac_logicaland([1, 2, 3], [2, 3, 4]) == [2, 3]

    def test_logicalor(self):
        assert bac_logicalor([1, 2], [3]) == [1, 2, 3]

    def test_select_contaminated(self):
        # only the refined cell (5) is selected, and only if the mask hits it
        assert bac_select([2], 5, [2, 5], 8, True) == [0, 0, 0, 0, 0, 1, 0, 0]
        assert bac_select([2], 5, [2], 8, True) == [0] * 8

    def test_select_uncontaminated(self):
        # only the coarse-only cell (2) is selected
        assert bac_select([2], 5, [2, 5], 8, False) == [0, 0, 1, 0, 0, 0, 0, 0]
        assert bac_select([2], 5, [5], 8, False) == [0] * 8

    def test_ghost_zones(self):
        # one cell, one layer of periodic ghosts: 3**3 - 1 neighbours
        assert bac_ghost_zone_count(0, 1, 2) == 26

    def test_logicalxor(self):
        assert bac_logicalxor([1, 2, 3], [2, 3, 4]) == [1, 4]

    def test_contains(self):
        assert bac_contains([1, 2], 2)
        assert not bac_contains([1, 2], 3)

    def test_counts(self):
        # three keys, two of them refined, one coarse-only
        assert bac_counts([1, 2, 3], [(2, 0), (3, 1)]) == {
            "total": 3,
            "refined": 2,
            "coarse": 1,
        }

    def test_set_pieces_match_set(self):
        # set_coarse + set_refn + set_map is the same as a refined set()
        assert bac_set_pieces(5, 2) == {
            "get": True,
            "isref": True,
            "eq": 1,
            "ne": 0,
        }

    def test_set_refined_only(self):
        # set_refined marks the refinement but not the coarse key
        assert bac_set_refined_only(5, 2) == {
            "contains": False,
            "isref": True,
            "count_refined": 1,
        }

    def test_coarse_array_roundtrip(self):
        flags = [0, 1, 1, 0, 1]
        assert bac_coarse_array_roundtrip(flags) == flags

    def test_get_coarse_array(self):
        assert bac_get_coarse_array([1, 3], 5) == [0, 1, 0, 1, 0]
        with pytest.raises(IndexError):
            bac_get_coarse_array([1, 7], 5)

    def test_set_refined_array(self):
        assert bac_set_refined_array(5, [0, 1, 1, 0]) == {
            "isref": True,
            "get": [False, True, True, False],
        }

    def test_richcmp(self):
        # opcodes follow Python's rich comparison: 2 is ==, 3 is !=
        assert bac_richcmp([1, 2], [1, 2], 2) == 1
        assert bac_richcmp([1, 2], [1, 3], 2) == 0
        assert bac_richcmp([1, 2], [1, 3], 3) == 1
