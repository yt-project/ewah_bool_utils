from ewah_bool_utils._testing import (
    bac_new,
    bac_empty,
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
        assert bac_empty() == 0

    def test_dumps(self):
        assert isinstance(bac_dumps(), bytes)

    def test_serialization_roundtrip(self):
        assert bac_dumps_loads() == 1 # always 1 on success

    def test_check(self):
        assert bac_check() == 1
