import unittest
from unittest.mock import Mock

from default_handlers import HANDLERS, ensure_handlers


ZEN = "app.zen-browser.zen"


class DefaultHandlerTests(unittest.TestCase):
    def test_already_selected_handlers_never_call_the_rejected_setter(self):
        setter = Mock(side_effect=AssertionError("redundant setter returns error -54"))

        self.assertEqual(ensure_handlers(ZEN, lambda *_: ZEN, setter), [])
        setter.assert_not_called()

    def test_repairs_and_verifies_only_the_mismatched_handler(self):
        state = {handler: ZEN for handler in HANDLERS}
        state[("uti", "public.xhtml")] = "com.exafunction.windsurf"

        def set_handler(kind, target):
            state[(kind, target)] = ZEN
            return 0

        setter = Mock(side_effect=set_handler)
        reader = Mock(side_effect=lambda kind, target: state[(kind, target)])

        self.assertEqual(ensure_handlers(ZEN, reader, setter), [])
        setter.assert_called_once_with("uti", "public.xhtml")
        self.assertEqual(reader.call_args_list[-1].args, ("uti", "public.xhtml"))
        self.assertEqual(reader.call_count, len(HANDLERS) + 1)

    def test_rejected_mismatch_stays_an_error(self):
        reader = lambda kind, target: "com.apple.Safari" if target == "https" else ZEN

        failures = ensure_handlers(ZEN, reader, lambda *_: 2)

        self.assertEqual(len(failures), 1)
        self.assertIn("https", failures[0])
        self.assertIn("com.apple.Safari", failures[0])
        self.assertIn("duti exited 2", failures[0])

    def test_successful_exit_without_changing_the_handler_is_an_error(self):
        reader = lambda kind, target: None if target == "http" else ZEN

        failures = ensure_handlers(ZEN, reader, lambda *_: 0)

        self.assertEqual(len(failures), 1)
        self.assertIn("no handler", failures[0])

    def test_verified_state_is_success_even_if_setter_reports_an_error(self):
        reader = Mock(side_effect=[ZEN, "com.apple.Safari", ZEN, ZEN, ZEN])

        self.assertEqual(ensure_handlers(ZEN, reader, lambda *_: 2), [])

    def test_checks_other_handlers_after_one_update_is_rejected(self):
        setter = Mock(return_value=2)

        failures = ensure_handlers(ZEN, lambda *_: "com.apple.Safari", setter)

        self.assertEqual(len(failures), len(HANDLERS))
        self.assertEqual(setter.call_count, len(HANDLERS))


if __name__ == "__main__":
    unittest.main()
