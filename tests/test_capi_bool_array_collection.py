from ewah_bool_utils._testing import (
    bac_new,
    bac_count_total,
    bac_dumps,
    bac_dumps_loads,
    bac_check,
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
        assert bac_dumps_loads() # always 1 on success

    def test_check(self):
        assert bac_check()
