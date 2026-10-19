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


def _words_from_refined_cells(refined_cell_ids: list[int], nwords_per_cell: int=2):
    """Pack refined cell ids into 32-bit words: cell i sets bit i % 32 of word i // 32.
    
    this mimics what yt does in yt/geometry/particle_oct_container.pyx: it iterates 
    over coarse cells and for each cell that requires refinement it sets the bits 
    in a word array corresponding to the refined subcells in the coarse cell.
    """
    words = [0] * nwords_per_cell
    for i in refined_cell_ids:
        word_for_this_cell = i // 32  # which word contains the bit for this cell
        bit_within_current_word = i % 32  # which bit within that word holds the cell
        word_with_bit_set = 1 << bit_within_current_word  # a word with only that bit set        
        words[word_for_this_cell] |= word_with_bit_set  # OR it in, keeping bits from earlier cells
    return words

_refined_cell_ids_cases = {
    "all in first word": [0, 1, 2],
    "all in second word": [32, 33, 34],
    "one in each word (0,32)": [0, 32],
    "one in each word (1,33)": [1, 33],
    "every bit of the first word": list(range(32)),
    "every bit of the second word": list(range(32, 64)),
    "every bit of both words": list(range(64)),
    "no bits": [],
}

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

    @pytest.mark.parametrize(
        "refined_cell_ids",
        _refined_cell_ids_cases.values(),
        ids=_refined_cell_ids_cases.keys()
    )
    def test_set_refined_words(self, refined_cell_ids):        
        nwords_per_cell = 2
        coarse_index = 5  # arbitrary coarse index for testing: does not impact the test 
        refined_words = _words_from_refined_cells(refined_cell_ids, nwords_per_cell=nwords_per_cell)        
        probe_ids = range(32 * nwords_per_cell)  # the cells to check: check every one                
        # only those that we set by refined_cell_ids should be True, find them:
        expected = [i in refined_cell_ids for i in probe_ids]
        assert bac_set_refined_words(coarse_index, refined_words, probe_ids) == {
            "isref": True,
            "get": expected,
        }
        with pytest.raises(ValueError):
            bac_set_refined_words_twice(coarse_index, refined_words)
