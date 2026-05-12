import unittest
from scripts.lib.classifier import classify_concept


class ClassifierTests(unittest.TestCase):
    def test_known_concepts(self):
        cases = [
            ("ToastView",            "Toast"),
            ("ToastBanner",          "Toast"),
            ("CardContainer",        "Card"),
            ("LoadingSpinner",       "Loading"),
            ("LoadingOverlay",       "Loading"),
            ("ConfirmDialog",        "Dialog"),
            ("AlertDialog",          "Dialog"),
            ("PrimaryButton",        "Button"),
            ("CTAButton",            "Button"),
            ("CustomTextField",      "TextField"),
            ("SearchField",          "TextField"),
            ("SplashScreen",         "Splash"),
            ("OnboardingPage1",      "OnboardingPage"),
            ("OnboardingWelcome",    "OnboardingPage"),
            ("PaywallView",          "Paywall"),
            ("CameraScanView",       "CameraScan"),
            ("BarcodeScanner",       "CameraScan"),
            ("SettingsRowToggle",    "SettingsRow"),
        ]
        for name, expected in cases:
            self.assertEqual(classify_concept(name), expected, msg=name)

    def test_unknown_returns_none(self):
        self.assertIsNone(classify_concept("WaterDetailViewModel"))
        self.assertIsNone(classify_concept("ChessBoard"))
